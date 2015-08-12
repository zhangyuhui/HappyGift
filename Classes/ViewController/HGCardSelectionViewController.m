//
//  HGCardSelectionViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGCardSelectionViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGGiftCard.h"
#import "HGGiftCardTemplate.h"
#import "HGGiftCardCategory.h"
#import "HGGiftOrder.h"
#import "HGPopoverView.h"
#import "HGProgressView.h"
#import "HGAccountService.h"
#import "HGDeliveryDetailViewController.h"
#import "HGGiftCardService.h"
#import "HGRecipientSelectionViewController.h"
#import "HGCardSelectionTemplateListItemView.h"
#import "HGGiftsSelectionViewGiftsListItemView.h"
#import "HGRecipient.h"
#import "HGTrackingService.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>

#define kCardSelectionViewControllerMarginX 35.0
#define kCardSelectionViewControllerMarginY 12.0
#define kCardSelectionViewControllerSpacing 5.0
#define kCardSelectionViewControllerWidth 240.0
#define kCardSelectionViewControllerHeight 310.0

@interface HGCardSelectionViewController()<UIScrollViewDelegate, HGPopoverViewDelegate, UIGestureRecognizerDelegate>
  
@end

@implementation HGCardSelectionViewController

- (id)initWithGiftOrder:(HGGiftOrder*)theGiftOrder{
    self = [super initWithNibName:@"HGCardSelectionViewController" bundle:nil];
    if (self != nil){
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
    navigationBar.topItem.rightBarButtonItem = nil;
    
    
    CGRect titleViewFrame = CGRectMake(25, 0, 170, 44);
    UIView* titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    
    CGRect navTitleLabelFrame = CGRectMake(0, 0, 170, 40);
	navTitleLabel = [[UILabel alloc] initWithFrame:navTitleLabelFrame];
	navTitleLabel.backgroundColor = [UIColor clearColor];
	navTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate naviagtionTitleFontSize]];
    navTitleLabel.minimumFontSize = 20.0;
    navTitleLabel.adjustsFontSizeToFitWidth = YES;
	navTitleLabel.textAlignment = UITextAlignmentCenter;
	navTitleLabel.textColor = [UIColor whiteColor];
	navTitleLabel.text = @"选择贺卡";
    [titleView addSubview:navTitleLabel];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    titleLabel.textColor = [UIColor darkGrayColor];
    NSArray* titleWords = [HGGiftCardService titleWords];
    titleLabel.text = [titleWords objectAtIndex:0];
    
    [titleButton addTarget:self action:@selector(handleTitleButtonTouchDownAction:) forControlEvents:UIControlEventTouchDown];
    [titleButton addTarget:self action:@selector(handleTitleButtonTouchUpAction:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchUpInside|UIControlEventTouchCancel];
    [titleButton addTarget:self action:@selector(handleTitleButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [enclosureButton addTarget:self action:@selector(handleEnclosureButtonTouchDownAction:) forControlEvents:UIControlEventTouchDown];
    [enclosureButton addTarget:self action:@selector(handleEnclosureButtonTouchUpAction:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel|UIControlEventTouchUpInside];
    [enclosureButton addTarget:self action:@selector(handleEnclosureButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    recipientNameTextField.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    recipientNameTextField.textColor = [UIColor darkGrayColor];
    recipientNameTextField.placeholder = @"接收人";
    
    HGRecipient* recipient = [HGRecipientService sharedService].selectedRecipient;
    if (recipient) {
        recipientNameTextField.text = recipient.recipientDisplayName;
    } else {
        recipientNameTextField.text = @"";
    }
    
    contentTextView.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    contentTextView.textColor = [UIColor darkGrayColor];
    contentTextView.text = @"";
    
    enclosureLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    enclosureLabel.textColor = [UIColor darkGrayColor];
    enclosureLabel.text = @"";
    
    senderTextFiled.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    senderTextFiled.textColor = [UIColor darkGrayColor];
    senderTextFiled.placeholder = @"发送人";
        
    HGAccountService* accountService = [HGAccountService sharedService];
    if (accountService.currentAccount.userName != nil && [accountService.currentAccount.userName isEqualToString:@""] == NO){
        senderTextFiled.text = accountService.currentAccount.userName;
    }
 
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleTapCardDetailViewGesture:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    tapGestureRecognizer.delegate = self;
    [cardDetailView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
    
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;

    giftCardCategories = [HGGiftCardService sharedService].giftCardCategories;
    [giftCardCategories retain];
    
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];

    isFirstAppear = YES;
    CGRect categoriesScrollViewFrame = cardCategoryView.frame;
    categoriesScrollViewFrame.origin.x = 320.0;
    cardCategoryView.frame = categoriesScrollViewFrame;
    
    [self setupCardCategoryViews];
    [self setupCardViews];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    
    [leftBarButtonItem release];
    leftBarButtonItem = nil;
    
    [navTitleLabel removeFromSuperview];
    [navTitleLabel release];
    navTitleLabel = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (isFirstAppear == YES){
        isFirstAppear = NO;
        [self performShowUpViewAnimation:cardCategoryView];
    }
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [giftOrder release];
    if (progressView != nil){
        [progressView release];
    }
    [navTitleLabel release];
    [cardsView release];
    [leftBarButtonItem release];
    [cardsScrollView release];
    [cardsScrollSubViews release];
    [cardDetailView release];
    [giftCardCategories release];
    [titleLabel release];
    [titleIndicatorView release];
    [titleButton release];
    [recipientNameTextField release];
    [recipientUnderlineView release];
    [contentTextView release];
    [contentUnderlineView release];
    [enclosureLabel release];
    [enclosureIndicatorView release];
    [enclosureButton release];
    [senderTextFiled release];
    [senderUnderlineView release];
	[super dealloc];
}

- (void)handleCancelAction:(id)sender{
    if (cardsView.hidden == YES){
        [self checkKeyboardVisiblity];
        cardsView.alpha = 0.0;
        cardsView.hidden = NO;
        
        cardCategoryView.alpha = 0.0;
        cardCategoryView.hidden = NO;
        
        cardsScrollView.userInteractionEnabled = NO;
        cardCategoryView.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.2 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             cardDetailView.alpha = 0.0;
                             cardsView.alpha = 1.0;
                             cardCategoryView.alpha = 1.0;
                         } 
                         completion:^(BOOL finished) {
                             cardDetailView.hidden = YES;
                             HGCardSelectionTemplateListItemView* templateListItemView = (HGCardSelectionTemplateListItemView*)[cardsScrollSubViews objectAtIndex:giftCardIndex];
                             [UIView animateWithDuration:0.3 
                                                   delay:0.0 
                                                 options:UIViewAnimationOptionCurveEaseInOut 
                                              animations:^{
                                                  templateListItemView.transform = CGAffineTransformIdentity;
                                                  CGPoint templateListItemViewCenter = templateListItemView.center;
                                                  templateListItemViewCenter.y = kCardSelectionViewControllerMarginY + kCardSelectionViewControllerHeight/2.0;
                                                  templateListItemView.center = templateListItemViewCenter;
                                              } 
                                              completion:^(BOOL finished) {
                                                  cardsScrollView.userInteractionEnabled = YES;
                                                  cardCategoryView.userInteractionEnabled = YES;
                                                  navTitleLabel.text = @"选择贺卡";
                                                  navigationBar.topItem.rightBarButtonItem = nil;
                                              }];
                             
                         }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleDoneAction:(id)sender{
    [self checkKeyboardVisiblity];
    
    HGAccountService* accountService = [HGAccountService sharedService];
    accountService.currentAccount.userName = senderTextFiled.text;
    [accountService updateAccount:accountService.currentAccount];
    
    if (giftOrder.giftCard == nil){
        HGGiftCard* theGiftCard = [[HGGiftCard alloc] init];
        theGiftCard.identifier = selectedCardTemplate.identifier;
        theGiftCard.cover = selectedCardTemplate.coverImageUrl;
        theGiftCard.title = titleLabel.text;
        theGiftCard.content = contentTextView.text;
        theGiftCard.enclosure = enclosureLabel.text;
        theGiftCard.sender = senderTextFiled.text;
        giftOrder.giftCard = theGiftCard;
        [theGiftCard release];
    }else{
        giftOrder.giftCard.identifier = selectedCardTemplate.identifier;
        giftOrder.giftCard.cover = selectedCardTemplate.coverImageUrl;
        giftOrder.giftCard.title = titleLabel.text;
        giftOrder.giftCard.content = contentTextView.text;
        giftOrder.giftCard.enclosure = enclosureLabel.text;
        giftOrder.giftCard.sender = senderTextFiled.text;
    }
    
    giftOrder.giftRecipient = [[HGRecipientService sharedService] selectedRecipient];
    
    NSString* recipientName = [recipientNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (recipientName && ![@"" isEqualToString:recipientName] && giftOrder.giftRecipient != nil && 
        (giftOrder.giftCard.sender != nil && [giftOrder.giftCard.sender isEqualToString:@""] == NO) && 
        (giftOrder.giftCard.title != nil && [giftOrder.giftCard.title isEqualToString:@""] == NO) && 
        (giftOrder.giftCard.content != nil && [giftOrder.giftCard.content isEqualToString:@""] == NO)){
    
        if (![giftOrder.giftRecipient.recipientDisplayName isEqualToString:recipientName]) {
            giftOrder.giftRecipient.recipientDisplayName = recipientName;
            [[HGRecipientService sharedService] updateRecipient:giftOrder.giftRecipient];
        }
        
        if (giftOrder.giftDelivery == nil){
            HGGiftDelivery* theGiftDelivery = [[HGGiftDelivery alloc] init];
            theGiftDelivery.email = giftOrder.giftRecipient.recipientEmail;
            theGiftDelivery.phone = giftOrder.giftRecipient.recipientPhone;
            if (theGiftDelivery.email != nil && [theGiftDelivery.email isEqualToString:@""] == NO){
                theGiftDelivery.emailNotify = YES;
            }
            if (theGiftDelivery.phone != nil && [theGiftDelivery.phone isEqualToString:@""] == NO){
                theGiftDelivery.phoneNotify = YES;
            }
            giftOrder.giftDelivery = theGiftDelivery;
            [theGiftDelivery release];
        }
        
        [HGTrackingService logEvent:kTrackingEventEnterGiftDelivery withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGCardSelectionViewController", @"from", nil]];
        
        giftOrder.orderNotifyDate = nil;
        HGDeliveryDetailViewController* viewController = [[HGDeliveryDetailViewController alloc] initWithGiftOrder:giftOrder];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
    }else{
        if (giftOrder.giftRecipient == nil || [@"" isEqualToString:recipientName]) {
            [self performBounceViewAnimation:recipientNameTextField];
            [self performBounceViewAnimation:recipientUnderlineView];
        }else if ((giftOrder.giftCard.sender == nil || [giftOrder.giftCard.sender isEqualToString:@""] == YES)){
            [self performBounceViewAnimation:senderTextFiled];
            [self performBounceViewAnimation:senderUnderlineView];
        }else if ((giftOrder.giftCard.content == nil || [giftOrder.giftCard.content isEqualToString:@""] == YES)){
            [self performBounceViewAnimation:contentTextView];
            [self performBounceViewAnimation:contentUnderlineView];
        }
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:@"请将卡片信息填写完整"];
    }
}

- (void)setupCardCategoryViews {
    categoryIndex = 0;
    
    CGFloat viewX = 5.0;
    CGFloat viewY = 0;
    CGFloat viewWidth = 65.0;
    CGFloat viewHeight = 65.0;
    
    int theCategoryIndex = 0;
    for (HGGiftCardCategory* theGiftCardCategory in giftCardCategories) {
         UIButton* categoryListItemButton = [[UIButton alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, viewHeight)];
        
        if (theCategoryIndex == categoryIndex) {
            currentSelectedCategoryView = categoryListItemButton;
            currentSelectedCategoryView.selected = YES;
        }
        
        [categoryListItemButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [categoryListItemButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [categoryListItemButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        
        categoryListItemButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeTiny]];
        categoryListItemButton.titleLabel.textAlignment = UITextAlignmentCenter;
        
        [categoryListItemButton addTarget:self action:@selector(handleSingleTapCategoryView:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage* backgroundImage = [[UIImage imageNamed:@"gift_card_category_background"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
        [categoryListItemButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        categoryListItemButton.tag = theCategoryIndex++;
        
        [categoryListItemButton setTitle:theGiftCardCategory.name forState:UIControlStateNormal];
        
        UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"card_selection_category_%@", theGiftCardCategory.identifier]];
        if (!image) {
            image = [UIImage imageNamed:[NSString stringWithFormat:@"card_selection_category_3"]];
        }
        UIImage* imageSelected = [UIImage imageNamed:[NSString stringWithFormat:@"card_selection_category_selected_%@", theGiftCardCategory.identifier]];
        if (!imageSelected) {
            imageSelected = [UIImage imageNamed:[NSString stringWithFormat:@"card_selection_category_selected_3"]];
        }
        
        [categoryListItemButton setImage:image forState:UIControlStateNormal];
        [categoryListItemButton setImage:imageSelected forState:UIControlStateSelected];
        [cardCategoryView addSubview:categoryListItemButton];
        
        [categoryListItemButton setImageEdgeInsets:UIEdgeInsetsMake(-5.0, 0.0, 0.0, 0.0)];
        [categoryListItemButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -image.size.width + 2.0, -image.size.height*0.65, 0.0)];
        
        viewX += categoryListItemButton.frame.size.width;
        [categoryListItemButton release];
        
        if (theGiftCardCategory == [giftCardCategories lastObject]){
            viewX += 5.0;
        }
    }
    
    CGSize contentSize = cardCategoryView.contentSize;
    if (viewX <= cardCategoryView.frame.size.width) {
        viewX = cardCategoryView.frame.size.width + 1.0;
    }
    contentSize.height = cardCategoryView.frame.size.height;
    contentSize.width = viewX;
    cardCategoryView.contentSize = contentSize;
}


- (void)setupCardViews{
    if (cardsScrollSubViews == nil){
        cardsScrollSubViews = [[NSMutableArray alloc] init];
    }else{
        for (UIView* subView in cardsScrollSubViews){
            [subView removeFromSuperview];
        }
        [cardsScrollSubViews removeAllObjects];
    }
    
    CGFloat viewX = kCardSelectionViewControllerMarginX + kCardSelectionViewControllerSpacing;
    CGFloat viewY = kCardSelectionViewControllerMarginY;
    CGFloat viewWidth = kCardSelectionViewControllerWidth;
    CGFloat viewHeight = kCardSelectionViewControllerHeight;
    
    HGGiftCardCategory* category = [giftCardCategories objectAtIndex:categoryIndex];
    NSArray* giftCardTemplates = category.cardTemplates;
    
    int theGiftCardIndex = 0;
    for (HGGiftCardTemplate* theGiftCardTemplate in giftCardTemplates){
        HGCardSelectionTemplateListItemView* templateListItemView = [HGCardSelectionTemplateListItemView cardSelectionTemplateListItemView];
        CGRect templateListItemViewFrame = templateListItemView.frame;
        templateListItemViewFrame.origin.x = viewX;
        templateListItemViewFrame.origin.y = viewY;
        templateListItemViewFrame.size.width = viewWidth;
        templateListItemViewFrame.size.height = viewHeight;
        templateListItemView.frame = templateListItemViewFrame;
        
        templateListItemView.tag = theGiftCardIndex++;
        templateListItemView.userInteractionEnabled = YES;
        
        templateListItemView.giftCardTemplate = theGiftCardTemplate;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTapCardView:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        [templateListItemView addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        
        [cardsScrollView addSubview:templateListItemView];
        [cardsScrollSubViews addObject:templateListItemView];
        
        viewX += viewWidth + kCardSelectionViewControllerSpacing;
        
        if (theGiftCardTemplate == [giftCardTemplates lastObject]){
            viewX += kCardSelectionViewControllerMarginX;
        }
    }
    
    CGSize contentSize = cardsScrollView.contentSize;
    if (viewX <= cardsScrollView.frame.size.width){
        viewX = cardsScrollView.frame.size.width + 1.0;
    }
    contentSize.width = viewX;
    cardsScrollView.contentSize = contentSize;
    
    dargOffsetPageNumber = [giftCardTemplates count];
    dragOffsetX = cardsScrollView.contentOffset.x;
    dargOffsetPage = floor((dragOffsetX - (kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing) / 2) / (kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing)) + 1;
    [self checkCardCoverImageRequest];
}

- (void) checkCardCoverImageRequest {
    //check order: 0, -1, 1
    for (int delta = 0; delta != 2; ) {
        int pageIndex = dargOffsetPage + delta;
        if (0 <= pageIndex && pageIndex < [cardsScrollSubViews count]) {
            HGCardSelectionTemplateListItemView* templateListItemView = (HGCardSelectionTemplateListItemView*)[cardsScrollSubViews objectAtIndex:pageIndex];
            if (!templateListItemView.isCoverImageRequestStarted) {
                [templateListItemView requestCoverImage];
            }
        }
        if (delta == 0) {
            delta = -1;
        } else if (delta == -1) {
            delta = 1;
        } else {
            delta = 2;
        }
    }
}

- (void)handleTitleButtonClickAction:(id)sender{
    [self checkKeyboardVisiblity];
    
    popoverView = [HGPopoverView popoverView];
    popoverView.delegate = self;
    popoverView.budyLabel = titleLabel;
    popoverView.items = [HGGiftCardService titleWords];
    [popoverView performShow:self.view atPoint:CGPointMake(titleLabel.frame.origin.x - 9.0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 5.0)];
}

- (void)handleTitleButtonTouchDownAction:(id)sender{
    titleLabel.highlighted = YES;
    titleIndicatorView.highlighted = YES;
}

- (void)handleTitleButtonTouchUpAction:(id)sender{
    titleLabel.highlighted = NO;
    titleIndicatorView.highlighted = NO;
}

- (void)handleEnclosureButtonClickAction:(id)sender{
    [self checkKeyboardVisiblity];
    
    popoverView = [HGPopoverView popoverView];
    popoverView.delegate = self;
    popoverView.budyLabel = enclosureLabel;
    popoverView.items = [HGGiftCardService enclosureWords];
    [popoverView performShow:self.view atPoint:CGPointMake(enclosureLabel.frame.origin.x - 9.0, enclosureLabel.frame.origin.y - 120.0 - 5.0)];
}

- (void)handleEnclosureButtonTouchDownAction:(id)sender{
    enclosureLabel.highlighted = YES;
    enclosureIndicatorView.highlighted = YES;
}

- (void)handleEnclosureButtonTouchUpAction:(id)sender{
    enclosureLabel.highlighted = NO;
    enclosureIndicatorView.highlighted = NO;
}

- (void)checkKeyboardVisiblity{
    if ([contentTextView isFirstResponder]){
        [contentTextView resignFirstResponder];
    }
    if ([senderTextFiled isFirstResponder]){
        [senderTextFiled resignFirstResponder];
    }
    if ([recipientNameTextField isFirstResponder]) {
        [recipientNameTextField resignFirstResponder];
    }
}

- (void)checkTextInputVisiblity{
    if ([contentTextView isFirstResponder]){
        
    }else if ([senderTextFiled isFirstResponder]){
        CGPoint scrollViewContentOffset = cardDetailView.contentOffset;
        CGSize scrollViewContentSize = cardDetailView.contentSize;
        scrollViewContentOffset.y = scrollViewContentSize.height - cardDetailView.frame.size.height;
        [cardDetailView setContentOffset:scrollViewContentOffset animated:YES];
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

- (void)performShowUpViewAnimation:(UIView*)showUpView{
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         CGRect showUpViewFrame = showUpView.frame;
                         showUpViewFrame.origin.x = -50.0;
                         showUpView.frame = showUpViewFrame;
                     } 
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 
                                               delay:0.0 
                                             options:UIViewAnimationOptionCurveEaseInOut 
                                          animations:^{
                                              CGRect showUpViewFrame = showUpView.frame;
                                              showUpViewFrame.origin.x = 30.0;
                                              showUpView.frame = showUpViewFrame;
                                          } 
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.2 
                                                                    delay:0.0 
                                                                  options:UIViewAnimationOptionCurveEaseInOut 
                                                               animations:^{
                                                                   CGRect showUpViewFrame = showUpView.frame;
                                                                   showUpViewFrame.origin.x = 0.0;
                                                                   showUpView.frame = showUpViewFrame;
                                                               } 
                                                               completion:^(BOOL finished) {
                                                                   
                                                               }];
                                          }];
                     }];
}

#pragma mark - UITapGestureRecognizer
- (void)handleSingleTapCardView:(UITapGestureRecognizer *)sender{
    HGGiftCardCategory* category = [giftCardCategories objectAtIndex:categoryIndex];
    NSArray* giftCardTemplates = category.cardTemplates;
    
    cardsScrollView.userInteractionEnabled = NO;
    HGCardSelectionTemplateListItemView* templateListItemView = (HGCardSelectionTemplateListItemView*)sender.view;
    giftCardIndex = templateListItemView.tag;
    selectedCardTemplate = [giftCardTemplates objectAtIndex:giftCardIndex];
    [cardsScrollView bringSubviewToFront:templateListItemView];
    
    [HGTrackingService logEvent:kTrackingEventSelectGiftCardTemplate withParameters:[NSDictionary dictionaryWithObjectsAndKeys:selectedCardTemplate.identifier, @"template", nil]];
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         CGFloat scaleWidth = self.view.frame.size.width/(templateListItemView.frame.size.width - 10.0);
                         CGFloat scaleHeight = (self.view.frame.size.height- 44.0)/(templateListItemView.frame.size.height - 10.0);
                         CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleWidth, scaleHeight);
                         templateListItemView.transform = transform;
                         CGPoint templateListItemViewCenter = templateListItemView.center;
                         templateListItemViewCenter.y = (self.view.frame.size.height - 44.0)/2.0 - 10.0;
                         templateListItemView.center = templateListItemViewCenter;
                         
                         cardCategoryView.alpha = 0.0;
                     } 
                     completion:^(BOOL finished) {
                         navTitleLabel.text = @"填写贺卡";
                         
                         cardCategoryView.hidden = YES;
                         cardCategoryView.userInteractionEnabled = YES;
                         
                         CGSize contentSize = cardDetailView.contentSize;
                         contentSize.height = cardDetailView.frame.size.height + 1.0;
                         cardDetailView.contentSize = contentSize;
                         
                         titleLabel.text = @"嗨！";
                         contentTextView.text = selectedCardTemplate.defaultContent;
                         enclosureLabel.text = @"来自";
                         
                         if (giftOrder.giftCard != nil){
                             recipientNameTextField.text = giftOrder.giftRecipient.recipientDisplayName;
                             senderTextFiled.text = giftOrder.giftCard.sender;
                         }
                         cardDetailView.alpha = 0.0;
                         cardDetailView.hidden = NO;
                         [UIView animateWithDuration:0.6 
                                               delay:0.0 
                                             options:UIViewAnimationOptionCurveEaseInOut 
                                          animations:^{
                                              cardsView.alpha = 0.0;
                                              
                                              cardDetailView.alpha = 1.0;
                                          } 
                                          completion:^(BOOL finished) {
                                              cardsView.hidden = YES;
                                              cardsScrollView.userInteractionEnabled = YES;
                                              navigationBar.topItem.rightBarButtonItem = rightBarButtonItem;
                                              
                                          }];
                         
                     }];   
}

- (void)handleSingleTapCategoryView:(id)sender {
    currentSelectedCategoryView.selected = NO;
    
    UIButton* categoryListItemView = (UIButton*)sender;
    categoryListItemView.selected = YES;
    currentSelectedCategoryView = categoryListItemView;
    
    categoryIndex = categoryListItemView.tag;
    
    [HGTrackingService logEvent:kTrackingEventSelectGiftCardCategory withParameters:[NSDictionary dictionaryWithObjectsAndKeys:categoryListItemView.titleLabel.text, @"category", nil]];
    
    [UIView animateWithDuration:0.5 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cardsView.alpha = 0.1;
                     } 
                     completion:^(BOOL finished) {
                         [self setupCardViews];
                         [UIView animateWithDuration:0.5 
                                               delay:0.0 
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              cardsView.alpha = 1.0;
                                          } 
                                          completion:^(BOOL finished) {
                                              
                                          }];
                     }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([scrollView isEqual:cardsScrollView]) { 
        dragOffsetX = scrollView.contentOffset.x;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([scrollView isEqual:cardsScrollView] && decelerate == NO) {
        CGFloat theDragOffsetX = scrollView.contentOffset.x;
        int theCurrentPage = floor((theDragOffsetX - (kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing) / 2) / (kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing) ) + 1;
        
        if (theCurrentPage < dargOffsetPage){
            if ((theCurrentPage*(kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing) - theDragOffsetX) < ((theCurrentPage + 1)*(kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing) - theDragOffsetX)){
                if (theDragOffsetX != theCurrentPage*(kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing)){
                    CGPoint contentOffsetX = scrollView.contentOffset;
                    contentOffsetX.x = theCurrentPage*(kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing);
                    [scrollView setContentOffset:contentOffsetX animated:YES];
                }
            }else{
                if (theDragOffsetX != (theCurrentPage + 1)*(kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing)){
                    CGPoint contentOffsetX = scrollView.contentOffset;
                    contentOffsetX.x = (theCurrentPage + 1)*(kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing);
                    [scrollView setContentOffset:contentOffsetX animated:YES];
                }
            }
        }else{
            if (theDragOffsetX != [cardsScrollSubViews count]*(kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing)){
                CGPoint contentOffsetX = scrollView.contentOffset;
                contentOffsetX.x = [cardsScrollSubViews count]*(kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing);
                [scrollView setContentOffset:contentOffsetX animated:YES];
            }
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:cardsScrollView]) {
        if (dragOffsetXChange > 0){
            if ((dargOffsetPageNumber - dargOffsetPage) >= 2){
                CGPoint contentOffset = scrollView.contentOffset;
                [scrollView setContentOffset:contentOffset animated:NO];
                CGPoint contentOffsetX = scrollView.contentOffset;
                contentOffsetX.x = (dargOffsetPage + 1)*(kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing);
                [scrollView setContentOffset:contentOffsetX animated:YES];
            }
        }else{
            if (dargOffsetPage >= 1){
                CGPoint contentOffset = scrollView.contentOffset;
                [scrollView setContentOffset:contentOffset animated:NO];
                CGPoint contentOffsetX = scrollView.contentOffset;
                contentOffsetX.x = (dargOffsetPage - 1)*(kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing);
                [scrollView setContentOffset:contentOffsetX animated:YES];
            }
        }
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isEqual:cardsScrollView]) {
        CGFloat lastDragOffset = dragOffsetX;
        dragOffsetX = scrollView.contentOffset.x;
        dragOffsetXChange = (dragOffsetX - lastDragOffset);
        dargOffsetPage = floor((dragOffsetX - (kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing) / 2) / (kCardSelectionViewControllerWidth + kCardSelectionViewControllerSpacing)) + 1;
        
        [self checkCardCoverImageRequest];
    }
}

#pragma mark Gesture
- (void)handleTapCardDetailViewGesture:(UITapGestureRecognizer*)sender{
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
                         
                         CGRect cardDetailViewFrame = cardDetailView.frame;
                         cardDetailViewFrame.size.height = 416.0 - keyboardBounds.size.height;
                         cardDetailView.frame = cardDetailViewFrame;
                     } 
                     completion:^(BOOL finished) {
                         [self checkTextInputVisiblity];
                     }];
}

- (void)keyboardDidShow:(NSNotification *)notfication {
}

- (void)keyboardWillHide:(NSNotification *)notfication {
    
    [cardDetailView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect keyboardBounds;
                         [[notfication.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
                         
                         CGRect cardDetailViewFrame = cardDetailView.frame;
                         cardDetailViewFrame.size.height = 416.0;
                         cardDetailView.frame = cardDetailViewFrame;
                     } 
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)keyboardDidHide:(NSNotification *)notfication {
}

#pragma mark HGPopoverViewDelegate
- (void)popoverView:(HGPopoverView *)thePopoverView didSelectItem:(NSString*)text{
    UILabel* theBudyLabel = popoverView.budyLabel;
    theBudyLabel.text = text;
    [popoverView performHide];
}

- (void)popoverView:(HGPopoverView *)thePopoverView didRejectItem:(NSInteger)index{    
    [popoverView performHide];
    popoverView = nil;
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == titleButton ||
        touch.view == enclosureButton) {
        return NO;
    }
    return YES; 
}
@end

