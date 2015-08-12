//
//  HGGiftAssistantQuestion.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftAssistantQuestion.h"
NSString* const kGiftAssistantQuestionIdentifier = @"gift_assistant_question_identifier";
NSString* const kGiftAssistantQuestionName = @"gift_assistant_question_name";
NSString* const kGiftAssistantQuestionOptions = @"gift_assistant_question_options";

@implementation HGGiftAssistantQuestion
@synthesize identifier;
@synthesize name;
@synthesize options;

-(void)dealloc{
    [identifier release];
    [name release];
    [options release];
	[super dealloc];
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        identifier = [[coder decodeObjectForKey:kGiftAssistantQuestionIdentifier] retain]; 
        name = [[coder decodeObjectForKey:kGiftAssistantQuestionName] retain]; 
        options = [[coder decodeObjectForKey:kGiftAssistantQuestionOptions] retain];    
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:identifier forKey:kGiftAssistantQuestionIdentifier];
    [encoder encodeObject:name forKey:kGiftAssistantQuestionName];
    [encoder encodeObject:options forKey:kGiftAssistantQuestionOptions];
    
}
@end
