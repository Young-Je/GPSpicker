//
//  HTNaviViewController.m
//  officialDemoLoc
//
//  Created by Hutong on 27/09/2017.
//  Copyright © 2017 AutoNavi. All rights reserved.
//

#import "HTNaviViewController.h"
#import "MANaviRoute.h"
#import "MBProgressHUD.h"

@import MapKit;//ios7 使用苹果自带的框架使用@import导入则不用在Build Phases 导入框架了
@import CoreLocation;

static const NSString *RoutePlanningViewControllerStartTitle       = @"起点";
static const NSString *RoutePlanningViewControllerDestinationTitle = @"终点";
static const NSInteger RoutePlanningPaddingEdge                    = 20;

@interface HTNaviViewController ()<MAMapViewDelegate,AMapSearchDelegate>{
    int routeType;//选中的路线类型
}
@property (weak, nonatomic) IBOutlet UIButton *walkBtn;
@property (weak, nonatomic) IBOutlet UILabel *walkDration;
@property (weak, nonatomic) IBOutlet UILabel *busDration;
@property (weak, nonatomic) IBOutlet UILabel *driveDration;
@property (weak, nonatomic) IBOutlet UILabel *destinationName;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UIButton *carBtn;
@property (weak, nonatomic) IBOutlet UIButton *busBtn;
@property (weak, nonatomic) IBOutlet UIButton *navigationBtn;
@property (weak, nonatomic) IBOutlet UIView *navView;


@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapRoute *route;
@property (nonatomic, strong) AMapRoute *busRoute;
@property (nonatomic, strong) AMapRoute *driveRoute;
@property (nonatomic, strong) AMapRoute *walkRoute;
@property (nonatomic, strong) AMapGeoPoint *ampDistancePoint;
@property(strong,nonatomic) AMapSearchAPI *search;

/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;
/* 用于显示当前路线方案. */
@property (nonatomic, strong) MANaviRoute *naviRoute;

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *destinationAnnotation;
@property (nonatomic, strong) AMapGeoPoint *origin;
@property (nonatomic, strong) AMapGeoPoint *destination;

@end

@implementation HTNaviViewController

- (MANaviRoute *)naviRoute{
    if (_naviRoute == nil) {
        _naviRoute = [[MANaviRoute alloc] init];
    }
    return _naviRoute;
}

- (AMapGeoPoint *)origin{
    if (_origin == nil) {
        //34.098445, 108.659917
        _origin = [AMapGeoPoint locationWithLatitude:34.098445
                                           longitude:108.659917];
    }
    return _origin;
}

- (AMapGeoPoint *)destination{
    if (_destination == nil) {
        _destination = [AMapGeoPoint locationWithLatitude:34.259411
                                                     longitude:108.871277];
    }
    return  _destination;
}

- (IBAction)drivingBtn:(id)sender {
    [self clear];
    routeType=1;
    self.distance.text =[self disFormat:self.driveRoute.paths[0].distance];
    [self presentCurrentCourse];
}


-(AMapGeoPoint *)pointFormat:(NSString *)point{
    //经纬度格式转换
    NSArray *arry= [point componentsSeparatedByString:@","];
    double p2=((NSString *)arry[0]).doubleValue;
    double p1=((NSString *)arry[1]).doubleValue;
    return [AMapGeoPoint locationWithLatitude:CLLocationCoordinate2DMake(p1,p2).latitude
                                    longitude:CLLocationCoordinate2DMake(p1,p2).longitude];
}

- (IBAction)busBtn:(id)sender {
    [self clear];
    routeType=2;
    self.distance.text =[self disFormat:self.busRoute.transits[0].distance];
    [self presentCurrentCourse];
    
    // [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)walkAction:(id)sender {
//    [self clear];
    [self WalkNav];
    self.distance.text =[self disFormat:self.walkRoute.paths[0].distance];
    [self presentCurrentCourse];
    
}

- (void)addrouteWalk{
    [self clear];
    routeType=3;
    self.distance.text =[self disFormat:self.walkRoute.paths[0].distance];
    [self presentCurrentCourse];
}

