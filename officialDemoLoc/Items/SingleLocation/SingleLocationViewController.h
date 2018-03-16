//
//  SingleLocationViewController.h
//  officialDemoLoc
//
//  Created by 刘博 on 15/9/21.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface SingleLocationViewController : UIViewController

@property (nonatomic, strong) MAMapView *mapView;
@property (strong, nonatomic) UITextField *longitudeTextField;
//自己纬度
@property (strong, nonatomic) UITextField *latitudeTextField;

@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (strong,nonatomic) UIButton *positioningStart;

@property (strong,nonatomic) MAPointAnnotation *annotation;
@property (strong,nonatomic) MAPointAnnotation *startAnnotation;
@property (strong,nonatomic) MAPointAnnotation *destinationAnnotation;

@property (strong, nonatomic) AMapSearchAPI *search;

@end
