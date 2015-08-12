//
//  HGWish.m
//  HappyGift
//
//  Created by Zhang Yuhui on 12-7-9.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGWish.h"

NSString* const kWishContent = @"wish_content";

@implementation HGWish
@synthesize content;

- (void)dealloc {
    [content release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        content = [[coder decodeObjectForKey:kWishContent] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:content forKey:kWishContent]; 
}

@end