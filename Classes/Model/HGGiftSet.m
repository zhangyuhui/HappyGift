//
//  HGGiftSet.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftSet.h"
#import "HGDefines.h"
#import "HGGift.h"

NSString* const kGiftSetIdentifier = @"gift_set_identifier";
NSString* const kGiftSetName = @"gift_set_name";
NSString* const kGiftSetCover = @"gift_set_cover";
NSString* const kGiftSetThumb = @"gift_set_cover_thumb";
NSString* const kGiftSetDescription = @"gift_set_description";
NSString* const kGiftSetManufacturer = @"gift_set_manufacturer";
NSString* const kGiftSetGifts = @"gift_set_images";
NSString* const kGiftSetCanLetThemChoose = @"gift_set_can_let_them_choose";

@implementation HGGiftSet
@synthesize identifier;
@synthesize name;
@synthesize cover;
@synthesize thumb;
@synthesize description;
@synthesize manufacturer;
@synthesize canLetThemChoose;
@synthesize gifts;

-(void)dealloc{
    [identifier release];
    [name release];
    [cover release];
    [thumb release];
    [description release];
    [manufacturer release];
    [gifts release];
	[super dealloc];
}

- (id)initWithProductJsonDictionary:(NSDictionary *)productJsonDictionary {
    self = [super init];
    
    if (self) {
        NSDictionary* productGroupDictionary = [productJsonDictionary objectForKey:@"group"];
        if (productGroupDictionary != nil) {
            NSString* theGroupIdentifier = [productGroupDictionary objectForKey:@"product_group_id"];
            NSString* theGroupCover = [productGroupDictionary objectForKey:@"image"];
            NSString* theGroupCoverMid = [productGroupDictionary objectForKey:@"mid_image"];
            NSString* theGroupCoverSmall = [productGroupDictionary objectForKey:@"small_image"];
            NSString* theGroupName = [productGroupDictionary objectForKey:@"name"];
            NSString* theGroupDescription = [productGroupDictionary objectForKey:@"description"];
            NSString* theGroupCanLetThemChoose = [productGroupDictionary objectForKey:@"let_them_choose"];
            
            self.identifier = theGroupIdentifier;
            self.name = theGroupName;
            self.cover = theGroupCover;
            self.thumb = isRetina ? theGroupCoverMid : theGroupCoverSmall;
            self.description = theGroupDescription;
            self.canLetThemChoose = [@"1" isEqualToString: theGroupCanLetThemChoose] ? YES : NO;
            
            NSArray* productsDictionary = [productJsonDictionary objectForKey:@"products"];
            NSMutableArray* theGifts = [[NSMutableArray alloc] init];
            for (NSDictionary* productDictionary in productsDictionary) {
                HGGift* gift = [[HGGift alloc] initWithProductJsonDictionary:productDictionary];
                gift.giftSetIdentifier = self.identifier;
                [theGifts addObject:gift];
                if (self.manufacturer == nil) {
                    self.manufacturer = gift.manufacturer;
                }
                [gift release];
            }
            self.gifts = theGifts;
            [theGifts release];
        } else {
            HGGift* gift = [[HGGift alloc] initWithProductJsonDictionary:productJsonDictionary];
            self.name = gift.name;
            self.cover = gift.cover;
            self.thumb = gift.thumb;
            self.description = gift.description;
            self.manufacturer = gift.manufacturer;
            self.canLetThemChoose = NO;
            self.gifts = [NSArray arrayWithObject:gift];
            [gift release];
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        identifier = [[coder decodeObjectForKey:kGiftSetIdentifier] retain]; 
        name = [[coder decodeObjectForKey:kGiftSetName] retain]; 
        cover = [[coder decodeObjectForKey:kGiftSetCover] retain];
        thumb = [[coder decodeObjectForKey:kGiftSetThumb] retain];
        description = [[coder decodeObjectForKey:kGiftSetDescription] retain];
        manufacturer = [[coder decodeObjectForKey:kGiftSetManufacturer] retain];
        canLetThemChoose = [coder decodeBoolForKey:kGiftSetCanLetThemChoose];
        gifts = [[coder decodeObjectForKey:kGiftSetGifts] retain];    
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:identifier forKey:kGiftSetIdentifier];
    [encoder encodeObject:name forKey:kGiftSetName];
    [encoder encodeObject:cover forKey:kGiftSetCover];
    [encoder encodeObject:thumb forKey:kGiftSetThumb];
    [encoder encodeObject:description forKey:kGiftSetDescription]; 
    [encoder encodeObject:manufacturer forKey:kGiftSetManufacturer];  
    [encoder encodeBool:canLetThemChoose forKey:kGiftSetCanLetThemChoose];
    [encoder encodeObject:gifts forKey:kGiftSetGifts];
    
}
@end
