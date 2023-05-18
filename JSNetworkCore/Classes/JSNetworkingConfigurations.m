//
//  JSNetworkingConfigurations.m
//  JSNetworking
//

#import "JSNetworkingConfigurations.h"
#import <AFNetworking/AFNetworking.h>

#define JSNetworkStatusChangeNotification @"SMNetworkStatusChangeNotification"

@interface JSNetworkingConfigurations ()

@property (nonatomic, strong, readwrite) NSString* baseUrl;

@property(strong,nonatomic,readwrite) dispatch_semaphore_t semap;

@end

@implementation JSNetworkingConfigurations

+ (instancetype)sharedInstance
{
    static JSNetworkingConfigurations *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JSNetworkingConfigurations alloc] init];
        sharedInstance.apiNetworkingTimeoutSeconds = 20.0f;
        sharedInstance.cacheOutdateTimeSeconds = 600;
        sharedInstance.cacheCountLimit = 1000*3;
        sharedInstance.baseUrl = @"";
        sharedInstance.enableSSL = NO;
        sharedInstance.semap = dispatch_semaphore_create(1);
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        //简单网络监听，ip变化
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:
                    [[NSNotificationCenter defaultCenter] postNotificationName:JSNetworkStatusChangeNotification object:nil userInfo:@{@"status":@(AFNetworkReachabilityStatusNotReachable)}];
                    sharedInstance.networkStatus = JSNetworkNotReach;
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    [[NSNotificationCenter defaultCenter] postNotificationName:JSNetworkStatusChangeNotification object:nil userInfo:@{@"status":@(AFNetworkReachabilityStatusReachableViaWWAN)}];
                    sharedInstance.networkStatus = JSNetworkWWAN;
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    [[NSNotificationCenter defaultCenter] postNotificationName:JSNetworkStatusChangeNotification object:nil userInfo:@{@"status":@(AFNetworkReachabilityStatusReachableViaWiFi)}];
                    sharedInstance.networkStatus = JSNetworkWIFI;
                    break;
                case AFNetworkReachabilityStatusUnknown:
                    sharedInstance.networkStatus = JSNetworkUnKnow;
                    break;
                default:
                    break;
            }
        }];
    });
    return sharedInstance;
}

- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

-(NSString*)generatorUrlStr:(NSString*)methodName
{
    return [NSString stringWithFormat:@"%@%@",self.baseUrl,methodName];
}

-(void)registerDomain:(NSString*)baseUrl
{
    self.baseUrl = baseUrl;
}

-(void)registerConfigurationsDelegate:(NSString*)ClassName
{
    Class class = NSClassFromString(ClassName);
    if(class){
        id obj = [[class alloc]init];
        if ([obj conformsToProtocol:@protocol(HTJSNetworkingConfigurationDelegate)]) {
            self.delegate = (id <HTJSNetworkingConfigurationDelegate>)obj;
        } else {
            NSException *exception = [[NSException alloc] initWithName:@"JSNetworkingBaseManager提示" reason:[NSString stringWithFormat:@"%@没有遵循JSNetworkingConfigurationDelegate协议",obj] userInfo:nil];
            @throw exception;
        }
    }
}

-(void)registerCustomHttpHeader:(NSDictionary*)httpHeaders
{
    self.httpHeaders = httpHeaders;
}

-(void)setMaxConcurrentCount:(NSInteger)maxConcurrentCount
{
    if(maxConcurrentCount>0){
        _maxConcurrentCount = maxConcurrentCount;
        _semap = dispatch_semaphore_create(maxConcurrentCount);
    }
}

@end