-(void)driveNav{
    
    routeType=1;//自定义的路线类型，1为驾车，2为公共交通，3为步行
    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
    navi.requireExtension = YES;//是否返回扩展信息，默认为 NO
    navi.strategy = 5;// 驾车导航策略([default = 0]) 0-速度优先（时间）；1-费用优先（不走收费路段的最快道路）；2-距离优先；3-不走快速路；4-结合实时交通（躲避拥堵）；5-多策略（同时使用速度优先、费用优先、距离优先三个策略）；6-不走高速；7-不走高速且避免收费；8-躲避收费和拥堵；9-不走高速且躲避收费和拥堵
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:_mapView.userLocation.location.coordinate.latitude
                                           longitude:_mapView.userLocation.location.coordinate.longitude];
    /* 目的地. */
    navi.destination =self.ampDistancePoint;
    [self.search AMapDrivingRouteSearch:navi];//驾车路线规划
}
-(void)busNav{
    routeType=2;
    AMapTransitRouteSearchRequest *navi = [[AMapTransitRouteSearchRequest alloc] init];
    navi.requireExtension = YES;
    navi.strategy = 4;//公交换乘策略([default = 0])0-最快捷模式；1-最经济模式；2-最少换乘模式；3-最少步行模式；4-最舒适模式；5-不乘地铁模式
    navi.city =@"chongqing";
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:_mapView.userLocation.location.coordinate.latitude
                                           longitude:_mapView.userLocation.location.coordinate.longitude];
    /* 目的地. */
    navi.destination =self.ampDistancePoint;
    [self.search AMapTransitRouteSearch:navi];//公共交通路线规
}
-(void)WalkNav{
    routeType=3;
    AMapWalkingRouteSearchRequest *navi = [[AMapWalkingRouteSearchRequest alloc] init];
    /* 出发点. */
    navi.origin = self.origin;
    /* 目的地. */
    navi.destination = self.destination;
    if (self.search) {
        [self.search AMapWalkingRouteSearch:navi];
    }
    
}

- (void)addAnnotationToMapView:(id<MAAnnotation>)annotation
{
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    [self.mapView setZoomLevel:15.1 animated:YES];
//    [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.title=self.dsTitle;
    UIBarButtonItem *barItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goToBack)];
    self.navigationItem.leftBarButtonItem=barItem;
    
    // Do any additional setup after loading the view, typically from a nib.
    ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
    [AMapServices sharedServices].enableHTTPS = YES;
    self.ampDistancePoint= self.destination;
    ///初始化地图

    ///把地图添加至view
    
    [self.view addSubview:self.mapView];
    self.destinationName.text=self.dsTitle;
    
    [self isHideNavView:NO];
}

-(MAMapView *)mapView{
    if (_mapView == nil) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64,375,360)];
        _mapView.delegate=self;
        _mapView.centerCoordinate=CLLocationCoordinate2DMake(self.destination.latitude,self.destination.longitude);//定位中心点
        _mapView.zoomLevel=16.5;//地图缩放级别
        _mapView.showsUserLocation = YES;  //显示定位蓝点
        _mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    }
    return _mapView;
}

-(AMapSearchAPI *)search{
    if (_search == nil) {
        _search =  [[AMapSearchAPI alloc] init];
        _search.delegate = self;
    }
    return _search;
}

