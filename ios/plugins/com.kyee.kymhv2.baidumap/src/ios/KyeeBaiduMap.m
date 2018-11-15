//
//  KyeeBaiduMap.m
//  Quyiyuan
//
//  Created by Zhu Xueliang on 15/6/15.
//
//

#import "KyeeBaiduMap.h"
#import "AppDelegate.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import "BaiduMapViewController.h"

#import <BaiduMapAPI_Map/BMKMapView.h>//ĺŞĺźĺ
Ľćéçĺä¸Şĺ¤´ćäťś

@interface KyeeBaiduMap()

@property (nonatomic,strong) BMKRouteSearch *routeSearch;


@end

@implementation KyeeBaiduMap

CDVInvokedUrlCommand *commandCallback;
BMKOfflineMap        *_offlineMap;
BMKLocationService   *_locService;
BMKGeoCodeSearch     *_geocodesearch;
NSMutableDictionary  *geoDicM;
BOOL isAcquireLatitude;
BOOL isGetCityCode;
BMKMapManager* _mapManager;

NSInteger cityCode;     //äżĺ­ĺĺ¸code
NSInteger provinceCode; //äżĺ­ĺĺ¸çäť˝code
//BMKRouteSearch *routeSearch;


double latitude;
double longtitude;

+ (BOOL)allocBaiduMapAndGetCode{
    
    // çžĺşŚĺ°ĺžĺźĺ
    Ľ
    _mapManager = [[BMKMapManager alloc]init];
    BOOL isYes = [_mapManager start: @"cZdyKWbXcoE6z7EHmlPz92py"  generalDelegate:nil];
    return  isYes;
}

- (void)getCityName: (CDVInvokedUrlCommand *)command {
    
    //    [self pathPlanning];
    
    commandCallback = command;
    
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];
    _geocodesearch.delegate = self;
    
    //    //ĺĺ§ĺBMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    
    //    //ĺŻĺ¨LocationService
    [_locService startUserLocationService];
    
}


/**
 *ć šćŽĺ°ĺĺç§°čˇĺĺ°çäżĄćŻ
 *ĺźć­Ľĺ˝ć°ďźčżĺçťćĺ¨BMKGeoCodeSearchDelegateçonGetAddrResultéçĽ
 *@param geoCodeOption       geoćŁç´˘äżĄćŻçąť
 *@return ćĺčżĺYESďźĺŚĺčżĺNO
 */
- (BOOL)geoCode:(BMKGeoCodeSearchOption*)geoCodeOption{
    
    return nil;
}

/**
 *ć šćŽĺ°çĺć čˇĺĺ°ĺäżĄćŻ
 *ĺźć­Ľĺ˝ć°ďźčżĺçťćĺ¨BMKGeoCodeSearchDelegateçonGetAddrResultéçĽ
 *@param reverseGeoCodeOption ĺgeoćŁç´˘äżĄćŻçąť
 *@return ćĺčżĺYESďźĺŚĺčżĺNO
 */
- (BOOL)reverseGeoCode:(BMKReverseGeoCodeOption*)reverseGeoCodeOption{
    
    return nil;
}




//ĺ¤çä˝ç˝Žĺć ć´ć°
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
    
    latitude = userLocation.location.coordinate.latitude;
    longtitude = userLocation.location.coordinate.longitude;
    
    geoDicM = [NSMutableDictionary dictionary];
    [geoDicM setObject: [NSNumber numberWithDouble: latitude] forKey: @"Latitude"];
    [geoDicM setObject: [NSNumber numberWithDouble: longtitude] forKey: @"Longtitude"];
    
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    
    
    BOOL flag = [_geocodesearch reverseGeoCode: reverseGeocodeSearchOption];
    if(flag) {
        
        // ĺĺçźç ćĺ
        [_locService stopUserLocationService];
        _locService.delegate = nil;
        _locService = nil;
    }
    else{
        
        // ĺĺçźç ĺ¤ąč´Ľ
        _locService.delegate = nil;
        _geocodesearch.delegate = nil;
        _locService = nil;
        _geocodesearch = nil;
    }
}



