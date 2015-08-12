//
//  HGCardSelectionViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGGiftCard;
@class HGGiftOrder;
@class HGPopoverView;
@class HGRecipient;
@class HGGiftCardTemplate;
@class HGCardSelectionCategoryListItemView;

@interface HGCardSelectionViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIView*           cardsView;
    IBOutlet UIScrollView*     cardsScrollView;
    IBOutlet UIScrollView*     cardDetailView;
    IBOutlet UIScrollView*     cardCategoryView;
    IBOutlet UILabel*          titleLabel;
    IBOutlet UIImageView*      titleIndicatorView;
    IBOutlet UIButton*         titleButton;
    IBOutlet UITextField*      recipientNameTextField;
    IBOutlet UIImageView*      recipientUnderlineView;
    IBOutlet UITextView*       contentTextView;
    IBOutlet UIImageView*      contentUnderlineView;
    IBOutlet UILabel*          enclosureLabel;
    IBOutlet UIImageView*      enclosureIndicatorView;
    IBOutlet UIButton*         enclosureButton;
    IBOutlet UITextField*      senderTextFiled;
    IBOutlet UIImageView*      senderUnderlineView;
    
    UIBarButtonItem* leftBarButtonItem;
    UIBarButtonItem* rightBarButtonItem;
    UILabel* navTitleLabel;
    HGProgressView*  progressView;
    HGPopoverView* popoverView;
    
    HGGiftOrder* giftOrder;
    HGGiftCardTemplate* selectedCardTemplate;
    NSArray*  giftCardCategories;
    NSMutableArray*  cardsScrollSubViews;
    UIButton* currentSelectedCategoryView;
    int     giftCardIndex;
    int     categoryIndex;
    CGFloat dragOffsetX;
    CGFloat dragOffsetXChange;
    int     dargOffsetPage;
    int     dargOffsetPageNumber;
    
    BOOL isFirstAppear;
}
- (id)initWithGiftOrder:(HGGiftOrder*)giftOrder;
@end
