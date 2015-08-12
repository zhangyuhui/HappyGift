//
//  HGWeiBoAuth2ViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-28.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HGWeiBoAuth2ViewController.h"
#import "HappyGiftAppDelegate.h"
#import "UINavigationBar+Addition.h"
#import "UIBarButtonItem+Addition.h"
#import "WBEngine.h"
#import "HGProgressView.h"
#import "HGLogging.h"

@interface HGWeiBoAuth2ViewController () <WBEngineDelegate>
@end

@implementation HGWeiBoAuth2ViewController
@synthesize delegate;

- (void) dealloc {
    [webView release];
    [navigationBar release];
    [leftBarButtonItem release];
    [progressView release];
    [[WBEngine sharedWeibo] setDelegate:nil];
	[super dealloc];
}

- (id)initWithDelegate:(id<HGWeiBoAuth2ViewControllerDelegate>)theDelegate {
    self = [super initWithNibName:@"HGWeiBoAuth2ViewController" bundle:nil];
    if (self){
        delegate = theDelegate;
    }
    return self;
}

#pragma mark Actions

- (void)handleCancelAction:(id)sender {
    [self cancelAuth:sender];
}

- (void)finishAuth: (HGAccount*)account {
    if (self.delegate != nil && [(id)self.delegate respondsToSelector:@selector(weiBoAuth2ViewController:didWeiBoAuthSucceed:)]) {
        [self.delegate weiBoAuth2ViewController:self didWeiBoAuthSucceed:account];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)cancelAuth: (id) sender {
    if (self.delegate != nil && [(id)self.delegate respondsToSelector:@selector(weiBoAuth2ViewController:didWeiBoAuthFail:)]) {
        [self.delegate weiBoAuth2ViewController:self didWeiBoAuthFail:@"cancel"];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)failAuth {
    if (self.delegate != nil && [(id)self.delegate respondsToSelector:@selector(weiBoAuth2ViewController:didWeiBoAuthFail:)]) {
        [self.delegate weiBoAuth2ViewController:self didWeiBoAuthFail:nil];
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
	titleLabel.text = @"微博登录";
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    
    progressView.hidden = YES;
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray* weiboCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://api.weibo.com"]];
	for (NSHTTPCookie* cookie in weiboCookies) {
		[cookies deleteCookie:cookie];
	}
    
    WBEngine* engine = [WBEngine sharedWeibo];
    [engine setDelegate:self];    
    [engine logOut];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:kWBAppKey, @"client_id",
                            @"code", @"response_type",
                            kWBCallbackURL, @"redirect_uri", 
                            @"mobile", @"display", nil];
    NSString *urlString = [WBRequest serializeURL:kWBAuthorizeURL
                                           params:params
                                       httpMethod:@"GET"];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    [webView setDelegate:self];
    [webView loadRequest:request];
}

#pragma mark - WBEngineDelegate Methods

#pragma mark Authorize

- (void)engineDidLogIn:(WBEngine *)theEngine
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:theEngine.accessToken, @"access_token", theEngine.userID, @"uid", nil];
    
    [theEngine loadRequestWithMethodName:(NSString *)@"users/show.json" httpMethod:@"GET" params:params postDataType:kWBRequestPostDataTypeNone httpHeaderFields:nil];
}

- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
    HGDebug(@"didFailToLogInWithError: %@", error);
    [self failAuth];
}

- (void)engineDidLogOut:(WBEngine *)engine {
}

- (void)engineNotAuthorized:(WBEngine *)engine {
    HGDebug(@"engineNotAuthorized");
    [self failAuth];
}

- (void)engineAuthorizeExpired:(WBEngine *)engine {
    HGDebug(@"engineAuthorizeExpired");
    [self failAuth];
}

- (void)engine:(WBEngine *)theEngine requestDidFailWithError:(NSError *)error {
    HGDebug(@"requestDidFailWithError");
    [self failAuth];
}

- (void)engine:(WBEngine *)theEngine requestDidSucceedWithResult:(id)result {
    HGDebug(@"requestDidSucceedWithResult");
    
    if (result != nil && [result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *userDictionary = (NSDictionary*)result;
        
        HGAccount* account = [[HGAccount alloc] init];
        account.weiBoUserId = theEngine.userID;
        account.weiBoUserName = [userDictionary objectForKey:@"screen_name"];
        account.weiBoUserDescription = [userDictionary objectForKey:@"description"];
        
        account.weiBoUserIcon = [userDictionary objectForKey:@"profile_image_url"];
        account.weiBoUserIconLarge = [userDictionary objectForKey:@"avatar_large"];
        
        NSMutableString* userInfoText = [[NSMutableString alloc] init];
        
        if ([@"m" isEqualToString: [userDictionary objectForKey:@"gender"]]) {
            [userInfoText appendString:@"男"];
        } else {
            [userInfoText appendString:@"女"];
        }
        
        NSString* location = [userDictionary objectForKey:@"location"];
        if (location != nil && [location isEqualToString:@""] == NO){
            if ([userInfoText isEqualToString:@""]){
                [userInfoText appendString:location];
            }else{
                [userInfoText appendFormat:@" %@", location];
            }
        }
        account.weiBoUserDescription = userInfoText;
        [userInfoText release];
        account.weiBoUserSignature = [userDictionary objectForKey:@"description"];
        account.weiboFavoriteCount = [[userDictionary objectForKey:@"favourites_count"] intValue];
        account.weiboStatusCount = [[userDictionary objectForKey:@"statuses_count"] intValue];
        account.weiboFriendsCount = [[userDictionary objectForKey:@"friends_count"] intValue];
        account.weiboFollowersCount = [[userDictionary objectForKey:@"followers_count"] intValue];        
        
        account.weiBoAuthToken = theEngine.accessToken;
        
        [self finishAuth:account];
        [account release];
    }
}

#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{ 
	[progressView startAnimation];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	[progressView stopAnimation];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    [progressView stopAnimation];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
    
    if (range.location != NSNotFound)
    {
        NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
        
        // if not canceled
        if (![code isEqualToString:@"21330"]) {
            [[WBEngine sharedWeibo].authorize requestAccessTokenWithAuthorizeCode:code];
        } else {
            // user canceled
            [self cancelAuth:nil];
        }
    }
    HGDebug(@"%@", request.URL.absoluteString);
    
    if ([request.URL.absoluteString hasPrefix:kWBCallbackURL]) {
        return NO;
    }
    
    return YES;
}

@end
