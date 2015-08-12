//
//  HGOccasionTag.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGOccasionTag.h"

NSString* const kOccasionTagIdentifier = @"occasion_tag_identifier";
NSString* const kOccasionTagName = @"occasion_tag_name";
NSString* const kOccasionTagIcon = @"occasion_tag_icon";
NSString* const kOccasionTagCornerIcon = @"occasion_tag_corner_icon";

@implementation HGOccasionTag

@synthesize identifier;
@synthesize name;
@synthesize icon;
@synthesize cornerIcon;

-(void)dealloc {
    [identifier release];
    [name release];
    [icon release];
    [cornerIcon release];
	[super dealloc];
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        identifier = [[coder decodeObjectForKey:kOccasionTagIdentifier] retain];
        name = [[coder decodeObjectForKey:kOccasionTagName] retain];  
        icon = [[coder decodeObjectForKey:kOccasionTagIcon] retain];
        cornerIcon = [[coder decodeObjectForKey:kOccasionTagCornerIcon] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:identifier forKey:kOccasionTagIdentifier];
    [encoder encodeObject:name forKey:kOccasionTagName];
    [encoder encodeObject:icon forKey:kOccasionTagIcon];
    [encoder encodeObject:cornerIcon forKey:kOccasionTagCornerIcon];
}

@end
