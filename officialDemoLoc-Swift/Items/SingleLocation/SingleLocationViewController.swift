//
//  SingleLocationViewController.swift
//  officialDemoLoc
//
//  Created by liubo on 10/8/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

import UIKit

//针对MAAnnotationView的扩展
extension MAAnnotationView {
    
    /// 根据heading信息旋转大头针视图
    ///
    /// - Parameter heading: 方向信息
    func rotateWithHeading(heading: CLHeading) {
        
        //将设备的方向角度换算成弧度
        let headings = M_PI * heading.magneticHeading / 180.0
        //创建不断旋转CALayer的transform属性的动画
        let rotateAnimation = CABasicAnimation(keyPath: "transform")
        //动画起始值
        let formValue = self.layer.transform
        rotateAnimation.fromValue = NSValue(caTransform3D: formValue)
        //绕Z轴旋转heading弧度的变换矩阵
        let toValue = CATransform3DMakeRotation(CGFloat(headings), 0, 0, 1)
        //设置动画结束值
        rotateAnimation.toValue = NSValue(caTransform3D: toValue)
        rotateAnimation.duration = 0.35
        rotateAnimation.isRemovedOnCompletion = true
        //设置动画结束后layer的变换矩阵
        self.layer.transform = toValue
        
        //添加动画
        self.layer.add(rotateAnimation, forKey: nil)
        
    }
}


class SingleLocationViewController: UIViewController, MAMapViewDelegate, AMapLocationManagerDelegate {
    
    //MARK: - Properties
    
    let defaultLocationTimeout = 6
    let defaultReGeocodeTimeout = 3
    
    var mapView: MAMapView!
    var completionBlock: AMapLocatingCompletionBlock!
    lazy var locationManager = AMapLocationManager()
    
    //MARK: - Action Handle
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        
        //取得用户大头针视图
        let userView = mapView.view(for: userLocation)
        
        //取方向信息
        let userHeading = userLocation.heading
        
        //根据方向旋转箭头
        userView.rotateWithHeading(heading: userHeading)
        
    }
    
    func configLocationManager() {
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.locationTimeout = defaultLocationTimeout
        
        locationManager.reGeocodeTimeout = defaultReGeocodeTimeout
    }
    
    func cleanUpAction() {
        locationManager.stopUpdatingLocation()
        
        locationManager.delegate = nil
        
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func reGeocodeAction() {
        mapView.removeAnnotations(mapView.annotations)
        
        locationManager.requestLocation(withReGeocode: true, completionBlock: completionBlock)
    }
    
    func locAction() {
        mapView.removeAnnotations(mapView.annotations)
        
        locationManager.requestLocation(withReGeocode: false, completionBlock: completionBlock)
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        initToolBar()
        
        initNavigationBar()
        
        initMapView()
        
        initCompleteBlock()
        
        configLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    //MARK: - Initialization
    
    func initCompleteBlock() {
        
        completionBlock = { [weak self] (location: CLLocation?, regeocode: AMapLocationReGeocode?, error: Error?) in
            
            if let error = error {
                let error = error as NSError
                
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                    NSLog("定位错误:{\(error.code) - \(error.localizedDescription)};")
                    return
                }
                else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    
                    //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
                    NSLog("逆地理错误:{\(error.code) - \(error.localizedDescription)};")
                }
                else {
                    //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
                }
            }
            
            //根据定位信息，添加annotation
            if let location = location {
                let annotation = MAPointAnnotation()
                annotation.coordinate = location.coordinate
                
                if let regeocode = regeocode {
                    annotation.title = regeocode.formattedAddress
                    annotation.subtitle = "\(regeocode.citycode!)-\(regeocode.adcode!)-\(location.horizontalAccuracy)m"
                }
                else {
                    annotation.title = String(format: "lat:%.6f;lon:%.6f;", arguments: [location.coordinate.latitude, location.coordinate.longitude])
                    annotation.subtitle = "accuracy:\(location.horizontalAccuracy)m"
                }
                
                self?.addAnnotationsToMapView(annotation)
            }
            
        }
    }
    
    func initMapView() {
        mapView = MAMapView(frame: view.bounds)
        mapView.delegate = self
        
        view.addSubview(mapView)
    }
    
    func addAnnotationsToMapView(_ annotation: MAAnnotation) {
        
        
        作者：just_xam
        链接：http://www.jianshu.com/p/c02948a30ace
        來源：简书
        著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
        mapView.addAnnotation(annotation)
        
        mapView.selectAnnotation(annotation, animated: true)
        mapView.setZoomLevel(15.1, animated: false)
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    
    func initToolBar() {
        let flexble = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let reGeocodeItem = UIBarButtonItem(title: "带逆地理定位", style: .plain, target: self, action: #selector(reGeocodeAction))
        let locItem = UIBarButtonItem(title: "不带逆地理定位", style: .plain, target: self, action: #selector(locAction))
        
        setToolbarItems([flexble, reGeocodeItem, flexble, locItem, flexble], animated: false)
    }
    
    func initNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clean", style: .plain, target: self, action: #selector(cleanUpAction))
    }
    
    //MARK: - MAMapVie Delegate
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAPointAnnotation {
            let pointReuseIndetifier = "pointReuseIndetifier"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView?.canShowCallout  = true
            annotationView?.animatesDrop    = true
            annotationView?.isDraggable     = false
            annotationView?.pinColor        = .purple
            annotationView?.image = UIImage(named: "arrow")
            
            return annotationView
        }
        
        return nil
    }

}
