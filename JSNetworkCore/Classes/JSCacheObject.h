//
//  JSCacheObject.h
//  JSNetworking
//

#import <Foundation/Foundation.h>

@interface JSCacheObject : NSObject <NSCoding>
/*! 缓存的正文内容 */
@property (nonatomic, copy, readonly) NSData *content;
/*! 缓存最后的更新时间 */
@property (nonatomic, copy, readonly) NSDate *lastUpdateTime;
/*! 缓存是否过期 */
@property (nonatomic, assign, readonly) BOOL isOutdated;
/*! 判断缓存的 content==nil*/
@property (nonatomic, assign, readonly) BOOL isEmpty;
/*!
 @brief 初始化一个缓存对象
 @return JSCacheObject
 */
- (instancetype)initWithContent:(NSData *)content;
/*!
 @brief 更新缓存正文内容
 @param content 更新的缓存内容
 */
- (void)updateContent:(NSData *)content;

@end
