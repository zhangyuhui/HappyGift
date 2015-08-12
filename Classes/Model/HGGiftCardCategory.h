//
//  HGGiftCardCategory.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-23.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGiftCardCategory : NSObject {
    NSString* identifier;
    NSString* name;
    NSString* descriptionText;
    
    NSArray* cardTemplates;
}
@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* descriptionText;
@property (nonatomic, retain) NSArray* cardTemplates;

@end
