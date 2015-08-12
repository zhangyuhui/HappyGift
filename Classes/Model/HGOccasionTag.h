//
//  HGOccasionTag.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGOccasionTag : NSObject <NSCoding> {
    NSString* identifier;
    NSString* name;
    NSString* icon;
    NSString* cornerIcon;
}

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* icon;
@property (nonatomic, retain) NSString* cornerIcon;

@end
