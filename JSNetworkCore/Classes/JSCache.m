//
//  JSCache.m
//  JSNetworking
//

#import "JSCache.h"
#import "JSNetworkingConfigurations.h"
#import "JSCacheObject.h"
#import "YYCache.h"

@interface JSCache ()

@property (nonatomic, strong) YYCache* cache;

@end

@implementation JSCache
#pragma mark - getters and setters
- (YYCache *)cache
{
    if (_cache == nil) {
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _cache = [YYCache cacheWithPath:[path stringByAppendingPathComponent:@"JSNetworkCache"]];
    }
    return _cache;
}

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static JSCache *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JSCache alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public method
- (NSData *)fetchCachedDataWithmethodName:(NSString *)methodName
                            requestParams:(NSDictionary *)requestParams
{
    return [self fetchCachedDataWithKey:[JSCache keyWithMethodName:methodName requestParams:requestParams]];
}

- (void)saveCacheWithData:(NSData *)cachedData
               methodName:(NSString *)methodName
            requestParams:(NSDictionary *)requestParams
{
    [self saveCacheWithData:cachedData key:[JSCache keyWithMethodName:methodName requestParams:requestParams]];
}

- (void)deleteCacheWithmethodName:(NSString *)methodName
                    requestParams:(NSDictionary *)requestParams
{
    [self deleteCacheWithKey:[JSCache keyWithMethodName:methodName requestParams:requestParams]];
}

- (NSData *)fetchCachedDataWithKey:(NSString *)key
{
    JSCacheObject *cachedObject = (JSCacheObject*)[self.cache objectForKey:key];
    if (!cachedObject || cachedObject.isEmpty) {
        return nil;
    } else {
        return cachedObject.content;
    }
}

- (void)saveCacheWithData:(NSData *)cachedData key:(NSString *)key
{
    JSCacheObject *cachedObject = (JSCacheObject*)[self.cache objectForKey:key];
    if (cachedObject == nil) {
        cachedObject = [[JSCacheObject alloc] init];
    }
    [cachedObject updateContent:cachedData];
    [self.cache setObject:cachedObject forKey:key];
}

- (void)deleteCacheWithKey:(NSString *)key
{
    [self.cache removeObjectForKey:key];
}

- (void)clean
{
    [self.cache removeAllObjects];
}

+ (NSString *)keyWithMethodName:(NSString *)methodName requestParams:(NSDictionary *)requestParams
{
    return [NSString stringWithFormat:@"%@%@",methodName,[self transformedParams:requestParams]];
}

+ (NSArray *)transformedParams:(NSDictionary*)params
{
    if(![params isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            obj = [NSString stringWithFormat:@"%@", obj];
        }
        if ([obj length] > 0 && ![key isEqualToString:@"update_time"]) {
            [result addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }
    }];
    NSArray *sortedResult = [result sortedArrayUsingSelector:@selector(compare:)];
    return sortedResult;
}

@end
