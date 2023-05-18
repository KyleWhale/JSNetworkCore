//
//  JSNetworkingConfigurations.h
//  JSNetworking
//

#import <Foundation/Foundation.h>
#import "JSNetworkingBaseManager.h"

typedef enum : NSUInteger {
    JSNetworkUnKnow,
    JSNetworkNotReach,
    JSNetworkWIFI,
    JSNetworkWWAN,
} JSNetworkingStatus;

@class JSNetworkingBaseManager;
/*********************************************************************
 *  网络请求返回参数验证代理
 *********************************************************************/
/*! 网络请求返回参数验证代理函数 */
@protocol HTJSNetworkingConfigurationDelegate <NSObject>
@required
/*!
 @brief 验证返回的参数是否符合具体项目的一个正确response
 
 @discussion 方法需要对params做一个api是否成功的验证
 
 @param manager 具体发起api的manager
 @param params  api返回参数
 @return 是否符合预期的返回
 */
-(BOOL)manager:(JSNetworkingBaseManager*)manager isCorrectWithResponse:(NSDictionary*)params;
-(void)networkError:(JSNetworkingBaseManager*)manager;
/*!
 @brief 获取用于发送API的token
 @return 用户token
 */
-(NSString*)getCurrentUserToken;
@optional
/*!
 @brief 开启SSL验证
 @discussion 如果未注册全局SSL代理方法配置，则关闭SSL验证
 @return ssl证书名称
 */
-(NSString*)getSSLName;
@end

@interface JSNetworkingConfigurations : NSObject

+ (instancetype)sharedInstance;
/*! 当前手机网络是否可用判断 */
@property (nonatomic, assign, readonly) BOOL isReachable;
/*! 是否开启ssl验证，如果开启必须实现<getSSLName>代理方法 */
@property (nonatomic, assign) BOOL enableSSL;
/*! 全局网络请求超时设定 */
@property (nonatomic, assign) NSTimeInterval apiNetworkingTimeoutSeconds;
/*! 缓存过期时间，单位秒 */
@property (nonatomic, assign) NSTimeInterval cacheOutdateTimeSeconds;
/*! 缓存最大数量 */
@property (nonatomic, assign) NSInteger cacheCountLimit;
/*! 全局api的host地址 */
@property (nonatomic, strong, readonly) NSString* baseUrl;
/*! 外挂的全局response验证和token获取代理，如果有注册则调用代理方法，如果没有则默认访问成功，不对response做验证 */
@property (nonatomic, strong) id<HTJSNetworkingConfigurationDelegate> delegate;
/*! 全局的httpheader设置，就以当前里面的Kev-Value对Header做追加*/
@property(copy,nonatomic) NSDictionary* httpHeaders;
/*!<#Description#>*/
@property(assign,nonatomic) JSNetworkingStatus networkStatus;
/*!控制上传图片并发数*/
@property(strong,nonatomic,readonly) dispatch_semaphore_t semap;
/*!最大并发数量,默认为1，目前只对上传图片生效*/
@property(assign,nonatomic) NSInteger maxConcurrentCount;
/*!
 @brief 生成具体的api url字符串
 @discussion 生成规则   baseUrl+methodName
 @param methodName 访问的action
 @return 拼接完整的url
 */
-(NSString*)generatorUrlStr:(NSString*)methodName;
/*!
 @brief 注册api域名domain   如：https://api.shipindiy.com/
 @param baseUrl 如：https://api.shipindiy.com/
 */
-(void)registerDomain:(NSString*)baseUrl;
/*!
 @brief 全局外挂对response的验证，比如项目中只有返回的status_code == 1才算一个正确的网络请求，需要在<JSNetworkingConfigurationDelegate>代理具体编写逻辑
 @param ClassName 外挂的类名
 */
-(void)registerConfigurationsDelegate:(NSString*)ClassName;
/*!
 @brief 全局http头设置
 @remark  有一点需要特别强调一下，关于token：如果token变更需要通知到api
 @param httpHeaders 具体http headers key-value参数
 */
-(void)registerCustomHttpHeader:(NSDictionary*)httpHeaders;


@end
