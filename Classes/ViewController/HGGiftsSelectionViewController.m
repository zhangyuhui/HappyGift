//
//  HGGiftsSelectionViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGGiftsSelectionViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGGift.h"
#import "HGGiftSet.h"
#import "HGGiftCategoryService.h"
#import "HGOccasionGiftCollection.h"
#import "HGProgressView.h"
#import "HGFeaturedGiftCollection.h"
#import "HGGiftCollectionService.h"
#import "HGRecipientSelectionViewController.h"
#import "HGGiftsSelectionViewGiftsListCellView.h"
#import "HGGiftDetailViewController.h"
#import "HGGiftSetDetailViewController.h"
#import "HGGiftCategory.h"
#import "HGImageService.h"
#import "HGGiftCategoryService.h"
#import "HGOccasionCategory.h"
#import "HGTrackingService.h"
#import "HGGiftAssistantService.h"
#import "HGRecipientService.h"
#import "HGGiftsSelectionViewAssistantQuestionView.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGRangeSliderControl.h"
#import "HGConstants.h"
#import "HGDefines.h"
#import "HGGiftSetsService.h"

@interface HGGiftsSelectionViewController()<UIScrollViewDelegate, HGRecipientSelectionViewControllerDelegate, HGRangeSliderControlDelegate, HGGiftAssistantServiceDelegate, HGGiftsSelectionViewAssistantQuestionViewDelegate, UIGestureRecognizerDelegate>
  
@end

@implementation HGGiftsSelectionViewController

- (id)initWithGiftSets:(NSDictionary*)theGiftSets occasionGiftCollection:(HGOccasionGiftCollection*)theOccasionGiftCollection{
    self = [super initWithNibName:@"HGGiftsSelectionViewController" bundle:nil];
    if (self){
        NSMutableDictionary* theGiftSetsWithOccassion = [[NSMutableDictionary alloc] initWithDictionary:theGiftSets];
        [theGiftSetsWithOccassion setObject:theOccasionGiftCollection.giftSets forKey:theOccasionGiftCollection.occasion.occasionCategory.name];
        giftSets = [theGiftSetsWithOccassion retain];
        [theGiftSetsWithOccassion release];
        
        occasionGiftCollection = [theOccasionGiftCollection retain];
        currentGiftCategory = [theOccasionGiftCollection.occasion.occasionCategory.name retain];
    }
    return self;
}

