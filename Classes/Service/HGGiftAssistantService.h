//
//  HGGiftAssistantService.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGGiftAssistantLoader;
@protocol HGGiftAssistantServiceDelegate;
@class HGRecipient;

@interface HGGiftAssistantService : NSObject {
    HGGiftAssistantLoader* giftAssistantLoader;
    id<HGGiftAssistantServiceDelegate> delegate;
}
@property (nonatomic, assign) id<HGGiftAssistantServiceDelegate> delegate;

+ (HGGiftAssistantService*)sharedService;
+ (void)killService;

- (void)requestGiftAssistantQuestions:(HGRecipient*)recipient;
- (void)requestGiftAssistantAnswers:(NSArray*)giftAssistantAnswers;
@end

@protocol HGGiftAssistantServiceDelegate<NSObject>
- (void)giftAssistantService:(HGGiftAssistantService *)giftAssistantService didRequestGiftAssistantQuestionsSucceed:(NSArray*)giftAssistantQuestions;
- (void)giftAssistantService:(HGGiftAssistantService *)giftAssistantService didRequestGiftAssistantQuestionsFail:(NSString*)error;
- (void)giftAssistantService:(HGGiftAssistantService *)giftAssistantService didRequestGiftAssistantAnswersSucceed:(NSArray*)assistantGiftSets;
- (void)giftAssistantService:(HGGiftAssistantService *)giftAssistantService didRequestGiftAssistantAnswersFail:(NSString*)error;
@end
