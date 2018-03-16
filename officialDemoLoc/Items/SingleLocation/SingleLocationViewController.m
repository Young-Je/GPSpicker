//
//  SingleLocationViewController.m
//  officialDemoLoc
//
//  Created by 刘博 on 15/9/21.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import "SingleLocationViewController.h"
#import "MyDocument.h"
#import "MyPoint.h"
#import "MAAnnotationView+Extension.h"

#define DefaultLocationTimeout  6
#define DefaultReGeocodeTimeout 3
//AMapLocationManagerDelegate
@interface SingleLocationViewController () <MAMapViewDelegate, AMapLocationManagerDelegate,AMapSearchDelegate>

@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;

@end

@implementation SingleLocationViewController

//-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
//{
//    CLHeading *heading = userLocation.heading;
//    MAAnnotationView *userview = [self.mapView viewForAnnotation:userLocation];
//    [userview rotateWithHeading:heading];
//
//}

#pragma mark - Action Handle

- (void)configLocationManager
{
//    self.mapView.showsCompass= YES; // 设置成NO表示关闭指南针；YES表示显示指南针
//    
//    self.mapView.compassOrigin= CGPointMake(_mapView.compassOrigin.x, 22); //设置指南针位置
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //设置期望定位精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //设置定位超时时间
    [self.locationManager setLocationTimeout:DefaultLocationTimeout];
    
    //设置逆地理超时时间
    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
    
    //设置开启虚拟定位风险监测，可以根据需要开启
    [self.locationManager setDetectRiskOfFakeLocation:NO];
}

- (AMapSearchAPI *)search{
    if (_search == nil) {
        _search = [[AMapSearchAPI alloc] init];
    }
    return _search;
}

-(void)initSearch{
    self.search.delegate = self;
}

- (void)cleanUpAction
{
    //停止定位
    [self.locationManager stopUpdatingLocation];
    
    [self.locationManager setDelegate:nil];

    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)reGeocodeAction
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //进行单次带逆地理定位请求
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}

// 1. Any file can be uploaded to iCloud container of any size (yes you should be having that much of space in iCloud) lets take an example SampleData.zip

// 2. This method will upload or sync SampleData.zip file in iCloud container, iCloud actually checks the metadata of your file before it uploads it into your iCloud container (so for first time it will upload the file and from next time it will only upload the changes)


- (void)locAction
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //进行单次定位请求
    [self.locationManager requestLocationWithReGeocode:NO completionBlock:self.completionBlock];
}

#pragma mark - Initialization
//MAPointAnnotation *annotation
-(MAPointAnnotation*)annotation{
    if (_annotation == nil) {
      _annotation = [[MAPointAnnotation alloc] init];
    }
    return _annotation;
}

-(MAPointAnnotation*)startAnnotation{
    if (_startAnnotation == nil) {
        _startAnnotation = [[MAPointAnnotation alloc] init];
    }
    return _startAnnotation;
}

-(MAPointAnnotation*)destinationAnnotation{
    if (_destinationAnnotation == nil) {
        _destinationAnnotation = [[MAPointAnnotation alloc] init];
    }
    return _destinationAnnotation;
}


- (void)initCompleteBlock
{
    __weak SingleLocationViewController *weakSelf = self;
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error != nil && error.code == AMapLocationErrorLocateFailed)
        {
            //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
            NSLog(@"定位错误:{%ld - %@};", (long)error.code, error.localizedDescription);
            return;
        }
        else if (error != nil
                 && (error.code == AMapLocationErrorReGeocodeFailed
                     || error.code == AMapLocationErrorTimeOut
                     || error.code == AMapLocationErrorCannotFindHost
                     || error.code == AMapLocationErrorBadURL
                     || error.code == AMapLocationErrorNotConnectedToInternet
                     || error.code == AMapLocationErrorCannotConnectToHost))
        {
            //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
            NSLog(@"逆地理错误:{%ld - %@};", (long)error.code, error.localizedDescription);
        }
        else if (error != nil && error.code == AMapLocationErrorRiskOfFakeLocation)
        {
            //存在虚拟定位的风险：此时location和regeocode没有返回值，不进行annotation的添加
            NSLog(@"存在虚拟定位的风险:{%ld - %@};", (long)error.code, error.localizedDescription);
            return;
        }
        else
        {
            //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
        }
        
        //根据定位信息，添加annotation
//        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
         SingleLocationViewController *strongSelf = weakSelf;
        [strongSelf.annotation setCoordinate:location.coordinate];
        
        //有无逆地理信息，annotationView的标题显示的字段不一样
        if (regeocode)
        {
            [strongSelf.annotation setTitle:[NSString stringWithFormat:@"%@", regeocode.formattedAddress]];
            [strongSelf.annotation setSubtitle:[NSString stringWithFormat:@"%@-%@-%.2fm", regeocode.citycode, regeocode.adcode, location.horizontalAccuracy]];
        }
        else
        {
            [strongSelf.annotation setTitle:[NSString stringWithFormat:@"lat:%f;lon:%f;", location.coordinate.latitude, location.coordinate.longitude]];
            [strongSelf.annotation setSubtitle:[NSString stringWithFormat:@"accuracy:%.2fm", location.horizontalAccuracy]];
        }
        
       
        [strongSelf addAnnotationToMapView:strongSelf.annotation];
    };
}

