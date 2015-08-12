//
//  HGGiftCardTemplate.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-23.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGiftCardTemplate : NSObject {
    NSString* identifier;
    NSString* cardCategoryId;
    NSString* name;
    NSString* coverImageUrl;
    UIColor* backgroundColor;
    NSString* defaultContent;
}

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* cardCategoryId;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* coverImageUrl;
@property (nonatomic, retain) UIColor* backgroundColor;
@property (nonatomic, retain) NSString* defaultContent;

@end
