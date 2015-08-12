//
//  HGImageComposeItemView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/27/12.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGImageComposeItemView : UIView {
    UIImageView* imageView;
    CGPoint topCorner;
    CGPoint bottomCorner;
    CGPoint innerCenter;
    //CGAffineTransform topCornerTransform;
    //CGAffineTransform bottomCornerTransform;
    BOOL selected;
}
@property (nonatomic, assign) UIImage* image;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, readonly) CGPoint topCorner;
@property (nonatomic, readonly) CGPoint bottomCorner;
@property (nonatomic, readonly) CGPoint innerCenter;

- (void)performTranslate:(CGPoint)translation;
- (void)performZoom:(CGFloat)scale;
- (void)performRotate:(CGFloat)rotation;


@end