- (id)initWithGiftSets:(NSDictionary*)theGiftSets currentGiftCategory:(NSString*)theCurrentGiftCategory{
    self = [super initWithNibName:@"HGGiftsSelectionViewController" bundle:nil];
    if (self){
        giftSets = [theGiftSets retain];
        if (theCurrentGiftCategory == nil || [theCurrentGiftCategory isEqualToString:@""] == YES){
            HGGiftCategory* firstGiftCategory = [[HGGiftCategoryService sharedService].giftCategories objectAtIndex:0];
            currentGiftCategory = [[NSString alloc] initWithString:firstGiftCategory.identifier];
        }else{
            currentGiftCategory = [theCurrentGiftCategory retain];
        }
    }
    return self;    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleBackAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    navigationBar.topItem.rightBarButtonItem = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* giftSelectionTutorialShown = [defaults stringForKey:kHGPreferenceKeyGiftSelectionTutorialShown];

    if (giftSelectionTutorialShown == nil) {
        CGRect frame = CGRectMake(0, 0, 320, 460);
        tutorialView = [[UIImageView alloc] initWithFrame:frame];
        UIImage* tutorialImage = [UIImage imageNamed:@"gift_selection_tutorial"];
        tutorialView.image = tutorialImage;
        [tutorialView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleTutorialViewTap:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        tapGestureRecognizer.delegate = self;
        [tutorialView addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        
        [self.view addSubview:tutorialView];
        
        [defaults setObject:@"1" forKey:kHGPreferenceKeyGiftSelectionTutorialShown];
        [defaults synchronize];
    }
    
    [recipientButton addTarget:self action:@selector(handleRecipientButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [categoryButton setTitleColor:UIColorFromRGB(0x484744) forState:UIControlStateNormal];
    [categoryButton setTitleColor:UIColorFromRGB(0xd53d3b) forState:UIControlStateSelected];
    [categoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    categoryButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    categoryButton.titleLabel.minimumFontSize = 12.0;
    categoryButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [categoryButton addTarget:self action:@selector(handleFeatureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [priceButton setTitleColor:UIColorFromRGB(0x484744) forState:UIControlStateNormal];
    [priceButton setTitleColor:UIColorFromRGB(0xd53d3b) forState:UIControlStateSelected];
    [priceButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    priceButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    priceButton.titleLabel.minimumFontSize = [HappyGiftAppDelegate fontSizeNormal];
    priceButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [priceButton setTitleEdgeInsets:UIEdgeInsetsMake(3.0, 0.0, 0.0, 0.0)];//The postion of the text for this font dose not show well postion
    [priceButton addTarget:self action:@selector(handlePriceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [assistantButton setTitleColor:UIColorFromRGB(0x484744) forState:UIControlStateNormal];
    [assistantButton setTitleColor:UIColorFromRGB(0xd53d3b) forState:UIControlStateSelected];
    [assistantButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    assistantButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    [assistantButton addTarget:self action:@selector(handleAssistantButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    emptyView.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    
    recipientLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    recipientLabel.textColor = [UIColor whiteColor];
    recipientLabel.backgroundColor = [UIColor clearColor];
    recipientLabel.textAlignment = UITextAlignmentLeft;
    
    [[HGRecipientService sharedService] updateRecipientLabel:recipientLabel];
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    assistantView.hidden = YES;
    
    assistantQuestionView = [[HGGiftsSelectionViewAssistantQuestionView giftsSelectionViewAssistantQuestionView] retain];
    assistantQuestionView.delegate = self;
    [assistantView addSubview:assistantQuestionView];
    
    UISwipeGestureRecognizer *topSwipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftGesture:)]; 
    [topSwipeLeftGesture setDirection:(UISwipeGestureRecognizerDirectionLeft)]; 
    [assistantQuestionView addGestureRecognizer:topSwipeLeftGesture]; 
    [topSwipeLeftGesture release]; 
    
    UISwipeGestureRecognizer *topSwipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGesture:)]; 
    [topSwipeRightGesture setDirection:(UISwipeGestureRecognizerDirectionRight)]; 
    [assistantQuestionView addGestureRecognizer:topSwipeRightGesture]; 
    [topSwipeRightGesture release];
    
    [assistantLeftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [assistantLeftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [assistantLeftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    assistantLeftButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    [assistantLeftButton addTarget:self action:@selector(handleAssistantLeftButtonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [assistantLeftButton setTitle:@"上一个" forState:UIControlStateNormal];
    [assistantView bringSubviewToFront:assistantLeftButton];
    
    [assistantRightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [assistantRightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [assistantRightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    assistantRightButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    [assistantRightButton addTarget:self action:@selector(handleAssistantRightButtonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [assistantRightButton setTitle:@"下一个" forState:UIControlStateNormal];
    [assistantView bringSubviewToFront:assistantRightButton];
    
    assistantLeftButton.hidden = YES;
    assistantRightButton.hidden = YES;
    
    assistantNumberView.layer.cornerRadius = 5.0;
    [assistantView bringSubviewToFront:assistantNumberView];
    
    HGRangeSliderControl *priceSlider=  [[HGRangeSliderControl alloc] initWithFrame:priceView.bounds];
    priceSlider.delegate = self;
    priceSlider.minValue = 0;
    priceSlider.selectedMinValue = 0;
    priceSlider.maxValue = 500;
    priceSlider.selectedMaxValue = 500;
    priceSlider.minRange = 0;
    
    minPriceValue = priceSlider.selectedMinValue;
    maxPriceValue = priceSlider.selectedMaxValue;
    if ([priceSlider isUnlimited] == YES) {
        maxPriceValue = CGFLOAT_MAX;
    }
    
    [priceView addSubview:priceSlider];
    [priceSlider release];
    
    if (minPriceValue <= 0.005){
        if (maxPriceValue == CGFLOAT_MAX){
            [priceButton setTitle:[NSString stringWithFormat:@"免费-¥500+"] forState:UIControlStateNormal];
        }else{
            [priceButton setTitle:[NSString stringWithFormat:@"免费-¥%d", (int)maxPriceValue] forState:UIControlStateNormal];
        }
    }else{
        if (maxPriceValue == CGFLOAT_MAX){
            [priceButton setTitle:[NSString stringWithFormat:@"¥%d-¥500+", (int)minPriceValue] forState:UIControlStateNormal];
        }else{
            [priceButton setTitle:[NSString stringWithFormat:@"¥%d-¥%d", (int)minPriceValue, (int)maxPriceValue] forState:UIControlStateNormal];
        }
    }
    
    isFirstAppear = YES;
    CGRect categoriesScrollViewFrame = categoriesScrollView.frame;
    categoriesScrollViewFrame.origin.x = 320.0;
    categoriesScrollView.frame = categoriesScrollViewFrame;
    
    [self setupCategoryView];

    if (giftSets != nil && [giftSets count] > 0){
        [self updateGiftSetsDisplay];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGiftSetsUpdatedForEmptyGiftSets:) name:kHGNotificationGiftSetsUpdated object:nil];
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    
    [leftBarButtonItem release];
    leftBarButtonItem = nil;
    
    if (assistantNumberViewTimer != nil){
        [assistantNumberViewTimer invalidate];
        assistantNumberViewTimer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationGiftSetsUpdated object:nil]; 
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (isFirstAppear == YES){
        isFirstAppear = NO;
        categoryButton.selected = YES;
        [self showFeatureView];
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
    [giftSetsTableView release];
    [currentGiftSets release];
    [progressView release];
    [leftBarButtonItem release];
    [occasionGiftCollection release];
    [recipientButton release];
    [categoryButton release];
    [priceButton release];
    [assistantButton release];
    [recipientLabel release];
    [categoriesView release];
    [buttonsView release];
    [priceView release];
    [categoriesScrollView release];
    [giftSets release];
    [currentGiftCategory release];
    [assistantView release];
    [assistantQuestionView release];
    [assistantLeftButton release];
    [assistantRightButton release];
    [assistantNumberView release];
    [assistantNumberLabel release];
    if (assistantNumberViewTimer != nil){
        [assistantNumberViewTimer invalidate];
        assistantNumberViewTimer = nil;
    }
    [giftAssistantQuestions release];
    [assistantOverlayView release];
    [giftAssistantGiftSets release];
    [giftCategoroSubViews release];
    
    if (tutorialView) {
        [tutorialView removeFromSuperview];
        [tutorialView release];
        tutorialView = nil;
    }
    
    HGGiftAssistantService* giftAssistantService = [HGGiftAssistantService sharedService];
    if (giftAssistantService.delegate == self) {
        giftAssistantService.delegate = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationGiftSetsUpdated object:nil]; 
    
	[super dealloc];
}

- (void)handleTutorialViewTap:(id)sender {
    if (tutorialView) {
        [tutorialView removeFromSuperview];
        [tutorialView release];
        tutorialView = nil;
    }
}

- (void)handleBackAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleRecipientButtonAction:(id)sender{
    [HGTrackingService logEvent:kTrackingEventEnterRecipientSelection withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGiftsSelectionViewController", @"from", nil]];
    
    HGRecipientSelectionViewController* viewController = [[HGRecipientSelectionViewController alloc] initWithNibName:@"HGRecipientSelectionViewController" bundle:nil];
    viewController.delegate = self;
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)handleFeatureButtonAction:(id)sender{
    if (categoryButton.selected == NO){
        if (assistantButton.selected == YES){
            categoryButton.selected = YES;
            assistantButton.selected = NO;
            [self hideAssistantView];
        }else{
            categoryButton.selected = YES;
            priceButton.selected = NO;
            assistantButton.selected = NO;
            [self showFeatureView];
        }
    }else{
        categoryButton.selected = NO;
        [self hideFeatureView];
    }
}

- (void)handlePriceButtonAction:(id)sender{
    if (priceButton.selected == NO){
        if (assistantButton.selected == YES){
            priceButton.selected = YES;
            assistantButton.selected = NO;
            [self hideAssistantView];
        }else{
            priceButton.selected = YES;
            categoryButton.selected = NO;
            assistantButton.selected = NO;
            [self showPriceView];
        }
    }else{
        priceButton.selected = NO;
        [self hidePriceView];
    }
}

- (void)handleAssistantButtonAction:(id)sender{
    if (assistantButton.selected == NO){
        assistantOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0, 416)];
        assistantOverlayView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:assistantOverlayView];
        recipientButton.userInteractionEnabled = NO;
        
        [progressView startAnimation];
        HGGiftAssistantService* giftAssistantService = [HGGiftAssistantService sharedService];
        giftAssistantService.delegate = self;
        
        HGRecipientService* recipientService = [HGRecipientService sharedService];
        [giftAssistantService requestGiftAssistantQuestions:recipientService.selectedRecipient];
    }else{
        assistantButton.selected = NO;
        [self hideAssistantView];
    }
}

- (void)showFeatureView{
    if (categoriesView.hidden == YES){
        categoriesView.hidden = NO;
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             CGRect featureViewFrame = categoriesView.frame;
                             featureViewFrame.origin.y = buttonsView.frame.origin.y + buttonsView.frame.size.height;
                             categoriesView.frame = featureViewFrame;
                             
                             CGRect priceViewFrame = priceView.frame;
                             priceViewFrame.origin.y = buttonsView.frame.origin.y;
                             priceView.frame = priceViewFrame;
                             
                             CGRect contentViewFrame = giftSetsTableView.frame;
                             contentViewFrame.origin.y = buttonsView.frame.origin.y + buttonsView.frame.size.height + featureViewFrame.size.height;
                             contentViewFrame.size.height = self.view.frame.size.height - contentViewFrame.origin.y;
                             giftSetsTableView.frame = contentViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             priceView.hidden = YES;
                             if (categoriesScrollView.frame.origin.x != 0.0){
                                 [self performShowUpViewAnimation:categoriesScrollView];
                             }
                         }];
    }
}

- (void)hideFeatureView{
    if (categoriesView.hidden == NO && categoriesView.frame.origin.y == buttonsView.frame.origin.y + buttonsView.frame.size.height){
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             CGRect featureViewFrame = categoriesView.frame;
                             featureViewFrame.origin.y = buttonsView.frame.origin.y;
                             categoriesView.frame = featureViewFrame;
                             
                             CGRect contentViewFrame = giftSetsTableView.frame;
                             contentViewFrame.origin.y = buttonsView.frame.origin.y + buttonsView.frame.size.height;
                             contentViewFrame.size.height = self.view.frame.size.height - contentViewFrame.origin.y;
                             giftSetsTableView.frame = contentViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             categoriesView.hidden = YES;
                         }];
    }    
}

- (void)showPriceView{
    if (priceView.hidden == YES){
        priceView.hidden = NO;
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             CGRect priceViewFrame = priceView.frame;
                             priceViewFrame.origin.y = buttonsView.frame.origin.y + buttonsView.frame.size.height;
                             priceView.frame = priceViewFrame;
                             
                             CGRect featureViewFrame = categoriesView.frame;
                             featureViewFrame.origin.y = buttonsView.frame.origin.y;
                             categoriesView.frame = featureViewFrame;
                             
                             CGRect contentViewFrame = giftSetsTableView.frame;
                             contentViewFrame.origin.y = buttonsView.frame.origin.y + buttonsView.frame.size.height + priceViewFrame.size.height;
                             contentViewFrame.size.height = self.view.frame.size.height - contentViewFrame.origin.y;
                             giftSetsTableView.frame = contentViewFrame;
                             
                         } 
                         completion:^(BOOL finished) {
                             categoriesView.hidden = YES;
                         }];
    }
}

- (void)hidePriceView{
    if (priceView.hidden == NO && priceView.frame.origin.y == buttonsView.frame.origin.y + buttonsView.frame.size.height){
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             CGRect priceViewFrame = priceView.frame;
                             priceViewFrame.origin.y = buttonsView.frame.origin.y;
                             priceView.frame = priceViewFrame;
                             
                             CGRect contentViewFrame = giftSetsTableView.frame;
                             contentViewFrame.origin.y = buttonsView.frame.origin.y + buttonsView.frame.size.height;
                             contentViewFrame.size.height = self.view.frame.size.height - contentViewFrame.origin.y;
                             giftSetsTableView.frame = contentViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             priceView.hidden = YES;
                         }];
    }    
}


- (void)showAssistantView{
    if (assistantView.hidden == YES){
        CGRect assistantViewFrame = assistantView.frame;
        assistantViewFrame.origin.y = 460.0;
        assistantView.frame = assistantViewFrame;
        assistantView.hidden = NO;
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             CGRect giftSetsScrollViewFrame = giftSetsTableView.frame;
                             giftSetsScrollViewFrame.origin.y = 460.0;
                             giftSetsTableView.frame = giftSetsScrollViewFrame;
                             
                             CGRect priceViewFrame = priceView.frame;
                             priceViewFrame.origin.y = buttonsView.frame.origin.y;
                             priceView.frame = priceViewFrame;
                             
                             CGRect featureViewFrame = categoriesView.frame;
                             featureViewFrame.origin.y = buttonsView.frame.origin.y;
                             categoriesView.frame = featureViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             giftSetsTableView.hidden = YES;
                             priceView.hidden = YES;
                             categoriesView.hidden = YES;
                             [UIView animateWithDuration:0.3 
                                                   delay:0.0 
                                                 options:UIViewAnimationOptionCurveEaseInOut 
                                              animations:^{
                                                  CGRect assistantViewFrame = assistantView.frame;
                                                  assistantViewFrame.origin.y = buttonsView.frame.origin.y + buttonsView.frame.size.height;
                                                  assistantView.frame = assistantViewFrame;
                                              } 
                                              completion:^(BOOL finished) {
                                                  [self showAssistantNumberView];
                                                  
                                                  HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
                                                  [appDelegate sendNotification:[NSString stringWithFormat:@"请回答关于TA的几个问题，我们将会根据您的答案来推荐礼物。"]];
                                              }];
                         }];
    }
}

- (void)hideAssistantView{
    if (assistantView.hidden == NO && assistantView.frame.origin.y == buttonsView.frame.origin.y + buttonsView.frame.size.height){
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             CGRect assistantViewFrame = assistantView.frame;
                             assistantViewFrame.origin.y = 460.0;
                             assistantView.frame = assistantViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             assistantView.hidden = YES;
                             CGRect giftSetsScrollViewFrame = giftSetsTableView.frame;
                             giftSetsScrollViewFrame.origin.y = 460.0;
                             giftSetsTableView.frame = giftSetsScrollViewFrame;
                             giftSetsTableView.hidden = NO;
                             if (categoryButton.selected == YES){
                                 categoriesView.hidden = NO;
                             }else if (priceButton.selected == YES){
                                 priceView.hidden = NO;
                             }
                             [UIView animateWithDuration:0.3 
                                                   delay:0.0 
                                                 options:UIViewAnimationOptionCurveEaseInOut 
                                              animations:^{
                                                  if (categoryButton.selected == YES){
                                                      CGRect categoriesViewFrame = categoriesView.frame;
                                                      categoriesViewFrame.origin.y = buttonsView.frame.origin.y + buttonsView.frame.size.height;
                                                      categoriesView.frame = categoriesViewFrame;
                                                      CGRect giftSetsScrollViewFrame = giftSetsTableView.frame;
                                                      giftSetsScrollViewFrame.origin.y = buttonsView.frame.origin.y + buttonsView.frame.size.height + categoriesViewFrame.size.height;
                                                      giftSetsScrollViewFrame.size.height = self.view.frame.size.height - giftSetsScrollViewFrame.origin.y;
                                                      giftSetsTableView.frame = giftSetsScrollViewFrame;
                                                  }else if (priceButton.selected == YES){
                                                      CGRect priceViewFrame = priceView.frame;
                                                      priceViewFrame.origin.y = buttonsView.frame.origin.y + buttonsView.frame.size.height;
                                                      priceView.frame = priceViewFrame;
                                                      CGRect giftSetsScrollViewFrame = giftSetsTableView.frame;
                                                      giftSetsScrollViewFrame.origin.y = buttonsView.frame.origin.y + buttonsView.frame.size.height + priceViewFrame.size.height;
                                                      giftSetsScrollViewFrame.size.height = self.view.frame.size.height - giftSetsScrollViewFrame.origin.y;
                                                      giftSetsTableView.frame = giftSetsScrollViewFrame;
                                                  }else{
                                                      CGRect giftSetsScrollViewFrame = giftSetsTableView.frame;
                                                      giftSetsScrollViewFrame.origin.y = buttonsView.frame.origin.y + buttonsView.frame.size.height;
                                                      giftSetsScrollViewFrame.size.height = self.view.frame.size.height - giftSetsScrollViewFrame.origin.y;
                                                      giftSetsTableView.frame = giftSetsScrollViewFrame;
                                                  }
                                              } 
                                              completion:^(BOOL finished) {
                                                  [HGGiftAssistantService killService];
                                              }];
                         }];
    }    
}

- (void)showAssistantNumberView{
    if (assistantNumberViewTimer != nil){
        [assistantNumberViewTimer invalidate];
        assistantNumberViewTimer = nil;
    }
    
    assistantNumberViewTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                       target:self
                                                     selector:@selector(handleNumberViewTimer:)
                                                     userInfo:nil
                                                      repeats:NO];
    
    assistantNumberLabel.text = [NSString stringWithFormat:@"%d/%d", assistantQuestionIndex + 1, [giftAssistantQuestions count]];
    
    if (assistantNumberView.hidden == YES){
        assistantNumberView.alpha = 0.0;
        assistantNumberView.hidden = NO;
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             assistantNumberView.alpha = 1.0;
                         } 
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)hideAssistantNumberView{
    if (assistantNumberView.hidden == NO){
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             assistantNumberView.alpha = 0.0;
                         } 
                         completion:^(BOOL finished) {
                             assistantNumberView.hidden = YES;
                             assistantNumberView.alpha = 1.0;
                         }];
    }
}

- (BOOL)isAssistantNumberViewShown{
    return (assistantNumberView.hidden == NO);
}

- (void)handleNumberViewTimer:(NSTimer*)timer{
    assistantNumberViewTimer = nil;
    [self hideAssistantNumberView];
}

- (void)handleCategoryButtonAction:(id)sender{
    if (currentGiftCategoryButton != sender){
        if (currentGiftCategoryButton != nil){
            currentGiftCategoryButton.selected = NO;
        }
        currentGiftCategoryButton = (UIButton*)sender;
        currentGiftCategoryButton.selected = YES;
        
        if (currentGiftCategoryButton.tag == 100){
            if (currentGiftCategory != nil){
                [currentGiftCategory release];
                currentGiftCategory = nil;
            }
            currentGiftCategory = [[NSString alloc] initWithString:@"推荐"];
            
            [HGTrackingService logEvent:kTrackingEventSelectGiftCategory withParameters:[NSDictionary dictionaryWithObjectsAndKeys:currentGiftCategory, @"category", nil]];
        }else if (currentGiftCategoryButton.tag == 101){
            if (currentGiftCategory != nil){
                [currentGiftCategory release];
                currentGiftCategory = nil;
            }
            currentGiftCategory = [occasionGiftCollection.occasion.occasionCategory.name retain];
            
            [HGTrackingService logEvent:kTrackingEventSelectGiftCategory withParameters:[NSDictionary dictionaryWithObjectsAndKeys:currentGiftCategory, @"category", nil]];
        }else{
            HGGiftCategory* selectedGiftCategory = [[HGGiftCategoryService sharedService].giftCategories objectAtIndex:currentGiftCategoryButton.tag];
            if (currentGiftCategory != nil){
                [currentGiftCategory release];
                currentGiftCategory = nil;
            }
            currentGiftCategory = [[NSString alloc] initWithString:selectedGiftCategory.identifier];
            
            [HGTrackingService logEvent:kTrackingEventSelectGiftCategory withParameters:[NSDictionary dictionaryWithObjectsAndKeys:selectedGiftCategory.name, @"category", nil]];
        }
        
        if (currentGiftCategoryButton != nil){
            [categoryButton setTitle:currentGiftCategoryButton.titleLabel.text forState:UIControlStateNormal];
            [categoryButton setImage:[currentGiftCategoryButton imageForState:UIControlStateNormal] forState:UIControlStateNormal];
            [categoryButton setImage:[currentGiftCategoryButton imageForState:UIControlStateNormal] forState:UIControlStateHighlighted];
            [categoryButton setImage:[currentGiftCategoryButton imageForState:UIControlStateSelected] forState:UIControlStateSelected];
        }else{
            [categoryButton setTitle:@"特征" forState:UIControlStateNormal];
            [categoryButton setImage:[UIImage imageNamed:@"gift_selection_panel_category"] forState:UIControlStateNormal];
            [categoryButton setImage:[UIImage imageNamed:@"gift_selection_panel_category"] forState:UIControlStateHighlighted];
            [categoryButton setImage:[UIImage imageNamed:@"gift_selection_panel_category_selected"] forState:UIControlStateSelected];
        }
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.15];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [categoryButton.layer addAnimation:animation forKey:@"updateCategoryButtonAnimation"];
        
        [giftSetsTableView setContentOffset:CGPointMake(giftSetsTableView.contentOffset.x, giftSetsTableView.contentOffset.y) animated:NO];
        [self performSelector:@selector(updateGiftSetsDisplayWithAnimation) withObject:nil afterDelay:0.01];
    }
}

- (void)setupCategoryView{
    if (giftCategoroSubViews != nil){
        for (UIView* subView in giftCategoroSubViews){
            [subView removeFromSuperview];
        }
        [giftCategoroSubViews removeAllObjects];
    }else{
        giftCategoroSubViews = [[NSMutableArray alloc] init];
    }
    
    HGGiftCategoryService* giftCategoryService = [HGGiftCategoryService sharedService];
    CGFloat viewX = 0;
    CGFloat viewY = 0;
    CGFloat viewWidth = 72.0;
    CGFloat viewHeight = 44.0;
    if (giftAssistantGiftSets != nil){
        UIButton* giftCategoryButton = [[UIButton alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, viewHeight)];
        giftCategoryButton.tag = 100;
        [giftCategoryButton setImage:[UIImage imageNamed:@"gift_selection_category_custom"] forState:UIControlStateNormal];
        [giftCategoryButton setImage:[UIImage imageNamed:@"gift_selection_category_custom"] forState:UIControlStateHighlighted];
        [giftCategoryButton setImage:[UIImage imageNamed:@"gift_selection_category_selected_custom"] forState:UIControlStateSelected];
        [giftCategoryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [giftCategoryButton setTitleColor:UIColorFromRGB(0xd53d3b) forState:UIControlStateSelected];
        [giftCategoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [giftCategoryButton setTitle:@"推荐" forState:UIControlStateNormal];
        giftCategoryButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        giftCategoryButton.titleLabel.minimumFontSize = 12.0;
        giftCategoryButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        giftCategoryButton.selected = YES;
        
        [giftCategoroSubViews addObject:giftCategoryButton];
        [categoriesScrollView addSubview:giftCategoryButton];
        currentGiftCategoryButton = giftCategoryButton;
        
        [giftCategoryButton addTarget:self action:@selector(handleCategoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [giftCategoryButton release];
        
        UIImageView* giftCategorySeperatorView = [[UIImageView alloc] initWithFrame:CGRectMake(viewX + viewWidth -1.0, 0.0, 1.0, viewHeight)];
        giftCategorySeperatorView.image = [UIImage imageNamed:@"gift_selection_panel_seperator"];
        
        [giftCategoroSubViews addObject:giftCategorySeperatorView];
        [categoriesScrollView addSubview:giftCategorySeperatorView];
        [giftCategorySeperatorView release];
        
        viewX += viewWidth;
    }
    
    if (occasionGiftCollection != nil){
        UIButton* giftCategoryButton = [[UIButton alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, viewHeight)];
        giftCategoryButton.tag = 101;
        [giftCategoryButton setImage:[UIImage imageNamed:@"occasion_holiday_category_icon_general"] forState:UIControlStateNormal];
        [giftCategoryButton setImage:[UIImage imageNamed:@"occasion_holiday_category_icon_general"] forState:UIControlStateHighlighted];
        [giftCategoryButton setImage:[UIImage imageNamed:@"occasion_holiday_category_icon_general_selected"] forState:UIControlStateSelected];
        [giftCategoryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [giftCategoryButton setTitleColor:UIColorFromRGB(0xd53d3b) forState:UIControlStateSelected];
        [giftCategoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [giftCategoryButton setTitle:occasionGiftCollection.occasion.occasionCategory.name forState:UIControlStateNormal];
        giftCategoryButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        giftCategoryButton.titleLabel.minimumFontSize = 12.0;
        giftCategoryButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        giftCategoryButton.selected = YES;
        
        [giftCategoroSubViews addObject:giftCategoryButton];
        [categoriesScrollView addSubview:giftCategoryButton];
        currentGiftCategoryButton = giftCategoryButton;
        
        [giftCategoryButton addTarget:self action:@selector(handleCategoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [giftCategoryButton release];
        
        UIImageView* giftCategorySeperatorView = [[UIImageView alloc] initWithFrame:CGRectMake(viewX + viewWidth -1.0, 0.0, 1.0, viewHeight)];
        giftCategorySeperatorView.image = [UIImage imageNamed:@"gift_selection_panel_seperator"];
        
        [giftCategoroSubViews addObject:giftCategorySeperatorView];
        [categoriesScrollView addSubview:giftCategorySeperatorView];
        [giftCategorySeperatorView release];
        
        viewX += viewWidth;
    }
    
    int categoryIndex = 0;
    for (HGGiftCategory* giftCategory in giftCategoryService.giftCategories){
        UIButton* giftCategoryButton = [[UIButton alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, viewHeight)];
        giftCategoryButton.tag = categoryIndex;
        [giftCategoryButton setImage:[UIImage imageNamed:giftCategory.cover] forState:UIControlStateNormal];
        [giftCategoryButton setImage:[UIImage imageNamed:giftCategory.coverSelected] forState:UIControlStateSelected];
        [giftCategoryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [giftCategoryButton setTitleColor:UIColorFromRGB(0xd53d3b) forState:UIControlStateSelected];
        [giftCategoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [giftCategoryButton setTitle:giftCategory.name forState:UIControlStateNormal];
        giftCategoryButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        if ([giftCategory.identifier isEqualToString:currentGiftCategory]){
            giftCategoryButton.selected = YES;
            currentGiftCategoryButton = giftCategoryButton;
        }
        [giftCategoryButton addTarget:self action:@selector(handleCategoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [giftCategoroSubViews addObject:giftCategoryButton];
        [categoriesScrollView addSubview:giftCategoryButton];
        [giftCategoryButton release];
        
        if (giftCategory != [giftCategoryService.giftCategories lastObject]){
            UIImageView* giftCategorySeperatorView = [[UIImageView alloc] initWithFrame:CGRectMake(viewX + viewWidth -1.0, 0.0, 1.0, viewHeight)];
            giftCategorySeperatorView.image = [UIImage imageNamed:@"gift_selection_panel_seperator"];
            
            [giftCategoroSubViews addObject:giftCategorySeperatorView];
            [categoriesScrollView addSubview:giftCategorySeperatorView];
            [giftCategorySeperatorView release];
        }
        viewX += viewWidth;
        categoryIndex += 1;
    }
    
    if (currentGiftCategoryButton != nil){
        [categoryButton setTitle:currentGiftCategoryButton.titleLabel.text forState:UIControlStateNormal];
        [categoryButton setImage:[currentGiftCategoryButton imageForState:UIControlStateNormal] forState:UIControlStateNormal];
        [categoryButton setImage:[currentGiftCategoryButton imageForState:UIControlStateNormal] forState:UIControlStateHighlighted];
        [categoryButton setImage:[currentGiftCategoryButton imageForState:UIControlStateSelected] forState:UIControlStateSelected];
    }else{
        [categoryButton setTitle:@"特征" forState:UIControlStateNormal];
        [categoryButton setImage:[UIImage imageNamed:@"gift_selection_panel_category"] forState:UIControlStateNormal];
        [categoryButton setImage:[UIImage imageNamed:@"gift_selection_panel_category"] forState:UIControlStateHighlighted];
        [categoryButton setImage:[UIImage imageNamed:@"gift_selection_panel_category_selected"] forState:UIControlStateSelected];
    }
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionFade];
    [animation setDuration:0.15];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [categoryButton.layer addAnimation:animation forKey:@"updateCategoryButtonAnimation"];
    
    CGSize contentSize = categoriesScrollView.contentSize;
    contentSize.width = viewX;
    categoriesScrollView.contentSize = contentSize;
    
    [categoriesScrollView setContentOffset:CGPointMake(0.0, 0.0)];
}

- (void)updateGiftSetsDisplayWithAnimation {
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         giftSetsTableView.alpha = 0.0;
                     } 
                     completion:^(BOOL finished) {
                         [self updateGiftSetsDisplay];
                         
                         [UIView animateWithDuration:0.3 
                                               delay:0.0 
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              giftSetsTableView.alpha = 1.0;
                                          } 
                                          completion:^(BOOL finished) {
                                              
                                          }];
                     }];

}

- (void)updateGiftSetsDisplay{
    if (currentGiftSets) {
        [currentGiftSets removeAllObjects];
    } else {
        currentGiftSets = [[NSMutableArray alloc] init];
    }
    
    BOOL showEmptyView = YES;
    NSArray* categoryGiftSets = [giftSets objectForKey:currentGiftCategory];
    if (categoryGiftSets != nil && [categoryGiftSets count] > 0){
        for (HGGiftSet* giftSet in categoryGiftSets){
            BOOL priceCheck = YES;
            for (HGGift* gift in giftSet.gifts){
                if ((minPriceValue > 0.005 && gift.price < minPriceValue) || gift.price > maxPriceValue){
                    priceCheck = NO;
                    break;
                }
            }
            if (priceCheck == NO){
                continue;
            }
            [currentGiftSets addObject:giftSet];
            showEmptyView = NO;
        }
    }
    [giftSetsTableView setContentOffset:CGPointMake(0, 0)];
    [giftSetsTableView reloadData];
    emptyView.hidden = !showEmptyView;
}

- (void)handleGiftsListItemViewAction:(id)sender{
    HGGiftsSelectionViewGiftsListCellView* giftsSelectionViewGiftsListItemView = (HGGiftsSelectionViewGiftsListCellView*)sender;
    HGGiftSet* theGiftSet = giftsSelectionViewGiftsListItemView.giftSet;
    if ([theGiftSet.gifts count] == 1){
        HGGift* theGift = [theGiftSet.gifts objectAtIndex:0];
        
        [HGTrackingService logEvent:kTrackingEventEnterGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGiftsSelectionViewController", @"from", theGift.identifier, @"productId", nil]];
        
        HGGiftDetailViewController* viewContoller = [[HGGiftDetailViewController alloc] initWithGift:theGift];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    }else{
        [HGTrackingService logEvent:kTrackingEventEnterGiftGroupDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGiftsSelectionViewController", @"from", nil]];
        HGGiftSetDetailViewController* viewContoller = [[HGGiftSetDetailViewController alloc] initWithGiftSet:theGiftSet];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    }
}

- (void)handleAssistantLeftButtonButtonAction:(id)sender{
    if (assistantQuestionIndex > 0){
        if (assistantQuestionIndex == [giftAssistantQuestions count] - 1){
            [assistantRightButton setTitle:@"下一个" forState:UIControlStateNormal];
        }
        assistantQuestionIndex -= 1;
        
        if (assistantQuestionIndex == 0){
            [assistantLeftButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            assistantLeftButton.enabled = NO;
        }
        
        assistantQuestionView.giftAssistantQuestion = [giftAssistantQuestions objectAtIndex:assistantQuestionIndex]; 
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setDuration:0.3];
        [animation setValue:@"showPrevQuestion" forKey:@"animationName"];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[assistantQuestionView layer] addAnimation:animation forKey:@"showPrevQuestion"];
    }else{
        [UIView animateWithDuration:0.2 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             CGRect optionsScrollViewFrame = assistantQuestionView.optionsScrollView.frame;
                             optionsScrollViewFrame.origin.x = 120.0;
                             assistantQuestionView.optionsScrollView.frame = optionsScrollViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.1 
                                                   delay:0.0 
                                                 options:UIViewAnimationOptionCurveEaseInOut 
                                              animations:^{
                                                  CGRect optionsScrollViewFrame = assistantQuestionView.optionsScrollView.frame;
                                                  optionsScrollViewFrame.origin.x = 5.0;
                                                  assistantQuestionView.optionsScrollView.frame = optionsScrollViewFrame;
                                              } 
                                              completion:^(BOOL finished) {
                                                  
                                              }];
                         }];
    }
    
    
    [self showAssistantNumberView];
}

- (void)handleAssistantRightButtonButtonAction:(id)sender{
    if (assistantQuestionIndex < [giftAssistantQuestions count] - 1){
        if (assistantQuestionIndex == 0){
            [assistantLeftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            assistantLeftButton.enabled = YES;
        }
        assistantQuestionIndex += 1;
        if (assistantQuestionIndex == [giftAssistantQuestions count] - 1){
            [assistantRightButton setTitle:@"提交" forState:UIControlStateNormal];
        }
        
        assistantQuestionView.giftAssistantQuestion = [giftAssistantQuestions objectAtIndex:assistantQuestionIndex]; 
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setDuration:0.3];
        [animation setValue:@"showNextQuestion" forKey:@"animationName"];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[assistantQuestionView layer] addAnimation:animation forKey:@"showNextQuestion"];
        
        [self showAssistantNumberView];
    }else{
        assistantOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0, 416)];
        assistantOverlayView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:assistantOverlayView];
        recipientButton.userInteractionEnabled = NO;
        
        [progressView startAnimation];
        HGGiftAssistantService* giftAssistantService = [HGGiftAssistantService sharedService];
        giftAssistantService.delegate = self;
        [giftAssistantService requestGiftAssistantAnswers:giftAssistantQuestions];
    }
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

- (void)handleGiftSetsUpdatedForEmptyGiftSets:(NSNotification *)notification{
    if (giftSets != nil){
        [giftSets release];
        giftSets = nil;
    }
    giftSets = [[HGGiftSetsService sharedService].giftSets retain];
    if (giftSets != nil && [giftSets count] > 0){
        [self updateGiftSetsDisplay];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationGiftSetsUpdated object:nil]; 
}

#pragma mark Gesture Handler
- (void)handleSwipeRightGesture:(UISwipeGestureRecognizer*)recognizer{
    [self handleAssistantLeftButtonButtonAction:assistantLeftButton];
}

- (void)handleSwipeLeftGesture:(UISwipeGestureRecognizer*)recognizer{
    [self handleAssistantRightButtonButtonAction:assistantRightButton];
}

#pragma mark Slider Action

- (void)didRangesSliderChanged:(HGRangeSliderControl*)priceSlider {
    minPriceValue = priceSlider.selectedMinValue;
    maxPriceValue = priceSlider.selectedMaxValue;
    if ([priceSlider isUnlimited] == YES) {
        maxPriceValue = CGFLOAT_MAX;
    }
    
    if (minPriceValue <= 0.005){
        if (maxPriceValue == CGFLOAT_MAX){
            [priceButton setTitle:[NSString stringWithFormat:@"免费-¥500+"] forState:UIControlStateNormal];
        }else{
            [priceButton setTitle:[NSString stringWithFormat:@"免费-¥%d", (int)maxPriceValue] forState:UIControlStateNormal];
        }
    }else{
        if (maxPriceValue == CGFLOAT_MAX){
            [priceButton setTitle:[NSString stringWithFormat:@"¥%d-¥500+", (int)minPriceValue] forState:UIControlStateNormal];
        }else{
            [priceButton setTitle:[NSString stringWithFormat:@"¥%d-¥%d", (int)minPriceValue, (int)maxPriceValue] forState:UIControlStateNormal];
        }
    }

    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionFade];
    [animation setDuration:0.15];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [priceButton.layer addAnimation:animation forKey:@"updatePriceButtonAnimation"];
    
    [HGTrackingService logEvent:kTrackingEventSelectGiftPrice withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"¥%d-¥%d", (int)minPriceValue, (int)maxPriceValue], @"price", nil]];
    
    [self performSelector:@selector(updateGiftSetsDisplayWithAnimation) withObject:nil afterDelay:0.01];
}

#pragma mark HGRecipientSelectionViewControllerDelegate
- (void)didRecipientSelected: (HGRecipient*) recipient {
    [[HGRecipientService sharedService] updateRecipientLabel:recipientLabel];
}

#pragma mark HGGiftAssistantServiceDelegate
- (void)giftAssistantService:(HGGiftAssistantService *)theGiftAssistantService didRequestGiftAssistantQuestionsSucceed:(NSArray*)theGiftAssistantQuestions{
    if (giftAssistantQuestions != nil){
        [giftAssistantQuestions release];
        giftAssistantQuestions = nil;
    }
    giftAssistantQuestions = [theGiftAssistantQuestions retain];
    if (giftAssistantQuestions != nil && [giftAssistantQuestions count] > 0){
        assistantQuestionIndex = 0;
        assistantQuestionView.giftAssistantQuestion = [giftAssistantQuestions objectAtIndex:assistantQuestionIndex];
        priceButton.selected = NO;
        categoryButton.selected = NO;
        assistantButton.selected = YES;
        [assistantLeftButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        assistantLeftButton.enabled = NO;
        [assistantRightButton setTitle:@"下一个" forState:UIControlStateNormal];
        [self showAssistantView];
    }else {
        assistantQuestionIndex = -1;
    }
    [assistantOverlayView removeFromSuperview];
    [assistantOverlayView release];
    assistantOverlayView = nil;
    recipientButton.userInteractionEnabled = YES;
    [progressView stopAnimation];
    
    [HGTrackingService logEvent:kTrackingEventSelectGiftAssistant];
}

- (void)giftAssistantService:(HGGiftAssistantService *)theGiftAssistantService didRequestGiftAssistantQuestionsFail:(NSString*)error{
    [assistantOverlayView removeFromSuperview];
    [assistantOverlayView release];
    assistantOverlayView = nil;
    recipientButton.userInteractionEnabled = YES;
    [progressView stopAnimation];
}

- (void)giftAssistantService:(HGGiftAssistantService *)giftAssistantService didRequestGiftAssistantAnswersSucceed:(NSArray*)assistantGiftSets{
    if (giftAssistantGiftSets != nil){
        [giftAssistantGiftSets release];
        giftAssistantGiftSets = nil;
    }
    giftAssistantGiftSets = [assistantGiftSets retain];

    if (giftAssistantGiftSets != nil){
        if (currentGiftCategory != nil){
            [currentGiftCategory release];
            currentGiftCategory = nil;
        }
        currentGiftCategory = [[NSString alloc] initWithString:@"推荐"];
        NSMutableDictionary* theGiftSetsWithAssistant = [[NSMutableDictionary alloc] initWithDictionary:giftSets];
        [theGiftSetsWithAssistant setObject:giftAssistantGiftSets forKey:currentGiftCategory];
        [giftSets release];
        giftSets = [theGiftSetsWithAssistant retain];
        [theGiftSetsWithAssistant release];
        [self setupCategoryView];
        [self updateGiftSetsDisplay];
    }
    
    [assistantOverlayView removeFromSuperview];
    [assistantOverlayView release];
    assistantOverlayView = nil;
    recipientButton.userInteractionEnabled = YES;
    [progressView stopAnimation];
    
    [self handleFeatureButtonAction:categoryButton];
    
    [HGTrackingService logEvent:kTrackingEventSubmitGiftAssistant];
}

- (void)giftAssistantService:(HGGiftAssistantService *)giftAssistantService didRequestGiftAssistantAnswersFail:(NSString*)error{
    [assistantOverlayView removeFromSuperview];
    [assistantOverlayView release];
    assistantOverlayView = nil;
    recipientButton.userInteractionEnabled = YES;
    [progressView stopAnimation];
    
    [self handleAssistantButtonAction:assistantButton];
}

#pragma mark - HGGiftsSelectionViewAssistantQuestionViewDelegate
- (void)giftsSelectionViewAssistantQuestionView:(HGGiftsSelectionViewAssistantQuestionView *)theGiftsSelectionViewAssistantQuestionView didSelecteGiftAssistantOption:(HGGiftAssistantOption*)theGiftAssistantOption{
    if (assistantQuestionIndex < [giftAssistantQuestions count] - 1){
        if (assistantQuestionIndex == 0){
            [assistantLeftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            assistantLeftButton.enabled = YES;
        }
        assistantQuestionIndex += 1;
        if (assistantQuestionIndex == [giftAssistantQuestions count] - 1){
            [assistantRightButton setTitle:@"提交" forState:UIControlStateNormal];
        }
        
        assistantQuestionView.giftAssistantQuestion = [giftAssistantQuestions objectAtIndex:assistantQuestionIndex]; 
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setDuration:0.3];
        [animation setValue:@"showNextQuestion" forKey:@"animationName"];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[assistantQuestionView layer] addAnimation:animation forKey:@"showNextQuestion"];
        
        [self showAssistantNumberView];
    }else{
        assistantOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0, 416)];
        assistantOverlayView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:assistantOverlayView];
        recipientButton.userInteractionEnabled = NO;
        
        [progressView startAnimation];
        HGGiftAssistantService* giftAssistantService = [HGGiftAssistantService sharedService];
        giftAssistantService.delegate = self;
        [giftAssistantService requestGiftAssistantAnswers:giftAssistantQuestions];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
   
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath: indexPath animated: YES];
    
    HGGiftSet* theGiftSet = [currentGiftSets objectAtIndex:indexPath.row];
    if ([theGiftSet.gifts count] == 1){
        HGGift* theGift = [theGiftSet.gifts objectAtIndex:0];
        
        [HGTrackingService logEvent:kTrackingEventEnterGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGiftsSelectionViewController", @"from", theGift.identifier, @"productId", nil]];
        
        HGGiftDetailViewController* viewContoller = [[HGGiftDetailViewController alloc] initWithGift:theGift];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    }else{
        [HGTrackingService logEvent:kTrackingEventEnterGiftGroupDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGiftsSelectionViewController", @"from", nil]];
        HGGiftSetDetailViewController* viewContoller = [[HGGiftSetDetailViewController alloc] initWithGiftSet:theGiftSet];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return currentGiftSets ? [currentGiftSets count] : 0;
}

-(UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *viewIdentifier=@"HGGiftsSelectionViewGiftsListCellView";
    
    HGGiftsSelectionViewGiftsListCellView *cell=[theTableView dequeueReusableCellWithIdentifier:viewIdentifier];
    if (cell == nil) {
        cell = [HGGiftsSelectionViewGiftsListCellView giftsSelectionViewGiftsListItemView];
    }
    cell.giftSet = [currentGiftSets objectAtIndex:indexPath.row];
    
    return cell;
}




@end

