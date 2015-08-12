//
//  HGGiftAssistantOption.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGiftAssistantOption : NSObject <NSCoding>{
    NSString* image;
    NSString* text;
    int       index;
    BOOL      selected;
}

@property (nonatomic, retain) NSString* image;
@property (nonatomic, retain) NSString* text;
@property (nonatomic, assign) int  index;
@property (nonatomic, assign) BOOL  selected;
@end
