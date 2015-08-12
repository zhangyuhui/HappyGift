//
//  HGSplash.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGSplash.h"

NSString* const kSplashImage = @"splash_image";
NSString* const kSplashUrl = @"splash_url";
NSString* const kSplashTitle = @"splash_title";
NSString* const kSplashPubDate = @"splash_pubDate";

@implementation HGSplash
@synthesize image;
@synthesize url;
@synthesize title;
@synthesize pubDate;

-(void)dealloc{
	[image release];
    [url release];
    [title release];
    [pubDate release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        UIImage* theImage = [coder decodeObjectForKey:kSplashImage]; 
        NSString* theUrl = [coder decodeObjectForKey:kSplashUrl];
        NSString* theTitle = [coder decodeObjectForKey:kSplashTitle];
        NSString* thePubDate = [coder decodeObjectForKey:kSplashPubDate];
               
        image = [theImage retain]; 
        url = [theUrl retain];
        title = [theTitle retain];
        pubDate = [thePubDate retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:image forKey:kSplashImage]; 
    [encoder encodeObject:url forKey:kSplashUrl];
    [encoder encodeObject:title forKey:kSplashTitle]; 
    [encoder encodeObject:pubDate forKey:kSplashPubDate];
    
}
@end
