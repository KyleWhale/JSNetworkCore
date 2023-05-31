//
//  XZProgress.m
//  XZYiBoEducation
//
//  Created by mac on 2019/11/7.
//  Copyright © 2019 ybed. All rights reserved.
//

#import "XZProgressHUD.h"
#import "SVProgressHUD.h"
#import "SVProgressHUD+JS.h"

@implementation XZProgressHUD

+ (UIColor *)hexColor:(int)rgbValue {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                            blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

+ (BOOL)isEmpty:(NSString *)string {
    return (string == nil ||
            [string isKindOfClass:[NSNull class]] ||
            [string isEqualToString:@""] ||
            [string isEqualToString:@"<null>"] ||
            [string isEqualToString:@"(null)"]);
}

+ (void)setMinimumDismissTimeInterval {
    [SVProgressHUD setMinimumDismissTimeInterval:2];
    [SVProgressHUD setMaximumDismissTimeInterval:2];
}

+ (void)show
{
    [self loadFullScreenLoading];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setForegroundColor:[self hexColor:0xFFFFFF]];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
    [SVProgressHUD setMinimumSize:CGSizeMake(90, 90)];
    [SVProgressHUD showImage:[UIImage imageNamed:@""] status:@"Loading..."];
}

+ (void)showLoading {
    [self showLoadingWithStatus:@""];
}

+ (void)loadFullScreenLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD sharedView].transform = CGAffineTransformIdentity;
    });
}

+ (void)showLoadingWithStatus:(NSString *)status {
    
    [self loadFullScreenLoading];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setForegroundColor:[self hexColor:0xFFFFFF]];//FF9935
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
    [SVProgressHUD setMinimumSize:CGSizeMake(90, 90)];
    if ([self isEmpty:status]) {
        [SVProgressHUD showImage:[UIImage imageNamed:@""] status:@"Loading..."];
    } else {
        [SVProgressHUD showImage:[UIImage imageNamed:@""] status:status];
    }
}

+ (void)showWithMaskType
{
    [self loadFullScreenLoading];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD show];
}

+ (void)showWithStatus:(NSString *)string
{
    [self loadFullScreenLoading];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setForegroundColor:[self hexColor:0xFFFFFF]];//FF9935
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
    [SVProgressHUD setMinimumSize:CGSizeMake(90, 90)];
    [SVProgressHUD showWithStatus:string];
}

+ (void)showInfoWithStatus:(NSString *)string
{
    if ([self isEmpty:string]) return;
    [self loadFullScreenLoading];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD showInfoWithStatus:string];
}

+ (void)showSuccessWithStatus:(NSString *)string
{
    if ([self isEmpty:string]) return;
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD showSuccessWithStatus:string];
}

+ (void)showErrorWithStatus:(NSString *)string
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD showErrorWithStatus:string];
}

+ (void)showImage:(UIImage*)image status:(NSString *)string
{
    if ([self isEmpty:string]) return;
    [self loadFullScreenLoading];
    [SVProgressHUD setMinimumSize:CGSizeZero];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD showImage:image status:string];
}

+ (void)dismiss
{
    [self loadFullScreenLoading];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD dismiss];
}

+ (void)dismissWithDelay:(NSTimeInterval)delay
{
    [self loadFullScreenLoading];
    [SVProgressHUD dismissWithDelay:delay];
}


@end
