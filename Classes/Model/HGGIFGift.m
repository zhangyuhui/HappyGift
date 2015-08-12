//
//  HGGIFGift.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-27.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGGIFGift.h"

NSString* const kGIFGiftIdentifier = @"gif_gift_identifier";
NSString* const kGIFGiftName = @"gif_gift_name";
NSString* const kGIFGiftImage = @"gif_gift_image";
NSString* const kGIFGiftGIF = @"gif_gift_gif";
NSString* const kGIFGiftWishes = @"gif_gift_wishes";

@implementation HGGIFGift
@synthesize identifier;
@synthesize name;
@synthesize image;
@synthesize gif;
@synthesize wishes;

- (void)dealloc {
    [identifier release];
    [name release];
    [image release];
    [gif release];
    [wishes release];
    [super dealloc];
}

- (id)initWithGIFGiftJsonDictionary:(NSDictionary*)gifGiftJsonDictionary {
    self = [super init];
    
    if (self) {
        self.identifier = [gifGiftJsonDictionary objectForKey:@"image_id"];
        self.name = [gifGiftJsonDictionary objectForKey:@"name"];
        self.image = [gifGiftJsonDictionary objectForKey:@"image"];
        self.wishes = [gifGiftJsonDictionary objectForKey:@"wish"];
        self.gif = [gifGiftJsonDictionary objectForKey:@"animate"];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        identifier = [[coder decodeObjectForKey:kGIFGiftIdentifier] retain];
        name = [[coder decodeObjectForKey:kGIFGiftName] retain];
        image = [[coder decodeObjectForKey:kGIFGiftImage] retain];
        gif = [[coder decodeObjectForKey:kGIFGiftGIF] retain];
        wishes = [[coder decodeObjectForKey:kGIFGiftWishes] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:identifier forKey:kGIFGiftIdentifier]; 
    [encoder encodeObject:name forKey:kGIFGiftName]; 
    [encoder encodeObject:image forKey:kGIFGiftImage];
    [encoder encodeObject:gif forKey:kGIFGiftGIF];
    [encoder encodeObject:wishes forKey:kGIFGiftWishes];
}

@end