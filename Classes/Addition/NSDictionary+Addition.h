//
//  NSDictionary+Addition.h
//  HappyGift
//
//  Created by Yuhui Zhang on 11-10-6.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (Additions)

- (BOOL)getBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (int)getIntValueForKey:(NSString *)key defaultValue:(int)defaultValue;
- (time_t)getTimeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue;
- (long long)getLongLongValueValueForKey:(NSString *)key defaultValue:(long long)defaultValue;
- (NSString *)getStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

@end