-(void)goToBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//根据导航类型绘制覆盖物
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        
        static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:routePlanningCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.image = nil;
        
        
        if ([annotation isKindOfClass:[MANaviAnnotation class]])
        {
            switch (((MANaviAnnotation*)annotation).type)
            {
                case MANaviAnnotationTypeRailway:
                    poiAnnotationView.image = [UIImage imageNamed:@"railway_station"];
                    break;
                    
                case MANaviAnnotationTypeBus:
                    poiAnnotationView.image = [UIImage imageNamed:@"bus"];
                    break;
                    
                case MANaviAnnotationTypeDrive:
                    poiAnnotationView.image = [UIImage imageNamed:@"car"];
                    break;
                    
                case MANaviAnnotationTypeWalking:
                    poiAnnotationView.image = [UIImage imageNamed:@"man"];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            /* 起点. */
            if ([[annotation title] isEqualToString:self.dsTitle])
            {
                static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
                MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
                if (annotationView == nil)
                {
                    annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
                }
                annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
                annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
                annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
                annotationView.pinColor = MAPinAnnotationColorRed;
                return annotationView;
            }
        }
        return poiAnnotationView;
    }
    
    return nil;
    
}
//在这里预加载导航路线，并显示菊花
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[AMapGeoPoint locationWithLatitude:34.259411 longitude:108.871277];
    self.destinationPoint= @"34.259411,108.871277";//@"106.577052,29.557259";
    self.dsTitle=@"解放碑";
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(self.destination.latitude,self.destination.longitude);
    pointAnnotation.title = self.dsTitle; //大头针
    [self.mapView addAnnotation:pointAnnotation];
//    MBProgressHUD *HUD= [MBProgressHUD showHUDAddedTo:self.navView animated:YES];
//    HUD.color=[UIColor clearColor];
//    HUD.activityIndicatorColor=[UIColor grayColor];
    
    
//    [self clear];
    [self WalkNav];
//
//    [self presentCurrentCourse];
}
//笨方法，隐藏加载中的控件
-(void)isHideNavView:(BOOL) ishide{
    self.busBtn.hidden=ishide;
    self.busDration.hidden=ishide;
    self.driveDration.hidden=ishide;
    self.carBtn.hidden=ishide;
    self.walkDration.hidden=ishide;
    self.walkBtn.hidden=ishide;
}
/* 路径规划搜索回调. */

- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (response.route == nil)
    {
        return;
    }
    /* 预加载*/
    if (routeType==1) {
        self.driveRoute=response.route;
        self.driveDration.text=[self timeFomart: response.route.paths[0].duration];
        [MBProgressHUD hideHUDForView:self.navView animated:YES];
        self.distance.text =[self disFormat:self.driveRoute.paths[0].distance];
        [self isHideNavView:false];
        
    }
    if (routeType==2) {
        self.busRoute=response.route;
        if (response.route.transits!=nil && response.route.transits.count!=0) {
            if(response.route.transits.lastObject!=nil){
                self.busDration.text=[self timeFomart:response.route.transits[0].duration];
            }
        }else{
            self.busDration.text=@"暂无";
            self.busBtn.enabled=false;
        }
        [self driveNav];
    }
    if (routeType==3) {
        self.walkRoute=response.route;
        if (response.route.paths!=nil) {
            self.walkDration.text=[self timeFomart: response.route.paths[0].duration];
        }
        else{
            self.walkDration.text=@"暂无";
            self.walkBtn.enabled=false;
        }
        [self WalkNav];
    }
    self.route = response.route;
    self.currentCourse = 0;
}
//时间格式转换
-(NSString *)timeFomart:(double)duration{
    return [NSString stringWithFormat:@"%0.0f分钟",duration/60];
}

//根据不同导航类型解析不同路线
- (void)presentCurrentCourse
{
    
    MANaviAnnotationType type = MANaviAnnotationTypeDrive;
    if (routeType==1) {
        type = MANaviAnnotationTypeDrive;
        self.naviRoute = [MANaviRoute naviRouteForPath:self.driveRoute.paths[self.currentCourse] withNaviType:type showTraffic:YES startPoint:[AMapGeoPoint  locationWithLatitude:self.mapView.userLocation.location.coordinate.latitude longitude:self.mapView.userLocation.location.coordinate.longitude]
                                              endPoint:self.ampDistancePoint];
        [self.naviRoute addToMapView:self.mapView];
        
    }
    if (routeType==2) {
        self.naviRoute = [MANaviRoute naviRouteForTransit:self.busRoute.transits[self.currentCourse] startPoint:[AMapGeoPoint  locationWithLatitude:self.mapView.userLocation.location.coordinate.latitude longitude:self.mapView.userLocation.location.coordinate.longitude]
                                                 endPoint:self.ampDistancePoint];
        [self.naviRoute addToMapView:self.mapView];
    }
    if (routeType==3) {
        type = MANaviAnnotationTypeWalking;
        self.naviRoute = [MANaviRoute naviRouteForPath:self.walkRoute.paths[self.currentCourse] withNaviType:type showTraffic:YES startPoint:self.origin
                                              endPoint:self.destination];
 
        [self.naviRoute addToMapView:self.mapView];

        
    }
    
    /* 缩放地图使其适应polylines的展示. */
    self.naviRoute.anntationVisible=YES;
    [self.mapView showOverlays:self.naviRoute.routePolylines edgePadding:UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge) animated:YES];
    
}

