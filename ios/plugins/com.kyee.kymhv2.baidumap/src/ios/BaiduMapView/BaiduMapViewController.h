//
//  BaiduMapViewController.h
//  Quyiyuan
//
//  Created by Zhu Xueliang on 15/6/16.
//
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件

#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h> //经纬度相关对象封装
#import <BaiduMapAPI_Search/BMKRouteSearch.h>   //经纬度相关对象封装
#import <BaiduMapAPI_Search/BMKBusLineSearch.h>
#import <BaiduMapAPI_Search/BMKRouteSearch.h> //公交等出行路线规划
#import <BaiduMapAPI_Search/BMKPoiSearch.h>
//#import "BNCoreServices.h"
#import "MBProgressHUD.h"

@interface BaiduMapViewController : UIViewController<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKRouteSearchDelegate, BMKGeoCodeSearchDelegate, BMKPoiSearchDelegate, UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate> {
    
    BMKMapView *_mapView;
    BMKLocationService *_locService;
    BMKRouteSearch* _routesearch;
    BMKGeoCodeSearch* _geocodesearch;
    BMKPoiSearch* _poisearch;
    NSMutableArray *instructions;
    NSMutableArray *hospitalName;
    NSMutableArray *hospitalAddr;
    NSMutableArray *annotations;
    UITableView *table;
    UIButton *hideOrShowButton;
    UIButton *searchHospitalOrGetRoute;
    BOOL hideState;
    MBProgressHUD *HUD;                // 更新提示框
    BOOL globalFlag;
    double _endLatitude;
    double _endLongtitude;
}

@property (nonatomic) double endLatitude;
@property (nonatomic) double endLongtitude;

@end
