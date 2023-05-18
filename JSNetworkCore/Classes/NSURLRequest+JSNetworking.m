//
//  NSURLRequest+JSNetworking.m
//  JSNetworking
//

#import "NSURLRequest+JSNetworking.h"
#import <objc/runtime.h>
static void *JSNetworkingRequestParams;

@implementation NSURLRequest (JSNetworking)

- (void)setRequestParams:(NSDictionary *)requestParams
{
    objc_setAssociatedObject(self, &JSNetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)requestParams
{
    return objc_getAssociatedObject(self, &JSNetworkingRequestParams);
}

@end
