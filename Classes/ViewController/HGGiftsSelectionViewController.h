//
//  HGGiftsSelectionViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGFeaturedGiftCollection;
@class HGOccasionGiftCollection;
@class HGGiftsSelectionViewAssistantQuestionView;

@interface HGGiftsSelectionViewController : UIViewController{
    IBOutlet UITableView*  giftSetsTableView;
    IBOutlet UIView*  assistantView;
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIButton* recipientButton;
    IBOutlet UILabel*  recipientLabel;
    IBOutlet UIButton* categoryButton;
    IBOutlet UIButton* priceButton;
    IBOutlet UIButton* assistantButton;
    
    IBOutlet UIView*   buttonsView;
    IBOutlet UIView*   categoriesView;
    IBOutlet UIScrollView* categoriesScrollView;
    IBOutlet UIView*   priceView;
    IBOutlet UILabel* emptyView;
    
    UIImageView* tutorialView;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    
    HGOccasionGiftCollection* occasionGiftCollection;
    
    NSDictionary* giftSets;
    NSMutableArray* giftCategoroSubViews;
    NSString* currentGiftCategory; 
    HGGiftsSelectionViewAssistantQuestionView* assistantQuestionView;
    IBOutlet UIButton* assistantLeftButton;
    IBOutlet UIButton* assistantRightButton;
    IBOutlet UIView* assistantNumberView;
    IBOutlet UILabel* assistantNumberLabel;
    UIView*  assistantOverlayView;
    NSTimer* assistantNumberViewTimer;
    NSArray* giftAssistantQuestions;
    NSArray* giftAssistantGiftSets;
    int assistantQuestionIndex;
    
    BOOL isFirstAppear;
    UIButton* currentGiftCategoryButton;
    CGFloat minPriceValue;
    CGFloat maxPriceValue;
    
    NSMutableArray* currentGiftSets;
}

- (id)initWithGiftSets:(NSDictionary*)giftSets occasionGiftCollection:(HGOccasionGiftCollection*)occasionGiftCollection;
- (id)initWithGiftSets:(NSDictionary*)giftSets currentGiftCategory:(NSString*)currentGiftCategory;
@end
