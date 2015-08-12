//
//  HGFeedbackService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-6.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HGFeedbackLoader;
@protocol HGFeedbackServiceDelegate;

@interface HGFeedbackService : NSObject {
    HGFeedbackLoader* feedbackLoader;
    id<HGFeedbackServiceDelegate> delegate;
}

@property (nonatomic, assign) id<HGFeedbackServiceDelegate> delegate;

+ (HGFeedbackService*)sharedService;
+ (void)killService;

- (void)requestUploadFeedback:(NSString*)feedback;

@end

@protocol HGFeedbackServiceDelegate <NSObject>
- (void)feedbackService:(HGFeedbackService *)feedbackService didRequestUploadFeedbackSucceed:(NSString*)nothing;
- (void)feedbackService:(HGFeedbackService *)feedbackService didRequestUploadFeedbackFail:(NSString*)error;
@end


