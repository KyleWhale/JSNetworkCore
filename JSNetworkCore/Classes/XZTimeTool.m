//
//  XZTimeTool.m
//  XZYiBoEducation
//
//  Created by mac on 2019/11/8.
//  Copyright © 2019 ybed. All rights reserved.
//

#import "XZTimeTool.h"
#import "JKCategories.h"

@interface XZTimeTool ()

/*! 日期格式化器 */
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
/*! 当前日历 */
@property (nonatomic, copy) NSCalendar *calendar;

@end

@implementation XZTimeTool

+ (XZTimeTool *)shareTimeTool{
    static XZTimeTool *timeTool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeTool = [[XZTimeTool alloc] init];
        timeTool.dateFormatter = [[NSDateFormatter alloc] init];
        timeTool.dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [timeTool.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
        timeTool.calendar = [NSCalendar currentCalendar];
        timeTool.calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [timeTool.calendar setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    });
    return timeTool;
}

# pragma mark - 获取当前中国标准时间date
- (NSDate *)getLocalCurrentDate{
    NSTimeInterval currentTimestamp = [NSDate date].timeIntervalSince1970;
    return [NSDate dateWithTimeIntervalSince1970:currentTimestamp];
}

# pragma mark - 获取当前中国标准时间戳
- (NSTimeInterval)getLocalCurrentTimestamp{
    return [NSDate date].timeIntervalSince1970;
}

#pragma mark --- 时间戳转为时间串
- (NSString *)getTimeToTimeStr:(NSInteger)nowTime{
    
    CGFloat time = nowTime/1000.0;
    NSDate * detailDate = [NSDate dateWithTimeIntervalSince1970:time];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeStr = [dateFormatter stringFromDate:detailDate];
    return timeStr;
}

#pragma mark --- 获取当前时间戳---不*1000是10位/*1000是13位
- (NSString *)getNowTime{

    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970];
    NSString *timeSp = [NSString stringWithFormat:@"%.0f", time];
    return timeSp;
}

# pragma mark - 获取当前中国标准时间字符串 如2017-09-01
- (NSString *)getLocalCurrentDateStringWithMode:(JSTimeFormatterMode)timeFormatterMode{
    self.dateFormatter.dateFormat = [self getFormatterString:timeFormatterMode];
    return [self.dateFormatter stringFromDate:[self getLocalCurrentDate]];
}

# pragma mark - private方法 获取格式化字符串
- (NSString *)getFormatterString:(JSTimeFormatterMode)timeFormatterMode{
    NSString *formatter = @"yyyy-MM-dd";
    switch (timeFormatterMode) {
        case timeFormatterMode1:
            formatter = @"yyyy-MM-dd";
            break;
        case timeFormatterMode2:
            formatter = @"yyyy-MM-dd HH:mm";
            break;
        case timeFormatterMode3:
            formatter = @"yyyy/MM/dd";
            break;
        case timeFormatterMode4:
            formatter = @"yyyy/MM/dd HH:mm";
            break;
        case timeFormatterMode5:
            formatter = @"HH:mm";
            break;
        case timeFormatterMode6:
            formatter = @"yyyy.MM.dd";
            break;
        case timeFormatterMode7:
            formatter = @"MM月dd日";
            break;
        case timeFormatterMode8:
            formatter = @"yyyy-MM-dd HH:mm:ss";
            break;
        case timeFormatterMode9:
            formatter = @"yyyy年MM月dd日";
            break;
        case timeFormatterMode10:
            formatter = @"MM-dd";
            break;
        default:
            break;
    }
    return formatter;
}

# pragma mark - 时间戳转时间字符串 如2017-09-01
- (NSString *)timestampTransformToDateStringWithMode:(JSTimeFormatterMode)timeFormatterMode timestamp:(NSTimeInterval)timestamp{
    self.dateFormatter.dateFormat = [self getFormatterString:timeFormatterMode];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [self.dateFormatter stringFromDate:date];
}

- (NSString *)timestampTransformToDateStringWithFormatter:(NSString*)timeFormatterMode timestamp:(NSTimeInterval)timestamp
{
    self.dateFormatter.dateFormat = timeFormatterMode;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [self.dateFormatter stringFromDate:date];
}

# pragma mark - 时间字符串转时间戳
- (NSTimeInterval)dateStringTransformToTimestampWithMode:(JSTimeFormatterMode)timeFormatterMode dateString:(NSString *)dateString{
    self.dateFormatter.dateFormat = [self getFormatterString:timeFormatterMode];
    NSDate *date = [self.dateFormatter dateFromString:dateString];
    return date.timeIntervalSince1970;
}

