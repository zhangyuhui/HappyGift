//
//  HGFriendEmotion.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-9.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGRecipient;

extern const int kFriendEmotionTypePositive;
extern const int kFriendEmotionTypeNegative;

@interface HGFriendEmotion: NSObject <NSCoding>  {
    HGRecipient* recipient;
    NSArray*  giftSets;
    NSArray*  gifGifts;
    
    NSArray* tweets;
    int emotionType;
    int score;
}

@property (nonatomic, retain) HGRecipient*  recipient;
@property (nonatomic, retain) NSArray*       giftSets;
@property (nonatomic, retain) NSArray* gifGifts;
@property (nonatomic, retain) NSArray*     tweets;
@property (nonatomic, assign) int emotionType;
@property (nonatomic, assign) int score;

@end
