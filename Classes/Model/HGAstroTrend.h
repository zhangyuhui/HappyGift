//
//  HGAstroTrend.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-4.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGRecipient;

@interface HGAstroTrend: NSObject <NSCoding>  {
    HGRecipient* recipient;
    NSArray*  giftSets;
    NSArray*  giftWishes;
    NSArray*  giftSongs;
    NSArray*  gifGifts;
    
    NSString* astroId;
    NSString* trendId;
    NSString* trendName;
    int trendScore;
    NSString* trendSummary;
    NSString* trendDetail;
}

@property (nonatomic, retain) HGRecipient*  recipient;
@property (nonatomic, retain) NSArray*      giftSets;
@property (nonatomic, retain) NSArray*      giftWishes;
@property (nonatomic, retain) NSArray*      giftSongs;
@property (nonatomic, retain) NSArray*      gifGifts;
@property (nonatomic, retain) NSString*     astroId;
@property (nonatomic, retain) NSString*     trendId;
@property (nonatomic, retain) NSString*     trendName;
@property (nonatomic, assign) int trendScore;
@property (nonatomic, retain) NSString* trendSummary;
@property (nonatomic, retain) NSString* trendDetail;

@end