# pragma mark - 时间字符串转date
- (NSDate *)dateStringTransformToDateWithMode:(JSTimeFormatterMode)timeFormatterMode dateString:(NSString *)dateString{
    self.dateFormatter.dateFormat = [self getFormatterString:timeFormatterMode];
    return [self.dateFormatter dateFromString:dateString];
}

# pragma mark - date转日期字符串
- (NSString *)dateTransformToDateStringWithMode:(JSTimeFormatterMode)timeFormatterMode date:(NSDate *)date{
    self.dateFormatter.dateFormat = [self getFormatterString:timeFormatterMode];
    return [self.dateFormatter stringFromDate:date];
}

# pragma mark - 时间戳转date
- (NSDate *)timestampTransformToDate:(NSTimeInterval)timestamp{
    return [NSDate dateWithTimeIntervalSince1970:timestamp];
}

# pragma mark - date转时间戳
- (NSTimeInterval)dateTransformToTimestamp:(NSDate *)date{
    return date.timeIntervalSince1970;
}

# pragma mark - 任意date当天00:00:00点(isForwardTime:NO)或者当天23:59:59点(isForwardTime:YES)
- (NSDate *)getZeroPointTimeWithSpecificDate:(NSDate *)specificDate isForwardTime:(BOOL)isForwardTime{
    int unit = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [self.calendar components:unit fromDate:specificDate];
    NSTimeInterval specificTimestamp = specificDate.timeIntervalSince1970;
    NSTimeInterval timestamp = 0;
    if (isForwardTime) {
        timestamp = specificTimestamp + (23 - components.hour) * 3600 + (59 - components.minute) * 60 + (59 - components.second);
    }else{
        timestamp = specificTimestamp - components.hour * 3600 - components.minute * 60 - components.second;
    }
    return [NSDate dateWithTimeIntervalSince1970:timestamp];
}

# pragma mark - n年前、n年后等(与当前时间相比)
- (NSDate *)getAnyDate:(NSInteger)type count:(NSInteger)count{
    NSDate *nowDate = [self getLocalCurrentDate];
    NSDateComponents *components = [self configComponents:type count:count];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *laterDate = [calendar dateByAddingComponents:components toDate:nowDate options:0];
    return laterDate;
}

# pragma mark - private方法 配置NSDateComponents
- (NSDateComponents *)configComponents:(NSInteger)type count:(NSInteger)count{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    switch (type) {
        case 0:
            components.year = count;
            break;
        case 1:
            components.month = count;
            break;
        case 2:
            components.day = count;
            break;
        case 3:
            components.hour = count;
            break;
        case 4:
            components.minute = count;
            break;
        case 5:
            components.second = count;
            break;
            
        default:
            break;
    }
    return components;
}

# pragma mark - 是否属于今天、昨天、明天 dayType-0:今天 1:昨天 2:明天
- (BOOL)isMemberOfSpecificDayWithDate:(NSDate *)date dayType:(NSInteger)dayType{
    if (dayType == 0) {
        return [self.calendar isDateInToday:date];
    }else if (dayType == 1){
        return [self.calendar isDateInYesterday:date];
    }else if (dayType == 2){
        return [self.calendar isDateInTomorrow:date];
    }else{
        NSLog(@"DayType given is invalid.");
        return NO;
    }
}

# pragma mark - 任意date所在月，月初当天00:00:00点和月末当天23:59:59点
- (NSDate *)getMonthBeginOrEndDate:(BOOL)isBeginTime anyDate:(NSDate *)anyDate{
    if (isBeginTime) {
        NSDateComponents *components = [self.calendar components:NSCalendarUnitDay fromDate:anyDate];
        NSTimeInterval timestamp = anyDate.timeIntervalSince1970 - (components.day - 1) * 24 * 3600;
        return [self getZeroPointTimeWithSpecificDate:[self timestampTransformToDate:timestamp] isForwardTime:NO];
    }else{
        NSDateComponents *components = [self.calendar components:NSCalendarUnitDay fromDate:anyDate];
        NSTimeInterval timestamp = anyDate.timeIntervalSince1970 + ([self getDaysCountInOneMonth] - components.day) * 24 * 3600;
        return [self getZeroPointTimeWithSpecificDate:[self timestampTransformToDate:timestamp] isForwardTime:YES];
    }
}

# pragma mark - private方法 获取当月天数
- (NSInteger)getDaysCountInOneMonth{
    NSRange range = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[self getLocalCurrentDate]];
    return range.length;
}

