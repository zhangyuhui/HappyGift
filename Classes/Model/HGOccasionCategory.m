//
//  HGOccasionCategory.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-28.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGOccasionCategory.h"

NSString* const kOccasionCategoryIdentifier = @"occasion_category_identifier";
NSString* const kOccasionCategoryName = @"occasion_category_name";
NSString* const kOccasionCategoryLongName = @"occasion_category_long_name";
NSString* const kOccasionCategoryIcon = @"occasion_category_icon";
NSString* const kOccasionCategoryHeaderIcon = @"occasion_category_header_icon";
NSString* const kOccasionCategoryHeaderBackground = @"occasion_category_header_background";

@implementation HGOccasionCategory
@synthesize identifier;
@synthesize name;
@synthesize longName;
@synthesize icon;
@synthesize headerIcon;
@synthesize headerBackground;

-(void)dealloc {
    [identifier release];
    [name release];
    [longName release];
    [icon release];
    [headerIcon release];
    [headerBackground release];
	[super dealloc];
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        identifier = [[coder decodeObjectForKey:kOccasionCategoryIdentifier] retain];
        name = [[coder decodeObjectForKey:kOccasionCategoryName] retain];  
        longName = [[coder decodeObjectForKey:kOccasionCategoryLongName] retain];
        icon = [[coder decodeObjectForKey:kOccasionCategoryIcon] retain];
        headerIcon = [[coder decodeObjectForKey:kOccasionCategoryHeaderIcon] retain];
        headerBackground = [[coder decodeObjectForKey:kOccasionCategoryHeaderBackground] retain]; 
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:identifier forKey:kOccasionCategoryIdentifier];
    [encoder encodeObject:name forKey:kOccasionCategoryName];
    [encoder encodeObject:longName forKey:kOccasionCategoryLongName];
    [encoder encodeObject:icon forKey:kOccasionCategoryIcon];
    [encoder encodeObject:headerIcon forKey:kOccasionCategoryHeaderIcon];
    [encoder encodeObject:headerBackground forKey:kOccasionCategoryHeaderBackground];
}

@end
