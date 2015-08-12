//
//  HGImageComposePickerItemView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 12-7-27.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGImageComposePickerItemView : UIControl{
    IBOutlet UIImageView* coverImageView;
    IBOutlet UIView*      overLayView;
    NSTimer* highlightTimer;
}
@property (nonatomic, retain) UIImageView* coverImageView;
    
+ (HGImageComposePickerItemView*)imageComposePickerItemView;
@end


