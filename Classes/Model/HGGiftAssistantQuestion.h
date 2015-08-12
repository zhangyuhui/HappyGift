//
//  HGGiftAssistantQuestion.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGiftAssistantQuestion : NSObject <NSCoding>{
    NSString* identifier;
    NSString* name;
    NSArray*  options;
}

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSArray*  options;

@end
