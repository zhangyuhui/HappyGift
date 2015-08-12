//
//  HGEraseLineLabel.m
//  HappyGift
//
//  Created by Yuhui Zhang on 4/18/12.
//  Copyright (c) 2012 Ztelic Inc. All rights reserved.
//

#import "HGEraseLineLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation HGEraseLineLabel
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)awakeFromNib {
}

- (void) drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetAllowsAntialiasing(context, NO);
    CGContextSetLineWidth(context, 0.2);
    CGContextSetStrokeColorWithColor(context, self.textColor.CGColor);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height * 0.55);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height * 0.55);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
}
@end

