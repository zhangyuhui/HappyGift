//
//  HGFriendRecommandationListViewController.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGDragToUpdateTableView;

@interface HGFriendRecommandationListViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet HGDragToUpdateTableView*  tableView;
    IBOutlet UIView*   occasionHeadView;
    IBOutlet UILabel*  occasionNameLabel;
    IBOutlet UIButton*  occasionButton;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    
    NSArray* friendRecommandations;
}

- (id)initWithFriendRecommandations:(NSArray*)theFriendRecommandations;
@end
