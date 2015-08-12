//
//  HGGIFGiftListViewController.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-27.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGDragToUpdateTableView;
@class HGOccasionGiftCollection;
@class HGFriendEmotion;
@class HGAstroTrend;
@class HGGIFGift;

@interface HGGIFGiftListViewController : UIViewController{
    IBOutlet HGDragToUpdateTableView*   tableView;
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIButton* recipientButton;
    IBOutlet UILabel* recipientLabel;
    IBOutlet UIView*   headView;
    IBOutlet UILabel*  titleLabel;
    IBOutlet UIScrollView* categoryScrollView;
    UIButton* selectedCategoryButton;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    
    NSArray* gifGifts;
    NSMutableDictionary* gifGiftsByCategory;
    HGGIFGift* selectedGIFGift;
    
    HGOccasionGiftCollection* occasionGiftCollection;
    HGFriendEmotion* friendEmotion;
    HGAstroTrend* astroTrend;
    
    NSMutableArray* contentSubViews;
}

- (id)initWithOccasionGiftCollection:(HGOccasionGiftCollection*)theGiftCollection;
- (id)initWithFriendEmotion:(HGFriendEmotion*)theFriendEmotion;
- (id)initWithAstroTrend:(HGAstroTrend*)theAstroTrend;
- (id)initWithGIFGiftsByCategory:(NSMutableDictionary* )theGIFGifts;
@end
