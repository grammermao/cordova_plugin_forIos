//
//  BaiduMapViewController.m
//  Quyiyuan
//
//  Created by Zhu Xueliang on 15/6/16.
//
//

#import "BaiduMapViewController.h"
#import "UIImage+Rotate.h"
#import "RouteTableViewCell.h"
#import "SearchTableViewCell.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface RouteAnnotation : BMKPointAnnotation {
    
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
    int _degree;
}
@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation
@synthesize type = _type;
@synthesize degree = _degree;
@end

// 自定义标签，用于点击table中的一项时，显示对于的内容
@interface CustomAnnotation : BMKPointAnnotation {
    
}
@end

@implementation CustomAnnotation

@end

@implementation BaiduMapViewController

@synthesize endLatitude = _endLatitude;
@synthesize endLongtitude = _endLongtitude;

int reGeo = 0; // 0--end；1--start；
NSString *endProvince = @"";
NSString *endCity = @"";
NSString *startProvince = @"";
NSString *startCity = @"";
double startLatitude = 0;
double startLongtitude = 0;
NSMutableArray *customAnnotations;
CustomAnnotation *myAnnotation;

// 获取百度提供的图片路径
- (NSString*)getMyBundlePath1:(NSString *)filename {
    
    NSBundle * libBundle = MYBUNDLE ;
    if (libBundle && filename) {
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent: filename];
        return s;
    }
    return nil ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化自定义视图
    [self initView];
    
    // 地图视图初始化
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 74, [[UIScreen mainScreen] bounds].size.width, 300)];
    [self.view addSubview:_mapView];
    // 设置地图的起点位置
    if (self.endLatitude == 0 || self.endLongtitude == 0) {
        [self showFailedAlert];
        return;
    }
    _mapView.centerCoordinate = (CLLocationCoordinate2D){self.endLatitude, self.endLongtitude};
    [_mapView setTrafficEnabled:YES];   // 开启路况信息
    
    // 地图表面的隐藏按钮
    hideOrShowButton = [[UIButton alloc] initWithFrame: CGRectMake([[UIScreen mainScreen] bounds].size.width / 2 - 40, 260 + 74, 80, 40)];
    [hideOrShowButton.layer setMasksToBounds:YES];
    [hideOrShowButton.layer setCornerRadius:10.0];
    hideState = false;
    [hideOrShowButton setTitle: @"隐藏" forState: UIControlStateNormal];
    hideOrShowButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [hideOrShowButton setBackgroundColor:[UIColor grayColor]];
    [hideOrShowButton setAlpha:0.5];
    //hideOrShowButton
    //[hideOrShowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [hideOrShowButton addTarget: self action: @selector(hideOrShow) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:hideOrShowButton];
    
    searchHospitalOrGetRoute = [[UIButton alloc] initWithFrame: CGRectMake(20, 94, 80, 40)];
    [searchHospitalOrGetRoute.layer setMasksToBounds:YES];
    [searchHospitalOrGetRoute.layer setCornerRadius:10.0];
    searchHospitalOrGetRoute.titleLabel.font = [UIFont systemFontOfSize:14];
    [searchHospitalOrGetRoute setTitle:@"周边医院" forState:UIControlStateNormal];
    [searchHospitalOrGetRoute setBackgroundColor: [UIColor grayColor]];
    [searchHospitalOrGetRoute setAlpha:0.5];
    [searchHospitalOrGetRoute addTarget: self action:@selector(searchOrGetRoute) forControlEvents: UIControlEventTouchUpInside];
    //[self.view addSubview: searchHospitalOrGetRoute];
}

