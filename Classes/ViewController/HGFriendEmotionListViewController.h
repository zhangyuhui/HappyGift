//
// HGFriendEmotionListViewController.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGDragToUpdateTableView;

@interface HGFriendEmotionListViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet HGDragToUpdateTableView*  tableView;
    IBOutlet UIView*   astroTrendHeadView;
    IBOutlet UILabel*  astroTrendTitleLabel;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    
    NSArray* friendEmotions;
}

- (id)initWithFriendEmotions:(NSArray*)theFriendEmotions;
@end
