//
//  BaiduLocation.m
//  demo
//
//  Created by yuchen on 2018/11/14.
//

#import "BaiduLocation.h"
#import "AppDelegate.h"


BOOL getCityName = NO;
BOOL getLaandeLon = NO;
BOOL getCityCode = NO;

@implementation BaiduLocation{
    BMKLocationManager *_locationManager;
    NSMutableDictionary *_resultMap;
    BMKGeoCodeSearch *_searcher;
    CDVInvokedUrlCommand *_command;
    BMKReverseGeoCodeSearchOption *_reverseGeoCodeSearchOption;
    complete _com;
}

-(void)getLatitudeAndLongtitude:(CDVInvokedUrlCommand *)command complet:(complete)com{
    getLaandeLon = YES;
    _com = com;
    [self startLcation:command];
}

- (void)getCityCode:(CDVInvokedUrlCommand *)command complete:(complete)com{
    getCityCode = YES;
    _com = com;
    [self startLcation:command];
}

-(void)getCityName:(CDVInvokedUrlCommand *)command complete:(complete)com{
    getCityName = YES;
    _com = com;
    [self startLcation:command];
}


-(void)startLcation:(CDVInvokedUrlCommand*)command{
    _command = command;
    _locationManager = [[BMKLocationManager alloc] init];
    _locationManager.delegate = self;
    //    _searcher = [[BMKGeoCodeSearch alloc]init];
    //    _searcher.delegate = self;
    
    _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    _locationManager.locationTimeout = 4;
    _locationManager.reGeocodeTimeout = 10;
    [_locationManager setLocatingWithReGeocode:YES];
    [_locationManager startUpdatingLocation];
}


#pragma mark ----delegate

/**
 代理方法
 
 @param manager manager description
 @param location location description
 @param error error description
 */
-(void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error{
    CDVPluginResult *result;
    if (error) {
        NSLog(@"定位发生错误：%@",error);
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"定位发生错误"];
        _com(result,NO);
    }else{
        [self freeStick];
        if (getCityName) {
            getCityName = NO;
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:location.rgcData.city];
            _com(result,YES);
        }else if (getLaandeLon) {
            getLaandeLon = NO;
            _resultMap = [NSMutableDictionary dictionaryWithCapacity:10];
            [_resultMap setObject:[NSNumber numberWithFloat:location.location.coordinate.latitude] forKey:@"Latitude"];
            [_resultMap setObject:[NSNumber numberWithFloat:location.location.coordinate.longitude] forKey:@"Longtitude"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",location.location.coordinate.latitude] forKey:@"lan"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",location.location.coordinate.longitude] forKey:@"long"];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_resultMap];
            _com(result,YES);
        }else if(getCityCode){
            [self getCityCodeFunctiom:location];
            return;
        }
        
    }
}

#pragma mark ----
-(void)getCityCodeFunctiom:(BMKLocation *)location {
    CDVPluginResult *pluginResult;
    NSString *addressD = [NSString stringWithFormat:@"%@%@%@%@%@",location.rgcData.province,location.rgcData.city,location.rgcData.district,location.rgcData.street,location.rgcData.streetNumber];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
    [result setValue:location.rgcData.district forKey:@"district"];
    [result setValue:location.rgcData.city forKey:@"city"];
    [result setValue:location.rgcData.country forKey:@"country"];
    [result setValue:location.rgcData.street forKey:@"streetName"];
    [result setValue:location.rgcData.cityCode forKey:@"cityCode"];
    [result setValue:addressD forKey:@"addressDetail"];
    [result setValue:location.rgcData.countryCode forKey:@"countryCode"];
    [result setValue:location.rgcData.streetNumber forKey:@"streetNumber"];
    [result setValue:location.rgcData.province forKey:@"province"];
    
    //    BMKOfflineMap *offMap = [[BMKOfflineMap alloc]init];
    //    NSArray *provinceRecords = [offMap searchCity:@"西安市"];
    //
    //    if ( provinceRecords.count !=0) {
    //        BMKOLSearchRecord* provinceOneRecord = [provinceRecords objectAtIndex:0];
    //        int provinceCode = provinceOneRecord.cityID;
    //        [result setValue:@(provinceCode) forKey:@"provinceCode"];
    //    }else {
    //        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"获取城市信息失败"];
    //        _com(pluginResult,NO);
    //        return;
    //    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    _com(pluginResult,YES);
    //    [result setValue:location.rgcData.addr forKey:@""];
    
}

/**
 代理方法
 
 @param searcher searcher description
 @param result result description
 @param error error description
 */
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error{
    CDVPluginResult *pluginResult;
    if (getCityName==YES) {
        if (error==0) {
            getCityName = NO;
            [_resultMap setObject:result.address forKey:@"address"];
            NSLog(@"%@",result.addressDetail);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_resultMap];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
        }else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"获取城市名字失败"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
        }
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_resultMap];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
    }
    [_locationManager stopUpdatingLocation];
    [self freeStick];
}

-(void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error{
    NSLog(@"ghj");
}

/**
 方式内存泄漏
 */
-(void)freeStick{
    _locationManager.delegate = nil;
    _searcher.delegate = nil;
    _searcher  = nil;
    _locationManager = nil;
    _reverseGeoCodeSearchOption = nil;
}

-(void)ChooseTheWayToNavigation:(NSString *)longtitudeEnd :(NSString *)latitudeEnd :(CDVInvokedUrlCommand *)command{
    
    NSString *lan = [[NSUserDefaults standardUserDefaults]objectForKey:@"lan"];
    NSString *lon  = [[NSUserDefaults standardUserDefaults]objectForKey:@"long"];
    
    NSString *requestGaode = [[NSString stringWithFormat: @"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=%@&slon=%@&sname=%@&did=BGVIS2&dlat=%@&dlon=%@&dname=%@&dev=0&m=0&t=0", lan,lon, @"我的位置", latitudeEnd, longtitudeEnd, @"终点"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *requestBaidu = [[NSString stringWithFormat: @"baidumap://map/direction?origin=latlng:%@,%@|name:我的位置&destination=latlng:%@,%@|name:终点&mode=driving",lan,lon,latitudeEnd,longtitudeEnd] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *urlString = [[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@,%@&saddr=slat,slng",longtitudeEnd,latitudeEnd] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    
    NSMutableArray *wayMArr = [NSMutableArray array];
    [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"baidumap://"]] ? [wayMArr addObject: @"百度地图"] : nil;
    [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"iosamap://"]]  ? [wayMArr addObject: @"高德地图"] : nil;
    [wayMArr addObject: @"苹果自带地图"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"请选择导航方式" message: @"请确保打开定位功能并授权对应APP使用位置信息" preferredStyle: UIAlertControllerStyleActionSheet];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    UIAlertAction *actionBaidu = [UIAlertAction actionWithTitle: @"百度地图" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: requestBaidu]];
    }];
    UIAlertAction *actionGaode = [UIAlertAction actionWithTitle: @"高德地图" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: requestGaode]];
    }];
    UIAlertAction *actionApple = [UIAlertAction actionWithTitle: @"苹果自带地图" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated: YES completion: nil];
    }];
    
    if (wayMArr.count == 2){
        if ([wayMArr containsObject:@"百度地图"]) {
            [alertController addAction:actionBaidu];
        }else {
            [alertController addAction:actionGaode];
        }
    }else{
        [alertController addAction: actionBaidu];
        [alertController addAction: actionGaode];
    }
    [alertController addAction:actionApple];
    [alertController addAction: actionCancel];
    [delegate.window.rootViewController presentViewController: alertController animated: YES completion: nil];
}

@end
