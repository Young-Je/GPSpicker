//
//  SerialLocationViewController.m
//  officialDemoLoc
//
//  Created by 刘博 on 15/9/21.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import "SerialLocationViewController.h"
#import "SharedInstance.h"
#import "GPSMetaData.h"
#import "MAAnnotationView+Extension.h"

@interface SerialLocationViewController ()<MAMapViewDelegate, AMapLocationManagerDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UISegmentedControl *showSegment;
@property (nonatomic, strong) MAPointAnnotation *pointAnnotaiton;
@property (nonatomic) BOOL wannaSavedata;
@property (nonatomic, strong)NSString *fileName;

@property (nonatomic) float latitude;
@property (nonatomic) float longtitude;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) float  accurcay;
@property (nonatomic) FILE *fp;
@property (nonatomic) FILE *fpProcessedData;
@property (nonatomic) NSInteger sampleCount;
@property (nonatomic, strong) GPSMetaData *centerLocation;
@property (nonatomic, strong) UISwitch *switcher;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) UIAlertController *alertCtl;
@property (nonatomic) NSInteger currentBusNum;
@property (strong, nonatomic)  MAMapView *myLocation;

@end

@implementation SerialLocationViewController

//typedef struct GPSMetaData{
//    float latitude;
//    float longtitude;
//}GPSMetaData;


#pragma mark - Action Handle

-(NSInteger)currentBusNum{
    if (!_currentBusNum) {
        _currentBusNum = 1;
    }
    return _currentBusNum;
}

-(GPSMetaData *)centerLocation{
    if (_centerLocation==nil) {
        _centerLocation = [[GPSMetaData alloc] init];
    }
    return _centerLocation;
}


//-(UIAlertController *)alertCtl{
//    if (_alertCtl==nil) {
//        _alertCtl = [UIAlertController alertControllerWithTitle:@"+" message:@"back Or forth" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//
//        }];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//        }];
// //       UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        [button addTarget:self action:@selector(upOrDown) forControlEvents:UIControlEventTouchDown];
//        [_alertCtl.view addSubview:button];
//        [_alertCtl addAction:cancelAction];
//        [_alertCtl addAction:okAction];
//        [_alertCtl addTextFieldWithConfigurationHandler:^(UITextField *textField){textField.placeholder = @"登录";}];
//    }
//    return _alertCtl;
//}

-(void)upOrDown{
    ;
    if ([self.alert.title isEqualToString:@"+"]) {
        [self.alert setTitle:@"-"];
        UIBarButtonItem *item = [self.navigationItem.rightBarButtonItems objectAtIndex:2];
        [item setTitle:@"-"];
    }else{
        [self.alert setTitle:@"+"];
        UIBarButtonItem *item = [self.navigationItem.rightBarButtonItems objectAtIndex:2];
        [item setTitle:@"+"];
    }
    
}

-(UIAlertView *)alert{
    if (_alert== nil) {
        _alert = [[UIAlertView alloc] initWithTitle:[[SharedInstance sharedInstance] stepFlag]
                                                        message:@"Rise up or descend"
                                                       delegate:self
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:@"Cancel",nil];
        
        _alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField * alertTextField = [_alert textFieldAtIndex:0];
        alertTextField.text = @"1";
        alertTextField.keyboardType = UIKeyboardTypeNumberPad;
        _alert.delegate = self;
    }
    return _alert;
}

-(NSInteger)sampleCount{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sampleCount = 3;
    });
    return _sampleCount;
}

- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];

    [self.locationManager setDelegate:self];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //设置允许连续定位逆地理
    [self.locationManager setLocatingWithReGeocode:YES];
    
//    [self.locationManager startUpdatingLocation];
//    [self.mapView setShowsUserLocation:YES];
}

