//
//  HGGiftAssistantService.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftAssistantService.h"
#import "HGGiftAssistantLoader.h"
#import "HappyGiftAppDelegate.h"
#import "HGRecipient.h"

static HGGiftAssistantService* giftAssistantService = nil;

@interface HGGiftAssistantService () <HGGiftAssistantLoaderDelegate>

@end

@implementation HGGiftAssistantService
@synthesize delegate;

+ (HGGiftAssistantService*)sharedService{
    if (giftAssistantService == nil){
        giftAssistantService = [[HGGiftAssistantService alloc] init];
    }
    return giftAssistantService;
}

+ (void)killService{
    if (giftAssistantService != nil){
        [giftAssistantService release];
        giftAssistantService = nil;
    }    
}

- (id)init{
    self = [super init];
    if (self){
    }
    return self;
}

- (void)dealloc{
    [giftAssistantLoader release];
    [super dealloc];
}

- (void)requestGiftAssistantQuestions:(HGRecipient*)recipient{
    if (giftAssistantLoader == nil){
        giftAssistantLoader = [[HGGiftAssistantLoader alloc] init];
        giftAssistantLoader.delegate = self;
    }else{
        [giftAssistantLoader cancel];
    }
    [giftAssistantLoader requestGiftAssistantQuestions:recipient];
}

- (void)requestGiftAssistantAnswers:(NSArray*)giftAssistantAnswers{
    if (giftAssistantLoader == nil){
        giftAssistantLoader = [[HGGiftAssistantLoader alloc] init];
        giftAssistantLoader.delegate = self;
    }else{
        [giftAssistantLoader cancel];
    }
    [giftAssistantLoader requestGiftAssistantAnswers:giftAssistantAnswers];    
}

#pragma mark　- HGGiftAssistantLoaderDelegate
- (void)giftAssistantLoader:(HGGiftAssistantLoader *)giftAssistantLoader didRequestGiftAssistantQuestionsSucceed:(NSArray*)giftAssistantQuestions{
    if ([delegate respondsToSelector:@selector(giftAssistantService:didRequestGiftAssistantQuestionsSucceed:)]){
        [delegate giftAssistantService:self didRequestGiftAssistantQuestionsSucceed:giftAssistantQuestions];
    }
}

- (void)giftAssistantLoader:(HGGiftAssistantLoader *)giftAssistantLoader didRequestGiftAssistantQuestionsFail:(NSString*)error{
    if ([delegate respondsToSelector:@selector(giftAssistantService:didRequestGiftAssistantQuestionsFail:)]){
        [delegate giftAssistantService:self didRequestGiftAssistantQuestionsFail:error];
    }
}


- (void)giftAssistantLoader:(HGGiftAssistantLoader *)giftAssistantLoader didRequestGiftAssistantAnswersSucceed:(NSArray*)assistantGiftSets{
    if ([delegate respondsToSelector:@selector(giftAssistantService:didRequestGiftAssistantAnswersSucceed:)]){
        [delegate giftAssistantService:self didRequestGiftAssistantAnswersSucceed:assistantGiftSets];
    }
}

- (void)giftAssistantLoader:(HGGiftAssistantLoader *)giftAssistantLoader didRequestGiftAssistantAnswersFail:(NSString*)error{
    if ([delegate respondsToSelector:@selector(giftAssistantService:didRequestGiftAssistantAnswersFail:)]){
        [delegate giftAssistantService:self didRequestGiftAssistantAnswersFail:error];
    }
}

@end
