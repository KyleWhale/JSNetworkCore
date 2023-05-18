//
//  JSAPIProxy.h
//  JSNetworking
//

#import <Foundation/Foundation.h>
#import "JSResponse.h"

typedef void(^JSCallback)(JSResponse *response);
typedef void(^JSUploadProgress)(NSProgress* progress);

@interface JSAPIProxy : NSObject

/*!
 @brief 单利生成网络发起对象，主要调用AFNetworking
 */
+ (instancetype)sharedInstance;
/*!
 @brief 配置ssl证书相关
  @param sslName ssl证书名称
 */
-(void)configSSL:(NSString*)sslName;
/*!
 @brief 调用Get网络发起函数
 
 @param params 调用api的参数列表
 @param methodName  调用的具体api地址
 @param version  当前调用api的版本号
 @param success  网络成功的回调，需要注意一点，这里的成功仅仅代表api调用成功，但是服务区返回参数如何不确定
 @param fail  网络调用失败，一般是服务抛出500等异常
 @return 当前请求的task id 用于取消网络请求
 */
- (NSInteger)callGETWithParams:(NSDictionary *)params methodName:(NSString *)methodName version:(NSString *)version success:(JSCallback)success fail:(JSCallback)fail;
/*!
 @brief 调用Post网络发起函数
 
 @param params 调用api的参数列表
 @param methodName  调用的具体api地址
 @param version  当前调用api的版本号
 @param success  网络成功的回调，需要注意一点，这里的成功仅仅代表api调用成功，但是服务区返回参数如何不确定
 @param fail  网络调用失败，一般是服务抛出500等异常
 @return 当前请求的task id 用于取消网络请求
 */
- (NSInteger)callPOSTWithParams:(NSDictionary *)params methodName:(NSString *)methodName version:(NSString *)version success:(JSCallback)success fail:(JSCallback)fail;
/*!
 @brief 上传NSData
 
 @param data 上传的数据
 @param methodName  调用的具体api地址
 @param version  当前调用api的版本号
 @param success  网络成功的回调，需要注意一点，这里的成功仅仅代表api调用成功，但是服务区返回参数如何不确定
 @param progress 上传的进度
 @param fail  网络调用失败，一般是服务抛出500等异常
 @return 当前请求的task id 用于取消网络请求
 */
- (NSInteger)callUploadWithData:(NSData *)data methodName:(NSString *)methodName version:(NSString *)version success:(JSCallback)success progress:(JSUploadProgress)progress fail:(JSCallback)fail;
/*!
 @brief 上传NSData
 
 @param fileUrl 上传的数据
 @param methodName  调用的具体api地址
 @param version  当前调用api的版本号
 @param success  网络成功的回调，需要注意一点，这里的成功仅仅代表api调用成功，但是服务区返回参数如何不确定
 @param progress 上传的进度
 @param fail  网络调用失败，一般是服务抛出500等异常
 @return 当前请求的task id 用于取消网络请求
 */
- (NSInteger)callUploadFileWithUrl:(NSURL *)fileUrl methodName:(NSString *)methodName version:(NSString *)version success:(JSCallback)success progress:(JSUploadProgress)progress fail:(JSCallback)fail;
/*! 内部调用，不供外部调用，除非有特殊的请求需要这么调用 */
- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(JSCallback)success fail:(JSCallback)fail;
-(NSInteger )callUploadProgressRequest:(NSURLRequest *)request success:(JSCallback)success progress:(JSUploadProgress)progress fail:(JSCallback)fail;
/*!
 @brief 取消单个网络请求
 @discussion 提供taskid取消网络请求，但是当网络已经发出去的种取消其实已经意义不大了
 @param requestID 对应取消的网络请求taskID
 */
- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
/*!
 @brief 取消多个网络请求
 @param requestIDList 对应取消的网络请求taskID数组
 */
- (void)cancelRequestWithRequestIDList:(NSDictionary *)requestIDList;

@end
