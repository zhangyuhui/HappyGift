//
//  HGGiftAssistantLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftAssistantLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "NSString+Addition.h"
#import "HGGiftAssistantOption.h"
#import "HGGiftAssistantQuestion.h"
#import "HGLogging.h"
#import <sqlite3.h>
#import "HGDefines.h"
#import "HGGiftSet.h"
#import "HGGift.h"
#import "HGRecipient.h"

#define kGiftAssistantRequestTypeQuestions 0
#define kGiftAssistantRequestTypeAnswers   1

static NSString *kGiftAssistantRequestQuestionsFormat = @"%@/gift/index.php?route=interest/get_question";
static NSString *kGiftAssistantRequestAnswersFormat = @"%@/gift/index.php?route=interest/recommend";

@interface HGGiftAssistantLoader()
@end

@implementation HGGiftAssistantLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestGiftAssistantQuestions:(HGRecipient*)recipient{
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    requestType = kGiftAssistantRequestTypeQuestions;
    NSString* requestString = [NSString stringWithFormat:kGiftAssistantRequestQuestionsFormat, [HappyGiftAppDelegate backendServiceHost]];
    
    if (recipient != nil && (recipient.recipientNetworkId == NETWORK_SNS_WEIBO || recipient.recipientNetworkId == NETWORK_SNS_RENREN)){
        requestString = [NSString stringWithFormat:@"%@&recipient_profile_id=%@&recipient_network=%d", requestString, recipient.recipientProfileId, recipient.recipientNetworkId];
    }
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

- (void)requestGiftAssistantAnswers:(NSArray*)giftAssistantAnswers{
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    requestType = kGiftAssistantRequestTypeAnswers;
    
    NSString* requestString = [NSString stringWithFormat:kGiftAssistantRequestAnswersFormat, [HappyGiftAppDelegate backendServiceHost]];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableString* postBodyString = [[NSMutableString alloc] init];
    for (HGGiftAssistantQuestion* giftAssistantAnswer in giftAssistantAnswers){
        for (HGGiftAssistantOption* giftAssistantOption in giftAssistantAnswer.options){
            if (giftAssistantOption.selected == YES){
                if ([postBodyString length] > 0){
                    [postBodyString appendFormat:@"&"];
                }
                [postBodyString appendFormat:@"%@=%@", giftAssistantAnswer.identifier, giftAssistantOption.text];
                break;
            }
        }
    }
    
    HGDebug(@"%@", postBodyString);
    [super requestByPost:requestURL bodyString:[postBodyString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [postBodyString release];
}

#pragma mark parsers

- (void)handleParseGiftAssistantQuestions:(NSData*)giftAssistantQuestionsData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSArray* giftAssistantQuestions = nil;
   
    NSString* jsonString = [NSString stringWithData:giftAssistantQuestionsData];
    HGDebug(@"%@", jsonString);
    
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
        NSDictionary *jsonDictionary = [jsonString JSONValue];
        if (jsonDictionary != nil){
            giftAssistantQuestions = [self parseGiftAssistantQuestions:jsonDictionary];
        }
    }
    
    if (giftAssistantQuestions != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyGiftAssistantQuestions:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:giftAssistantQuestions, @"giftAssistantQuestions", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyGiftAssistantQuestions:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyGiftAssistantQuestions:(NSDictionary*)giftAssistantQuestionsData {
    running = NO;
    NSArray* giftAssistantQuestions = [giftAssistantQuestionsData objectForKey:@"giftAssistantQuestions"];
    if (giftAssistantQuestions != nil){
        if ([(id)self.delegate respondsToSelector:@selector(giftAssistantLoader:didRequestGiftAssistantQuestionsSucceed:)]) {
            [self.delegate giftAssistantLoader:self didRequestGiftAssistantQuestionsSucceed:giftAssistantQuestions];
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(giftAssistantLoader:didRequestGiftAssistantQuestionsFail:)]) {
            [self.delegate giftAssistantLoader:self didRequestGiftAssistantQuestionsFail:nil];
        }
    }
    [self end];
}

-(NSArray*) parseGiftAssistantQuestions:(NSDictionary*)jsonDictionary {
    NSMutableArray* giftAssistantQuestions = [[[NSMutableArray alloc] init] autorelease];
    @try {
        NSDictionary* questionJsonObject = [jsonDictionary objectForKey:@"question"];
        NSArray* questionsJsonObject = [questionJsonObject objectForKey:@"questions"];
        for (NSDictionary* questionDictionary in questionsJsonObject){
            NSString* questionIdentifier = [questionDictionary objectForKey:@"qid"];
            NSString* questionName = [questionDictionary objectForKey:@"question"];
            NSArray* optionsJsonObject = [questionDictionary objectForKey:@"options"];
            NSMutableArray* questionOptions = [[NSMutableArray alloc] init];
            for (NSDictionary* optionDictionary in optionsJsonObject){
                NSString* optionImage = [optionDictionary objectForKey:@"image"];
                NSString* optionText = [optionDictionary objectForKey:@"option"];
                HGGiftAssistantOption* giftAssistantOption = [[HGGiftAssistantOption alloc] init];
                giftAssistantOption.image = optionImage;
                giftAssistantOption.text = optionText;
                [questionOptions addObject:giftAssistantOption];
                [giftAssistantOption release];
            }
            HGGiftAssistantQuestion* giftAssistantQuestion = [[HGGiftAssistantQuestion alloc] init];
            giftAssistantQuestion.identifier = questionIdentifier;
            giftAssistantQuestion.name = questionName;
            giftAssistantQuestion.options = questionOptions;
            [giftAssistantQuestions addObject:giftAssistantQuestion];
            [giftAssistantQuestion release];
        }
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseGiftAssistantQuestions");
    }@finally {
        
    }
    return giftAssistantQuestions;
}

- (void)handleParseAssistantProducts:(NSData*)assistantGiftSetsData{
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    NSArray* assistantGiftSets = nil;
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
        NSDictionary *jsonDictionary = [jsonString JSONValue];
        if (jsonDictionary != nil){
            assistantGiftSets = [self parseAssistantGiftSets:jsonDictionary];
        }
    }
    
    if (assistantGiftSets != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyAssistantProducts:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:assistantGiftSets, @"assistantGiftSets", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyAssistantProducts:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyAssistantProducts:(NSDictionary*)assistantGiftSetsData{
    running = NO;
    NSArray* assistantGiftSets = [assistantGiftSetsData objectForKey:@"assistantGiftSets"];
    if (assistantGiftSets != nil){
        if ([(id)self.delegate respondsToSelector:@selector(giftAssistantLoader:didRequestGiftAssistantAnswersSucceed:)]) {
            [self.delegate giftAssistantLoader:self didRequestGiftAssistantAnswersSucceed:assistantGiftSets];
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(giftAssistantLoader:didRequestGiftAssistantAnswersFail:)]) {
            [self.delegate giftAssistantLoader:self didRequestGiftAssistantAnswersFail:nil];
        }
    }
    [self end];
}


-(NSArray*) parseAssistantGiftSets:(NSDictionary*)jsonDictionary{
   NSMutableArray* assistantGiftSets = nil;
    @try {
        NSArray* productsJsonArray = [jsonDictionary objectForKey:@"products"];
        //NSString* error = [jsonDictionary objectForKey:@"error"];
        for (NSDictionary* productJsonDictionary in productsJsonArray){
            HGGiftSet* giftSet = [[HGGiftSet alloc] initWithProductJsonDictionary:productJsonDictionary];
            if (assistantGiftSets == nil){
                assistantGiftSets = [[[NSMutableArray alloc] init] autorelease];
            }
            [assistantGiftSets addObject:giftSet];
            [giftSet release];
        }
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseFeaturedGiftCollection");
    }@finally {
        
    }
    return assistantGiftSets;
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    if (requestType == kGiftAssistantRequestTypeQuestions){
        [self performSelectorInBackground:@selector(handleParseGiftAssistantQuestions:) withObject:self.data];
    }else if (requestType == kGiftAssistantRequestTypeAnswers){
        [self performSelectorInBackground:@selector(handleParseAssistantProducts:) withObject:self.data];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if (requestType == kGiftAssistantRequestTypeQuestions){
        if ([(id)self.delegate respondsToSelector:@selector(giftAssistantLoader:didRequestGiftAssistantQuestionsFail:)]) {
            [self.delegate giftAssistantLoader:self didRequestGiftAssistantQuestionsFail:[error description]];
        }
    }else if (requestType == kGiftAssistantRequestTypeAnswers){
        if ([(id)self.delegate respondsToSelector:@selector(giftAssistantLoader:didRequestGiftAssistantAnswersFail:)]) {
            [self.delegate giftAssistantLoader:self didRequestGiftAssistantAnswersFail:[error description]];
        }
    }
}
@end
