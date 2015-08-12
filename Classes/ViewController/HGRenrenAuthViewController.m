//
//  HGRenrenAuthViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/17/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HGRenrenAuthViewController.h"
#import "ROUtility.h"
#import "RenrenService.h"
#import "HGAccountService.h"
#import "HappyGiftAppDelegate.h"
#import "UINavigationBar+Addition.h"
#import "UIBarButtonItem+Addition.h"
#import "HGLogging.h"

@interface HGRenrenAuthViewController () <RenrenDelegate>
@end

@implementation HGRenrenAuthViewController
@synthesize delegate;

- (void) dealloc {
    [authWebView release];
    [navigationBar release];
    [leftBarButtonItem release];
    [progressView release];
    [renrenUser release];
    [account release];
    [super dealloc];
}

- (id)initWithDelegate:(id<HGRenrenAuthViewControllerDelegate>)theDelegate{
    self = [super initWithNibName:@"HGRenrenAuthViewController" bundle:nil];
    if (self){
        delegate = theDelegate;
    }
    return self;
}

- (void) finishWithFailure {
    if (self.delegate && [(id)self.delegate respondsToSelector:@selector(renrenAuthViewController:didRenrenAuthFail:)]) {
        [self.delegate renrenAuthViewController:self didRenrenAuthFail:nil];
    }
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Actions

- (void)handleCancelAction:(id)sender{
    if (self.delegate != nil && [(id)self.delegate respondsToSelector:@selector(renrenAuthViewController:didRenrenAuthFail:)]) {
        [self.delegate renrenAuthViewController:self didRenrenAuthFail:@"cancel"];
    }
	[self dismissModalViewControllerAnimated:YES];
}

- (void)handleSucceedAction:(id)sender{
    if (self.delegate != nil && [(id)self.delegate respondsToSelector:@selector(renrenAuthViewController:didRenrenAuthSucceed:account:)]) {
        [self.delegate renrenAuthViewController:self didRenrenAuthSucceed:renrenUser account:account];
    }
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark View Controller
- (void) loadView {
	[super loadView];
    
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleCancelAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    
    navigationBar.topItem.rightBarButtonItem = nil;
    
    
    CGRect titleViewFrame = CGRectMake(20, 0, 180, 44);
    UIView* titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    
    CGRect titleLabelFrame = CGRectMake(0, 0, 180, 40);
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate naviagtionTitleFontSize]];
    titleLabel.minimumFontSize = 20.0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.text = @"人人网登录";
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    if ([authWebView respondsToSelector:@selector(scrollView)]){
        authWebView.scrollView.scrollEnabled = NO;
    }
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
	
    requestCount = 0;
    
    progressView.hidden = YES;
    
    renrenService = [RenrenService sharedRenren];
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray* graphCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://graph.renren.com"]];
	
	for (NSHTTPCookie* cookie in graphCookies) {
		[cookies deleteCookie:cookie];
	}
	NSArray* widgetCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://widget.renren.com"]];
	for (NSHTTPCookie* cookie in widgetCookies) {
		[cookies deleteCookie:cookie];
	}
    renrenService.renrenDelegate = self;
    
    parameters = [NSMutableDictionary dictionary];
    [parameters setValue:RENREN_APP_ID forKey:@"client_id"];
    [parameters setValue:kRRSuccessURL forKey:@"redirect_uri"];
    [parameters setValue:@"token" forKey:@"response_type"];
    [parameters setValue:@"touch" forKey:@"display"];
    [parameters setValue:@"publish_feed,photo_upload,read_user_status,read_user_photo,read_user_blog,publish_comment,status_update" forKey:@"scope"];

    [parameters setObject:kWidgetDialogUA forKey:@"ua"];
    
    NSURL *url = [ROUtility generateURL:kAuthBaseURL params:parameters];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [authWebView loadRequest:request];
}

#pragma mark Webview Delegate
- (void) webViewDidFinishLoad: (UIWebView *) webView {
    [progressView stopAnimation];
}

- (void) webViewDidStartLoad: (UIWebView *) webView {
    [progressView startAnimation];
}

