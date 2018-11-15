//
//  KyeeBaiduMap.h
//  Quyiyuan
//
//  Created by Zhu Xueliang on 15/6/15.
//
//

#import <Cordova/CDV.h>
//#import <BaiduMapAPI/BMapKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件

#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h> //经纬度相关对象封装
#import <BaiduMapAPI_Search/BMKRouteSearch.h>   //经纬度相关对象封装
#import <BaiduMapAPI_Search/BMKBusLineSearch.h>
#import <BaiduMapAPI_Search/BMKRouteSearch.h> //公交等出行路线规划


@interface KyeeBaiduMap : CDVPlugin <BMKLocationServiceDelegate,BMKOfflineMapDelegate,BMKGeoCodeSearchDelegate,BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate>{
    
}

+ (BOOL)allocBaiduMapAndGetCode;

@end
