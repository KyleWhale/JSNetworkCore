//
//  SVProgressHUD+JS.m
//  JSNetworkCore
//
//  Created by 李雪健 on 2023/5/18.
//

#import "SVProgressHUD+JS.h"

@implementation SVProgressHUD (JS)

+ (SVProgressHUD *)sharedView {
    static dispatch_once_t once;
    
    static SVProgressHUD *sharedView;
#if !defined(SV_APP_EXTENSIONS)
    dispatch_once(&once, ^{ sharedView = [[self alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds]; });
#else
    dispatch_once(&once, ^{ sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
#endif
    return sharedView;
}

@end
