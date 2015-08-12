//
//  HGContactInfoViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-28.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//


#import "HGUtility.h"
#import "NSDate+Addition.h"
#import "HappyGiftAppDelegate.h"

@implementation HGUtility

+ (BOOL)isValidEmail:(NSString*)email {
    NSString* emailRegex = @"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
 //   NSString *emailRegex = @"^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:email];
}

+ (NSString*) normalizeMobileNumber:(NSString*) mobile {
    NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:@"-() "];
    NSString * normalizedNumber = [[mobile componentsSeparatedByCharactersInSet: characterSet] componentsJoinedByString: @""];
    return normalizedNumber;
}

+ (BOOL)isValidMobileNumber:(NSString*)mobile {
    mobile = [HGUtility normalizeMobileNumber:mobile];
    BOOL result = [mobile length] >= 11 ? YES : NO;
    if (result == YES) {
        NSString *mobileRegex = @"^[0-9+]+$"; 
        NSPredicate *mobileTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex]; 
        return [mobileTest evaluateWithObject:mobile];
    } else {
        return NO;
    }
}

+ (BOOL)validatePostCode:(NSString*)postCode {
    if (!postCode) {
        return NO;
    }
    
    NSString *numberRegex = @"^[0-9]{6}$"; 
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex]; 
    return [numberTest evaluateWithObject:postCode];
}

+ (BOOL)isEnglishCharacter:(unichar)character {
    return ('a' <= character && character <= 'z') || ('A' <= character && character <= 'Z') ? YES : NO;
}

+ (BOOL)isEnglishNameFirstName:(NSString*)firstName andLastName:(NSString*)lastName {
    BOOL result = NO;
    if (firstName && ![@"" isEqualToString:firstName]) {
        unichar c = [firstName characterAtIndex:0];
        if ([HGUtility isEnglishCharacter:c] == YES) {
            result = YES;
        }
    }
    
    if (result == NO && lastName && ![@"" isEqualToString:lastName]) {
        unichar c = [lastName characterAtIndex:0];
        if ([HGUtility isEnglishCharacter:c] == YES) {
            result = YES;
        }
    }
    
    return result;
}

+ (NSString*) formatBirthday:(NSString *)yearMonthDay {
    NSArray* monthAndDay = [HGUtility getMonthAndDay:yearMonthDay];
    NSString* result = nil;
    if ([monthAndDay count] == 2) {
        int month = [[monthAndDay objectAtIndex:0] intValue];
        int day = [[monthAndDay objectAtIndex:1] intValue];
        result = [NSString stringWithFormat:@"%d月%d日 生日", month, day];
    }
    return result;
}

+ (NSArray*) getMonthAndDay:(NSString *)yearMonthDay {
    NSArray* result = nil;
    NSArray *array = [yearMonthDay componentsSeparatedByString:@"-"];
    int count = [array count];
    if (count == 3 || count == 2) {
        int month = [[array objectAtIndex: 0] intValue];
        int day = [[array objectAtIndex: 1] intValue];
        if (count == 3) {
            month = [[array objectAtIndex: 1] intValue];
            day = [[array objectAtIndex: 2] intValue];
        }
        
        if (month > 0 && month <= 12 && day > 0 && day <= 31) {
            result = [NSArray arrayWithObjects: [NSNumber numberWithInteger:month], [NSNumber numberWithInteger:day], nil];
        }
    }
    return result;
}

+ (NSArray*) getYearMonthAndDay:(NSString *)yearMonthDay {
    NSArray* result = nil;
    NSArray *array = [yearMonthDay componentsSeparatedByString:@"-"];
    if ([array count] == 3) {
        int year = [[array objectAtIndex: 0] intValue];
        int month = [[array objectAtIndex: 1] intValue];
        int day = [[array objectAtIndex: 2] intValue];
        
        if (month > 0 && month <= 12 && day > 0 && day <= 31 && year > 0 && year < 2200) {
            result = [NSArray arrayWithObjects: [NSNumber numberWithInteger:year], [NSNumber numberWithInteger:month], [NSNumber numberWithInteger:day], nil];
        }
    }
    return result;
}

+ (NSTimeInterval) timeIntervalSinceNow:(NSInteger)year andMonth:(NSInteger)month andDay:(NSInteger)day {
    return [[NSDate dateFromYear: year andMonth:month andDay:day] timeIntervalSinceNow];
}