# pragma mark - 今天:返回如"13:00"类型  昨天:返回"昨天"  本(上)周:返回如"星期二"类型  其他:返回如"2017-09-12"具体日期
- (NSString *)timeTransformTypeOne:(NSTimeInterval)timestamp timeFormatterMode:(JSTimeFormatterMode)timeFormatterMode{
    NSDate *date = [self timestampTransformToDate:timestamp];
    if ([self.calendar isDateInToday:date]) {
        return [self dateTransformToDateStringWithMode:timeFormatterMode5 date:date];
    }else if ([self.calendar isDateInYesterday:date]){
        return @"昨天";
    }else{
        int unit = NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *components = [self.calendar components:unit fromDate:[self getLocalCurrentDate]];
        //从上周一00:00:00到现在之间的时间戳
        NSTimeInterval time = 5*24*3600+components.weekday*24*3600+components.hour*3600+components.minute*60+components.second;
        if (timestamp < [self getLocalCurrentTimestamp] - time) {
            return [self dateTransformToDateStringWithMode:timeFormatterMode date:date];
        }else{
            NSDateComponents *resultComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:date];
            NSString *resultTimeStr = @"";
            switch (resultComponents.weekday) {
                case 1:
                    resultTimeStr = @"星期日";
                    break;
                case 2:
                    resultTimeStr = @"星期一";
                    break;
                case 3:
                    resultTimeStr = @"星期二";
                    break;
                case 4:
                    resultTimeStr = @"星期三";
                    break;
                case 5:
                    resultTimeStr = @"星期四";
                    break;
                case 6:
                    resultTimeStr = @"星期五";
                    break;
                case 7:
                    resultTimeStr = @"星期六";
                    break;
                    
                default:
                    break;
            }
            return resultTimeStr;
        }
    }
}

# pragma mark - 剩余n天n小时等
- (NSString *)timeTransformTypeTwo:(NSTimeInterval)endTimestamp withCurrentTimestamp:(NSTimeInterval)currentTimestamp{
    NSDate *endDate = [self timestampTransformToDate:endTimestamp];
    NSDate *currentDate = [self timestampTransformToDate:currentTimestamp];
    NSTimeInterval space = [endDate timeIntervalSinceDate:currentDate];
    long days = ((long)space) / (3600 * 24);
    long hours = ((long)space) % (3600 * 24) / 3600;
    long mins = ((long)space) % (3600 * 24) % 3600 / 60;
    long secs = ((long)space) % (3600 * 24) % 3600 % 60;
    if (days > 0) {
        if (hours > 0) {
            return [NSString stringWithFormat:@"剩余%ld天%ld小时",days,hours];
        }else{
            return [NSString stringWithFormat:@"剩余%ld天",days];
        }
    }else if (hours > 0){
        if (mins > 0) {
            return [NSString stringWithFormat:@"剩余%ld小时%ld分钟",hours,mins];
        }else{
            return [NSString stringWithFormat:@"剩余%ld小时",hours];
        }
    }else if (mins > 0){
        if (secs > 0) {
            return [NSString stringWithFormat:@"剩余%ld分钟%ld秒",mins,secs];
        }else{
            return [NSString stringWithFormat:@"剩余%ld分钟",mins];
        }
    }else if (secs > 0){
        return [NSString stringWithFormat:@"剩余%ld秒",secs];
    }
    return @"";
}

# pragma mark - n天n小时前
- (NSString *)timeTransformTypeThree:(NSTimeInterval)startTimestamp withCurrentTimestamp:(NSTimeInterval)currentTimestamp isNeedSend:(BOOL)isNeedSend{
    NSDate *startDate = [self timestampTransformToDate:startTimestamp];
    NSDate *currentDate = [self timestampTransformToDate:currentTimestamp];
    NSTimeInterval space = [currentDate timeIntervalSinceDate:startDate];
    long days = ((long)space) / (3600 * 24);
    long hours = ((long)space) % (3600 * 24) / 3600;
    long mins = ((long)space) % (3600 * 24) % 3600 / 60;
    long secs = ((long)space) % (3600 * 24) % 3600 % 60;
    if (days > 0) {
        if (hours > 0 && isNeedSend) {
            return [NSString stringWithFormat:@"%ld天%ld小时前",days,hours];
        }else{
            return [NSString stringWithFormat:@"%ld天前",days];
        }
    }else if (hours > 0){
        if (mins > 0 && isNeedSend) {
            return [NSString stringWithFormat:@"%ld小时%ld分钟前",hours,mins];
        }else{
            return [NSString stringWithFormat:@"%ld小时前",hours];
        }
    }else if (mins > 0){
        if (secs > 0 && isNeedSend) {
            return [NSString stringWithFormat:@"%ld分钟%ld秒前",mins,secs];
        }else{
            return [NSString stringWithFormat:@"%ld分钟前",mins];
        }
    }else if (secs > 1){
        return [NSString stringWithFormat:@"%ld秒前",secs];
    }
    return @"刚刚";
}

