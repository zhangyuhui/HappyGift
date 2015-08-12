//
//  HGVirtualGiftsView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-27.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGVirtualGiftsView : UIControl{
    IBOutlet UIImageView* coverImageView;
    IBOutlet UILabel*     titleLabel;
    IBOutlet UILabel*     descriptionLabel;
    IBOutlet UIView*      overLayView;
    NSTimer* highlightTimer;
}
    
@property(nonatomic, retain) IBOutlet UIImageView* coverImageView;
@property(nonatomic, retain) IBOutlet UILabel* titleLabel;
@property(nonatomic, retain) IBOutlet UILabel* descriptionLabel;

+ (HGVirtualGiftsView*)virtualGiftsView;
@end
