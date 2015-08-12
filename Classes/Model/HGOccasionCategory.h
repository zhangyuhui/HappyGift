//
//  HGOccasionCategory.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-28.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGOccasionCategory : NSObject <NSCoding> {
    NSString* identifier;
    NSString* name;
    NSString* longName;
    NSString* icon;
    NSString* headerIcon;
    NSString* headerBackground;
}

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* longName;
@property (nonatomic, retain) NSString* icon;
@property (nonatomic, retain) NSString* headerIcon;
@property (nonatomic, retain) NSString* headerBackground;

@end
