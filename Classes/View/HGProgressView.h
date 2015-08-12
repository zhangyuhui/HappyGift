//
//  HGProgressView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/27/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGProgressView : UIView {
    IBOutlet UIView*      overlayView;
    IBOutlet UIActivityIndicatorView* indicatorView; 
}

@property (nonatomic, retain) UIActivityIndicatorView* indicatorView;
@property (nonatomic, retain) UIView*      overlayView;

- (void)startAnimation;
- (void)stopAnimation;
- (BOOL)animating;
    
+ (HGProgressView*)progressView:(CGRect)parentFrame;
+ (HGProgressView*)progressView;
@end