// 初始化视图，包括导航栏已经表格显示
- (void)initView {
    // 创建一个导航栏
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 74)];
     //#5baa8a
    navigationBar.barTintColor = [UIColor colorWithRed: (CGFloat)(91.0/255.0) green: (CGFloat)(170.0/255.0) blue: (CGFloat)(138.0/255.0) alpha:1.0];
   
    navigationBar.translucent = NO;
    // 创建一个导航栏集合
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
    
    // 创建一个左边按钮
    UIImage *resizeImage = [self reSizeImage:[UIImage imageNamed: @"back123"] toSize:CGSizeMake(22.0, 22.0)];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage: resizeImage style:UIBarButtonItemStylePlain target:self action:@selector(handleGoBack)];
    
    // 设置导航栏内容
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:21.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    navigationItem.titleView = label;
    label.text = @"院外导航";
    [label sizeToFit];
    
    // 把导航栏集合添加入导航栏中，设置动画关闭
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    
    // 把左右两个按钮添加入导航栏集合中
    [navigationItem setLeftBarButtonItem: leftButton];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];  
    
    // 把导航栏添加到视图中
    [self.view addSubview:navigationBar];
    
    // 导航详情表格初始化
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 374, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 374)];
    [self.view addSubview:table];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DetailCell"];
    table.delegate = self;
    table.dataSource = self;
    instructions = [[NSMutableArray alloc] init];
    hospitalName = [[NSMutableArray alloc] init];
    hospitalAddr = [[NSMutableArray alloc] init];
    customAnnotations = [[NSMutableArray alloc] init];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    
    // 路径搜索初始化
    _routesearch = [[BMKRouteSearch alloc] init];
    _routesearch.delegate = self;
    // 定位服务初始化
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    // 终点反编码
    reGeo = 0;
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];
    _geocodesearch.delegate = self;
    
    _poisearch = [[BMKPoiSearch alloc]init];
    _poisearch.delegate = self;
    
    [self startGetRoute];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    
    _mapView.delegate = nil;
    _mapView = nil;
    
    _locService.delegate = nil;
    _locService = nil;
    
    _geocodesearch.delegate = self;
    _geocodesearch = nil;
    
    _routesearch.delegate = nil;
    _routesearch = nil;
    
    _poisearch.delegate = nil;
    _poisearch = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startGetRoute {
    // 终点反编码
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.endLatitude, self.endLongtitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    
    globalFlag = [_geocodesearch reverseGeoCode: reverseGeocodeSearchOption];
    if(globalFlag) {
        // 反向编码成功 将回调onGetReverseGeoCodeResult
        [self showWithGradient];
        //NSLog(@"终点反编码成功");
    } else{
        // 反向编码失败
        //NSLog(@"终点反编码失败");
        [self showFailedAlert];
    }
}

- (void)hideOrShow {
    if (!hideState) {
        hideState = true;
        [UIView animateWithDuration:0.5 animations:^{
            //        table.frame.origin.y = [[UIScreen mainScreen] bounds].size.height;
            table.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 374);
            _mapView.frame = CGRectMake(0, 74, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 74);
            hideOrShowButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width / 2 - 40, [[UIScreen mainScreen] bounds].size.height - 40, 80, 40);
            [hideOrShowButton setTitle:@"显示" forState:UIControlStateNormal];
        }];
        
    } else {
        hideState = false;
        [UIView animateWithDuration:1 animations:^{
            table.frame = CGRectMake(0, 374, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 374);
            _mapView.frame = CGRectMake(0, 74, [[UIScreen mainScreen] bounds].size.width, 300);
            hideOrShowButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width / 2 - 40, 260 + 74, 80, 40);
            [hideOrShowButton setTitle: @"隐藏" forState: UIControlStateNormal];
        }];
        
    }
    
}

- (void)handleGoBack {
    [self dismissViewControllerAnimated:YES completion:^{
        //NSLog(@"dismiss");
    }];
}

-(void) searchOrGetRoute {
    if ([searchHospitalOrGetRoute.titleLabel.text isEqualToString:@"周边医院"]) {
        
        if (HUD == nil) {
            [self showWithGradient];
        }
        
        int curPage = 0;
        BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
        citySearchOption.pageIndex = curPage;
        citySearchOption.pageCapacity = 10;
        citySearchOption.city= endCity;
        citySearchOption.keyword = @"医院";
        BOOL flag = [_poisearch poiSearchInCity:citySearchOption];
        if (flag) {
            //NSLog(@"城市内检索发送成功");
            [searchHospitalOrGetRoute setTitle:@"获取路径" forState:UIControlStateNormal];
        }
        else {
            //NSLog(@"城市内检索发送失败");
            [self hudWasHidden];
            [self showFailedAlert];
        }
        
    } else if ([searchHospitalOrGetRoute.titleLabel.text isEqualToString:@"获取路径"]) {
        // 终点反编码
        [searchHospitalOrGetRoute setTitle:@"周边医院" forState:UIControlStateNormal];
        [self startGetRoute];
    }
}

