//
//  HGOccasionsListViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGOccasionGiftCollection;

@interface HGOccasionsListViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UITableView*  occasionTableView;
    IBOutlet UIView*   occasionHeadView;
    IBOutlet UILabel*  occasionNameLabel;
    IBOutlet UIImageView* occasionImageView;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    
    NSArray* giftCollections;
}

- (id)initWithGiftCollections:(NSArray*)giftCollections;
@end
