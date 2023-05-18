//
//  JSResponse.h
//  JSNetworking
//

#import <Foundation/Foundation.h>
/*! api发出后的response状态 */
typedef NS_ENUM(NSUInteger, JSResponseStatus)
{
    /*! 作为下层，请求是否成功只考虑是否成功收到服务器反馈*/
    CTURLResponseStatusSuccess,
    /*! 超时 */
    CTURLResponseStatusErrorTimeout,
    /*! 默认除了超时以外的错误都是无网络错误 */
    CTURLResponseStatusErrorNoNetwork
};
@interface JSResponse : NSObject
/*! 下层response状态，200就是成功，除了超时，其他都是无网络 */
@property (nonatomic, assign, readonly) JSResponseStatus status;
/*! 具体的response string */
@property (nonatomic, copy, readonly) NSString *contentString;
/*! objc类型的response正文 */
@property (nonatomic, copy, readonly) id content;
/*! 该response对应的request task id */
@property (nonatomic, assign, readonly) NSInteger requestId;
/*! 该response对应的 NSURLRequest 对象 */
@property (nonatomic, copy, readonly) NSURLRequest *request;
/*! 该response正文的 NSData 对象 */
@property (nonatomic, copy, readonly) NSData *responseData;
/*! 该response对应的 request 入参 */
@property (nonatomic, copy) NSDictionary *requestParams;
/*! 如果请求失败，则保存error信息 */
@property (nonatomic, strong, readonly) NSError *error;
/*! 当前这个response是否已经缓存 */
@property (nonatomic, assign, readonly) BOOL isCache;
/*! 当前参数只针对图片上传才有效，其余请求无效 */
@property (nonatomic, assign) NSInteger index;

/*!
 @brief 生成一个success的JSResponse对象
 @param responseString 对应的response string
 @param requestId  该response创建的taskId
 @param request 该response的request对象
 @param responseData 对应的response NSData类型
 @param status  请求的状态
 @return JSResponse 对象
 */
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData status:(JSResponseStatus)status;
/*!
 @brief 生成一个success的JSResponse对象
 @param responseString 对应的response string
 @param requestId  该response创建的taskId
 @param request 该response的request对象
 @param responseData 对应的response NSData类型
 @param error 错误信息
 @return JSResponse 对象
 */
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error;
/*!
 @brief 使用initWithData的response，它的isCache是YES，上面两个函数生成的response的isCache是NO
 
 @param data 缓存response的content
 @return JSResponse 对象
 */
- (instancetype)initWithData:(NSData *)data;

@end
