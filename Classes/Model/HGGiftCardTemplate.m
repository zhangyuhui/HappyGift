//
//  HGGiftCardTemplate.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-23.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGGiftCardTemplate.h"

NSString* const kGiftCardTemplateIdentifier = @"gift_card_template_identifier";
NSString* const kGiftCardTemplateCardCategoryId = @"gift_card_template_card_category_id";
NSString* const kGiftCardTemplateName = @"gift_card_template_name";
NSString* const kGiftCardTemplateCoverImageUrl = @"gift_card_template_cover_image_url";
NSString* const kGiftCardTemplateDefaultContent = @"gift_card_template_default_content";

@implementation HGGiftCardTemplate

@synthesize identifier;
@synthesize cardCategoryId;
@synthesize name;
@synthesize coverImageUrl;
@synthesize backgroundColor;
@synthesize defaultContent;

-(void)dealloc {
    [identifier release];
    [cardCategoryId release];
    [name release];
    [coverImageUrl release];
    [backgroundColor release];
    [defaultContent release];
    
	[super dealloc];
}

- (NSString*)description {
    NSMutableString * text = [NSMutableString string];
	[text appendString:@"cardTemplate = {\n"];
	[text appendFormat:@"identifier=%@\n", self.identifier];
    [text appendFormat:@"cardCategoryId=%@\n", self.cardCategoryId];
	[text appendFormat:@"name=%@\n", self.name];
	[text appendFormat:@"coverImageUrl=%@\n", self.coverImageUrl];
	[text appendFormat:@"backgroundColor=%@\n", self.backgroundColor];
	[text appendFormat:@"defaultContent=%@\n", self.defaultContent];
	[text appendString:@"}\n"];
	return text;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        identifier = [[coder decodeObjectForKey:kGiftCardTemplateIdentifier] retain];
        cardCategoryId = [[coder decodeObjectForKey:kGiftCardTemplateCardCategoryId] retain];
        name = [[coder decodeObjectForKey:kGiftCardTemplateName] retain];
        coverImageUrl = [[coder decodeObjectForKey:kGiftCardTemplateCoverImageUrl] retain];
        defaultContent = [[coder decodeObjectForKey:kGiftCardTemplateDefaultContent] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:identifier forKey:kGiftCardTemplateIdentifier]; 
    [encoder encodeObject:cardCategoryId forKey:kGiftCardTemplateCardCategoryId]; 
    [encoder encodeObject:name forKey:kGiftCardTemplateName]; 
    [encoder encodeObject:coverImageUrl forKey:kGiftCardTemplateCoverImageUrl];
    [encoder encodeObject:defaultContent forKey:kGiftCardTemplateDefaultContent];
}
@end
