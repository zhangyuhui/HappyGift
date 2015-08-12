//
//  HGOccasionGiftCollection.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGOccasionGiftCollection.h"

NSString* const kOccasionGiftCollectionDescription = @"occasion_gift_collection_description";
NSString* const kOccasionGiftCollectionGiftSets = @"occasion_gift_collection_giftsets";
NSString* const kOccasionGiftCollectionGiftOccasion = @"occasion_gift_collection_occasion";
NSString* const kOccasionGiftCollectionGifGifts = @"occasion_gift_collection_gifGifts";

@implementation HGOccasionGiftCollection
@synthesize description;
@synthesize giftSets;
@synthesize gifGifts;
@synthesize occasion;

-(void)dealloc{
    [description release];
    [giftSets release];
    [occasion release];
    [gifGifts release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        description = [[coder decodeObjectForKey:kOccasionGiftCollectionDescription] retain];
        giftSets = [[coder decodeObjectForKey:kOccasionGiftCollectionGiftSets] retain]; 
        occasion = [[coder decodeObjectForKey:kOccasionGiftCollectionGiftOccasion] retain];
        gifGifts = [[coder decodeObjectForKey:kOccasionGiftCollectionGifGifts] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:description forKey:kOccasionGiftCollectionDescription]; 
    [encoder encodeObject:giftSets forKey:kOccasionGiftCollectionGiftSets];
    [encoder encodeObject:occasion forKey:kOccasionGiftCollectionGiftOccasion];
    [encoder encodeObject:gifGifts forKey:kOccasionGiftCollectionGifGifts];
}
@end