//根据不同导航类型绘制路线
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay// 任何遵循此协议的对象
{
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineRenderer.lineWidth   = 8;
        //       polylineRenderer.lineDashPattern = @[@10, @15];
        polylineRenderer.strokeColor = [UIColor redColor];
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MANaviPolyline class]])
    {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        
        polylineRenderer.lineWidth = 8;
        
        if (naviPolyline.type == MANaviAnnotationTypeWalking)
        {
            polylineRenderer.strokeColor = self.naviRoute.walkingColor;
        }
        else if (naviPolyline.type == MANaviAnnotationTypeRailway)
        {
            polylineRenderer.strokeColor = self.naviRoute.railwayColor;
        }
        else
        {
            polylineRenderer.strokeColor = self.naviRoute.routeColor;
        }
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:(MAMultiPolyline *)overlay];
        polylineRenderer.lineWidth = 8;
        polylineRenderer.strokeColors = [self.naviRoute.multiPolylineColors copy];
        polylineRenderer.gradient = YES;
        return polylineRenderer;
    }
    return nil;
}
//清理绘制路线
- (void)clear
{
    [self.naviRoute removeFromMapView];
}

//出错处理
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    if (routeType==1) {
        self.driveDration.text=@"暂无";
        self.carBtn.enabled=false;
    }
    if (routeType==2) {
        self.busDration.text=@"暂无";
        self.busBtn.enabled=false;
        [self driveNav];
    }
    if (routeType==3) {
        self.walkDration.text=@"暂无";
        self.walkBtn.enabled=false;
        [self busNav];
    }
    NSLog(@"Error: %@", error);
}

//距离格式转换
-(NSString *)disFormat:(double)meters {
    double intDistance=(int)round(meters);
    return [NSString stringWithFormat:@"距离:%0.2fKM",intDistance/1000 ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*打开第三方地图*/
- (IBAction)openMap:(UIButton *)sender {
    NSString *urlScheme = @"MapJump://";
    NSString *appName = @"MapJump";
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.ampDistancePoint.latitude,self.ampDistancePoint.longitude);//要导航的终点的经纬度
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择地图" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //这个判断其实是不需要的
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]]) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            CLLocationCoordinate2D desCoordinate = coordinate;
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:desCoordinate addressDictionary:nil]];
            toLocation.name = self.dsTitle;//可传入目标地点名称
            [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
        }];
        [alert addAction:action];
    }
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        //coordinate = CLLocationCoordinate2DMake(40.057023, 116.307852);
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            CLLocationCoordinate2D desCoordinate = coordinate;
            
            NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&sname=%@&did=BGVIS2&dlat=%f&dlon=%f&dev=0&m=0&t=0",@"我的位置",desCoordinate.latitude, desCoordinate.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];//@"我的位置"可替换为@"终点名称"
            NSLog(@"%@",urlString);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                
            }];
            
        }];
        [alert addAction:action];
    }
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"谷歌地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            CLLocationCoordinate2D desCoordinate = coordinate;
            NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",appName,urlScheme,desCoordinate.latitude, desCoordinate.longitude]  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            NSLog(@"%@",urlString);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                
            }];
        }];
        
        [alert addAction:action];
    }
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]])    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            CLLocationCoordinate2D desCoordinate = coordinate;
            NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&from=我的位置&to=%@&tocoord=%f,%f&policy=1&referer=%@", @"终点名称", desCoordinate.latitude, desCoordinate.longitude, appName] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            
            NSLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                
            }];;
            
        }];
        [alert addAction:action];
    }
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:^{
    }];
}


@end
