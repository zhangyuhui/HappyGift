//
//  HGRecipientContactViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGRecipientContactViewController.h"
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

@interface HGRecipientContactViewController()<UIScrollViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate>

@end

@implementation HGRecipientContactViewController
- (id)initWithGiftOrder:(HGGiftOrder*)theGiftOrder{
    self = [super initWithNibName:@"HGRecipientContactViewController" bundle:nil];
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
	titleLabel.text = @"收礼信息";
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
    if (giftOrder.giftDelivery.phone != nil && giftOrder.giftDelivery.phone.length > 0){
        giftOrder.giftDelivery.phoneNotify = YES;
        notifyPhoneOverlayView.hidden = YES;
        [notifyPhoneButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
    }else{
        giftOrder.giftDelivery.phoneNotify = NO;
        notifyPhoneOverlayView.hidden = NO;
        [notifyPhoneButton setImage:[UIImage imageNamed:@"gift_delivery_switch_off"] forState:UIControlStateNormal];
    }
    
    [notifyEmailButton addTarget:self action:@selector(handleNotifyEmailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    notifyEmailTextFiled.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    notifyEmailTextFiled.textColor = [UIColor darkGrayColor];
    notifyEmailTextFiled.placeholder = @"通过邮件发送";
    notifyEmailTextFiled.text = giftOrder.giftDelivery.email;
    if (giftOrder.giftDelivery.email != nil && giftOrder.giftDelivery.email.length > 0){
        giftOrder.giftDelivery.emailNotify = YES;
        notifyEmailOverlayView.hidden = YES;
        [notifyEmailButton setImage:[UIImage imageNamed:@"gift_delivery_switch_on"] forState:UIControlStateNormal];
    }else{
        giftOrder.giftDelivery.emailNotify = NO;
        notifyEmailOverlayView.hidden = NO;
        [notifyEmailButton setImage:[UIImage imageNamed:@"gift_delivery_switch_off"] forState:UIControlStateNormal];
    }
    
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
	[super dealloc];
}


- (void)handleCancelAction:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)handleDoneAction:(id)sender{
    
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
        if (giftOrder.giftDelivery.phoneNotify == NO){
            [self performBounceViewAnimation:notifyPhoneView];
        }
        if (giftOrder.giftDelivery.emailNotify == NO){
            [self performBounceViewAnimation:notifyEmailView];
        }
        
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
        [HGTrackingService logEvent:kTrackingEventEnterGiftOrderDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGRecipientContactViewController", @"from", giftOrder.gift.identifier, @"gift", nil]];
        
        HGOrderViewController* viewController = [[HGOrderViewController alloc] initWithGiftOrder:giftOrder];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
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

- (void)checkKeyboardVisiblity{
    if ([notifyPhoneTextFiled isFirstResponder]){
        [notifyPhoneTextFiled resignFirstResponder];
    }
    if ([notifyEmailTextFiled isFirstResponder]){
        [notifyEmailTextFiled resignFirstResponder];
    }
}

- (void)checkTextInputVisiblity{
    if ([notifyPhoneTextFiled isFirstResponder] ||
        [notifyEmailTextFiled isFirstResponder]){
        CGPoint scrollViewContentOffset = deliveryDetailScrollView.contentOffset;
        scrollViewContentOffset.y = 103.0;
        [deliveryDetailScrollView setContentOffset:scrollViewContentOffset animated:YES];
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


- (void)handleTapDeliveryDetailViewGesture:(UITapGestureRecognizer*)sender{
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
        touch.view == notifyPhoneTextFiled ||
        touch.view == notifyEmailTextFiled) {
        return NO;
    }
    return YES;
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
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

