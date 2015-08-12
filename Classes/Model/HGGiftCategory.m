//
//  HGGiftCategory.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftCategory.h"

NSString* const kGiftCategoryIdentifier = @"gift_category_identifier";
NSString* const kGiftCategoryName = @"gift_category_name";
NSString* const kGiftCategoryDescription = @"gift_category_description";
NSString* const kGiftCategoryCover = @"gift_category_cover";
NSString* const kGiftCategoryCoverSelected = @"gift_category_cover_selected";

@implementation HGGiftCategory
@synthesize identifier;
@synthesize name;
@synthesize description;
@synthesize cover;
@synthesize coverSelected;

-(void)dealloc{
    [identifier release];
    [name release];
    [description release];
    [cover release];
    [coverSelected release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        NSString* theIdentifier = [coder decodeObjectForKey:kGiftCategoryIdentifier]; 
        NSString* theName = [coder decodeObjectForKey:kGiftCategoryName];
        NSString* theDescription = [coder decodeObjectForKey:kGiftCategoryDescription];
        NSString* theCover = [coder decodeObjectForKey:kGiftCategoryCover];
        NSString* theCoverSelected = [coder decodeObjectForKey:kGiftCategoryCoverSelected];
               
        identifier = [[NSString alloc] initWithString:theIdentifier]; 
        name = [[NSString alloc] initWithString:theName]; 
        description = [[NSString alloc] initWithString:theDescription];
        cover = [[NSString alloc] initWithString:theCover];
        coverSelected = [[NSString alloc] initWithString:theCoverSelected];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:identifier forKey:kGiftCategoryIdentifier]; 
    [encoder encodeObject:name forKey:kGiftCategoryName];
    [encoder encodeObject:description forKey:kGiftCategoryDescription]; 
    [encoder encodeObject:cover forKey:kGiftCategoryCover]; 
    [encoder encodeObject:coverSelected forKey:kGiftCategoryCoverSelected]; 
}
@end
