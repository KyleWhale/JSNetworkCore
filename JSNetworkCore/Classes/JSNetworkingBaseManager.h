//
//  JSNetworkingBaseManager.h
//  JSNetworking
//
//  Created by yky on 2017/9/26.
//

#import <Foundation/Foundation.h>
#import "JSNetworkingConfigurations.h"
#import "JSResponse.h"
static NSString * const JSNetworkingRequestID = @"JSNetworkingRequestID";

@class JSNetworkingBaseManager;
/*********************************************************************
 *  网络请求成功回调代理
 *********************************************************************/
/*! 网络请求代理回调，必须实现 */
@protocol JSNetworkingCallBackDelegate<NSObject>
@required
/*!
 @brief 网络请求成功回调代理函数
 @param manager JSNetworkingBaseManager
 */
-(void)callAPIDidSuccess:(JSNetworkingBaseManager*)manager;
/*!
 @brief 网络请求失败回调代理函数
 @param manager JSNetworkingBaseManager
 */
-(void)callAPIDidFail:(JSNetworkingBaseManager*)manager;

@end

/*********************************************************************
 *  网络请求参数代理
 *********************************************************************/
/*! 网络请求request 参数代理函数*/
@protocol JSNetworkingRequestParamsDelegate <NSObject>
@required
/*! 网络请求的参数代理，必须实现对应API的request参数,如果是普通的请求，返回NSDictionary,如果是上传图片请返回NSData */
-(id)requestParamsDelegate:(JSNetworkingBaseManager*)manager;
@end

/*********************************************************************
 *  网络请求request参数验证代理
 *********************************************************************/
/*! 网络请求参数验证代理函数 */
@protocol JSNetworkingRequestParamsValidatorDelegate <NSObject>
@required
-(BOOL)manager:(JSNetworkingBaseManager*)manager isCorrectWithParams:(NSDictionary*)params;
@end

/*********************************************************************
 *  网络请求前后拦截器
 *********************************************************************/
@protocol JSNetworkingManagerInterceptor <NSObject>
@optional
- (BOOL)manager:(JSNetworkingBaseManager *)manager beforePerformSuccessWithResponse:(JSResponse *)response;
- (void)manager:(JSNetworkingBaseManager *)manager afterPerformSuccessWithResponse:(JSResponse *)response;

- (BOOL)manager:(JSNetworkingBaseManager *)manager beforePerformFailWithResponse:(JSResponse *)response;
- (void)manager:(JSNetworkingBaseManager *)manager afterPerformFailWithResponse:(JSResponse *)response;

- (BOOL)manager:(JSNetworkingBaseManager *)manager shouldCallAPIWithParams:(NSDictionary *)params;
- (void)manager:(JSNetworkingBaseManager *)manager afterCallingAPIWithParams:(NSDictionary *)params;
@end

/*! 网络请求类型：get,post */
typedef NS_ENUM(NSUInteger, JSNetworkingRequestType)
{
    JSNetworkingRequestTypeGet,
    JSNetworkingRequestTypePost,
    JSNetworkingRequestTypeUpload,//图片
    JSNetworkingRequestTypeUploadFile,//文件
};

/*! 网络请求返回结果状态 */
typedef NS_ENUM(NSUInteger, JSNetworkingStatusType)
{
    /*! 默认类型，还没有发送网络请求 */
    JSNetworkingStatusTypeDefault,
    /*! 网络请求结果正确 */
    JSNetworkingStatusTypeSuccess,
    /*! 网络请求成功，但是返回结果错误 */
    JSNetworkingStatusTypeContentError,
    /*! 网络请求的request参数错误 */
    JSNetworkingStatusTypeParamsError,
    /*! 网络请求连接超时 */
    JSNetworkingStatusTypeTimeOut,
    /*! 无网络的情况，在发起网络请求之前先会确定网络是否正常 */
    JSNetworkingStatusTypeNoNetwork
};

/*********************************************************************
 *  网络请求api具体定义
 *********************************************************************/
@protocol JSApiDetailDelegate <NSObject>
@required
- (NSString *)methodName;
- (JSNetworkingRequestType)requestType;
- (BOOL)shouldCache;
- (NSString*)APIVersion;
- (BOOL)shouldShowHUD;

@optional
- (BOOL)shouldHidenErrorMsg;
- (BOOL)shouldDisableUserInterface;
@end

@interface JSNetworkingBaseManager : NSObject
/*! 网络请求回调代理 */
@property (strong, nonatomic) id<JSNetworkingCallBackDelegate> callBackDelegate;
/*! 网络请求request参数代理 */
@property (weak,nonatomic) id<JSNetworkingRequestParamsDelegate> paramSource;
/*! 网络请求request参数验证代理 */
@property (weak,nonatomic) id<JSNetworkingRequestParamsValidatorDelegate> paramValidator;
/*! 网络请求拦截器 */
@property (weak,nonatomic) id<JSNetworkingManagerInterceptor> interceptor;
/*! 网络请求api具体信息代理 */
@property (weak,nonatomic) NSObject<JSApiDetailDelegate> *apiDetail;
/*!
 网络请求具体状态，详情查看JSNetworkingStatusType定义
 */
@property(assign,nonatomic,readonly) JSNetworkingStatusType networkStatus;
/*!
 网络请求的response
 */
@property(strong,nonatomic) JSResponse* response;
/*!
 网络是否可用
 */
@property(assign,nonatomic,readonly) BOOL isReachable;
/*!
 网络是否加载中
 */
@property(assign,nonatomic,readonly) BOOL isLoading;
/*!
 分页参数，如果api需要设置分页，修改此参数。
 */
@property(copy,nonatomic) NSString* pageId;
/*!
 是否特殊缓存格式
 */
@property(assign,nonatomic) BOOL isSpecialCache;
/*!
 是否是外部请求，外部请求将不会拼接域名
 */
@property(assign,nonatomic) BOOL custom;
/*!
 @brief 网络请求发起函数
 @return 返回当前请求api的taskid
 */
- (NSInteger)loadData;
/*!
 @brief 取消当前Manager全部网络请求
 @remark 仅仅取消的是当前实例化manager的全部请求
 */
- (void)cancelAllRequests;
/*!
 @brief 取消具体对应TaskID的请求
 @param requestID -loadData函数返回的TaskID
 */
- (void)cancelRequestWithRequestId:(NSInteger)requestID;
/*!
 @brief 清除缓存
 */
- (void)cleanData;
/*!
 @brief 内部集约成功Block回调
 @param response api返回的JSResponse对象
 */
- (void)successedOnCallingAPI:(JSResponse *)response;
/*!
 @brief 内部集约失败Block回调
 @param response api返回的JSResponse对象
 @param statusType api失败的具体类型JSNetworkingStatusType
 */
- (void)failedOnCallingAPI:(JSResponse *)response withErrorType:(JSNetworkingStatusType)statusType;

///是否隐藏错误toast
@property(nonatomic,assign) BOOL hideErrorToast;

@end