- (void)showsSegmentAction:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex)
    {
        //停止定位
        [self.locationManager stopUpdatingLocation];
        
        //移除地图上的annotation
        [self.mapView removeAnnotations:self.mapView.annotations];
        self.pointAnnotaiton = nil;
    }
    else
    {
        //开始进行连续定位
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

-(NSString *)fileName{
    if (_fileName==nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //make a file name to write the data to using the documents directory:
        _fileName = [NSString stringWithFormat:@"%@/filename.txt",
                     documentsDirectory];
        return _fileName;
    }
    return _fileName;
}

//-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
//{
//    CLHeading *heading = userLocation.heading;
//    MAAnnotationView *userview = [self.mapView viewForAnnotation:userLocation];
//    [userview rotateWithHeading:heading];
//
//}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f; reGeocode:%@}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, reGeocode.formattedAddress);
    
    //获取到定位信息，更新annotation
    if (self.pointAnnotaiton == nil)
    {
        self.pointAnnotaiton = [[MAPointAnnotation alloc] init];
  
        [self.pointAnnotaiton setCoordinate:location.coordinate];
        
//        [self.pointAnnotaiton setTitle:[NSString stringWithFormat:@"%@", reGeocode.formattedAddress]];
//        [self.pointAnnotaiton setSubtitle:[NSString stringWithFormat:@"%@-%@-%.2fm", reGeocode.citycode, reGeocode.adcode, location.horizontalAccuracy]];

        
        [self.mapView addAnnotation:self.pointAnnotaiton];
    }
    NSString *address = reGeocode.formattedAddress;
    address = [address substringFromIndex:9];
    [self.pointAnnotaiton setTitle:[NSString stringWithFormat:@"lat:%f;lon:%f sample:%lu", location.coordinate.latitude, location.coordinate.longitude,(unsigned long)[[[SharedInstance sharedInstance] tripleSet] count]]];
    [self.pointAnnotaiton setSubtitle:[NSString stringWithFormat:@"ac:%.1fm%@", location.horizontalAccuracy, address]];
    [self.pointAnnotaiton setCoordinate:location.coordinate];
    
    
    if (self.wannaSavedata&&(self!=nil)) {

        self.latitude = location.coordinate.latitude;
        self.longtitude = location.coordinate.longitude;
        self.address = reGeocode.formattedAddress;
        self.accurcay = location.horizontalAccuracy;
        


        self.wannaSavedata = NO;
        
        
        [self.alert show];

        
    }
    
    //有无逆地理信息，annotationView的标题显示的字段不一样
    
    [self.mapView setCenterCoordinate:location.coordinate];
//    [self.mapView setZoomLevel:18.1 animated:YES];
}

-(void)decreaseOrIncrease{
    
}


//
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    switch (buttonIndex) {
        case 0:
        {
            GPSMetaData *point = [[GPSMetaData alloc] init];
            GPSMetaData *tempoint = [[GPSMetaData alloc] init];
            point.latitude = self.latitude;
            point.longtitude = self.longtitude;


           

            UITextField * alertTextField = [alertView textFieldAtIndex:0];
            NSInteger number = [alertTextField.text intValue];
             [[[SharedInstance sharedInstance] tripleSet] addObject:point];
            if ([[[SharedInstance sharedInstance] tripleSet] count]>=3) {
                for (GPSMetaData *samplepoint in [[SharedInstance sharedInstance] tripleSet]) {
                    tempoint.longtitude += samplepoint.longtitude;
                    tempoint.latitude += samplepoint.latitude;
                }
                self.centerLocation.longtitude = tempoint.longtitude/3;
                self.centerLocation.latitude = tempoint.latitude/3;
                [[[SharedInstance sharedInstance] tripleSet] removeAllObjects];
                if ([self.alert.title isEqualToString:@"+"]) {
                    number = number + 1;
                }else{
                    if (number > 0) {
                        number = number -1 ;
                    }
                }
            }
            self.currentBusNum = number;
            if (_fp) {
                        fprintf(_fp,"%f %f %s %f %s\n" ,self.latitude, self.longtitude,[self.address cStringUsingEncoding:NSUTF8StringEncoding] ,self.accurcay ,[alertTextField.text cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
            if (self.centerLocation.latitude != 0&&self.switcher.on) {
                if (_fpProcessedData) {
//                    NSString *currentCountStr = @"";
//                    if ([self.alert.title isEqualToString:@"+"]) {
//                        currentCountStr = [NSString stringWithFormat:@"%li",(long)number - 1];
//                    }else{
//                        if (number > 0) {
//                            number = number -1 ;
//                            currentCountStr = [NSString stringWithFormat:@"%li",(long)number + 1];
//                        }
                    
                        fprintf(_fpProcessedData,"%f %f %s %f %s\n" ,self.centerLocation.latitude, self.centerLocation.longtitude,[self.address cStringUsingEncoding:NSUTF8StringEncoding] ,self.accurcay ,[alertTextField.text cStringUsingEncoding:NSUTF8StringEncoding]);
                        self.centerLocation =  nil;
                }

            }
            alertTextField.text = [NSString stringWithFormat:@"%li", (long)number];
            
        
            break;
        }

        case 1:
//            [_alert show];
            break;
        case 2:
//            [_alert show];
            break;
        default:
//            [_alert show];
            break;
    }
}


#pragma mark - Initialization

- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        self.mapView.zoomingInPivotsAroundAnchorPoint = YES;
        [self.mapView setDelegate:self];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = 32.0;
        coordinate.longitude = 108.0;
        [self.mapView setCenterCoordinate:coordinate animated:YES];
        [self.mapView setZoomLevel:18.1 animated:YES];
        [self.view addSubview:self.mapView];
    }
}

