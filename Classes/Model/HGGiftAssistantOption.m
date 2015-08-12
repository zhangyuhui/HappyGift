//
//  HGGiftAssistantOption.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftAssistantOption.h"
NSString* const kGiftAssistantOptionImage = @"gift_assistant_option_image";
NSString* const kGiftAssistantOptionText = @"gift_assistant_option_text";
NSString* const kGiftAssistantOptionIndex = @"gift_assistant_option_index";

@implementation HGGiftAssistantOption
@synthesize image;
@synthesize text;
@synthesize index;
@synthesize selected;

-(void)dealloc{
    [image release];
    [text release];
	[super dealloc];
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        image = [[coder decodeObjectForKey:kGiftAssistantOptionImage] retain]; 
        text = [[coder decodeObjectForKey:kGiftAssistantOptionText] retain]; 
        index = [coder decodeIntForKey:kGiftAssistantOptionIndex];    
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:image forKey:kGiftAssistantOptionImage];
    [encoder encodeObject:text forKey:kGiftAssistantOptionText];
    [encoder encodeInt:index forKey:kGiftAssistantOptionIndex];
    
}
@end
