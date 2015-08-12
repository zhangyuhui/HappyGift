//
//  HGOccasionGiftCollection.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGGiftOccasion.h"

@interface HGOccasionGiftCollection : NSObject <NSCoding>{
    HGGiftOccasion* occasion;
    NSString* description;
    NSArray*  giftSets;
    NSArray*  gifGifts;
}
@property (nonatomic, retain) HGGiftOccasion* occasion;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSArray*  giftSets;
@property (nonatomic, retain) NSArray*  gifGifts;
@end