- (BOOL)webView: (UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType) navigationType {
    NSURL *url = request.URL;
    NSString *query = [url fragment]; // url中＃字符后面的部分。
    if (!query) {
        query = [url query];
    }
    NSDictionary *params = [ROUtility parseURLParams:query];
    NSString *accessToken = [params objectForKey:@"access_token"];
    //    NSString *error_desc = [params objectForKey:@"error_description"];
    NSString *errorReason = [params objectForKey:@"error"];
    if(nil != errorReason) {
        [self handleCancelAction:nil];
        return NO;
    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked)/*点击链接*/{
        BOOL userDidCancel = ((errorReason && [errorReason isEqualToString:@"login_denied"])||[errorReason isEqualToString:@"access_denied"]);
        if(userDidCancel){
            [self handleCancelAction:nil];
        }else {
            NSString *q = [url absoluteString];
            if (![q hasPrefix:@"http://graph.renren.com/oauth/authorize"]) {
                [[UIApplication sharedApplication] openURL:request.URL];
            }
        }
        return NO;
    }
    if (navigationType == UIWebViewNavigationTypeFormSubmitted) {//提交表单
        NSString *state = [params objectForKey:@"flag"];
        if ((state && [state isEqualToString:@"success"])||accessToken) {
            NSString *q = [url absoluteString];
            NSString *token = [ROUtility getValueStringFromUrl:q forParam:@"access_token"];
            NSString *expTime = [ROUtility getValueStringFromUrl:q forParam:@"expires_in"];
            NSDate   *expirationDate = [ROUtility getDateFromString:expTime];
            NSDictionary *responseDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:token,expirationDate,nil]
                                                                    forKeys:[NSArray arrayWithObjects:@"token",@"expirationDate",nil]];
            
            if ((token == (NSString *) [NSNull null]) || (token.length == 0)) {
                [self handleCancelAction:nil];
            } else {
                ROResponse* response = [ROResponse responseWithRootObject:responseDic];
                [renrenService checkOperation:response operateType:RODialogOperateSuccess];
            }
        }
    }
    return YES;
}

#pragma mark RenrenDelegate
- (void)renren:(RenrenService *)renren requestDidReturnResponse:(ROResponse*)response {
    if (response.error) {
        HGDebug(@"error response: %@", response.error.localizedDescription);
        [self finishWithFailure];
        return;
    }
    if ([response.param.method isEqualToString:@"users.getInfo"]) {
        id result = response.rootObject;
        if ([result isKindOfClass:[NSArray class]]) {
            if ([(NSArray *)result count] == 0) {
                [self finishWithFailure];
                return;
            }
            ROUserResponseItem *theRenrenUser = [(NSArray *)result objectAtIndex:0];
            if (theRenrenUser == nil) {
                [self finishWithFailure];
                return;
            }
            renrenUser = [theRenrenUser retain];
            
            account.renrenUserId = renrenUser.userId;
            account.renrenUserName = renrenUser.name;
            account.renrenUserIcon = renrenUser.tinyUrl;
            account.renrenUserIconLarge = renrenUser.headUrl;
            
            [self handleSucceedAction:nil];
        }
    }
}

/**
 * 授权登录成功时被调用，第三方开发者实现这个方法
 * @param renren 传回代理授权登录接口请求的Renren类型对象。
 */
- (void)renrenDidLogin:(RenrenService *)renren {
    if (renren == nil) {
        HGDebug(@"renren object is nil.");
        return;
    }
    if (account == nil){
        account = [[HGAccount alloc] init];
    }
    account.renrenAuthToken = renren.accessToken;
    account.renrenAuthSecret = renren.secret;
    
    ROUserInfoRequestParam* param = [[ROUserInfoRequestParam alloc] init];
    [renren getUsersInfo:param andDelegate:self];
    [param release];
}

/**
 * 用户登出成功后被调用 第三方开发者实现这个方法
 * @param renren 传回代理登出接口请求的Renren类型对象。
 */
- (void)renrenDidLogout:(RenrenService *)renren{
    
}

/**
 * 授权登录失败时被调用，第三方开发者实现这个方法
 * @param renren 传回代理授权登录接口请求的Renren类型对象。
 */
- (void)renren:(RenrenService *)renren loginFailWithError:(ROError*)error{
    UIAlertView *alertView =[[[UIAlertView alloc] initWithTitle:@"错误提示" message:@"授权失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
    [alertView show];
}

@end