- (NSString *)secondChangeDayHourMin:(long)space{
    long days = ((long)space) / (3600 * 24);
    long hours = ((long)space) % (3600 * 24) / 3600;
    long mins = ((long)space) % (3600 * 24) % 3600 / 60;
    long secs = ((long)space) % (3600 * 24) % 3600 % 60;
    
    NSString *time = [NSString stringWithFormat:@"%02ld、%02ld、%02ld、%02ld",days,hours,mins,secs];
    return time;
}

/*!
 @brief 天、时、分钟、秒转秒
 */
- (NSInteger)dayHourMinChangeSecond:(NSString *)time{
    NSArray * timeArr = [time componentsSeparatedByString:@":"];
    NSInteger mins = [timeArr[0] integerValue];
    NSInteger seconds = [timeArr[1] integerValue];
    return mins*60+seconds;
}

/*!
 @brief 秒转分钟、秒
 */
- (NSString *)minChangeSecond:(NSInteger)time{
    long mins = time / 60;
    long secs = time % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",mins,secs];
}

# pragma mark - 返回两个时间戳之间相隔的天数
- (NSString *)timeTransformTypeFourth:(NSTimeInterval)endTimestamp withCurrentTimestamp:(NSTimeInterval)currentTimestamp
{
    NSDate *endDate = [self timestampTransformToDate:endTimestamp];
    NSDate *currentDate = [self timestampTransformToDate:currentTimestamp];
    NSTimeInterval space = [endDate timeIntervalSinceDate:currentDate];
    long days = ((long)space) / (3600 * 24);
    return [NSString stringWithFormat:@"%ld",days];
}
- (NSString *)timeTransformTypeFive:(NSTimeInterval)startTimestamp timeFormatterMode:(JSTimeFormatterMode)timeFormatterMode
{
    NSInteger currentTimestamp = [self getLocalCurrentTimestamp];
    NSInteger timestamp = currentTimestamp - startTimestamp;
//    if(timestamp > 31536000){
        NSString * dateStr = [self timestampTransformToDateStringWithMode:timeFormatterMode timestamp:startTimestamp];
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        formater.dateFormat = @"yyyy-MM-dd";
        NSDate *sendDate  = [formater dateFromString:dateStr];
        if (!sendDate.jk_isThisYear) {
            dateStr = [self dateTransformToDateStringWithMode:timeFormatterMode1 date:sendDate];
            return dateStr;
        }
////
        
//    }else
    if (timestamp > 86400) {
        
        NSString * dateStr = [self timestampTransformToDateStringWithMode:timeFormatterMode timestamp:startTimestamp];
        NSString * curDateStr = [self timestampTransformToDateStringWithMode:timeFormatterMode timestamp:currentTimestamp];
        NSString *date4Str = @"";
        if (dateStr.length>4) {
            date4Str = [dateStr substringToIndex:4];
        }
        NSString *curDate4Str = @"1";
        if (curDate4Str.length>4) {
            curDate4Str = [curDateStr substringToIndex:4];
        }
        
        if ([date4Str isEqualToString:curDate4Str]) {
            return dateStr;
        }else{
            NSString * dateStr = [self timestampTransformToDateStringWithMode:timeFormatterMode10 timestamp:startTimestamp];
            return dateStr;
        }
    }else{
        NSDate *startDate = [self timestampTransformToDate:startTimestamp];
        NSDate *currentDate = [self timestampTransformToDate:currentTimestamp];
        NSTimeInterval space = [currentDate timeIntervalSinceDate:startDate];
        long days = ((long)space) / (3600 * 24);
        long hours = ((long)space) % (3600 * 24) / 3600;
        long mins = ((long)space) % (3600 * 24) % 3600 / 60;
        if (days > 0) {
            
            return [NSString stringWithFormat:@"%ld天前",days];
            
        }else if (hours > 0){
            
            return [NSString stringWithFormat:@"%ld小时前",hours];
            
        }else if (mins > 0){
            
            return [NSString stringWithFormat:@"%ld分钟前",mins];
            
        }else{
            return @"刚刚";
        }
    }
}






@end
