//
//  HGRenrenAuthViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/17/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGProgressView.h"

@class    HGRenrenAuthViewController;
@class    RenrenService;
@class    HGAccount;

@protocol HGRenrenAuthViewControllerDelegate <NSObject>
- (void)renrenAuthViewController:(HGRenrenAuthViewController*)renrenAuthViewController didRenrenAuthSucceed:(ROUserResponseItem*)user account:(HGAccount*)account;
- (void)renrenAuthViewController:(HGRenrenAuthViewController*)renrenAuthViewController didRenrenAuthFail:(NSString*)error;
@end

@interface HGRenrenAuthViewController:UIViewController<UIWebViewDelegate> {
    IBOutlet  UIWebView*                 authWebView;
    IBOutlet UINavigationBar*            navigationBar;
    HGProgressView*                      progressView;
    int                                  requestCount;
    RenrenService* renrenService;
    UIBarButtonItem* leftBarButtonItem;
    NSMutableDictionary *parameters;
    
    HGAccount* account;
    ROUserResponseItem* renrenUser;
    
    id<HGRenrenAuthViewControllerDelegate>  delegate;
}
- (id)initWithDelegate:(id<HGRenrenAuthViewControllerDelegate>)delegate;

@property (nonatomic, assign)  id<HGRenrenAuthViewControllerDelegate>  delegate;
@end
