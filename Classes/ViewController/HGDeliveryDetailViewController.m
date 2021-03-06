//
//  HGDeliveryDetailViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGDeliveryDetailViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGRecipientSelectionViewController.h"
#import "HGOrderViewController.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGGiftDelivery.h"
#import "HGGiftOrder.h"
#import "HGTrackingService.h"
#import "HGAccountService.h"
#import "HGContactInfoViewController.h"
#import "HGRecipientService.h"
#import "HGUtility.h"
#import "HGUserImageView.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface HGDeliveryDetailViewController()<UIScrollViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate>
  
@end

@implementation HGDeliveryDetailViewController
- (id)initWithGiftOrder:(HGGiftOrder*)theGiftOrder{
    self = [super initWithNibName:@"HGDeliveryDetailViewController" bundle:nil];
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
    
    rightBarButtonItem = [[UIBarButtonItem alloc ] initNavigationRightTextBarButtonItem:@"下一步" target:self action:@selector(handleDoneAction:)];
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
	titleLabel.text = @"递送设置";
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    senderTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    senderTitleLabel.textColor = [UIColor darkGrayColor];
    senderTitleLabel.text = @"发送至：";
    
    senderValueLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    senderValueLabel.textColor = [UIColor blackColor];
    senderValueLabel.text = giftOrder.giftRecipient.recipientDisplayName;
    [senderImageView updateUserImageViewWithRecipient:giftOrder.giftRecipient];
    [senderImageView removeTagImage];

    notifyTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    notifyTitleLabel.textColor = [UIColor darkGrayColor];
    notifyTitleLabel.text = @"如何通知礼物接收人？";

    [notifyAddressbookButton addTarget:self action:@selector(handleNotifyAddressBookButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [notifyPhoneButton addTarget:self action:@selector(handleNotifyPhoneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    notifyPhoneTextFiled.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    notifyPhoneTextFiled.textColor = [UIColor darkGrayColor];
    notifyPhoneTextFiled.placeholder = @"通过短信发送";
    notifyPhoneTextFiled.text = giftOrder.giftDelivery.phone;
    if (giftOrder.giftDelivery.phoneNotify == YES){
        notifyPhoneOverlayView.hidden = YES;
        [notifyPhoneButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
    }else{
        notifyPhoneOverlayView.hidden = NO;
        [notifyPhoneButton setImage:[UIImage imageNamed:@"gift_delivery_switch_off"] forState:UIControlStateNormal];
    }
    
    [notifyEmailButton addTarget:self action:@selector(handleNotifyEmailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    notifyEmailTextFiled.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    notifyEmailTextFiled.textColor = [UIColor darkGrayColor];
    notifyEmailTextFiled.placeholder = @"通过邮件发送";
    notifyEmailTextFiled.text = giftOrder.giftDelivery.email;
    if (giftOrder.giftDelivery.emailNotify == YES){
        notifyEmailOverlayView.hidden = YES;
        [notifyEmailButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
    }else{
        notifyEmailOverlayView.hidden = NO;
        [notifyEmailButton setImage:[UIImage imageNamed:@"gift_delivery_switch_off"] forState:UIControlStateNormal];
    }
    
    [notifyWeiboButton addTarget:self action:@selector(handleNotifyWeiboButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    notifyWeiboTextFiled.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    notifyWeiboTextFiled.textColor = [UIColor darkGrayColor];
    notifyWeiboTextFiled.placeholder = @"通过微博发送";
    notifyWeiboTextFiled.text = @"";
    
    notifyCalendarTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    notifyCalendarTitleLabel.textColor = [UIColor darkGrayColor];
    notifyCalendarTitleLabel.text = @"何时发送通知？";
    
    notifyCalendarLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    notifyCalendarLabel.textColor = [UIColor darkGrayColor];
    notifyCalendarLabel.text = @"立即发送";
    
    notifyWeiBoView.hidden = YES;
    
    [notifyCalendarButton addTarget:self action:@selector(handleCalendarButtonTouchDownAction:) forControlEvents:UIControlEventTouchDown];
    [notifyCalendarButton addTarget:self action:@selector(handleCalendarButtonTouchUpAction:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel|UIControlEventTouchUpInside];
    [notifyCalendarButton addTarget:self action:@selector(handleCalendarButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapDeliveryDetailGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleTapDeliveryDetailViewGesture:)];
    tapDeliveryDetailGestureRecognizer.numberOfTapsRequired = 1;
    tapDeliveryDetailGestureRecognizer.numberOfTouchesRequired = 1;
    tapDeliveryDetailGestureRecognizer.delegate = self;
    [deliveryDetailScrollView addGestureRecognizer:tapDeliveryDetailGestureRecognizer];
    [tapDeliveryDetailGestureRecognizer release];
    
    UITapGestureRecognizer *tapNotifyPhoneOverlayViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleTapNotifyPhoneOverlayViewGesture:)];
    tapNotifyPhoneOverlayViewGestureRecognizer.numberOfTapsRequired = 1;
    tapNotifyPhoneOverlayViewGestureRecognizer.numberOfTouchesRequired = 1;
    tapNotifyPhoneOverlayViewGestureRecognizer.delegate = self;
    [notifyPhoneOverlayView addGestureRecognizer:tapNotifyPhoneOverlayViewGestureRecognizer];
    [tapNotifyPhoneOverlayViewGestureRecognizer release];
    
    UITapGestureRecognizer *tapNotifyEmailOverlayViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleTapNotifyEmailOverlayViewGesture:)];
    tapNotifyEmailOverlayViewGestureRecognizer.numberOfTapsRequired = 1;
    tapNotifyEmailOverlayViewGestureRecognizer.numberOfTouchesRequired = 1;
    tapNotifyEmailOverlayViewGestureRecognizer.delegate = self;
    [notifyEmailOverlayView addGestureRecognizer:tapNotifyEmailOverlayViewGestureRecognizer];
    [tapNotifyEmailOverlayViewGestureRecognizer release];
    
    UITapGestureRecognizer *tapNotifyWeiboOverlayViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleTapNotifyWeiboOverlayViewGesture:)];
    tapNotifyWeiboOverlayViewGestureRecognizer.numberOfTapsRequired = 1;
    tapNotifyWeiboOverlayViewGestureRecognizer.numberOfTouchesRequired = 1;
    tapNotifyWeiboOverlayViewGestureRecognizer.delegate = self;
    [notifyWeiboOverlayView addGestureRecognizer:tapNotifyWeiboOverlayViewGestureRecognizer];
    [tapNotifyWeiboOverlayViewGestureRecognizer release];
 
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    CGSize contentSize = deliveryDetailScrollView.contentSize;
    contentSize.height = deliveryDetailScrollView.frame.size.height + 1.0;
    deliveryDetailScrollView.contentSize = contentSize;
    
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
    
    [self updateDeleveryDisplay];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    
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
    [deliveryDetailScrollView release];
    [giftOrder release];
    [senderTitleLabel release];
    [senderValueLabel release];
    [notifyTitleLabel release];
    [notifyAddressbookButton release];
    [notifyPhoneButton release];
    [notifyPhoneTextFiled release];
    [notifyPhoneOverlayView release];
    [notifyPhoneView release];
    [notifyEmailButton release];
    [notifyEmailTextFiled release];
    [notifyEmailOverlayView release];
    [notifyEmailView release];
    [notifyWeiboButton release];
    [notifyWeiboTextFiled release];
    [notifyWeiBoView release];
    [notifyWeiboOverlayView release];
    [notifyCalendarTitleLabel release];
    [notifyCalendarImageView release];
    [notifyCalendarLabel release];
    [notifyCalendarButton release];
    if (datePickerControlView != nil){
        [datePickerControlView release];
        datePickerControlView = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
	[super dealloc];
}


- (void)handleCancelAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleDoneAction:(id)sender{
    if ([self isDatePickerViewShown]){
        [self hideDatePickerView];
    }else{
        [self checkKeyboardVisiblity];
        
        if (notifyPhoneOverlayView.hidden == NO){
            giftOrder.giftDelivery.phoneNotify = NO;
        }else{
            giftOrder.giftDelivery.phoneNotify = YES;
        }
        giftOrder.giftDelivery.phone = [HGUtility normalizeMobileNumber:notifyPhoneTextFiled.text];
        
        if (notifyEmailOverlayView.hidden == NO){
            giftOrder.giftDelivery.emailNotify = NO;
        }else{
            giftOrder.giftDelivery.emailNotify = YES;
        }
        giftOrder.giftDelivery.email = [notifyEmailTextFiled.text stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (giftOrder.giftRecipient == nil ||
            ((giftOrder.giftDelivery.emailNotify == YES && ![HGUtility isValidEmail:giftOrder.giftDelivery.email]) || 
             (giftOrder.giftDelivery.phoneNotify == YES && ![HGUtility isValidMobileNumber:giftOrder.giftDelivery.phone]))){
                if (giftOrder.giftRecipient == nil){
                }else if (giftOrder.giftDelivery.emailNotify == YES && ![HGUtility isValidEmail:giftOrder.giftDelivery.email]){
                    [self performBounceViewAnimation:notifyEmailView];
                }else if (giftOrder.giftDelivery.phoneNotify == YES && ![HGUtility isValidMobileNumber:giftOrder.giftDelivery.phone]){
                    [self performBounceViewAnimation:notifyPhoneView];
                }
                
                HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                [appDelegate sendNotification:@"请填写正确的递送信息"];
                return;    
        }
        
        if (giftOrder.giftDelivery.phoneNotify == NO && giftOrder.giftDelivery.emailNotify == NO){
            
            [self performBounceViewAnimation:notifyEmailView];
            [self performBounceViewAnimation:notifyPhoneView];
            
            HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate sendNotification:@"请填写正确的递送信息"];
            return;
        }
        
        if (giftOrder.giftDelivery.phoneNotify == YES){
            [HGTrackingService logEvent:kTrackingEventEnablePhoneNotify];
        }
        if (giftOrder.giftDelivery.emailNotify == YES){
            [HGTrackingService logEvent:kTrackingEventEnableEmailNotify];
        }
        if (giftOrder.orderNotifyDate != nil){
            [HGTrackingService logEvent:kTrackingEventEnableDelayNotify];
        }
        
        BOOL recipientChanged = NO;
        if (giftOrder.giftDelivery.phone != nil && [giftOrder.giftDelivery.phone isEqualToString:@""] == NO){
            if (giftOrder.giftRecipient.recipientPhone == nil || [giftOrder.giftRecipient.recipientPhone isEqualToString:giftOrder.giftDelivery.phone] == NO){
                giftOrder.giftRecipient.recipientPhone = giftOrder.giftDelivery.phone;
                recipientChanged = YES;
            }
        }
        if (giftOrder.giftDelivery.email != nil && [giftOrder.giftDelivery.email isEqualToString:@""] == NO){
            if (giftOrder.giftRecipient.recipientEmail == nil || [giftOrder.giftRecipient.recipientEmail isEqualToString:giftOrder.giftDelivery.email] == NO){
                giftOrder.giftRecipient.recipientEmail = giftOrder.giftDelivery.email;
                recipientChanged = YES;
            }
        }
        if (recipientChanged){
            [[HGRecipientService sharedService] updateRecipient:giftOrder.giftRecipient];
        }
        
        HGAccount* currentAccount = [HGAccountService sharedService].currentAccount;
        if (![HGUtility isValidEmail:currentAccount.userEmail] && 
            ![HGUtility isValidMobileNumber:currentAccount.userPhone]) {
            HGContactInfoViewController* viewController = [[HGContactInfoViewController alloc] initWithGiftOrder:giftOrder];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
        } else {
            [HGTrackingService logEvent:kTrackingEventEnterGiftOrderDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGDeliveryDetailViewController", @"from", giftOrder.gift.identifier, @"gift", nil]];
            
            HGOrderViewController* viewController = [[HGOrderViewController alloc] initWithGiftOrder:giftOrder];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
        }
    }
}

- (void)handleNotifyAddressBookButtonAction:(id)sender{
    peoplePickerViewController = [[ABPeoplePickerNavigationController alloc] init];
    peoplePickerViewController.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_background"]];
    peoplePickerViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    peoplePickerViewController.peoplePickerDelegate = self;
    [self presentModalViewController:peoplePickerViewController animated:YES];
    [peoplePickerViewController release];
}

- (void)handleNotifyPhoneButtonAction:(id)sender{
    if (notifyPhoneOverlayView.hidden == YES){
        notifyPhoneOverlayView.hidden = NO;
        [notifyPhoneButton setImage:[UIImage imageNamed:@"gift_delivery_switch_off"] forState:UIControlStateNormal];
        [self checkKeyboardVisiblity];
    }else{
        notifyPhoneOverlayView.hidden = YES;
        [notifyPhoneButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
    }
}

- (void)handleNotifyEmailButtonAction:(id)sender{
    if (notifyEmailOverlayView.hidden == YES){
        notifyEmailOverlayView.hidden = NO;
        [notifyEmailButton setImage:[UIImage imageNamed:@"gift_delivery_switch_off"] forState:UIControlStateNormal];
        [self checkKeyboardVisiblity];
    }else{
        notifyEmailOverlayView.hidden = YES;
        [notifyEmailButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
    }
}

- (void)handleNotifyWeiboButtonAction:(id)sender{
    if (notifyWeiboOverlayView.hidden == YES){
        notifyWeiboOverlayView.hidden = NO;
        [notifyWeiboButton setImage:[UIImage imageNamed:@"gift_delivery_switch_off"] forState:UIControlStateNormal];
        [self checkKeyboardVisiblity];
    }else{
        notifyWeiboOverlayView.hidden = YES;
        [notifyWeiboButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
    }   
}

- (void)handleNotifyCalendarButtonAction:(id)sender{
    if (notifyWeiboOverlayView.hidden == YES){
        notifyWeiboOverlayView.hidden = NO;
        [notifyWeiboButton setImage:[UIImage imageNamed:@"gift_delivery_switch_off"] forState:UIControlStateNormal];
    }else{
        notifyWeiboOverlayView.hidden = YES;
        [notifyWeiboButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
    }   
}

- (void)handleCalendarButtonClickAction:(id)sender{
    [self checkKeyboardVisiblity];
    
    if ([self isDatePickerViewShown]){
        [self hideDatePickerView];
    }else{
        [self showDatePickerView];
    }
}

- (void)handleCalendarButtonTouchDownAction:(id)sender{
    notifyCalendarImageView.highlighted = YES;
    notifyCalendarLabel.highlighted = YES;
}

- (void)handleCalendarButtonTouchUpAction:(id)sender{
    notifyCalendarImageView.highlighted = NO;
    notifyCalendarLabel.highlighted = NO;
}


- (void)updateDeleveryDisplay{
    
}

- (void)checkKeyboardVisiblity{
    if ([notifyPhoneTextFiled isFirstResponder]){
        [notifyPhoneTextFiled resignFirstResponder];
    }
    if ([notifyEmailTextFiled isFirstResponder]){
        [notifyEmailTextFiled resignFirstResponder];
    }
    if ([notifyWeiboTextFiled isFirstResponder]){
        [notifyWeiboTextFiled resignFirstResponder];
    }
}

- (void)checkTextInputVisiblity{
    if ([notifyPhoneTextFiled isFirstResponder] ||
        [notifyEmailTextFiled isFirstResponder] ||
        [notifyWeiboTextFiled isFirstResponder]){
        CGPoint scrollViewContentOffset = deliveryDetailScrollView.contentOffset;
        scrollViewContentOffset.y = 103.0;
        [deliveryDetailScrollView setContentOffset:scrollViewContentOffset animated:YES];
    }
}

- (void)handleDatePickerValueChanged:(id)sender {
    NSDate* deliveryDate = datePickerControlView.date;
    giftOrder.orderNotifyDate = deliveryDate;
    if (giftOrder.orderNotifyDate == nil/* || [giftOrder.orderNotifyDate timeIntervalSinceNow] <= 60*15*/){
        notifyCalendarLabel.text = @"立即发送";
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        notifyCalendarLabel.text = [dateFormatter stringFromDate:giftOrder.orderNotifyDate];
        [dateFormatter release];
    }
} 


- (void)showDatePickerView{
    if (datePickerControlView == nil){
        datePickerControlView = [[UIDatePicker alloc] init];
        datePickerControlView.minimumDate = [NSDate dateWithTimeIntervalSinceNow:0];
        datePickerControlView.maximumDate = [NSDate dateWithTimeIntervalSinceNow:3600*24*30];
        CGRect datePickerFrame = datePickerControlView.frame;
        datePickerFrame.origin.x = 0.0;
        datePickerFrame.origin.y = self.view.frame.size.height;
        datePickerControlView.frame = datePickerFrame;
        
        if (giftOrder.orderNotifyDate) {
            datePickerControlView.date = giftOrder.orderNotifyDate;
        }
        
        [datePickerControlView addTarget:self action:@selector(handleDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.view addSubview:datePickerControlView];
        
        UIButton* rightBarButton = (UIButton*)rightBarButtonItem.customView;
        [rightBarButton setTitle:@"确定"  forState:UIControlStateNormal];
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.3];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [rightBarButton.layer addAnimation:animation forKey:@"updateRightButtonAnimation"];
        
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect datePickerFrame = datePickerControlView.frame;
                             datePickerFrame.origin.y = self.view.frame.size.height - datePickerFrame.size.height;
                             datePickerControlView.frame = datePickerFrame;
                             
                             CGRect deliveryDetailScrollViewFrame = deliveryDetailScrollView.frame;
                             deliveryDetailScrollViewFrame.size.height = 416.0 - datePickerFrame.size.height;
                             deliveryDetailScrollView.frame = deliveryDetailScrollViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             
                             CGPoint scrollViewContentOffset = deliveryDetailScrollView.contentOffset;
                             scrollViewContentOffset.y = 215.0;
                             [deliveryDetailScrollView setContentOffset:scrollViewContentOffset animated:YES];
                             
                         }];
    }
}

- (void)hideDatePickerView{
    if (datePickerControlView != nil){
        
        UIButton* rightBarButton = (UIButton*)rightBarButtonItem.customView;
        [rightBarButton setTitle:@"下一步"  forState:UIControlStateNormal];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.3];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [rightBarButton.layer addAnimation:animation forKey:@"updateRightButtonAnimation"];
        
        
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect datePickerFrame = datePickerControlView.frame;
                             datePickerFrame.origin.y = self.view.frame.size.height;
                             datePickerControlView.frame = datePickerFrame;
                             
                             CGRect deliveryDetailScrollViewFrame = deliveryDetailScrollView.frame;
                             deliveryDetailScrollViewFrame.size.height = 416.0;
                             deliveryDetailScrollView.frame = deliveryDetailScrollViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             
                             CGPoint scrollViewContentOffset = deliveryDetailScrollView.contentOffset;
                             scrollViewContentOffset.y = 0.0;
                             [deliveryDetailScrollView setContentOffset:scrollViewContentOffset animated:YES];
                             
                             [datePickerControlView removeFromSuperview];
                             [datePickerControlView release];
                             datePickerControlView = nil;
                         }];
    }
}

- (BOOL)isDatePickerViewShown{
    if (datePickerControlView == nil){
        return NO;
    }else{
        return YES;
    }
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
- (void)handleTapDatePickerOverLayViewGesture:(UITapGestureRecognizer*)sender{
    [self hideDatePickerView];
}

- (void)handleTapNotifyPhoneOverlayViewGesture:(UITapGestureRecognizer*)sender{
    notifyPhoneOverlayView.hidden = YES;
    [notifyPhoneButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
    [notifyPhoneTextFiled becomeFirstResponder];
}

- (void)handleTapNotifyEmailOverlayViewGesture:(UITapGestureRecognizer*)sender{
    notifyEmailOverlayView.hidden = YES;
    [notifyEmailButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
    [notifyEmailTextFiled becomeFirstResponder];
}

- (void)handleTapNotifyWeiboOverlayViewGesture:(UITapGestureRecognizer*)sender{
    notifyWeiboOverlayView.hidden = YES;
    [notifyWeiboButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
    [notifyWeiboTextFiled becomeFirstResponder];
}

- (void)handleTapDeliveryDetailViewGesture:(UITapGestureRecognizer*)sender{
    [self checkKeyboardVisiblity];
    if (datePickerControlView != nil){
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect datePickerFrame = datePickerControlView.frame;
                             datePickerFrame.origin.y = self.view.frame.size.height;
                             datePickerControlView.frame = datePickerFrame;
                             
                             CGRect deliveryDetailScrollViewFrame = deliveryDetailScrollView.frame;
                             deliveryDetailScrollViewFrame.size.height = 416.0;
                             deliveryDetailScrollView.frame = deliveryDetailScrollViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             
                             CGPoint scrollViewContentOffset = deliveryDetailScrollView.contentOffset;
                             scrollViewContentOffset.y = 0.0;
                             [deliveryDetailScrollView setContentOffset:scrollViewContentOffset animated:YES];
                             
                             [datePickerControlView removeFromSuperview];
                             [datePickerControlView release];
                             datePickerControlView = nil;
                         }];
    }
}

#pragma mark - Actions
- (void)keyboardWillShow:(NSNotification *)notfication {
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect keyboardBounds;
                         [[notfication.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
                         
                         CGRect deliveryDetailScrollViewFrame = deliveryDetailScrollView.frame;
                         deliveryDetailScrollViewFrame.size.height = 416.0 - keyboardBounds.size.height;
                         deliveryDetailScrollView.frame = deliveryDetailScrollViewFrame;
                     } 
                     completion:^(BOOL finished) {
                         [self checkTextInputVisiblity];
                     }];
}

- (void)keyboardDidShow:(NSNotification *)notfication {
}

- (void)keyboardWillHide:(NSNotification *)notfication {
    
    [deliveryDetailScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect keyboardBounds;
                         [[notfication.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
                         
                         CGRect deliveryDetailScrollViewFrame = deliveryDetailScrollView.frame;
                         deliveryDetailScrollViewFrame.size.height = 416.0;
                         deliveryDetailScrollView.frame = deliveryDetailScrollViewFrame;
                     } 
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)keyboardDidHide:(NSNotification *)notfication {
}


#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == notifyPhoneButton ||
        touch.view == notifyAddressbookButton ||
        touch.view == notifyEmailButton ||
        touch.view == notifyWeiboButton ||
        touch.view == notifyCalendarButton ||
        touch.view == notifyPhoneTextFiled ||
        touch.view == notifyEmailTextFiled||
        touch.view == notifyWeiboTextFiled) {
        return NO;
    }
    return YES; 
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self hideDatePickerView];
    return YES;
}

#pragma mark UITextFieldDelegate
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    return YES;
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField{
//    if (notifyPhoneTextFiled == textField){
//        giftOrder.giftDelivery.phoneNotify = YES;
//        giftOrder.giftDelivery.phone =  [notifyPhoneTextFiled.text stringByTrimmingCharactersInSet:
//                                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    }else if (notifyWeiboTextFiled == textField){
//       
//    }else if (notifyEmailTextFiled == textField){
//        giftOrder.giftDelivery.emailNotify = YES;
//        giftOrder.giftDelivery.email = [notifyEmailTextFiled.text stringByTrimmingCharactersInSet:
//                                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    }
//}

#pragma mark ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [peoplePickerViewController dismissModalViewControllerAnimated:YES];
    peoplePickerViewController = nil;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    
    ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSMutableArray *phones = [[NSMutableArray alloc] init];
    for (int index = 0; index < ABMultiValueGetCount(phoneMulti); index++){
        NSString *aPhone = [(NSString*)ABMultiValueCopyValueAtIndex(phoneMulti, index) autorelease];
        NSString *aLabel = [(NSString*)ABMultiValueCopyLabelAtIndex(phoneMulti, index) autorelease];
        if([aLabel isEqualToString:@"_$!<Mobile>!$_"]){
            [phones addObject:aPhone];
        }
    }
    if([phones count]>0){
        NSString *mobileNo = [phones objectAtIndex:0];
        if (notifyPhoneOverlayView.hidden == NO){
            notifyPhoneOverlayView.hidden = YES;
            giftOrder.giftDelivery.phoneNotify = YES;
            [notifyPhoneButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
        }
        giftOrder.giftDelivery.phone = mobileNo;
        notifyPhoneTextFiled.text = mobileNo;
    }
   
    ABMutableMultiValueRef emailMulti = ABRecordCopyValue(person, kABPersonEmailProperty);
    NSMutableArray *emails = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < ABMultiValueGetCount(emailMulti); index++){
        NSString *emailAdress = [(NSString*)ABMultiValueCopyValueAtIndex(emailMulti, index) autorelease];
        [emails addObject:emailAdress];
    }
    if([emails count]>0){
        NSString *email = [emails objectAtIndex:0];
        if (notifyEmailOverlayView.hidden == NO){
            notifyEmailOverlayView.hidden = YES;
            giftOrder.giftDelivery.emailNotify = YES;
            [notifyEmailButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
        }
        giftOrder.giftDelivery.email = email;
        notifyEmailTextFiled.text = email;
    }
    
    [peoplePickerViewController dismissModalViewControllerAnimated:YES];
    peoplePickerViewController = nil;
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}
@end

