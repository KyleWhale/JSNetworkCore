//
//  NSURLRequest+JSNetworking.h
//  JSNetworking
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (JSNetworking)
/*! 为request添加参数变量 */
@property (nonatomic, copy) NSDictionary *requestParams;

@end
