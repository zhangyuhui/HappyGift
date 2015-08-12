//
//  HGMyLikesViewController.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-25.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
@class HGProgressView;

@interface HGMyLikesViewController : UIViewController {
    IBOutlet UINavigationBar*  navigationBar;
    
    HGProgressView*  progressView;
    
    IBOutlet UIScrollView*  giftSetsScrollView;
    IBOutlet UILabel* emptyView;
    
    NSMutableArray* contentSubViews;
}

@end