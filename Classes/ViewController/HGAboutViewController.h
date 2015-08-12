//
//  HGAboutViewController.h
//  HappyGift
//
//  Created by Yuhui Zhang on 8/21/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;

@interface HGAboutViewController : UIViewController {
    IBOutlet UINavigationBar*           navigationBar;
    IBOutlet UIScrollView*              contentScrollView;
    UIBarButtonItem*                    leftBarButtonItem;
    HGProgressView*                     progressView;
    
    IBOutlet UIButton*                  followUsButton;
}

@end
