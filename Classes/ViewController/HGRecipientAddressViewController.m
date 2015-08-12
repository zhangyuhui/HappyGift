//
//  HGRecipientAddressViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-27.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGRecipientAddressViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGOrderViewController.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGGiftOrder.h"
#import "HGTrackingService.h"
#import "HGAccountService.h"
#import "HGRecipientService.h"
#import "HGUtility.h"
#import "HGContactInfoViewController.h"
#import "HGLogging.h"

#define kProvinceComponent 0
#define kCityComponent 1


@interface HGRecipientAddressViewController()<UIScrollViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
  
@end

@implementation HGRecipientAddressViewController
@synthesize provinceCities;
@synthesize provinces;
@synthesize cities;
@synthesize provincePicker;

- (id)initWithGiftOrder:(HGGiftOrder*)theGiftOrder{
    self = [super initWithNibName:@"HGRecipientAddressViewController" bundle:nil];
    if (self){
        giftOrder = [theGiftOrder retain];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initProvinceData];
    
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
    
    recipientLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    recipientLabel.textColor = [UIColor darkGrayColor];
    
    provinceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    provinceLabel.textColor = [UIColor darkGrayColor];
    
    streetAddressLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    streetAddressLabel.textColor = [UIColor darkGrayColor];
    
    postCodeLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    postCodeLabel.textColor = [UIColor darkGrayColor];
    
    phoneLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    phoneLabel.textColor = [UIColor darkGrayColor];

    notificationTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    notificationTitleLabel.textColor = [UIColor darkGrayColor];
    
    notificationSubTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    notificationSubTitleLabel.textColor = [UIColor lightGrayColor];
    
    phoneLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    phoneLabel.textColor = [UIColor darkGrayColor];
    
    recipientTextField.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    recipientTextField.textColor = [UIColor darkGrayColor];
    
    provinceTextField.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    provinceTextField.textColor = [UIColor darkGrayColor];
    
    streetAddressTextField.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    streetAddressTextField.textColor = [UIColor darkGrayColor];

    postCodeTextField.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    postCodeTextField.textColor = [UIColor darkGrayColor];
    
    phoneTextField.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    phoneTextField.textColor = [UIColor darkGrayColor];
    
    [nextStepButton addTarget:self action:@selector(handleDoneAction:) forControlEvents:UIControlEventTouchUpInside];
    UIImage* addButtonBackgroundImage = [[UIImage imageNamed:@"gift_selection_button"] stretchableImageWithLeftCapWidth:5 topCapHeight:10];
    [nextStepButton setBackgroundImage:addButtonBackgroundImage forState:UIControlStateNormal];
    nextStepButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    [nextStepButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextStepButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    notifyCalendarLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    notifyCalendarLabel.textColor = [UIColor darkGrayColor];
    notifyCalendarLabel.text = @"立即发送";
    
    [notifyCalendarButton addTarget:self action:@selector(handleCalendarButtonTouchDownAction:) forControlEvents:UIControlEventTouchDown];
    [notifyCalendarButton addTarget:self action:@selector(handleCalendarButtonTouchUpAction:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel|UIControlEventTouchUpInside];
    [notifyCalendarButton addTarget:self action:@selector(handleCalendarButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [provinceButton addTarget:self action:@selector(handleSelectProvinceAction:) forControlEvents:UIControlEventTouchUpInside];

    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    UITapGestureRecognizer *tapDeliveryDetailGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleTapDeliveryDetailViewGesture:)];
    tapDeliveryDetailGestureRecognizer.numberOfTapsRequired = 1;
    tapDeliveryDetailGestureRecognizer.numberOfTouchesRequired = 1;
    tapDeliveryDetailGestureRecognizer.delegate = self;
    [recipientAddressScrollView addGestureRecognizer:tapDeliveryDetailGestureRecognizer];
    [tapDeliveryDetailGestureRecognizer release];
    
    
    HGRecipient* recipient = giftOrder.giftRecipient;
    
    recipientTextField.text = recipient.recipientDisplayName;
    selectedProvince = [recipient.recipientProvince retain];
    selectedCity = [recipient.recipientCity retain];
    if (recipient.recipientProvince && ![@"" isEqualToString:recipient.recipientProvince] &&
        recipient.recipientCity && ![@"" isEqualToString:recipient.recipientCity]) {
         provinceTextField.text = [HGUtility displayTextForProvince:recipient.recipientProvince andCity:recipient.recipientCity];
    }
    
    streetAddressTextField.text = recipient.recipientStreetAddress;
    postCodeTextField.text = recipient.recipientPostCode;
    phoneTextField.text = recipient.recipientPhone;
    
    CGSize contentSize = recipientAddressScrollView.contentSize;
    contentSize.height = recipientAddressScrollView.frame.size.height + 1.0;
    recipientAddressScrollView.contentSize = contentSize;
    
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

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [progressView release];
    [leftBarButtonItem release];
    [recipientAddressScrollView release];
    [giftOrder release];
    
    [recipientTextField release];
    [provinceTextField release];
    [streetAddressTextField release];
    [postCodeTextField release];
    [phoneTextField release];
    
    [recipientLabel release];
    [provinceLabel release];
    [streetAddressLabel release];
    [postCodeLabel release];
    [phoneLabel release];
    [notificationTitleLabel release];
    [notificationSubTitleLabel release];
    
    [recipientNameBackground release];
    [provinceBackground release];
    [streetAddressBackground release];
    [postCodeBackground release];
    [phoneBackground release];
    
    [nextStepButton release];
    
    [selectedProvince release];
    [selectedCity release];
    
    self.provincePicker = nil;
    self.provinceCities = nil;
    self.provinces = nil;
    self.cities = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
	[super dealloc];
}

NSInteger compareByName(id p1, id p2, void *context) {
    NSString* c1 = [[HGRecipientService sharedService].provinceCode objectForKey:(NSString*)p1];
    NSString* c2 = [[HGRecipientService sharedService].provinceCode objectForKey:(NSString*)p2];
    
    return [c1 compare:c2];
}

- (void)handleSelectProvinceAction:(id)sender {
    [self hideDatePickerView];
    [self checkKeyboardVisiblity];
    if (provincePicker == nil) {
        [self showProvincePickerView];
    } else {
        [self hideProvincePickerView];
    }
}

- (void)handleDatePickerValueChanged:(id)sender {
    NSDate* deliveryDate = datePickerControlView.date;
    giftOrder.orderNotifyDate = deliveryDate;
    if (giftOrder.orderNotifyDate == nil) {
        notifyCalendarLabel.text = @"立即发送";
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        notifyCalendarLabel.text = [dateFormatter stringFromDate:giftOrder.orderNotifyDate];
        [dateFormatter release];
    }
}

- (void)handleCancelAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleDoneAction:(id)sender {
    if ([self isDatePickerViewShown]){
        [self hideDatePickerView];
    } else if (provincePicker != nil) {
        [self hideProvincePickerView];
    } else {
        [self checkKeyboardVisiblity];
        NSString* recipientName = [recipientTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString* province = [selectedProvince stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString* city = [selectedCity stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString* streetAddress = [streetAddressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString* postCode = [postCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString* phone = [HGUtility normalizeMobileNumber:phoneTextField.text];
        
        BOOL checkPass = YES;
        if (!recipientName || [@"" isEqualToString:recipientName]) {
            checkPass = NO;
            [self performBounceViewAnimation:recipientTextField];
            [self performBounceViewAnimation:recipientNameBackground];
        }
        
        if (!province || [@"" isEqualToString:province]) {
            checkPass = NO;
            [self performBounceViewAnimation:provinceTextField];
            [self performBounceViewAnimation:provinceBackground];
        }
        
        if (!streetAddress || [@"" isEqualToString:streetAddress]) {
            checkPass = NO;
            [self performBounceViewAnimation:streetAddressTextField];
            [self performBounceViewAnimation:streetAddressBackground];
        }
        
        if (![HGUtility validatePostCode:postCode]) {
            checkPass = NO;
            [self performBounceViewAnimation:postCodeTextField];
            [self performBounceViewAnimation:postCodeBackground];
        }
        
        if (![HGUtility isValidMobileNumber:phone]) {
            checkPass = NO;
            [self performBounceViewAnimation:phoneTextField];
            [self performBounceViewAnimation:phoneBackground];
        }
        
        if (!checkPass) {
            HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate sendNotification:@"请填写正确的收礼信息"];
        } else {
            giftOrder.giftRecipient.recipientDisplayName = recipientName;
            giftOrder.giftRecipient.recipientProvince = province;
            giftOrder.giftRecipient.recipientCity = city;
            giftOrder.giftRecipient.recipientStreetAddress = streetAddress;
            giftOrder.giftRecipient.recipientPostCode = postCode;
            giftOrder.giftRecipient.recipientPhone = phone;
            
            [[HGRecipientService sharedService] updateRecipient:giftOrder.giftRecipient];
            
            if (giftOrder.giftDelivery == nil) {
                HGGiftDelivery* theGiftDelivery = [[HGGiftDelivery alloc] init];
                giftOrder.giftDelivery = theGiftDelivery;
                [theGiftDelivery release];
            }
            
            giftOrder.giftDelivery.phone = giftOrder.giftRecipient.recipientPhone;
            giftOrder.giftDelivery.emailNotify = NO;
            giftOrder.giftDelivery.phoneNotify = YES;
            
            if ([giftOrder.gift isFixedShippingCost]) {
                giftOrder.shippingCost = giftOrder.gift.shippingCostMax;
            } else {
                giftOrder.shippingCost = -1.0;
            }
            
            if (giftOrder.orderNotifyDate != nil){
                [HGTrackingService logEvent:kTrackingEventEnableDelayNotify];
            }
            
            HGAccount* currentAccount = [HGAccountService sharedService].currentAccount;
            if (![HGUtility isValidEmail:currentAccount.userEmail] && 
                ![HGUtility isValidMobileNumber:currentAccount.userPhone]) {
                HGContactInfoViewController* viewController = [[HGContactInfoViewController alloc] initWithGiftOrder:giftOrder];
                [self.navigationController pushViewController:viewController animated:YES];
                [viewController release];
            } else {
                [HGTrackingService logEvent:kTrackingEventEnterGiftOrderDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGRecipientAddressViewController", @"from", giftOrder.gift.identifier, @"gift", nil]];
                
                HGOrderViewController* viewController = [[HGOrderViewController alloc] initWithGiftOrder:giftOrder];
                [self.navigationController pushViewController:viewController animated:YES];
                [viewController release];
            }

        }
    }
}

- (void)handleCalendarButtonClickAction:(id)sender{
    [self hideProvincePickerView];
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

- (void)initProvinceData {
    NSString *plistURL = [[NSBundle mainBundle] pathForResource:@"ProvinceCities" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:plistURL];
    
    self.provinceCities = dictionary;
    NSArray *components = [self.provinceCities allKeys];
    NSArray *sorted = [components sortedArrayUsingFunction:compareByName context:NULL];
    self.provinces = sorted;
    
    NSString *selectedState = [self.provinces objectAtIndex:0];
    NSArray *array = [[provinceCities objectForKey:selectedState] objectForKey:@"cities"];
    self.cities = array;
} 

- (void)showProvincePickerView{
    if (provincePicker == nil){
        provincePicker = [[UIPickerView alloc] init];
        provincePicker.delegate = self;
        provincePicker.dataSource = self;
        provincePicker.showsSelectionIndicator = YES;
        CGRect datePickerFrame = provincePicker.frame;
        datePickerFrame.origin.x = 0.0;
        datePickerFrame.origin.y = self.view.frame.size.height;
        provincePicker.frame = datePickerFrame;
        
        if (selectedProvince && ![@"" isEqualToString:selectedProvince]) {
            NSUInteger pos = [self.provinces indexOfObject:selectedProvince];
            if (pos !=  NSNotFound) {
                [provincePicker selectRow:pos inComponent:kProvinceComponent animated:NO];
                self.cities = [[provinceCities objectForKey:selectedProvince] objectForKey:@"cities"];
                
                if (selectedCity && ![@"" isEqualToString:selectedCity]) {
                    NSUInteger pos = [self.cities indexOfObject:selectedCity];
                    if (pos !=  NSNotFound) {
                        [provincePicker selectRow:pos inComponent:kCityComponent animated:NO];
                    }
                } 
            }
        }
        
        if (!provinceTextField.text || [@"" isEqualToString:provinceTextField.text]) {
            NSUInteger pos = [self.provinces indexOfObject:@"北京"];
            
            [provincePicker selectRow:pos inComponent:kProvinceComponent animated:NO];
            NSString *province = [self.provinces objectAtIndex:pos];
            
            self.cities = [[provinceCities objectForKey:province] objectForKey:@"cities"];
            NSString *city = [self.cities objectAtIndex:0];
            
            selectedProvince = [province retain];
            selectedCity = [city retain];
            
            provinceTextField.text = [HGUtility displayTextForProvince:province andCity:city];
        }
        
        [provincePicker reloadAllComponents];
        
        [self.view addSubview:provincePicker];
        
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
                             CGRect datePickerFrame = provincePicker.frame;
                             datePickerFrame.origin.y = self.view.frame.size.height - datePickerFrame.size.height;
                             provincePicker.frame = datePickerFrame;
                             
                             CGRect deliveryDetailScrollViewFrame = recipientAddressScrollView.frame;
                             deliveryDetailScrollViewFrame.size.height = 416.0 - datePickerFrame.size.height;
                             recipientAddressScrollView.frame = deliveryDetailScrollViewFrame;
                         } 
                         completion:^(BOOL finished) {
                         }];
    }
}

- (void)hideProvincePickerView{
    if (provincePicker != nil){
        
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
                             CGRect datePickerFrame = provincePicker.frame;
                             datePickerFrame.origin.y = self.view.frame.size.height;
                             provincePicker.frame = datePickerFrame;
                             
                             CGRect deliveryDetailScrollViewFrame = recipientAddressScrollView.frame;
                             deliveryDetailScrollViewFrame.size.height = 416.0;
                             recipientAddressScrollView.frame = deliveryDetailScrollViewFrame;
                             
                             provincePicker.alpha = 0.0;
                         } 
                         completion:^(BOOL finished) {
                             
                             CGPoint scrollViewContentOffset = recipientAddressScrollView.contentOffset;
                             scrollViewContentOffset.y = 0.0;
                             [recipientAddressScrollView setContentOffset:scrollViewContentOffset animated:YES];
                             
                             [provincePicker removeFromSuperview];
                             [provincePicker release];
                             provincePicker = nil;
                         }];
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
        [datePickerControlView addTarget:self action:@selector(handleDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        if (giftOrder.orderNotifyDate) {
            datePickerControlView.date = giftOrder.orderNotifyDate;
        }
        
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
                             
                             CGRect deliveryDetailScrollViewFrame = recipientAddressScrollView.frame;
                             deliveryDetailScrollViewFrame.size.height = 416.0 - datePickerFrame.size.height;
                             recipientAddressScrollView.frame = deliveryDetailScrollViewFrame;
                             
                         //    datePickerOverLayView.alpha = 0.4;
                         } 
                         completion:^(BOOL finished) {
                             
                             CGPoint scrollViewContentOffset = recipientAddressScrollView.contentOffset;
                             scrollViewContentOffset.y = 215.0;
                             [recipientAddressScrollView setContentOffset:scrollViewContentOffset animated:YES];
                             
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
                             
                             CGRect deliveryDetailScrollViewFrame = recipientAddressScrollView.frame;
                             deliveryDetailScrollViewFrame.size.height = 416.0;
                             recipientAddressScrollView.frame = deliveryDetailScrollViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             
                             CGPoint scrollViewContentOffset = recipientAddressScrollView.contentOffset;
                             scrollViewContentOffset.y = 0.0;
                             [recipientAddressScrollView setContentOffset:scrollViewContentOffset animated:YES];
                             
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



- (void)checkKeyboardVisiblity {
    NSArray* textFields = [[NSArray alloc] initWithObjects:recipientTextField, provinceTextField, streetAddressTextField, postCodeTextField, phoneTextField, nil];
    
    for (UITextField* textField in textFields) {
        if ([textField isFirstResponder]){
            [textField resignFirstResponder];
        }
    }
    
    [textFields release];
}

- (void)checkTextInputVisiblity {
    if ([postCodeTextField isFirstResponder] ||
              [phoneTextField isFirstResponder]) {
        CGPoint scrollViewContentOffset = recipientAddressScrollView.contentOffset;
        scrollViewContentOffset.y = 140.0;
        [recipientAddressScrollView setContentOffset:scrollViewContentOffset animated:YES];
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

- (void)handleTapDeliveryDetailViewGesture:(UITapGestureRecognizer*)sender{
    [self checkKeyboardVisiblity];
    [self hideProvincePickerView];
    [self hideDatePickerView];
}

#pragma mark - Actions
- (void)keyboardWillShow:(NSNotification *)notfication {
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect keyboardBounds;
                         [[notfication.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
                         
                         CGRect scrollViewFrame = recipientAddressScrollView.frame;
                         scrollViewFrame.size.height = 416.0 - keyboardBounds.size.height;
                         recipientAddressScrollView.frame = scrollViewFrame;
                     } 
                     completion:^(BOOL finished) {
                         [self checkTextInputVisiblity];
                     }];
}

- (void)keyboardDidShow:(NSNotification *)notfication {
}

- (void)keyboardWillHide:(NSNotification *)notfication {
    
    [recipientAddressScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect keyboardBounds;
                         [[notfication.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
                         
                         CGRect deliveryDetailScrollViewFrame = recipientAddressScrollView.frame;
                         deliveryDetailScrollViewFrame.size.height = 416.0;
                         recipientAddressScrollView.frame = deliveryDetailScrollViewFrame;
                     } 
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)keyboardDidHide:(NSNotification *)notfication {
}

#pragma mark Picker Date Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == kProvinceComponent) {
        return [self.provinces count];
    }
    return [self.cities count];
}

#pragma mark Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == kProvinceComponent) {
        return [self.provinces objectAtIndex:row];
    }
    return [self.cities objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == kProvinceComponent) {
        NSString *selectedState = [self.provinces objectAtIndex:row];
        NSArray *array = [[provinceCities objectForKey:selectedState] objectForKey:@"cities"];
        self.cities = array;
        [provincePicker selectRow:0 inComponent:kCityComponent animated:YES];
        [provincePicker reloadComponent:kCityComponent];
    } else if (component == kCityComponent) {
        NSInteger provinceRow = [provincePicker selectedRowInComponent:kProvinceComponent];
        NSString *province = [self.provinces objectAtIndex:provinceRow];
        NSArray *cityArray = [[provinceCities objectForKey:province] objectForKey:@"cities"];
        
        if (![cityArray isEqualToArray:self.cities]) {
            self.cities = cityArray;
            [provincePicker selectRow:0 inComponent:kCityComponent animated:YES];
            [provincePicker reloadComponent:kCityComponent];
        }
    }
    
    NSInteger provinceRow = [provincePicker selectedRowInComponent:kProvinceComponent];
    NSInteger cityRow = [provincePicker selectedRowInComponent:kCityComponent];
    
    NSString *province = [self.provinces objectAtIndex:provinceRow];
    NSString *city = [self.cities objectAtIndex:cityRow];
    
    selectedProvince = [province retain];
    selectedCity = [city retain];
    
    provinceTextField.text = [HGUtility displayTextForProvince:province andCity:city];
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == kCityComponent) {
        return 150;
    }
    return 140;
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self hideProvincePickerView];
    [self hideDatePickerView];
    return YES;
}


#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == recipientTextField ||
        touch.view == provinceTextField ||
        touch.view == streetAddressTextField ||
        touch.view == postCodeTextField ||
        touch.view == phoneTextField||
        touch.view == nextStepButton || 
        touch.view == notifyCalendarButton || 
        touch.view == provinceButton) {
        return NO;
    }
    
    return YES; 
}

@end