- (void)initToolBar
{
    self.wannaSavedata = NO;
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveData)];
    UIBarButtonItem *upOrDownButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(upOrDown)];
    self.navigationItem.rightBarButtonItems  = [NSArray arrayWithObjects:anotherButton,flexble,upOrDownButton, nil];

    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"ClearBuffer" style:UIBarButtonItemStylePlain target:self action:@selector(ClearBuffer)];

    
    
    
    self.showSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Start", @"Stop", nil]];
    [self.showSegment addTarget:self action:@selector(showsSegmentAction:) forControlEvents:UIControlEventValueChanged];
    self.showSegment.selectedSegmentIndex = 0;
    UIBarButtonItem *showItem = [[UIBarButtonItem alloc] initWithCustomView:self.showSegment];
    
    _switcher = [[UISwitch  alloc] init];
    [_switcher addTarget:self action:@selector(swithDidChanged) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *togglerItem = [[UIBarButtonItem alloc] initWithCustomView:self.switcher];
    
    
    self.toolbarItems = [NSArray arrayWithObjects:clearButton, flexble,showItem, flexble,togglerItem,  nil];
}

-(void)ClearBuffer{
    [[[SharedInstance sharedInstance] tripleSet] removeAllObjects];
}

-(void)swithDidChanged{
    if (self.switcher.on) {
        [[SharedInstance sharedInstance] setSampleMode:NO];
    }else{
        [[SharedInstance sharedInstance] setSampleMode:YES];
    }
    
}

-(void)saveData{
    self.wannaSavedata = YES;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.centerLocation = nil;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initToolBar];
    
    [self initMapView];
    
    [self configLocationManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.switcher.on = YES;
    self.centerLocation = nil;
    self.alert.title = [[SharedInstance sharedInstance] stepFlag];
    UITextField * alertTextField = [self.alert textFieldAtIndex:0];
    NSString *temp = [NSString stringWithFormat:@"%li",[[[SharedInstance sharedInstance] numberBusNum] integerValue]];
    alertTextField.text =temp;
    UIBarButtonItem *item = [self.navigationItem.rightBarButtonItems objectAtIndex:2];
    [item setTitle:[[SharedInstance sharedInstance] stepFlag]];
    NSString *locationFilePath = self.fileName;
    _fp = fopen([locationFilePath UTF8String], "a");
    
    NSString *processedData = [[SharedInstance sharedInstance] processedDataFileName];
    _fpProcessedData = fopen([processedData UTF8String], "a");
    self.navigationController.toolbar.translucent   = YES;
    self.navigationController.toolbarHidden         = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [[SharedInstance sharedInstance] setStepFlag:self.alert.title];
    NSUInteger temp = [[NSNumber numberWithInteger:self.currentBusNum] integerValue];
    [[SharedInstance sharedInstance] setNumberBusNum:[NSNumber numberWithInteger:self.currentBusNum]];
 //   [[SharedInstance sharedInstance] setCurrentStopNum:self.currentBusNum];
    fclose(_fp);
    fclose(_fpProcessedData);
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSNumber * temp = [[SharedInstance sharedInstance] numberBusNum];
    NSInteger num = [temp integerValue];
//    self.currentBusNum = [[SharedInstance sharedInstance] currentBusNum];
    [self.locationManager startUpdatingLocation];
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
        
//        annotationView.canShowCallout   = NO;
//        annotationView.animatesDrop     = NO;
//        annotationView.draggable        = NO;
//        annotationView.image            = [UIImage imageNamed:@"icon_location.png"];
//
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
