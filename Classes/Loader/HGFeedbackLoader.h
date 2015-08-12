//
//  HGFeedbackLoader.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-6.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@protocol HGFeedbackLoaderDelegate;

@interface HGFeedbackLoader : HGNetworkConnection {
    BOOL running;
}

@property (nonatomic, assign)   id<HGFeedbackLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL running;

- (void)requestUploadFeedback:(NSString*)feedback userName:(NSString*)userName userPhone:(NSString*)userPhone userEmail:(NSString*)userEmail;

@end

@protocol HGFeedbackLoaderDelegate
- (void)feedbackLoader:(HGFeedbackLoader *)feedbackLoader didRequestUploadFeedbackSucceed:(NSString*)nothing;
- (void)feedbackLoader:(HGFeedbackLoader *)feedbackLoader didRequestUploadFeedbackFail:(NSString*)error;
@end

