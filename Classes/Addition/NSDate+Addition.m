//
//  NSDate+Addition.m
//  HappyGift
//
//  Created by Yuhui Zhang on 5/23/10.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "NSDate+Addition.h"

#define TIMESTAMP_DATA_FORMAT @"MM-dd HH:mm"

@implementation NSDate (Addition)

+ (NSString*)stringFromTimeInterval:(NSTimeInterval)theInterval {

    int seconds, minutes, hours, days, interval;
    interval = (int) theInterval;
    if (interval < 0) interval = -1 * interval;
    
    if (interval < 1) return @"";
    
    
    interval = [[NSDate date] timeIntervalSince1970] - interval;
    
    seconds = minutes = hours = days = 0;
    
    if (interval >= 0) {
        seconds =  interval % 60;
    }
    if (interval >= 60) {
        minutes = (interval / 60) % 60;
    }
    if (interval >= 3600) {
        hours = (interval / 3600);
    }
    if (interval >= 86400) {
        days = interval / 86400;
    }
    
    if (days > 0) {
        /*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:TIMESTAMP_DATA_FORMAT];
        NSDate *dateObject = [NSDate dateWithTimeIntervalSince1970:theInterval];
        NSString *dateString = [dateFormatter stringFromDate:dateObject];
        [dateFormatter release];
        return dateString;*/
        return (days == 1) ? NSLocalizedString(@"1 day ago", nil) : [NSString stringWithFormat: NSLocalizedString(@"%i days ago", nil), days];
    }
    else if (hours > 0) {
        return (hours == 1) ? NSLocalizedString(@"1 hour ago", nil) : [NSString stringWithFormat: NSLocalizedString(@"%i hours ago", nil), hours];
    } 
    else if (minutes > 0) {
        return (minutes == 1) ? NSLocalizedString(@"1 minute ago", nil) : [NSString stringWithFormat: NSLocalizedString(@"%i minutes ago", nil), minutes];
    } 
    else {
         return (seconds == 1) ? NSLocalizedString(@"1 second ago", nil) : [NSString stringWithFormat: NSLocalizedString(@"%i seconds ago", nil), seconds];
    }
}


+ (NSString*)stringFromTimeIntervalSinceReferenceDate:(NSTimeInterval)theInterval {
    NSCalendar* currentCalendar = [NSCalendar currentCalendar];
    NSCalendarUnit units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents* now = [currentCalendar components: units fromDate: [NSDate date]];
    NSDateComponents* then = [currentCalendar components: units fromDate: [NSDate dateWithTimeIntervalSinceReferenceDate: theInterval]];
    
    NSTimeInterval timeIntervalSinceNow = [[NSDate dateWithTimeIntervalSinceReferenceDate: theInterval] timeIntervalSinceNow];
    
    int nowDay = now.week * 7 + now.weekday;
    int thenDay = then.week * 7 + then.weekday;
    
    if (nowDay == thenDay) {
        return [self stringFromTimeInterval: timeIntervalSinceNow];
    }
    
    if (nowDay - 1 == thenDay) {
        return NSLocalizedString(@"Yesterday", nil);
    }
    
    if (nowDay - 7 < thenDay) {
        switch (then.weekday) {
            case 0:
                return NSLocalizedString(@"Sunday", nil);
            case 1:
                return NSLocalizedString(@"Monday", nil);
            case 2:
                return NSLocalizedString(@"Tuesday", nil);
            case 3: 
                return NSLocalizedString(@"Wednesday", nil);
            case 4: 
                return NSLocalizedString(@"Thursday", nil);
            case 5: 
                return NSLocalizedString(@"Friday", nil);
            case 6: 
                return NSLocalizedString(@"Saturday", nil);
        }
    }

    return [self stringFromTimeInterval: timeIntervalSinceNow];
}

-(BOOL)isLeapYear {
    NSInteger y = [self year];
    return ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0) ? YES : NO;
}

-(NSInteger)year {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSInteger year = [[formatter stringFromDate:self] intValue];
    [formatter release];
    return year;
}

-(NSInteger)month {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M"];
    NSInteger month = [[formatter stringFromDate:self] intValue];
    [formatter release];
    return month;
}

-(NSInteger)day {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d"];
    NSInteger day = [[formatter stringFromDate:self] intValue];
    [formatter release];
    return day;
}

+(NSDate*)dateFromYear: (NSInteger)year andMonth:(NSInteger)month andDay:(NSInteger)day {
    NSString* dayStr = [NSString stringWithFormat:@"%04d-%02d-%02d", year, month, day];

    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formater dateFromString:dayStr];

    [formater release];
    return date;
}

@end
