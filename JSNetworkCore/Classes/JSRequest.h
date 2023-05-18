//
//  JSRequest.h
//  JSNetworking
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
@interface JSRequest : NSObject

@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@property (nonatomic, strong) AFJSONRequestSerializer *httpJsonRequestSerializer;

/*! 单利request生成对象 */
+ (instancetype)sharedInstance;
/*!
 @brief 生成Get类型的NSURLRequest
 @param requestParams 请求的入参
 @param methodName 请求的api action地址
 @param version 对应api的版本号
 @return NSURLRequest
 */
- (NSURLRequest *)generateGETRequestWithParams:(NSDictionary *)requestParams methodName:(NSString *)methodName version:(NSString*)version;
/*!
 @brief 生成Post类型的NSURLRequest
 @param requestParams 请求的入参
 @param methodName 请求的api action地址
 @param version 对应api的版本号
 @return NSURLRequest
 */
- (NSURLRequest *)generatePOSTRequestWithParams:(NSDictionary *)requestParams methodName:(NSString *)methodName version:(NSString*)version;

/*!
 @brief 生成上传图片文件的NSURLRequest
 @param data 具体上传的数据
 @param methodName 请求的api action地址
 @param version 对应api的版本号
 @return NSURLRequest
 */
- (NSURLRequest *)generateUploadRequestWithData:(NSData*)data methodName:(NSString *)methodName version:(NSString*)version;

/*!
 @brief 生成上传图片文件的NSURLRequest
 @param fileUrl 具体上传的数据本地url
 @param methodName 请求的api action地址
 @param version 对应api的版本号
 @return NSURLRequest
 */
- (NSURLRequest *)generateUploadFileRequestWithFileUrl:(NSURL*)fileUrl methodName:(NSString *)methodName version:(NSString*)version;

/*!
 @brief 生成NSURLRequest
 @param requestParams 请求的入参
 @param methodName 请求的api action地址
 @param version 对应api的版本号
 @param method 对应的Request Method
 @return NSURLRequest
 */
- (NSURLRequest *)generateRequestWithParams:(NSDictionary *)requestParams methodName:(NSString *)methodName version:(NSString*)version requestWithMethod:(NSString *)method;
/*!
 @brief 重置AFHTTPRequestSerializer对象
 */
- (void)rest;

@end
