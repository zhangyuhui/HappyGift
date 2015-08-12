//
//  HGImageComposeView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/27/12.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGImageComposeItemView;
@class HGImageComposeDrawingView;

@interface HGImageComposeView : UIView {
    UIButton* deleteButton;
    UIButton* rotateButton;
    CGPoint lastTranslation;
    CGFloat lastScale;
    CGFloat lastRotation;
    HGImageComposeItemView* currentImageComposeItemView;
    HGImageComposeItemView* outlineImageComposeItemView;
    NSMutableArray* imageComposeItemViews;
    HGImageComposeDrawingView* imageComposeDrawingView;
    CGPoint currentHitTestPoint;
    BOOL dragingDeleteButton;
    BOOL dragingRotateButton;
    CGPoint dragingRotateOrigin;
    CGPoint dragingRotateCenter;
    CGFloat dragingRotateDistanceOrigin;
    CGFloat dragingRotateVectorXOrigin;
    CGFloat dragingRotateVectorYOrigin;
    BOOL drawing;
    CGFloat drawingWidth;
    UIColor* drawingColor;
}
@property (nonatomic, assign) BOOL drawing;
@property (nonatomic, assign) CGFloat drawingWidth;
@property (nonatomic, retain) UIColor* drawingColor;

+ (HGImageComposeView*)createImageComposeView;

- (void)addCanvas:(UIImage*)canvas;
- (void)addWidget:(UIImage*)widget;
- (void)addText:(UIImage*)text;
- (void)addOutline:(UIImage*)outline;

- (void)removeSelected;
- (void)clearSelected;

@end