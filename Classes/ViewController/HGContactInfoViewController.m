//
//  HGContactInfoViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-25.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGContactInfoViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGProgressView.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGAccountService.h"
#import "NSString+Addition.h"
#import "HGOrderViewController.h"
#import "HGTrackingService.h"
#import "HGUtility.h"
#import "HGGiftOrder.h"
#import "HGGift.h"

@interface HGContactInfoViewController()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
  
@end

@implementation HGContactInfoViewController

- (id)initWithGiftOrder:(HGGiftOrder*)theGiftOrder {
    self = [super initWithNibName:@"HGContactInfoViewController" bundle:nil];
    if (self){
        giftOrder = [theGiftOrder retain];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleCancelAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    
    if (giftOrder != nil){
        rightBarButtonItem = [[UIBarButtonItem alloc ] initNavigationRightTextBarButtonItem:@"下一步" target:self action:@selector(handleDoneAction:)];
        navigationBar.topItem.rightBarButtonItem = rightBarButtonItem;
    }else{
        navigationBar.topItem.rightBarButtonItem = nil;
    }
    
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
	titleLabel.text = @"个人信息";
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    contactTagLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    contactTagLabel.textColor = [UIColor whiteColor];
    contactTagLabel.text = @"联系方式";
    
    if (giftOrder != nil){
        pageDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        pageDescriptionLabel.textColor = UIColorFromRGB(0xd53d3b);
        
        pageDescriptionLabel.text = @"请填写送礼人信息，我们将使用您预留的联系方式即时通知您送礼订单的状态。";
        
        pageDescriptionLabel.hidden = NO;
        seperatorView.hidden = NO;
        
        CGRect userInfoViewFrame = userInfoView.frame;
        userInfoViewFrame.origin.y = 105.0;
        userInfoView.frame = userInfoViewFrame;
    }else{
        pageDescriptionLabel.hidden = YES;
        seperatorView.hidden = YES;
        
        CGRect userInfoViewFrame = userInfoView.frame;
        userInfoViewFrame.origin.y = 35.0;
        userInfoView.frame = userInfoViewFrame;
    }
    
    userNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userNameLabel.textColor = [UIColor blackColor];
    userNameLabel.text = @"姓名：";
    
    userNameTextField.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userNameTextField.textColor = [UIColor darkGrayColor];
    userNameTextField.placeholder = @"输入您的姓名";
    
    userPhoneLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userPhoneLabel.textColor = [UIColor blackColor];
    userPhoneLabel.text = @"手机：";
    
    userPhoneTextField.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userPhoneTextField.textColor = [UIColor darkGrayColor];
    userPhoneTextField.placeholder = @"输入您的手机号码";
    
    userEmailLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userEmailLabel.textColor = [UIColor blackColor];
    userEmailLabel.text = @"邮箱：";
    
    userEmailTextField.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userEmailTextField.textColor = [UIColor darkGrayColor];
    userEmailTextField.placeholder = @"输入您的常用邮箱";
    
    editingAccount = [HGAccountService sharedService].currentAccount;
    [editingAccount retain];
    userNameTextField.text = editingAccount.userName;
    userPhoneTextField.text = editingAccount.userPhone;
    userEmailTextField.text = editingAccount.userEmail;    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleTapContactInfoViewGesture:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    tapGestureRecognizer.delegate = self;
    [contactInfoScrollView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
 
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    CGSize contentSize = contactInfoScrollView.contentSize;
    contentSize.height = contactInfoScrollView.frame.size.height + 1.0;
    contactInfoScrollView.contentSize = contentSize;
    
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
    [contactInfoScrollView release];
    [userNameTextField release];
    [userPhoneTextField release];
    [userEmailTextField release];
    [editingAccount release];
    [userInfoView release];
    [seperatorView release];
    [contactTagLabel release];
    [userNameLabel release];
    [userEmailLabel release];
    [userPhoneLabel release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
	[super dealloc];
}


- (void)handleCancelAction:(id)sender{
    if (giftOrder != nil){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        userNameTextField.text = [userNameTextField.text stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        userPhoneTextField.text = [HGUtility normalizeMobileNumber:userPhoneTextField.text];
        userEmailTextField.text = [userEmailTextField.text stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([userNameTextField.text isEmptyOrWhitespace] == NO) {
            editingAccount.userName = userNameTextField.text;
        } 
        if ([HGUtility isValidMobileNumber:userPhoneTextField.text]){
            editingAccount.userPhone = userPhoneTextField.text;
        }
        if ([HGUtility isValidEmail:userEmailTextField.text]) {
            editingAccount.userEmail = userEmailTextField.text;
        }
        [[HGAccountService sharedService] updateAccount:editingAccount];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)handleDoneAction:(id)sender {
    userNameTextField.text = [userNameTextField.text stringByTrimmingCharactersInSet:
     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    userPhoneTextField.text = [HGUtility normalizeMobileNumber:userPhoneTextField.text];
    userEmailTextField.text = [userEmailTextField.text stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([userNameTextField.text isEmptyOrWhitespace]) {
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:@"姓名不能为空"];
    } else if (![HGUtility isValidMobileNumber:userPhoneTextField.text] &&
               ![HGUtility isValidEmail:userEmailTextField.text]) {
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:@"请填写一个有效的电话号码或E-Mail"];
    } else {
        editingAccount.userName = userNameTextField.text;
        editingAccount.userPhone = userPhoneTextField.text;
        editingAccount.userEmail = userEmailTextField.text;
        
        [[HGAccountService sharedService] updateAccount:editingAccount];
        
        if (giftOrder != nil){
            [HGTrackingService logEvent:kTrackingEventEnterGiftOrderDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGContactInfoViewController", @"from", giftOrder.gift.identifier, @"gift", nil]];
            
            HGOrderViewController* viewController = [[HGOrderViewController alloc] initWithGiftOrder:giftOrder];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
        }else{
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

- (void)checkKeyboardVisiblity{
    if ([userNameTextField isFirstResponder]){
        [userNameTextField resignFirstResponder];
    }
    if ([userPhoneTextField isFirstResponder]){
        [userPhoneTextField resignFirstResponder];
    }
    if ([userEmailTextField isFirstResponder]){
        [userEmailTextField resignFirstResponder];
    }
}

- (void)checkTextInputVisiblity{
    if ([userNameTextField isFirstResponder] ||
        [userPhoneTextField isFirstResponder] ||
        [userEmailTextField isFirstResponder]){
        CGPoint scrollViewContentOffset = contactInfoScrollView.contentOffset;
        if (giftOrder != nil){
            if ([userPhoneTextField isFirstResponder]){
                scrollViewContentOffset.y = 70.0;
            }else if ([userEmailTextField isFirstResponder]){
                scrollViewContentOffset.y = 120.0;
            }
        }else{
            if ([userEmailTextField isFirstResponder]){
                scrollViewContentOffset.y = 50.0;
            }
        }
        [contactInfoScrollView setContentOffset:scrollViewContentOffset animated:YES];
    }
}

#pragma mark Gesture

- (void)handleTapContactInfoViewGesture:(UITapGestureRecognizer*)sender{
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
                         
                         CGRect contactInfoScrollViewFrame = contactInfoScrollView.frame;
                         if (giftOrder != nil){
                             contactInfoScrollViewFrame.size.height = 386.0 - 120.0;
                         }else{
                             contactInfoScrollViewFrame.size.height = 386.0 - 50.0;
                         }
                         contactInfoScrollView.frame = contactInfoScrollViewFrame;
                     } 
                     completion:^(BOOL finished) {
                         [self checkTextInputVisiblity];
                     }];
}

- (void)keyboardDidShow:(NSNotification *)notfication {
}

- (void)keyboardWillHide:(NSNotification *)notfication {
    [contactInfoScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect keyboardBounds;
                         [[notfication.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
                         
                         CGRect contactInfoScrollViewFrame = contactInfoScrollView.frame;
                         contactInfoScrollViewFrame.size.height = 386.0;
                         contactInfoScrollView.frame = contactInfoScrollViewFrame;
                     } 
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)keyboardDidHide:(NSNotification *)notfication {
}


#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (
        touch.view == userNameTextField ||
        touch.view == userEmailTextField||
        touch.view == userPhoneTextField) {
        return NO;
    }
    return YES; 
}
@end

