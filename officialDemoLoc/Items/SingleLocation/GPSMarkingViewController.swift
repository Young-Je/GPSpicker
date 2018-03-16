//
//  GPSMarkingViewController.swift
//  officialDemoLoc
//
//  Created by Hutong on 13/10/2017.
//  Copyright © 2017 AutoNavi. All rights reserved.
//

import UIKit

class GPSMarkingViewController: UIViewController,MAMapViewDelegate{
    
    var mapView: MAMapView?

    override func viewDidLoad() {
        super.viewDidLoad()

        AMapServices.shared().enableHTTPS = true
        
        mapView = MAMapView(frame: self.view.bounds)
        mapView!.delegate = self
        self.view.addSubview(mapView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