- (void)addAnnotationToMapView:(id<MAAnnotation>)annotation
{
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    [self.mapView setZoomLevel:15.1 animated:YES];
    [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
}

//
//- (MAMapView *)mapView
//{
//    if (!_mapView) {
//        _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
//        _mapView.delegate = self;
////        _mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
////
////        [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:NO]; //地图跟着位置移动
////
////        //自定义定位经度圈样式
////        _mapView.customizeUserLocationAccuracyCircleRepresentation = NO;
////        //地图跟踪模式
////        _mapView.userTrackingMode = MAUserTrackingModeFollow;
////
////        //后台定位
////        _mapView.pausesLocationUpdatesAutomatically = NO;
////
////        _mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
//
//    }
//    return _mapView;
//}

- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        [self.mapView setDelegate:self];
        self.mapView.showsUserLocation = YES;
 //∫       self.mapView.customizeUserLocationAccuracyCircleRepresentation = NO;
        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        self.mapView.pausesLocationUpdatesAutomatically = NO;
        self.mapView.allowsBackgroundLocationUpdates = YES;
 //       [self.mapView addSubview:self.longitudeTextField];
        
        [self.view addSubview:self.mapView];
    }
}

- (void)initToolBar
{
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    UIBarButtonItem *reGeocodeItem = [[UIBarButtonItem alloc] initWithTitle:@"带逆地理定位"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(reGeocodeAction)];
    
    UIBarButtonItem *locItem = [[UIBarButtonItem alloc] initWithTitle:@"不带逆地理定位"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(locAction)];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexble, reGeocodeItem, flexble, locItem, flexble, nil];
}

- (void)initNavigationBar
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clean"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(cleanUpAction)];
}

#pragma mark - Life Cycle

- (UIButton *)positioningStart{
    if (_positioningStart==nil) {
        _positioningStart = [[UIButton alloc] initWithFrame:CGRectMake(40, 140, 40, 40)];
        [_positioningStart addTarget:self action:@selector(startPositioning:) forControlEvents:UIControlEventTouchDown];
        [_positioningStart setBackgroundColor:[UIColor blueColor]];
    }
    return _positioningStart;
}

-(void)startPositioning:(id)sender{

//    [UIView animateWithDuration:3 animations:^{
//        [self.annotation setCoordinate:CLLocationCoordinate2DMake(34.108730, 108.623344)];
//    }];
    [self.startAnnotation setCoordinate:CLLocationCoordinate2DMake(34.108730, 108.623344)];
    [self.destinationAnnotation setCoordinate:CLLocationCoordinate2DMake(34.079182, 108.696716)];
    
    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
    
    navi.requireExtension = YES;
    navi.strategy = 5;
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:34.108730
                                           longitude:108.623344];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:34.079182
                                                longitude:108.696716];
    [self.search AMapDrivingRouteSearch:navi];
}


-(UITextField *)longitudeTextField{
    if (_longitudeTextField==nil) {
        _longitudeTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, 90, 160, 44)];
        _longitudeTextField.backgroundColor = [UIColor whiteColor];
    }
    
    return _longitudeTextField;
}

-(UITextField *)latitudeTextField{
    if (_latitudeTextField==nil) {
        _latitudeTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, 40, 160, 44)];
        _latitudeTextField.backgroundColor = [UIColor whiteColor];
    }
    
    return _latitudeTextField;
}

-(void)initTextField{
//    _latitudeTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, 140, 160, 44)];
//    _longitudeTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, 190, 160, 44)];
    [self.view addSubview:self.longitudeTextField];
    [self.view addSubview:self.latitudeTextField];
    [self.view addSubview:self.positioningStart];
//    [self.view addSubview:self.latitudeTextField];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initToolBar];
    
    [self initNavigationBar];
    
    [self initMapView];
    [self initTextField];
    [self initCompleteBlock];
    
    [self configLocationManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.translucent   = YES;
    self.navigationController.toolbarHidden         = NO;
}

- (void)dealloc
{
    [self cleanUpAction];
    
    self.completionBlock = nil;
}

#pragma mark - MAMapView Delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout   = YES;
        annotationView.animatesDrop     = YES;
        annotationView.draggable        = NO;
        annotationView.pinColor         = MAPinAnnotationColorPurple;
//        annotationView.image = [UIImage imageNamed:@"arrow"];
        
        return annotationView;
    }
    
    return nil;
}

@end
