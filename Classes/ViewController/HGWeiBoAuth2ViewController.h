//
//  HGWeiBoAuth2ViewController.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-28.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HGWeiBoAuth2ViewController;
@class HGAccount;
@class WBEngine;
@class HGProgressView;

@protocol HGWeiBoAuth2ViewControllerDelegate <NSObject>
- (void)weiBoAuth2ViewController:(HGWeiBoAuth2ViewController*)weiBoAuthViewController didWeiBoAuthSucceed:(HGAccount*)account;
- (void)weiBoAuth2ViewController:(HGWeiBoAuth2ViewController*)weiBoAuthViewController didWeiBoAuthFail:(NSString*)error;
@end

@interface HGWeiBoAuth2ViewController:UIViewController<UIWebViewDelegate> {
    IBOutlet UINavigationBar*            navigationBar;
    IBOutlet UIWebView*                  webView;
    HGProgressView*                      progressView;
    UIBarButtonItem* leftBarButtonItem;
    
    id<HGWeiBoAuth2ViewControllerDelegate>  delegate;
}

- (id)initWithDelegate:(id<HGWeiBoAuth2ViewControllerDelegate>)delegate;

@property (nonatomic, assign)  id<HGWeiBoAuth2ViewControllerDelegate>  delegate;
@end
