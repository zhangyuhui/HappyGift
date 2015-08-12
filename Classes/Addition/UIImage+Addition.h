//
//  UIImage+YAdditions.h
//  HappyGift
//
//  Created by Zhang Yuhui on 12/14/10.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ROUND_CORNER_RADIUS_BIG   25
#define ROUND_CORNER_RADIUS_NORMAL 10 
#define ROUND_CORNER_RADIUS_SMALL  5 

@interface UIImage (YAdditions) 
- (UIImage*)imageWithScale:(CGSize)size;
- (UIImage*)imageWithReflection:(CGFloat)fraction;
- (UIImage*)imageWithOutline:(UIColor*)color;
- (UIImage*)imageWithOutline:(UIColor*)color scale:(CGFloat)scale;
- (UIImage*)imageWithOutline:(UIColor*)color size:(CGSize)size;
- (UIImage*)imageWithCornerNumber:(int)number;
- (UIImage*)imageWithBottomNumber:(int)number;
- (UIImage*)imageWithRoundCorners:(int)radius;
- (UIImage*)imageWithBackground:(UIColor*)color size:(CGSize)size outline:(UIColor*)outline spacing:(CGFloat)spacing;
- (UIImage *)imageWithGreyscale;
- (UIImage *)imageWithThumbnail:(CGSize)size;
- (UIImage *)imageWithCrop:(CGRect)rect;
- (UIImage *)imageWithFrame:(CGSize)size color:(UIColor*)color;
@end
