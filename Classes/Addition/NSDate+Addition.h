//
//  NSDate+Addition.h
//  HappyGift
//
//  Created by Yuhui Zhang on 5/23/10.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Addition)

+ (NSString*)stringFromTimeInterval:(NSTimeInterval)theInterval; 
+ (NSString*)stringFromTimeIntervalSinceReferenceDate:(NSTimeInterval)theInterval;
- (BOOL)isLeapYear;
- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
+(NSDate*)dateFromYear: (NSInteger)year andMonth:(NSInteger)month andDay:(NSInteger)day;

@end
