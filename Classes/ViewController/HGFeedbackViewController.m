//
//  HGFeedbackViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-25.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFeedbackViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGProgressView.h"
#import "UIBarButtonItem+Addition.h"
#import "NSString+Addition.h"
#import "HGOrderViewController.h"
#import "HGUtility.h"
#import "HGDefines.h"
#import "HGFeedbackService.h"
#import <QuartzCore/QuartzCore.h>

@interface HGFeedbackViewController()<UIScrollViewDelegate, UIGestureRecognizerDelegate, HGFeedbackServiceDelegate>
  
@end

@implementation HGFeedbackViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleCancelAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    
    rightBarButtonItem = [[UIBarButtonItem alloc ] initNavigationRightTextBarButtonItem:@"发送" target:self action:@selector(handleSendAction:)];
    navigationBar.topItem.rightBarButtonItem = rightBarButtonItem;
    
    CGRect titleViewFrame = CGRectMake(20, 0, 180, 44);
    UIView* titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    
    CGRect titleLabelFrame = CGRectMake(0, 0, 180, 40);
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate naviagtionTitleFontSize]];;
    titleLabel.minimumFontSize = 20.0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.text = @"意见反馈";
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    feedbackTagLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    feedbackTagLabel.textColor = [UIColor whiteColor];
    feedbackTagLabel.text = @"反馈信息";
    
    pageDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    pageDescriptionLabel.textColor = UIColorFromRGB(0xd53d3b);
    
    pageDescriptionLabel.text = @"请填写您的意见反馈，我们将使用您预留的联系方式即时与您沟通。";
    
    pageDescriptionLabel.hidden = NO;
    seperatorView.hidden = NO;
    
    feedbackContentTextView.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    feedbackContentTextView.textColor = [UIColor darkGrayColor];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleTapFeedbackInfoViewGesture:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    tapGestureRecognizer.delegate = self;
    [feedbackInfoScrollView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
 
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    CGSize contentSize = feedbackInfoScrollView.contentSize;
    contentSize.height = feedbackInfoScrollView.frame.size.height + 1.0;
    feedbackInfoScrollView.contentSize = contentSize;
    
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [progressView removeFromSuperview];
    [progressView release];
    
    [leftBarButtonItem release];
    leftBarButtonItem = nil;
    
    [rightBarButtonItem release];
    rightBarButtonItem = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [progressView release];
    [leftBarButtonItem release];
    [feedbackInfoScrollView release];
    [feedbackContentTextView release];
    [seperatorView release];
    [feedbackTagLabel release];
    [feedbackContentView release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    HGFeedbackService* feedbackService = [HGFeedbackService sharedService];
    if (feedbackService.delegate == self) {
        feedbackService.delegate = nil;
    }
    
	[super dealloc];
}


- (void)handleCancelAction:(id)sender{    
    [HGFeedbackService killService];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)handleSendAction:(id)sender {
    feedbackContentTextView.text = [feedbackContentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* feedback = feedbackContentTextView.text;
    if (feedback == nil || [feedback isEqualToString:@""] == YES){
        [self performBounceViewAnimation:feedbackContentView];
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:@"请将反馈信息填写完整"];
    }else{
        [progressView startAnimation];
        feedbackContentTextView.userInteractionEnabled = NO;
        [self checkKeyboardVisiblity];
        HGFeedbackService* feedbackService = [HGFeedbackService sharedService];
        feedbackService.delegate = self;
        [feedbackService requestUploadFeedback:feedback];
    }
}

- (void)checkKeyboardVisiblity{
    if ([feedbackContentTextView isFirstResponder]){
        [feedbackContentTextView resignFirstResponder];
    }
}

- (void)checkTextInputVisiblity{

}

- (void)performBounceViewAnimation:(UIView*)bounceView{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.5;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    CGFloat minValue = bounceView.layer.position.x - 5.0;
    CGFloat maxValue = bounceView.layer.position.x + 5.0;
    CGFloat currentValue = bounceView.layer.position.x;
    CGFloat stepValue = 2.0;
    BOOL increase = YES;
    int bounces = 0;
    while (bounces < 3) {
        if (increase == YES){
            currentValue += stepValue;
        }else{
            currentValue -= stepValue;
        }
        [values addObject:[NSNumber numberWithFloat:currentValue]];
        if (increase == YES){
            if (currentValue > maxValue){
                increase = NO;
            }
        }else{
            if (currentValue < minValue){
                increase = YES;
                bounces += 1;
            }
        }
    }
    animation.values = values;
    [values release];
    
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    [bounceView.layer addAnimation:animation forKey:nil];
}

#pragma mark Gesture

- (void)handleTapFeedbackInfoViewGesture:(UITapGestureRecognizer*)sender{
    [self checkKeyboardVisiblity];
}

#pragma mark - Actions
- (void)keyboardWillShow:(NSNotification *)notfication {
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect keyboardBounds;
                         [[notfication.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
                         
                         CGRect contactInfoScrollViewFrame = feedbackInfoScrollView.frame;
                         
                         contactInfoScrollViewFrame.size.height = 386.0 - 90.0;
                         
                         feedbackInfoScrollView.frame = contactInfoScrollViewFrame;
                     } 
                     completion:^(BOOL finished) {
                         [self checkTextInputVisiblity];
                     }];
}

- (void)keyboardDidShow:(NSNotification *)notfication {
}

- (void)keyboardWillHide:(NSNotification *)notfication {
    [feedbackInfoScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect keyboardBounds;
                         [[notfication.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
                         
                         CGRect contactInfoScrollViewFrame = feedbackInfoScrollView.frame;
                         contactInfoScrollViewFrame.size.height = 386.0;
                         feedbackInfoScrollView.frame = contactInfoScrollViewFrame;
                     } 
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)keyboardDidHide:(NSNotification *)notfication {
}


#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (
        touch.view == feedbackContentTextView) {
        return NO;
    }
    return YES; 
}

#pragma mark HGFeedbackServiceDelegate
- (void)feedbackService:(HGFeedbackService *)feedbackService didRequestUploadFeedbackSucceed:(NSString*)nothing{
    feedbackContentTextView.userInteractionEnabled = YES;
    [progressView stopAnimation];
    
    [self performSelector:@selector(handleCancelAction:) withObject:nil afterDelay:0.01];
}

- (void)feedbackService:(HGFeedbackService *)feedbackService didRequestUploadFeedbackFail:(NSString*)error{
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate sendNotification:@"提交反馈信息错误"];
    feedbackContentTextView.userInteractionEnabled = YES;
    [progressView stopAnimation];
}
@end

