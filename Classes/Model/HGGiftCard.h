//
//  HGGiftCard.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGRecipient.h"

@interface HGGiftCard : NSObject <NSCoding>{
    NSString* identifier;
    NSString* cover;
    NSString* name;
    NSString* title;
    NSString* content;
    NSString* enclosure;
    NSString* sender;
}
@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* cover;
@property (nonatomic, retain) NSString* content;
@property (nonatomic, retain) NSString* enclosure;
@property (nonatomic, retain) NSString* sender;

@end
