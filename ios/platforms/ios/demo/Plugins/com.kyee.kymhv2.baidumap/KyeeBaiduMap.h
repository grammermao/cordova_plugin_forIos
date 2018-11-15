//
//  KyeeBaiduMap.h
//  demo
//
//  Created by yuchen on 2018/11/14.
//

#import <Cordova/CDV.h>
#import <BMKLocationkit/BMKLocationComponent.h>

@interface KyeeBaiduMap : CDVPlugin<BMKLocationAuthDelegate,BMKLocationManagerDelegate>


/// 获取城市名称
- (void)getCityName: (CDVInvokedUrlCommand *)command;

/// 获取经纬度
- (void)getLatitudeAndLongtitude:(CDVInvokedUrlCommand *)command;

/// 展示地图
- (void)showMap: (CDVInvokedUrlCommand *)command;

/// 获取城市编码
- (void)getCityCode:(CDVInvokedUrlCommand *)command;


@end
