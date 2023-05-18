//
//  XZTimeTool.h
//  XZYiBoEducation
//
//  Created by mac on 2019/11/8.
//  Copyright © 2019 ybed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JSTimeFormatterMode) {
    /*! 日期格式为2017-09-01 */
    timeFormatterMode1,
    /*! 日期格式为2017-09-01 00:00 */
    timeFormatterMode2,
    /*! 日期格式为2017/09/01 */
    timeFormatterMode3,
    /*! 日期格式为2017/09/01 00:00 */
    timeFormatterMode4,
    /*! 日期格式为00:00 */
    timeFormatterMode5,
    /*! 2017.09.01 */
    timeFormatterMode6,
    /*! 7月18日 */
    timeFormatterMode7,
    /*! 日期格式为2017-09-01 00:00:00 */
    timeFormatterMode8,
    /*! 日期格式为2017年09月01日*/
    timeFormatterMode9,
    /*! 7-18 */
    timeFormatterMode10,
};

NS_ASSUME_NONNULL_BEGIN

@interface XZTimeTool : NSObject

/*!
 @brief 获取timeTool
 @return 返回实例
 */
+ (XZTimeTool *)shareTimeTool;

/*!
 @brief 获取当前中国标准时间date
 */
- (NSDate *)getLocalCurrentDate;

/*!
 @brief 获取当前中国标准时间戳
 */
- (NSTimeInterval)getLocalCurrentTimestamp;
/*!
 @brief 时间戳转为时间串
 */
- (NSString *)getTimeToTimeStr:(NSInteger)nowTime;
/*!
 @brief 获取当前时间戳---10位
 */
- (NSString *)getNowTime;

/*!
 @brief 获取当前中国标准日期字符串 如2017-09-01
 */
- (NSString *)getLocalCurrentDateStringWithMode:(JSTimeFormatterMode)timeFormatterMode;

/*!
 @brief 时间戳转日期字符串 如2017-09-01
 */
- (NSString *)timestampTransformToDateStringWithMode:(JSTimeFormatterMode)timeFormatterMode timestamp:(NSTimeInterval)timestamp;
- (NSString *)timestampTransformToDateStringWithFormatter:(NSString*)timeFormatterMode timestamp:(NSTimeInterval)timestamp;

/*!
 @brief 日期字符串转时间戳
 */
- (NSTimeInterval)dateStringTransformToTimestampWithMode:(JSTimeFormatterMode)timeFormatterMode dateString:(NSString *)dateString;

/*!
 @brief 日期字符串转date
 */
- (NSDate *)dateStringTransformToDateWithMode:(JSTimeFormatterMode)timeFormatterMode dateString:(NSString *)dateString;
/*!
 @brief date转日期字符串
 */
- (NSString *)dateTransformToDateStringWithMode:(JSTimeFormatterMode)timeFormatterMode date:(NSDate *)date;

/*!
 @brief 时间戳转date
 */
- (NSDate *)timestampTransformToDate:(NSTimeInterval)timestamp;

/*!
 @brief date转时间戳
 */
- (NSTimeInterval)dateTransformToTimestamp:(NSDate *)date;

/*!
 @brief 获取任意date当天00:00:00点或者当天23:59:59点
 @param isForwardTime = NO-00:00:00点 isForwardTime = YES-23:59:59点
 */
- (NSDate *)getZeroPointTimeWithSpecificDate:(NSDate *)specificDate isForwardTime:(BOOL)isForwardTime;

/*!
 @brief (与当前时间相比)n年前、n年后等
 @param type - 0:年 1:月 2:日 3:小时 4:分钟 5:秒
 @param count - 如(count=1,1月后)(count=-1,1月前)
 */
- (NSDate *)getAnyDate:(NSInteger)type count:(NSInteger)count;

/*!
 @brief 是否属于今天、昨天、明天
 @param dayType - 0:今天 1:昨天 2:明天
 */
- (BOOL)isMemberOfSpecificDayWithDate:(NSDate *)date dayType:(NSInteger)dayType;

/*!
 @brief 任意date所在月，月初当天00:00:00点和月末当天23:59:59点
 @param isBeginTime = YES:月初  isBeginTime = NO:月末
 */
- (NSDate *)getMonthBeginOrEndDate:(BOOL)isBeginTime anyDate:(NSDate *)anyDate;

/*!
 @brief 今天:返回如"13:00"类型  昨天:返回"昨天"  本(上)周:返回如"星期二"类型  其他:返回如"2017-09-12"具体日期
 @details 给出时间戳 返回对应的四种结果 1:返回如"13:00"具体时间 2:直接返回字符串"昨天" 3:返回如"2017-09-12"具体日期 4:返回如"星期二"具体周几
 */
- (NSString *)timeTransformTypeOne:(NSTimeInterval)timestamp timeFormatterMode:(JSTimeFormatterMode)timeFormatterMode;

/*!
 @brief 剩余n天n小时等
 */
- (NSString *)timeTransformTypeTwo:(NSTimeInterval)endTimestamp withCurrentTimestamp:(NSTimeInterval)currentTimestamp;

/*!
 @brief n天n小时前
 isNeedSend如果是NO，则只返回最大单位的时间，1小时5分钟前，返回1小时前
 */
- (NSString *)timeTransformTypeThree:(NSTimeInterval)startTimestamp withCurrentTimestamp:(NSTimeInterval)currentTimestamp isNeedSend:(BOOL)isNeedSend;

/*!
 @brief 秒转天、时、分钟、秒
 */
- (NSString *)secondChangeDayHourMin:(long)space;

/*!
 @brief 天、时、分钟、秒转秒
 */
- (NSInteger)dayHourMinChangeSecond:(NSString *)time;

/*!
 @brief 秒转分钟、秒
 */
- (NSString *)minChangeSecond:(NSInteger)time;

/*!
 @brief 返回两个时间戳之间相隔的天数
 */
- (NSString *)timeTransformTypeFourth:(NSTimeInterval)endTimestamp withCurrentTimestamp:(NSTimeInterval)currentTimestamp;
/*!
 @brief 如果是当天，如果当前时比X
 x < 60秒  刚刚
 x < 60分钟  x分前
 x < 24H   x小时前
 x > 24H   yyyy-MM-dd hh:mm:ss
 当年的显示MM-dd
 不是今年的显示yyyy-MM-dd
 */
- (NSString *)timeTransformTypeFive:(NSTimeInterval)startTimestamp timeFormatterMode:(JSTimeFormatterMode)timeFormatterMode;

@end

NS_ASSUME_NONNULL_END
