//
//  HGAstroTrend.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-4.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGAstroTrend.h"
#import "HGRecipient.h"

NSString* const kAstroTrendRecipient = @"astro_trend_recipient";
NSString* const kAstroTrendGiftSets = @"astro_trend_giftsets";
NSString* const kAstroTrendGiftWishes = @"astro_trend_giftwishes";
NSString* const kAstroTrendGiftSongs = @"astro_trend_giftsongs";
NSString* const kAstroTrendAstroId = @"astro_trend_astro_id";
NSString* const kAstroTrendTrendId = @"astro_trend_trend_id";
NSString* const kAstroTrendTrendName = @"astro_trend_trend_name";
NSString* const kAstroTrendTrendScore = @"astro_trend_trend_score";
NSString* const kAstroTrendTrendSummary = @"astro_trend_trend_summary";
NSString* const kAstroTrendTrendDetail = @"astro_trend_trend_detail";
NSString* const kAstroTrendGifGifts = @"astro_trend_gif_gifts";

@implementation HGAstroTrend

@synthesize recipient;
@synthesize giftSets;
@synthesize giftWishes;
@synthesize giftSongs;
@synthesize gifGifts;
@synthesize astroId;
@synthesize trendId;
@synthesize trendName;
@synthesize trendScore;
@synthesize trendSummary;
@synthesize trendDetail;

- (void)dealloc {
    [recipient release];
    [giftSets release];
    [giftWishes release];
    [giftSongs release];
    [astroId release];
    [trendId release];
    [trendName release];
    [trendSummary release];
    [trendDetail release];
    [gifGifts release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        recipient = [[coder decodeObjectForKey:kAstroTrendRecipient] retain];
        giftSets = [[coder decodeObjectForKey:kAstroTrendGiftSets] retain];
        giftWishes = [[coder decodeObjectForKey:kAstroTrendGiftWishes] retain];
        giftSongs = [[coder decodeObjectForKey:kAstroTrendGiftSongs] retain];
        gifGifts = [[coder decodeObjectForKey:kAstroTrendGifGifts] retain];
        astroId = [[coder decodeObjectForKey:kAstroTrendAstroId] retain];
        trendId = [[coder decodeObjectForKey:kAstroTrendTrendId] retain];
        trendName = [[coder decodeObjectForKey:kAstroTrendTrendName] retain];
        trendScore = [coder decodeIntForKey:kAstroTrendTrendScore];
        trendSummary = [[coder decodeObjectForKey:kAstroTrendTrendSummary] retain];
        trendDetail = [[coder decodeObjectForKey:kAstroTrendTrendDetail] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:recipient forKey:kAstroTrendRecipient]; 
    [encoder encodeObject:giftSets forKey:kAstroTrendGiftSets]; 
    [encoder encodeObject:giftWishes forKey:kAstroTrendGiftWishes];
    [encoder encodeObject:giftSongs forKey:kAstroTrendGiftSongs];
    [encoder encodeObject:gifGifts forKey:kAstroTrendGifGifts];
    [encoder encodeObject:astroId forKey:kAstroTrendAstroId];
    [encoder encodeObject:trendId forKey:kAstroTrendTrendId];
    [encoder encodeObject:trendName forKey:kAstroTrendTrendName]; 
    [encoder encodeInt:trendScore forKey:kAstroTrendTrendScore]; 
    [encoder encodeObject:trendSummary forKey:kAstroTrendTrendSummary]; 
    [encoder encodeObject:trendDetail forKey:kAstroTrendTrendDetail]; 
}

@end