//
//  KyeeBaiduMap.m
//  demo
//
//  Created by yuchen on 2018/11/14.
//

#import "KyeeBaiduMap.h"
#import "BaiduLocation.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>

@implementation KyeeBaiduMap{
    BMKLocationManager *_locationManager;
    NSMutableDictionary *_resultMap;
    BaiduLocation *_locationObj;
}

/**
 百度地图鉴权
 
 @param APPKEY appkey
 */
-(void)registerBDKEY{
    _locationObj = [[BaiduLocation alloc]init];
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:@"UWdmLMjGwEjB125vMv7tu7bA5TH2mfK6" authDelegate:self];
}
-(void)onCheckPermissionState:(BMKLocationAuthErrorCode)iError{
    if (iError == -1) {
        NSLog(@"未知错误");
    }else if(iError == 0){
        NSLog(@"鉴权成功");
    }else if (iError == 1){
        NSLog(@"因网络鉴权失败");
    }else if (iError == 2){
        NSLog(@"KEY非法鉴权失败");
    }
}


/**
 获取城市名称
 
 @param command command
 */
- (void)getCityName: (CDVInvokedUrlCommand *)command{
    [self registerBDKEY];
    [_locationObj getCityName:command complete:^(id result, BOOL err) {
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/**
 获取经纬度
 
 @param command command
 */
- (void)getLatitudeAndLongtitude:(CDVInvokedUrlCommand *)command{
    [self registerBDKEY];
    [_locationObj getLatitudeAndLongtitude:command complet:^(id result, BOOL err) {
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}


/**
 展示地图
 
 @param command command
 */
- (void)showMap: (CDVInvokedUrlCommand *)command{
    [self registerBDKEY];
//    NSString *longtitude = [command.arguments objectAtIndex:0];
//    NSString *latitude = [command.arguments objectAtIndex:1];
    [_locationObj ChooseTheWayToNavigation:@"116.39852" :@"39.926224" :command];
    
}

- (void)ChooseTheWayToNavigation:(NSString *)longtitudeEnd :(NSString *)latitudeEnd :(CDVInvokedUrlCommand *)command{

}


/**
 获取城市编码
 
 @param command command
 */
- (void)getCityCode:(CDVInvokedUrlCommand *)command{
    [self registerBDKEY];
    [_locationObj getCityCode:command complete:^(id result, BOOL err) {
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
    
}


@end
