//
//  HGGiftAssistantLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"
#import "HGFeaturedGiftCollection.h"

@class HGRecipient;
@protocol HGGiftAssistantLoaderDelegate;

@interface HGGiftAssistantLoader : HGNetworkConnection {
    BOOL running;
    int requestType;
}
@property (nonatomic, assign)   id<HGGiftAssistantLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestGiftAssistantQuestions:(HGRecipient*)recipient;
- (void)requestGiftAssistantAnswers:(NSArray*)giftAssistantAnswers;
@end


@protocol HGGiftAssistantLoaderDelegate
- (void)giftAssistantLoader:(HGGiftAssistantLoader *)giftAssistantLoader didRequestGiftAssistantQuestionsSucceed:(NSArray*)giftAssistantQuestions;
- (void)giftAssistantLoader:(HGGiftAssistantLoader *)giftAssistantLoader didRequestGiftAssistantQuestionsFail:(NSString*)error;

- (void)giftAssistantLoader:(HGGiftAssistantLoader *)giftAssistantLoader didRequestGiftAssistantAnswersSucceed:(NSArray*)assistantGiftSets;
- (void)giftAssistantLoader:(HGGiftAssistantLoader *)giftAssistantLoader didRequestGiftAssistantAnswersFail:(NSString*)error;
@end
