//
//  JSCacheObject.m
//  JSNetworking


#import "JSCacheObject.h"
#import "JSNetworkingConfigurations.h"

@interface JSCacheObject ()

@property (nonatomic, copy, readwrite) NSData *content;
@property (nonatomic, copy, readwrite) NSDate *lastUpdateTime;

@end

@implementation JSCacheObject

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init]){
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.lastUpdateTime = [aDecoder decodeObjectForKey:@"lastUpdateTime"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.lastUpdateTime forKey:@"lastUpdateTime"];
}

#pragma mark - getters and setters
- (BOOL)isEmpty
{
    return self.content == nil;
}

- (BOOL)isOutdated
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    return timeInterval > [JSNetworkingConfigurations sharedInstance].cacheOutdateTimeSeconds ;
}

- (void)setContent:(NSData *)content
{
    _content = [content copy];
    self.lastUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0];
}

#pragma mark - life cycle
- (instancetype)initWithContent:(NSData *)content
{
    self = [super init];
    if (self) {
        self.content = content;
    }
    return self;
}

#pragma mark - public method
- (void)updateContent:(NSData *)content
{
    self.content = content;
}

@end
