//
//  XZProgress.h
//  XZYiBoEducation
//
//  Created by mac on 2019/11/7.
//  Copyright © 2019 ybed. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZProgressHUD : NSObject

/// 设置文字显示时长
+ (void)setMinimumDismissTimeInterval;

+ (void)show;
/// 显示加载动画
+ (void)showLoading;

+ (void)showWithStatus:(NSString*)string;
+ (void)showWithMaskType;

+ (void)dismiss;
+ (void)dismissWithDelay:(NSTimeInterval)delay;

+ (void)showInfoWithStatus:(NSString*)string;
+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showErrorWithStatus:(NSString*)string;

+ (void)showImage:(UIImage*)image status:(NSString*)string;

@end

NS_ASSUME_NONNULL_END
