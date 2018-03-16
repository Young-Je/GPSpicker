//
//  HTMapViewController.m
//  WalkRoutePlanDemo
//
//  Created by HT 

//

#import "HTMapViewController.h"
#import "RoutePathDetailViewController.h"

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "MAAnnotationView+Extension.h"
#import <AMapLocationKit/AMapLocationKit.h>

#import "CommonUtility.h"
#import "MANaviRoute.h"
#define DefaultLocationTimeout  6
#define DefaultReGeocodeTimeout 3

static const NSInteger RoutePlanningPaddingEdge = 20;
static const NSString *RoutePlanningViewControllerStartTitle = @"起点";
static const NSString *RoutePlanningViewControllerDestinationTitle = @"终点";

@interface HTMapViewController ()<MAMapViewDelegate,AMapSearchDelegate,AMapLocationManagerDelegate>

@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;
@property (strong, nonatomic) MAMapView *mapView;  //地图
@property (strong, nonatomic) AMapSearchAPI *search;  // 地图内的搜索API类
@property (strong, nonatomic) AMapRoute *route;  //路径规划信息
@property (strong, nonatomic) MANaviRoute * naviRoute;  //用于显示当前路线方案.

@property (strong, nonatomic) MAPointAnnotation *startAnnotation;
@property (strong, nonatomic) MAPointAnnotation *destinationAnnotation;

@property (assign, nonatomic) CLLocationCoordinate2D startCoordinate; //起始点经纬度
@property (assign, nonatomic) CLLocationCoordinate2D destinationCoordinate; //终点经纬度

@property (assign, nonatomic) NSUInteger totalRouteNums;  //总共规划的线路的条数
@property (assign, nonatomic) NSUInteger currentRouteIndex; //当前显示线路的索引值，从0开始

//xib views
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *switchRouteBtn;
//@property (weak, nonatomic) IBOutlet UIButton *routeDetailBtn;
@property (weak, nonatomic) IBOutlet UIButton *routeDetailBtn;
@end

@implementation HTMapViewController

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    CLHeading *heading = userLocation.heading;
    MAAnnotationView *userview = [self.mapView viewForAnnotation:userLocation];
    [userview rotateWithHeading:heading];

}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMapViewAndSearch];
    
    [self setUpData];
    
    [self resetSearchResultAndXibViewsToDefault];
    
    [self addDefaultAnnotations];
    
    [self searchRoutePlanningWalk];  //步行路线开始规划
    
}


//初始化地图,和搜索API
- (void)initMapViewAndSearch {
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 45 - 64)];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = YES;  //显示定位蓝点
     [self.mapView setUserTrackingMode: MAUserTrackingModeFollow animated:NO]; //地图跟着位置移动
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
}

//初始化坐标数据
//- (AMapGeoPoint *)origin{
//    if (_origin == nil) {
//        //34.098445, 108.659917
//        _origin = [AMapGeoPoint locationWithLatitude:34.098445
//                                           longitude:108.659917];
//    }
//    return _origin;
//}
//
//- (AMapGeoPoint *)destination{
//    if (_destination == nil) {
//        _destination = [AMapGeoPoint locationWithLatitude:34.259411
//                                                longitude:108.871277];
//    }
//    return  _destination;
//}
- (void)setUpData {
    self.startCoordinate = CLLocationCoordinate2DMake(34.098445, 108.659917);
    self.destinationCoordinate = CLLocationCoordinate2DMake(34.259411, 108.871277);
    

}

//初始化或者规划失败后，设置view和数据为默认值
- (void)resetSearchResultAndXibViewsToDefault {
    self.totalRouteNums = 0;
    self.currentRouteIndex = 0;
    self.switchRouteBtn.enabled = self.routeDetailBtn.enabled = NO;
//    self.infoLabel.text = @"";
    [self.naviRoute removeFromMapView];
}

//在地图上添加起始和终点的标注点
- (void)addDefaultAnnotations {
    MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title = (NSString *)RoutePlanningViewControllerStartTitle;
//    startAnnotation.subtitle = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    self.startAnnotation = startAnnotation;
    
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = self.destinationCoordinate;
    destinationAnnotation.title = (NSString *)RoutePlanningViewControllerDestinationTitle;
//    destinationAnnotation.subtitle = [NSString stringWithFormat:@"{%f, %f}", self.destinationCoordinate.latitude, self.destinationCoordinate.longitude];
    self.destinationAnnotation = destinationAnnotation;
    
    [self.mapView addAnnotation:startAnnotation];
    [self.mapView addAnnotation:destinationAnnotation];
}

//步行路线开始规划
- (void)searchRoutePlanningWalk {
    
    AMapWalkingRouteSearchRequest *navi = [[AMapWalkingRouteSearchRequest alloc] init];
    
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    [self.search AMapWalkingRouteSearch:navi];
}

#pragma mark - AMapSearchDelegate

//当路径规划搜索请求发生错误时，会调用代理的此方法
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
    [self resetSearchResultAndXibViewsToDefault];
}

//路径规划搜索完成回调.
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response {
    
    if (response.route == nil){
        [self resetSearchResultAndXibViewsToDefault];
        return;
    }
    
    self.route = response.route;
    
    self.totalRouteNums = self.route.paths.count;
    self.currentRouteIndex = 0;
    self.routeDetailBtn.enabled = self.totalRouteNums > 0;
    self.switchRouteBtn.enabled = self.totalRouteNums > 1;
 //   self.distance.text =[self disFormat:self.driveRoute.paths[0].distance];
    self.infoLabel.text = [self disFormat:self.route.paths[0].distance];
    
    [self presentCurrentRouteCourse];
}

