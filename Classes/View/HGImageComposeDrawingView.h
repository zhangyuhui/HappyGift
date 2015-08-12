//
//  HGImageComposeDrawingView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/27/12.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGImageComposeDrawingView : UIView {
    NSMutableArray* drawingPoints;
    CGFloat drawingWidth;
    UIColor* drawingColor;
    CGContextRef drawingBufferContext;
    void* drawingBufferData;
}
@property (nonatomic, assign) CGFloat drawingWidth;
@property (nonatomic, retain) UIColor* drawingColor;

@end