+ (NSInteger) offsetTodayOf:(NSString*)birthday {
    NSArray* monthAndDay = [self getMonthAndDay:birthday];
    if ([monthAndDay count] != 2) {
        return 9999;
    }
    
    int month = [[monthAndDay objectAtIndex:0] intValue];
    int day = [[monthAndDay objectAtIndex:1] intValue];
    
    NSDate *today = [NSDate date];
    int year = [today year];
    int curMonth = [today month];
    int curDay = [today day];
    
    if (curMonth > month || (curMonth == month && curDay > day)) {
        year++;
    }
    
    if (month == 2 && day == 29) {
        while (![[NSDate dateFromYear: year andMonth:1 andDay:1] isLeapYear]) {
            year++;
        }
    }
    
    NSTimeInterval timeInterval = [self timeIntervalSinceNow:year andMonth:month andDay:day];
    int x = ceil(timeInterval / 86400.0);
    
    return x;
}

// form yyyy-mm-dd or mm-dd
+ (NSString*) formatBirthdayText:(NSString*) birthdayYearMonthDay forShortDescription:(BOOL)isShort {
    NSString* birthday = [HGUtility formatBirthday:birthdayYearMonthDay];
    if (birthday) {
        int offset = [HGUtility offsetTodayOf:birthdayYearMonthDay];
        NSString* text;
        if (offset == 0) {
            text = @"今天生日";
        } else if (offset == 1) {
            text = @"明天生日";
        } else if (offset == 2) {
            text = @"后天生日";
        } else {
            if (isShort == YES) {
                text = [NSString stringWithFormat:@"%@", birthday];
            } else {
                text = [NSString stringWithFormat:@"%@ | 还有%d天", birthday, offset];
            }
        }
        return text;
    } else {
        return nil;
    }
}
// form yyyy-mm-dd to m月d日
+ (NSString*) formatShortDate:(NSString *)yearMonthDay {
    NSArray* monthAndDay = [HGUtility getMonthAndDay:yearMonthDay];
    NSString* result = nil;
    if ([monthAndDay count] == 2) {
        int month = [[monthAndDay objectAtIndex:0] intValue];
        int day = [[monthAndDay objectAtIndex:1] intValue];
        result = [NSString stringWithFormat:@"%d月%d日", month, day];
    }
    return result;
}

// form yyyy-mm-dd to yyyy年m月d日
+ (NSString*) formatLongDate:(NSString *)yearMonthDay {
    NSArray* yearAndMonthAndDay = [HGUtility getYearMonthAndDay:yearMonthDay];
    NSString* result = nil;
    if ([yearAndMonthAndDay count] == 3) {
        int year = [[yearAndMonthAndDay objectAtIndex:0] intValue];
        int month = [[yearAndMonthAndDay objectAtIndex:1] intValue];
        int day = [[yearAndMonthAndDay objectAtIndex:2] intValue];
        result = [NSString stringWithFormat:@"%04d年%d月%d日", year, month, day];
    }
    return result;
}

+ (NSString*) formatTweetDateWithTime:(NSString*) tweetDate {
    NSString* result;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [dateFormatter dateFromString:tweetDate];
    if (date == nil) {
        result = tweetDate;
    } else {
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        result = [dateFormatter stringFromDate:date];
    }
    
    [dateFormatter release];
    return result;
}

+ (NSString*) appBuild{
    NSString* build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    return build;    
}

+ (NSString*) appVersion {
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (BOOL) wifiReachable {
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.wifiReachable;
}

+ (UIImage*) defaultImage:(CGSize)defaultImageSize {
    UIGraphicsBeginImageContext(defaultImageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddRect(context, CGRectMake(0, 0, defaultImageSize.width, defaultImageSize.height));
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [HappyGiftAppDelegate imageFrameColor].CGColor);
    CGContextAddRect(context, CGRectMake(0.0, 0.0, defaultImageSize.width, defaultImageSize.height));
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    UIImage *theDefaultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theDefaultImage;
}

+ (NSString*) displayTextForProvince:(NSString*)province andCity:(NSString*)city {
    if ([province isEqualToString:@"北京"] || [province isEqualToString:@"上海"] || [province isEqualToString:@"天津"] || [province isEqualToString:@"重庆"]) {
        return city;
    } else {
        return [NSString stringWithFormat:@"%@ %@", province, city];
    }
}

@end;