//距离格式转换
-(NSString *)disFormat:(double)meters {
    double intDistance=(int)round(meters);
    return [NSString stringWithFormat:@"距离:%0.2fKM",intDistance/1000 ];
}

//在地图上显示当前选择的路径
- (void)presentCurrentRouteCourse {
    
    if (self.totalRouteNums <= 0) {
        return;
    }
    
    [self.naviRoute removeFromMapView];  //清空地图上已有的路线
    
 //   self.infoLabel.text = [NSString stringWithFormat:@"共%u条路线，当前显示第%u条",(unsigned)self.totalRouteNums,(unsigned)self.currentRouteIndex + 1];  //提示信息
    
    MANaviAnnotationType type = MANaviAnnotationTypeWalking; //走路类型
    
    AMapGeoPoint *startPoint = [AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude]; //起点
    
    AMapGeoPoint *endPoint = [AMapGeoPoint locationWithLatitude:self.destinationAnnotation.coordinate.latitude longitude:self.destinationAnnotation.coordinate.longitude];  //终点
    
    //根据已经规划的路径，起点，终点，规划类型，是否显示实时路况，生成显示方案
    self.naviRoute = [MANaviRoute naviRouteForPath:self.route.paths[self.currentRouteIndex] withNaviType:type showTraffic:NO startPoint:startPoint endPoint:endPoint];
    
    [self.naviRoute addToMapView:self.mapView];  //显示到地图上
    
    UIEdgeInsets edgePaddingRect = UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge);
    
    //缩放地图使其适应polylines的展示
    [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
                        edgePadding:edgePaddingRect
                           animated:NO];
}

#pragma mark - MAMapViewDelegate

//地图上覆盖物的渲染，可以设置路径线路的宽度，颜色等
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    
    //虚线，如需要步行的
    if ([overlay isKindOfClass:[LineDashPolyline class]]) {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineRenderer.lineWidth = 6;
        polylineRenderer.lineDash = YES;
        polylineRenderer.strokeColor = [UIColor redColor];
        
        return polylineRenderer;
    }
    
    //showTraffic为NO时，不需要带实时路况，路径为单一颜色，比如步行线路目前为海蓝色
    if ([overlay isKindOfClass:[MANaviPolyline class]]) {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        
        polylineRenderer.lineWidth = 6;
        
        if (naviPolyline.type == MANaviAnnotationTypeWalking) {
            polylineRenderer.strokeColor = self.naviRoute.walkingColor;
        } else if (naviPolyline.type == MANaviAnnotationTypeRailway) {
            polylineRenderer.strokeColor = self.naviRoute.railwayColor;
        } else {
            polylineRenderer.strokeColor = self.naviRoute.routeColor;
        }
        
        return polylineRenderer;
    }
    
    //showTraffic为YES时，需要带实时路况，路径为多颜色渐变
    if ([overlay isKindOfClass:[MAMultiPolyline class]]) {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 6;
        polylineRenderer.strokeColors = [self.naviRoute.multiPolylineColors copy];
        
        return polylineRenderer;
    }
    
    return nil;
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
        
        //拐点的图标标注
        if ([annotation isKindOfClass:[MANaviAnnotation class]]) {
            switch (((MANaviAnnotation*)annotation).type) {
                case MANaviAnnotationTypeRailway:
                    poiAnnotationView.image = [UIImage imageNamed:@"arrow"];
                    break;
                    
                case MANaviAnnotationTypeBus:
                    poiAnnotationView.image = [UIImage imageNamed:@"bus"];
                    break;
                    
                case MANaviAnnotationTypeDrive:
                    poiAnnotationView.image = [UIImage imageNamed:@"bus"];
                    break;
                    
                case MANaviAnnotationTypeWalking:
                    poiAnnotationView.image = [UIImage imageNamed:@"pedestrain"];
                    break;
                    
                default:
                    break;
            }
        }else if([annotation isKindOfClass:[MAUserLocation class]])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"arrow"];
        }else{
            //起点，终点的图标标注
            if ([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerStartTitle]) {
                poiAnnotationView.image = [UIImage imageNamed:@"startpoint"];  //起点
            }else if([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerDestinationTitle]){
                poiAnnotationView.image = [UIImage imageNamed:@"destination"];  //终点
            }
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}


#pragma -mark Xib Btn Click

//重新规划按钮点击
- (IBAction)restartSearch:(id)sender {
    [self searchRoutePlanningWalk];
}

//下一路线按钮点击
- (IBAction)switchRoute:(id)sender {
    if (self.totalRouteNums > 0) {
        if (self.currentRouteIndex < self.totalRouteNums - 1) {
            self.currentRouteIndex++;
        }else{
            self.currentRouteIndex = 0;
        }
        [self presentCurrentRouteCourse];
    }
}


//路线详情按钮点击
- (IBAction)goToRouteDetail:(id)sender {
    RoutePathDetailViewController *routePathDetailViewController = [[RoutePathDetailViewController alloc] initWithNibName:@"RoutePathDetailViewController" bundle:nil];
    routePathDetailViewController.route = self.route;
    routePathDetailViewController.path = self.route.paths[self.currentRouteIndex];
    [self.navigationController pushViewController:routePathDetailViewController animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