// MARK: ReGeo
// 反编码委托方法
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (error == 0) {
        
        if (reGeo == 0) {
            
            endProvince = result.addressDetail.province;
            endCity = result.addressDetail.city;
            //NSLog(@"终点地址%@", result.address);
            
            reGeo = 1;
            
            // 定位当前用户所在位置，定位成功回到didUpdateBMKUserLocation，失败回调didFailToLocateUserWithError
            [_locService startUserLocationService];
            
            _mapView.showsUserLocation = NO;
            _mapView.userTrackingMode = BMKUserTrackingModeNone;
            _mapView.showsUserLocation = YES;
            
        } else if (reGeo == 1) {
            
            startProvince = result.addressDetail.province;
            startCity = result.addressDetail.city;
            //NSLog(@"终点地址%@", result.address);
            
            reGeo = 0;
            
            // 判断是否为同城
            if ([startProvince isEqualToString:endProvince] && [startCity isEqualToString:endCity]) {
                
                // 同城规划公交路线
                BMKPlanNode* start = [[BMKPlanNode alloc] init];
                start.pt = (CLLocationCoordinate2D){startLatitude, startLongtitude};
                
                BMKPlanNode* end = [[BMKPlanNode alloc] init];
                end.pt = (CLLocationCoordinate2D){self.endLatitude, self.endLongtitude};
                
                BMKTransitRoutePlanOption *transitRouteSearchOption = [[BMKTransitRoutePlanOption alloc]init];
                transitRouteSearchOption.city = startCity;
                transitRouteSearchOption.from = start;
                transitRouteSearchOption.to = end;
                globalFlag = [_routesearch transitSearch:transitRouteSearchOption];
                
                if(globalFlag) {
                    //NSLog(@"bus检索发送成功");
                }
                else {
                    [self hudWasHidden];
                    //NSLog(@"bus检索发送失败");
                    [self showFailedAlert];
                }
            } else {
                
                // 异地规划驾驶路线
                BMKPlanNode* start = [[BMKPlanNode alloc] init];
                start.pt = (CLLocationCoordinate2D){startLatitude, startLongtitude};
                
                BMKPlanNode* end = [[BMKPlanNode alloc] init];
                end.pt = (CLLocationCoordinate2D){self.endLatitude, self.endLongtitude};
                
                BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
                drivingRouteSearchOption.from = start;
                drivingRouteSearchOption.to = end;
                globalFlag = [_routesearch drivingSearch:drivingRouteSearchOption];
                if (globalFlag) {
                    //NSLog(@"car检索发送成功");
                }
                else {
                    [self hudWasHidden];
                    //NSLog(@"car检索发送失败");
                    [self showFailedAlert];
                }
            }
        } else {
            [self hudWasHidden];
            [self showFailedAlert];
        }
    } else {
        [self hudWasHidden];
        [self showFailedAlert];
    }
}

