//
//  HGGiftCardCategory.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-23.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGGiftCardCategory.h"

NSString* const kGiftCardCategoryIdentifier = @"gift_card_category_identifier";
NSString* const kGiftCardCategoryName = @"gift_card_category_name";
NSString* const kGiftCardCategoryDescriptionText = @"gift_card_category_description_text";
NSString* const kGiftCardCategoryCardTemplates = @"gift_card_category_card_templates";

@implementation HGGiftCardCategory
@synthesize identifier;
@synthesize name;
@synthesize descriptionText;
@synthesize cardTemplates;

-(void)dealloc {
    [identifier release];
    [name release];
    [descriptionText release];
    [cardTemplates release];
	[super dealloc];
}

- (NSString*)description {
    NSMutableString * text = [NSMutableString string];
	[text appendString:@"cardCategory = {\n"];
	[text appendFormat:@"identifier=%@\n", self.identifier];
	[text appendFormat:@"name=%@\n", self.name];
	[text appendFormat:@"description=%@\n", self.description];
	[text appendFormat:@"cardTemplates=%@\n", self.cardTemplates];
	[text appendString:@"}\n"];
	return text;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        identifier = [[coder decodeObjectForKey:kGiftCardCategoryIdentifier] retain];
        name = [[coder decodeObjectForKey:kGiftCardCategoryName] retain];
        descriptionText = [[coder decodeObjectForKey:kGiftCardCategoryDescriptionText] retain];
        cardTemplates = [[coder decodeObjectForKey:kGiftCardCategoryCardTemplates] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:identifier forKey:kGiftCardCategoryIdentifier]; 
    [encoder encodeObject:name forKey:kGiftCardCategoryName]; 
    [encoder encodeObject:descriptionText forKey:kGiftCardCategoryDescriptionText]; 
    [encoder encodeObject:cardTemplates forKey:kGiftCardCategoryCardTemplates];
}
@end
