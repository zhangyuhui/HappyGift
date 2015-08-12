//
//  HGGiftCard.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftCard.h"

NSString* const kGiftCardIdentifier = @"gift_card_identifier";
NSString* const kGiftCardCover = @"gift_card_cover";
NSString* const kGiftCardTitle = @"gift_card_title";
NSString* const kGiftCardName = @"gift_card_name";
NSString* const kGiftCardContent = @"gift_card_content";
NSString* const kGiftCardEnclosure = @"gift_card_enclosure";
NSString* const kGiftCardSender = @"gift_card_sender";

@implementation HGGiftCard
@synthesize identifier;
@synthesize cover;
@synthesize title;
@synthesize name;
@synthesize content;
@synthesize enclosure;
@synthesize sender;

-(void)dealloc{
    [identifier release];
    [cover release];
    [title release];
    [content release];
    [enclosure release];
    [sender release];
    [name release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        identifier = [[coder decodeObjectForKey:kGiftCardIdentifier] retain]; 
        cover = [[coder decodeObjectForKey:kGiftCardCover] retain]; 
        title = [[coder decodeObjectForKey:kGiftCardTitle] retain];
        name = [[coder decodeObjectForKey:kGiftCardName] retain];
        content = [[coder decodeObjectForKey:kGiftCardContent] retain];
        enclosure = [[coder decodeObjectForKey:kGiftCardEnclosure] retain];
        sender = [[coder decodeObjectForKey:kGiftCardSender] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:identifier forKey:kGiftCardIdentifier]; 
    [encoder encodeObject:cover forKey:kGiftCardCover];
    [encoder encodeObject:title forKey:kGiftCardTitle]; 
    [encoder encodeObject:name forKey:kGiftCardName];  
    [encoder encodeObject:content forKey:kGiftCardContent]; 
    [encoder encodeObject:enclosure forKey:kGiftCardEnclosure]; 
    [encoder encodeObject:sender forKey:kGiftCardSender]; 
    
}
@end
