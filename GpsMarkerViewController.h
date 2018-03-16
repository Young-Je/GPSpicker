//
//  GpsMarkerViewController.h
//  officialDemoLoc
//
//  Created by Hutong on 13/10/2017.
//  Copyright © 2017 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface GpsMarkerViewController : UIViewController
@property (nonatomic, strong) MAMapView *mapView;


@property (nonatomic, strong) AMapLocationManager *locationManager;


@property (assign, nonatomic) CLLocationCoordinate2D device1Coordinate; //起始点经纬度
@property (assign, nonatomic) CLLocationCoordinate2D device2Coordinate; //终点经纬度
@property (assign, nonatomic) CLLocationCoordinate2D phoneCoordinate; //终点经纬度

@property (strong,nonatomic) MAPointAnnotation *phoneAnnotation;
@property (strong,nonatomic) MAPointAnnotation *device1Annotation;
@property (strong,nonatomic) MAPointAnnotation *device2Annotation;

@end
