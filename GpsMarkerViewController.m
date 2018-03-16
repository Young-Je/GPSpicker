//
//  GpsMarkerViewController.m
//  officialDemoLoc
//
//  Created by Hutong on 13/10/2017.
//  Copyright © 2017 AutoNavi. All rights reserved.
//

#define DEVICE1 @"device1"
#define DEVICE2 @"device2"
#define PHONE @"phone"

#import "GpsMarkerViewController.h"

@interface GpsMarkerViewController ()<AMapLocationManagerDelegate,AMapSearchDelegate,MAMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *distanceBetweenDevices;
@property (weak, nonatomic) IBOutlet UILabel *distanceToPhone;

@end

@implementation GpsMarkerViewController


- (MAMapView *)mapView
{
    if (!_mapView) {
        CGRect rect = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, (self.view.bounds.size.height - 50));
        _mapView = [[MAMapView alloc] initWithFrame:rect];
        _mapView.delegate = self;
        [_mapView setZoomLevel:16.1 animated:YES];

//        _mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
//
//        [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:NO]; //地图跟着位置移动
//
//        //自定义定位经度圈样式
        _mapView.customizeUserLocationAccuracyCircleRepresentation = NO;

//        //地图跟踪模式
////        _mapView.userTrackingMode = MAUserTrackingModeFollow;
//
//        //后台定位
//        _mapView.pausesLocationUpdatesAutomatically = NO;
//
//        _mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置

    }
    return _mapView;
}

- (void)setUpData {    
    self.phoneCoordinate = CLLocationCoordinate2DMake(34.107800, 108.696388);
    self.device1Coordinate = CLLocationCoordinate2DMake(34.109294, 108.691748);
    self.device2Coordinate = CLLocationCoordinate2DMake(34.109302, 108.691764);
    
    CLLocation *phoneLocation = [[CLLocation alloc] initWithLatitude:self.phoneCoordinate.latitude longitude:self.phoneCoordinate.longitude];
    
    CLLocation *device1Location = [[CLLocation alloc] initWithLatitude:self.device1Coordinate.latitude longitude:self.device1Coordinate.longitude];
    
        CLLocation *device2Location = [[CLLocation alloc] initWithLatitude:self.device2Coordinate.latitude longitude:self.device2Coordinate.longitude];
    
    CLLocationDistance distance = [phoneLocation distanceFromLocation:device1Location];
    self.distanceToPhone.text = [NSString stringWithFormat:@"phone %f", distance];
    distance = [device1Location distanceFromLocation:device2Location];
    self.distanceBetweenDevices.text = [NSString stringWithFormat:@"devices  %f", distance];
    
}

- (void)addDefaultAnnotations {
    _device1Annotation = [[MAPointAnnotation alloc] init];
    _device1Annotation.title = DEVICE1;
    _device1Annotation.coordinate = self.device1Coordinate;
    
   _device2Annotation = [[MAPointAnnotation alloc] init];
    _device2Annotation.title = DEVICE2;
    _device2Annotation.coordinate = self.device2Coordinate;
    
    _phoneAnnotation = [[MAPointAnnotation alloc] init];
    _phoneAnnotation.title = PHONE;
    _phoneAnnotation.coordinate = self.phoneCoordinate;
    
    [self.mapView addAnnotation:self.device1Annotation];
    [self.mapView addAnnotation:self.device2Annotation];
    [self.mapView addAnnotation:self.phoneAnnotation];
    self.mapView.centerCoordinate = self.phoneCoordinate;
}

//地图上的起始点，终点，拐点的标注，可以自定义图标展示等,只要有标注点需要显示，该回调就会被调用
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        //标注的view的初始化和复用
        static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
        
        if (poiAnnotationView == nil) {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:routePlanningCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.image = nil;
        
        if ([[annotation title] isEqualToString:PHONE]) {
            poiAnnotationView.image = [UIImage imageNamed:@"startpoint"];  //起点
        }else {
            poiAnnotationView.image = [UIImage imageNamed:@"destination"];  //终点
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
    [self addDefaultAnnotations];
    [self.view addSubview:self.mapView];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
