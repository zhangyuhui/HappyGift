//
//  HGFeaturedGiftCollection.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGFeaturedGiftCollection : NSObject <NSCoding>{
    NSString* description;
    NSArray*  giftSets;
}
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSArray*  giftSets;
@end