// MARK: Location
/**
 * 用户位置更新后，会调用此函数
 * @param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    
    startLatitude = userLocation.location.coordinate.latitude;
    startLongtitude = userLocation.location.coordinate.longitude;
    //NSLog(@"latitude: %f", startLatitude);
    //NSLog(@"longitude: %f", startLongtitude);
    [_locService stopUserLocationService];
    
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){startLatitude, startLongtitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    
    globalFlag = [_geocodesearch reverseGeoCode: reverseGeocodeSearchOption];
    if(globalFlag) {
        // 反向编码成功
        //NSLog(@"起点反编码成功");
    } else{
        // 反向编码失败
        [self hudWasHidden];
        //NSLog(@"起点反编码失败");
        [self showFailedAlert];
    }
}

/**
 * 定位失败后，会调用此函数
 * @param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    [self hudWasHidden];
    [self showFailedAlert];
    [_locService stopUserLocationService];
}

// MARK: Route
/**
 * 返回公交搜索结果
 * @param searcher 搜索对象
 * @param result 搜索结果，类型为BMKTransitRouteResult
 * @param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error {
    
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKTransitRouteLine* plan = (BMKTransitRouteLine*)[result.routes objectAtIndex:0];
        [instructions removeAllObjects];
        // 计算路线方案中的路段数目
        long size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKTransitStep* transitStep = [plan.steps objectAtIndex:i];
            //NSLog(@"%@", transitStep.instruction);
            NSString *temp = [NSString stringWithFormat:@"%d. %@", i + 1, transitStep.instruction];
            [instructions addObject: temp];
            if (i == 0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            } else if(i == size - 1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.instruction;
            item.type = 3;
            [_mapView addAnnotation:item];
            
            // 轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKTransitStep* transitStep = [plan.steps objectAtIndex:j];
            int k = 0;
            for(k = 0; k < transitStep.pointsCount; k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        
        [table reloadData];
        [self hudWasHidden];
        
        CLLocationCoordinate2D coordinate; //设定经纬度
        coordinate.latitude = fmin(startLatitude, self.endLatitude) + fabs(startLatitude - self.endLatitude) / 2; //纬度
        coordinate.longitude = fmin(startLongtitude, self.endLongtitude) + fabs(startLongtitude - self.endLongtitude) / 2; //经度
        
//        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(coordinate, BMKCoordinateSpanMake(fabs(startLatitude - self.endLatitude), fabs(startLongtitude - self.endLongtitude)));
        BMKCoordinateRegion viewRegion;
        BMKCoordinateSpan span;
        span.latitudeDelta = fabs(startLatitude - self.endLatitude);
        span.longitudeDelta = fabs(startLongtitude - self.endLongtitude);
        viewRegion.center = coordinate;
        viewRegion.span = span;
        
        BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:adjustedRegion animated:YES];
    } else {
        [self hudWasHidden];
        [self showFailedAlert];
    }
    
}
/**
 * 返回驾乘搜索结果
 * @param searcher 搜索对象
 * @param result 搜索结果，类型为BMKDrivingRouteResult
 * @param error 错误号，@see BMKSearchErrorCode
 * 当为驾乘搜索时，只显示第一条线路
 */
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error {
    
    // 清除原有的标记
    NSArray* array = [NSArray arrayWithArray: _mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray: _mapView.overlays];
    [_mapView removeOverlays:array];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0]; // 选取第一条路线
        [instructions removeAllObjects];
        
        // 计算路线方案中的路段数目
        long size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            //NSLog(@"%@", transitStep.instruction);
            NSString *temp = [NSString stringWithFormat:@"%d. %@", i + 1, transitStep.instruction];
            [instructions addObject: temp];
            if(i == 0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i == size - 1){
                RouteAnnotation* item = [[RouteAnnotation alloc] init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
            }
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        
        [table reloadData];
        [self hudWasHidden];
        
        CLLocationCoordinate2D coordinate; //设定经纬度
        coordinate.latitude = fmin(startLatitude ,self.endLatitude) + fabs(startLatitude - self.endLatitude) / 2; //纬度
        coordinate.longitude = fmin(startLongtitude, self.endLongtitude) + fabs(startLongtitude - self.endLongtitude) / 2; //经度
        
//        BMKCoordinateRegion viewRegion =BMKCoordinateRegionMake(coordinate, BMKCoordinateSpanMake(fabs(startLatitude - self.endLatitude), fabs(startLongtitude - self.endLongtitude)));
        BMKCoordinateRegion viewRegion;
        BMKCoordinateSpan span;
        span.latitudeDelta = fabs(startLatitude - self.endLatitude);
        span.longitudeDelta = fabs(startLongtitude - self.endLongtitude);
        viewRegion.center = coordinate;
        viewRegion.span = span;
        BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:adjustedRegion animated:YES];
    } else {
        [self showFailedAlert];
        [self hudWasHidden];
    }
}
// MARK: Annotation
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation
{
    BMKAnnotationView* view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start@2x.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end@2x.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 2:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus@2x.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 3:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail@2x.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction@2x.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
            
        }
            break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"waypoint_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"waypoint_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_waypoint.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        default:
            break;
    }
    
    return view;
}

- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[RouteAnnotation class]]) { //BMKPointAnnotation
        
        return [self getRouteAnnotationView:view viewForAnnotation:(RouteAnnotation*)annotation];
    } else if ([annotation isKindOfClass:[CustomAnnotation class]]) {
        
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@ "myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES; // 设置该标注点动画显示
        
        [self mapView:view didSelectAnnotationView:newAnnotationView];
        
        return newAnnotationView;
        
    } else if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        
        return [self getPIOAnnotationView:view viewForAnnotation:(RouteAnnotation*)annotation];
    }
    return nil;
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    
    return nil;
}

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView*)getPIOAnnotationView:(BMKMapView *)view viewForAnnotation:(RouteAnnotation*)annotation {
    
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"KyeeMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    [self hudWasHidden];
    return annotationView;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}

// MARK:PIO
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray: _mapView.overlays];
    [_mapView removeOverlays:array];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        
        [instructions removeAllObjects];
        [hospitalName removeAllObjects];
        [hospitalAddr removeAllObjects];
        [customAnnotations removeAllObjects];
        double maxLatitude = 0;
        double maxLongtitude = 0;
        double minLatitude = MAXFLOAT;
        double minLongtitude = MAXFLOAT;
        for (int i = 0; i < result.poiInfoList.count; i++) {
            
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            
            maxLatitude = fmax(maxLatitude, poi.pt.latitude);
            maxLongtitude = fmax(maxLongtitude, poi.pt.longitude);
            minLatitude = fmin(minLatitude, poi.pt.latitude);
            minLongtitude = fmin(minLongtitude, poi.pt.longitude);
            
            NSString *temp = [NSString stringWithFormat:@"%d. %@", i + 1, poi.name];
            [hospitalName addObject: temp];
            [hospitalAddr addObject: poi.address];
            
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc] init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            
            [_mapView addAnnotation:item];
            // 添加入自定义标签组
            [customAnnotations addObject:item];
        }
        
        [table reloadData];
        CLLocationCoordinate2D coordinate; //设定经纬度
        coordinate.latitude = minLatitude + fabs(maxLatitude - minLatitude) / 2; //纬度
        coordinate.longitude = minLongtitude + fabs(maxLongtitude - minLongtitude) / 2; //经度
        
