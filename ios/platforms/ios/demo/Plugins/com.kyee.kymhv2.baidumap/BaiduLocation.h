//
//  BaiduLocation.h
//  demo
//
//  Created by yuchen on 2018/11/14.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <MapKit/MapKit.h>



typedef void(^complete)(id result,BOOL success);
@interface BaiduLocation : CDVPlugin<BMKLocationManagerDelegate,BMKGeoCodeSearchDelegate>


/**
 获取经纬度

 @param command command description
 */
- (void)getLatitudeAndLongtitude:(CDVInvokedUrlCommand *)command complet:(complete)com;


/**
 获取城市名字

 @param command command description
 */
- (void)getCityName: (CDVInvokedUrlCommand *)command complete:(complete)com;

/// 获取城市编码
- (void)getCityCode:(CDVInvokedUrlCommand *)command complete:(complete)com;


/**
 导航

 @param longtitudeEnd longtitudeEnd description
 @param latitudeEnd latitudeEnd description
 @param command command description
 */
- (void)ChooseTheWayToNavigation:(NSString *)longtitudeEnd :(NSString *)latitudeEnd :(CDVInvokedUrlCommand *)command;

@end
