//
//  JSCache.h
//  JSNetworking
//

#import <Foundation/Foundation.h>

@interface JSCache : NSURLRequest
/*! 缓存单利方法 */
+ (instancetype)sharedInstance;

/*!
 @brief 根据reqeust参数和api短地址生成缓存KEY
 
 @param methodName 具体api路径
 @param requestParams  api请求的入参
 @return 生成的缓存KEY值
 */
- (NSString *)keyWithMethodName:(NSString *)methodName
                         requestParams:(NSDictionary *)requestParams;

/*!
 @brief 获取缓冲的内容
 
 @param methodName 具体api路径
 @param requestParams  api请求的入参
 @return NSData 缓存的内容
 */
- (NSData *)fetchCachedDataWithmethodName:(NSString *)methodName
                                   requestParams:(NSDictionary *)requestParams;

/*!
 @brief 获取缓冲的内容
 
 @param cachedData  缓存的数据
 @param methodName  具体api路径
 @param requestParams  api请求的入参
 */
- (void)saveCacheWithData:(NSData *)cachedData
               methodName:(NSString *)methodName
            requestParams:(NSDictionary *)requestParams;

/*!
 @brief 删除某条API的缓存
 
 @param methodName  具体api路径
 @param requestParams  api请求的入参
 */
- (void)deleteCacheWithmethodName:(NSString *)methodName
                           requestParams:(NSDictionary *)requestParams;

/*!
 @brief 通过缓存的Key获取缓存的内容
 @param key  缓存的key值
 */
- (NSData *)fetchCachedDataWithKey:(NSString *)key;
/*!
 @brief 通过缓存的Key获取缓存的内容
 @param cachedData  缓存的数据
 @param key  缓存的key值
 */
- (void)saveCacheWithData:(NSData *)cachedData key:(NSString *)key;
/*!
 @brief 通过缓存的Key删除某条API的缓存
 @param key  缓存的key值
 */
- (void)deleteCacheWithKey:(NSString *)key;
/*!
 @brief 清除所有缓存
 */
- (void)clean;

+ (NSString *)keyWithMethodName:(NSString *)methodName requestParams:(NSDictionary *)requestParams;

@end
