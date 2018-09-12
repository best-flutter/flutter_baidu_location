#import "BaiduLocationPlugin.h"


#import <BMKLocationkit/BMKLocation.h>

#import <BMKLocationkit/BMKLocationComponent.h>
#import <BMKLocationkit/BMKLocationAuth.h>

@interface BaiduLocationPlugin()<BMKLocationAuthDelegate,BMKLocationManagerDelegate>
{
    BMKLocationManager *_locationManager;
}
@property (nonatomic,copy,readwrite) FlutterResult result;

@end

@implementation BaiduLocationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"baidu_location"
            binaryMessenger:[registrar messenger]];
  BaiduLocationPlugin* instance = [[BaiduLocationPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

-(void)initBaidu{
    //初始化实例
    _locationManager = [[BMKLocationManager alloc] init];
    //设置delegate
    _locationManager.delegate = self;
    //设置返回位置的坐标系类型
    _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    //设置距离过滤参数
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    //设置预期精度参数
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //设置应用位置类型
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    //设置是否自动停止位置更新
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    //设置是否允许后台定位,这个参数如果设置true，那么需要特别的 苹果审核,一般应用不用开启
    //_locationManager.allowsBackgroundLocationUpdates = YES;
    //设置位置获取超时时间
    _locationManager.locationTimeout = 10;
    //设置获取地址信息超时时间
    _locationManager.reGeocodeTimeout = 10;
    
}

-(NSDictionary*)location2map:(BMKLocation*)location state:(BMKLocationNetworkState) state{
    
     BMKLocationReGeocode* rgcData = location.rgcData;
    
    return @{
            //@"locationID":location.locationID,
             @"state":@(state),
             @"latitude":@(location.location.coordinate.latitude),
             @"longitude":@(location.location.coordinate.longitude),
            @"altitude":@(location.location.altitude),
             
             @"country":rgcData.country,
              @"countryCode":rgcData.countryCode,
             
             @"province":rgcData.province,
             
             @"city":rgcData.city,
              @"cityCode":rgcData.cityCode,
             
             @"district":rgcData.district,
             
            
            
             @"street":rgcData.street,
             @"streetNumber":rgcData.streetNumber,
             
             @"adCode":rgcData.adCode,
             
             @"locationDescribe":rgcData.locationDescribe,
             
             };
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* method = call.method;
    @synchronized(self){
        if ([@"setKey" isEqualToString:method]) {
            NSString* key = call.arguments;
            [[BMKLocationAuth sharedInstance] checkPermisionWithKey:key authDelegate:self];
            self.result = result;
            //result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
        } else if([@"getLocation" isEqualToString:method]){
            [self initBaidu];
            [_locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
                
                if(error){
                    result(@{
                             @"error" : @{
                                     @"code":@(error.code),
                                     @"domain":error.domain,
                                     @"userInfo":error.userInfo
                                     }
                             });
                }else{
                    if (location){
                        
                        result([self location2map:location state:state]);
                        
                    }else{
                        
                        result(@{
                                 @"error" : @{
                                          @"code":@"null",
                                         @"domain":@"null",
                                         
                                         }
                                 });
                        
                    }
                }
                
            }];
            
        } else {
            result(FlutterMethodNotImplemented);
        }
    }
  
}


#pragma BMKLocationAuthDelegate

/**
 *@brief 返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKLocationAuthErrorCode
 */
- (void)onCheckPermissionState:(BMKLocationAuthErrorCode)iError{
    if(self.result!=nil){
        self.result( @(iError == 0 ? YES : NO) );
        self.result = nil;
    }
   
}

@end
