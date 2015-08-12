//
//  UIButton+Addition.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/16/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "UIButton+Addition.h"

static NSMutableDictionary *images;

@implementation UIButton (Addition)


- (void)setImageNamed:(NSString *)name
         leftCapWidth:(CGFloat)left
         topCapHeight:(CGFloat)top
             forState:(UIControlState)s {
    if (images == nil) {
        images = [[NSMutableDictionary alloc] init];
    }
    
    UIImage *image = [images valueForKey:name];
    if (image == nil) {
        image = [[UIImage imageNamed:name] stretchableImageWithLeftCapWidth:left topCapHeight:top];
        [images setValue:image forKey:name];
    }
    
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.backgroundColor = [UIColor clearColor];
    
    [self setBackgroundImage:image forState:s];
}

@end