//        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(coordinate, BMKCoordinateSpanMake(fabs(maxLatitude - minLatitude), fabs(maxLongtitude - minLongtitude)));
        BMKCoordinateRegion viewRegion;
        BMKCoordinateSpan span;
        span.latitudeDelta = fabs(startLatitude - self.endLatitude);
        span.longitudeDelta = fabs(startLongtitude - self.endLongtitude);
        viewRegion.center = coordinate;
        viewRegion.span = span;
        BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:adjustedRegion animated:YES];
    } else {
        [self hudWasHidden];
        [self showFailedAlert];
    }
}

// MARK:TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([searchHospitalOrGetRoute.titleLabel.text isEqualToString:@"周边医院"]) {
        return [instructions count];
    } else if ([searchHospitalOrGetRoute.titleLabel.text isEqualToString:@"获取路径"]) {
        return [hospitalName count];
    }
    return [instructions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([searchHospitalOrGetRoute.titleLabel.text isEqualToString:@"周边医院"]) {
        RouteTableViewCell *cell = [[RouteTableViewCell alloc] init];
        if (indexPath.row == 0) {
            cell.headerImg.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
        } else if (indexPath.row == [instructions count] - 1) {
            cell.headerImg.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
        } else {
            cell.headerImg.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/pin_green.png"]];
        }
        
        cell.detailLabel.text = [instructions objectAtIndex: indexPath.row];
        cell.detailLabel.font = [UIFont systemFontOfSize:14];
        return cell;
    } else if ([searchHospitalOrGetRoute.titleLabel.text isEqualToString:@"获取路径"]) {
        SearchTableViewCell *cell = [[SearchTableViewCell alloc] init];
        cell.headerImg.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/pin_red.png"]];
        cell.hospitalName.text = [hospitalName objectAtIndex: indexPath.row];
        cell.hospitalName.font = [UIFont systemFontOfSize:15];
        cell.hospitalAddr.text = [hospitalAddr objectAtIndex: indexPath.row];
        cell.hospitalAddr.font = [UIFont systemFontOfSize:14];
        return cell;
    } else {
        return nil;
    }
}

// MARK:TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([searchHospitalOrGetRoute.titleLabel.text isEqualToString:@"周边医院"]) {
        return 38;
    } else if ([searchHospitalOrGetRoute.titleLabel.text isEqualToString:@"获取路径"]) {
        return 72;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([searchHospitalOrGetRoute.titleLabel.text isEqualToString:@"周边医院"]) {
        [tableView cellForRowAtIndexPath:indexPath].selected = NO;
    } else if ([searchHospitalOrGetRoute.titleLabel.text isEqualToString:@"获取路径"]) {
        if (myAnnotation != nil) {
            [_mapView removeAnnotation: myAnnotation];
        }
        BMKPointAnnotation *currentAnnotation = [customAnnotations objectAtIndex: indexPath.row];
        
        myAnnotation = [[CustomAnnotation alloc] init];
        CLLocationCoordinate2D coor;
        coor.latitude = currentAnnotation.coordinate.latitude;
        coor.longitude = currentAnnotation.coordinate.longitude;
        myAnnotation.coordinate = coor;
        myAnnotation.title = currentAnnotation.title;
        [_mapView addAnnotation: myAnnotation];
    }
}

// MARK: Alert
- (void)showFailedAlert {
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"提示";
    alert.message = @"路径规划失败！";
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

// MARK:HUD
// 显示更新提示框
- (void)showWithGradient {
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    //HUD.dimBackground = YES;
    HUD.labelText = @"正在加载";
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    // [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    [HUD show:YES];
}

// 去除更新提示框
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    if (HUD != nil) {
        [HUD removeFromSuperview];
        HUD = nil;
    }
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)size {
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    //Determine whether the screen is retina
    //if([[UIScreen mainScreen] scale] == 2.0){
        UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    //}else{
        //UIGraphicsBeginImageContext(size);
    //}
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

@end
