//
//  HGContactInfoViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-28.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface HGUtility : NSObject {
}

+ (BOOL)isValidEmail:(NSString*)email;
+ (BOOL)isValidMobileNumber:(NSString*)mobile;
+ (NSString*) normalizeMobileNumber:(NSString*) mobile;
+ (BOOL)validatePostCode:(NSString*)postCode;
+ (BOOL)isEnglishNameFirstName:(NSString*)firstName andLastName:(NSString*)lastName;

+ (NSArray*) getMonthAndDay:(NSString *)yearMonthDay;
+ (NSTimeInterval) timeIntervalSinceNow:(NSInteger)year andMonth:(NSInteger)month andDay:(NSInteger)day;
+ (NSInteger) offsetTodayOf:(NSString*)birthday;
+ (NSString*) formatBirthdayText:(NSString*) birthdayYearMonthDay forShortDescription:(BOOL)isShort ;
+ (NSString*) formatShortDate:(NSString *)yearMonthDay;
+ (NSString*) formatLongDate:(NSString *)yearMonthDay;
+ (NSString*) formatTweetDateWithTime:(NSString*) tweetDate;
+ (NSString*) appVersion;
+ (NSString*) appBuild;
+ (BOOL) wifiReachable;
+ (UIImage*) defaultImage:(CGSize)defaultImageSize;
+ (NSString*) displayTextForProvince:(NSString*)province andCity:(NSString*)city;

@end