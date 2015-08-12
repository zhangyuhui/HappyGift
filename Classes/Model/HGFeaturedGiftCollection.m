//
//  HGFeaturedGiftCollection.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGFeaturedGiftCollection.h"

NSString* const kFeaturedGiftCollectionDescription = @"featured_gift_collection_description";
NSString* const kFeaturedGiftCollectionGiftSets = @"featured_gift_collection_giftsets";

@implementation HGFeaturedGiftCollection
@synthesize description;
@synthesize giftSets;

-(void)dealloc{
    [description release];
    [giftSets release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        NSString* theDescription = [coder decodeObjectForKey:kFeaturedGiftCollectionDescription]; 
        NSArray* theGiftSets = [coder decodeObjectForKey:kFeaturedGiftCollectionGiftSets];
               
        description = [[NSString alloc] initWithString:theDescription]; 
        giftSets = [[NSArray alloc] initWithArray:theGiftSets];    
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:description forKey:kFeaturedGiftCollectionDescription]; 
    [encoder encodeObject:giftSets forKey:kFeaturedGiftCollectionGiftSets];
    
}
@end