/**
 *čżĺĺ°ĺäżĄćŻćç´˘çťć
 *@param searcher ćç´˘ĺŻščąĄ
 *@param result ćç´˘çťBMKGeoCodeSearchć
 *@param error éčŻŻĺˇďź@see BMKSearchErrorCode
 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    
}

/**
 *čżĺĺĺ°ççźç ćç´˘çťć
 *@param searcher ćç´˘ĺŻščąĄ
 *@param result ćç´˘çťć
 *@param error éčŻŻĺˇďź@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    CDVPluginResult *pluginResult;
    
    if (error == 0) {
        
        BMKAddressComponent *addDetail = result.addressDetail ;
        if (isGetCityCode) { //ĺ¤ć­ćŻĺŚä¸şčˇĺĺĺ¸çźç 
            
            isGetCityCode = NO;
            [self gitCityCodeFountion: result];
        }
        
        //ĺ¤ć­ćŻĺŚä¸şćĺ¨č§Śĺâćžéčżçĺťé˘âĺč˝ćéŽ
        if (isAcquireLatitude) {
            
            isAcquireLatitude = NO;
            [geoDicM setObject: result.address forKey: @"address"];
            NSDictionary *dic = geoDicM;
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: dic];
            [self.commandDelegate sendPluginResult: pluginResult callbackId: commandCallback.callbackId];
            return;
        }
        
        if ([addDetail.district isEqualToString: addDetail.city]) {
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: addDetail.district];
        }else {
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: addDetail.city];
        }
        NSLog(@"--------");
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:commandCallback.callbackId];
    }else {
        
        
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"ĺŽä˝ĺşç°éčŻŻ"];
        [self.commandDelegate sendPluginResult: pluginResult callbackId: commandCallback.callbackId];
    }
}

- (void)getLatitudeAndLongtitude:(CDVInvokedUrlCommand *)command {
    
    isAcquireLatitude = YES;
    commandCallback = command;
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];
    _geocodesearch.delegate = self;
    
    //ĺĺ§ĺBMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //ĺŻĺ¨LocationService
    [_locService startUserLocationService];
    
}

//ĺŻźčŞĺč˝ćšćł
- (void)showMap: (CDVInvokedUrlCommand *)command {
    // ĺ¤ć­äź ĺ
    Ľĺć°ćŻĺŚä¸ş2ä¸Ş
    if ([command.arguments count] != 2) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    // ĺ¤ć­äź ĺ
    Ľĺć°ćŻĺŚçŠş
    NSString *longtitude = [command.arguments objectAtIndex:0];
    NSString *latitude = [command.arguments objectAtIndex:1];
    
    
    // čˇĺä¸ťč§ĺž
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    BaiduMapViewController *vc = [[BaiduMapViewController alloc] initWithNibName:@"BaiduMapView" bundle:nil];
    vc.endLatitude = [latitude doubleValue];
    vc.endLongtitude = [longtitude doubleValue];
    
    if (vc.endLongtitude == 0 || vc.endLatitude == 0) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        vc = nil;
        return;
    }
    
    [delegate.viewController presentViewController:vc animated:YES completion:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getCityCode:(CDVInvokedUrlCommand *)command {
    
    commandCallback = command;
    isGetCityCode = YES;
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];
    _geocodesearch.delegate = self;
    
    //    //ĺĺ§ĺBMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    
    //    //ĺŻĺ¨LocationService
    [_locService startUserLocationService];
}

- (void)gitCityCodeFountion:(BMKReverseGeoCodeResult *)result {
    
    CDVPluginResult *pluginResult;
    
    if (!_offlineMap) {
        
        _offlineMap = [[BMKOfflineMap alloc] init];
    }
    BMKAddressComponent *addDetail = result.addressDetail ;
    NSArray *provinceRecords = [_offlineMap searchCity: addDetail.province? addDetail.province:nil];
    NSArray *cityRecords = [_offlineMap searchCity: addDetail.city? addDetail.city:nil];
    
    if (cityRecords.count != 0 && provinceRecords.count !=0) {
        
        BMKOLSearchRecord* oneRecord = [cityRecords objectAtIndex:0];
        cityCode = oneRecord.cityID;
        BMKOLSearchRecord* provinceOneRecord = [provinceRecords objectAtIndex:0];
        provinceCode = provinceOneRecord.cityID;
    }else {
        
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"ĺ°ĺşcodečˇĺĺşç°éŽé˘"];
        [self.commandDelegate sendPluginResult: pluginResult callbackId: commandCallback.callbackId];
    }
    
    NSMutableDictionary *addrsDetaliDic = [ToolClass getObjectData: addDetail];
    [addrsDetaliDic setObject: [NSNumber numberWithInteger: cityCode] ? [NSNumber numberWithInteger: cityCode] : [NSNull null] forKey: @"cityCode"];
    [addrsDetaliDic setObject: [NSNumber numberWithInteger: provinceCode] ? [NSNumber numberWithInteger: provinceCode] : [NSNull null] forKey: @"provinceCode"];
    [addrsDetaliDic setObject: result.address? result.address : [NSNull null] forKey: @"addressDetail"];
    NSString *jsonStr = [ToolClass changeObjToJSON: addrsDetaliDic];
    pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: addrsDetaliDic];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: commandCallback.callbackId];
    NSLog(@"%@",jsonStr);
}

//#pragma mark --- ĺ
Źäş¤ç­čˇŻĺžč§ĺćšćłĺäťŁç
//- (void)pathPlanning {
//
//    self.routeSearch = [[BMKRouteSearch alloc] init];
//    self.routeSearch.delegate = self;
//    //ćé ĺ
Źĺ
ąäş¤éčˇŻçşżč§ĺćŁç´˘äżĄćŻçąť
//    BMKPlanNode* start = [[BMKPlanNode alloc]init];
//    start.name = @"éćĽź";
//
//    BMKPlanNode* end = [[BMKPlanNode alloc]init];
//    end.name = @"ĺçŞĺ¤´";
//
//    BMKMassTransitRoutePlanOption *option = [[BMKMassTransitRoutePlanOption alloc]init];
//    option.from = start;
//    option.to = end;
//
//
//
//    //ĺčľˇćŁç´˘
//    //    BOOL flag = [routeSearch transitSearch:option];
//    BMKTransitRoutePlanOption *optionTransit = [[BMKTransitRoutePlanOption alloc] init];
//    optionTransit.city = @"čĽżĺŽĺ¸";
//    optionTransit.from = start;
//    optionTransit.to = end;
//
//
//
//
//    BMKDrivingRoutePlanOption *drivingOption = [[BMKDrivingRoutePlanOption alloc] init];
//    drivingOption.from = start;
//    drivingOption.to = end;
//
//    [self.routeSearch transitSearch: optionTransit];
//    //    [self.routeSearch drivingSearch: drivingOption];
//
//    //    [routeSearch drivingSearch:option];
//    //    if(flag) {
//    //        NSLog(@"ĺ
Źäş¤äş¤éćŁç´˘ďźćŻćĺŽĺďźĺéćĺ");
//    //
//    //    } else {
//    //        NSLog(@"ĺ
Źäş¤äş¤éćŁç´˘ďźćŻćĺŽĺďźĺéĺ¤ąč´Ľ");
//    //    }
//
//
//}
//
//
//
//
//#pragma mark --- ĺŻźčŞç­ćšćłĺäťŁç
//- (void)startNavi
//{
//    //čçšć°çť
//    NSMutableArray *nodesArray = [[NSMutableArray alloc]    initWithCapacity:2];
//
//    //čľˇçš
//    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
//    startNode.pos = [[BNPosition alloc] init];
//    startNode.pos.x = 113.936392;
//    startNode.pos.y = 22.547058;
//    startNode.pos.eType = BNCoordinate_BaiduMapSDK;
//    [nodesArray addObject:startNode];
//
//    //çťçš
//    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
//    endNode.pos = [[BNPosition alloc] init];
//    endNode.pos.x = 114.077075;
//    endNode.pos.y = 22.543634;
//    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
//    [nodesArray addObject:endNode];
//    //ĺčľˇčˇŻĺžč§ĺ
//    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
//}
//
////çŽčˇŻćĺĺďźĺ¨ĺč°ĺ˝ć°ä¸­ĺčľˇĺŻźčŞďźĺŚä¸ďź
////çŽčˇŻćĺĺč°
//-(void)routePlanDidFinished:(NSDictionary *)userInfo
//{
//    NSLog(@"çŽčˇŻćĺ");
//
//    //čˇŻĺžč§ĺćĺďźĺźĺ§ĺŻźčŞ
//    [BNCoreServices_UI showPage:BNaviUI_NormalNavi delegate:self extParams:nil];
//}

@end
