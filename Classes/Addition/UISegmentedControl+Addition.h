//
//  UISegmentedControl+Addition.h
//  HappyGift
//
//  Created by Zhang Yuhui on 3/16/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UISegmentedControl (Addition) 
-(void)setTag:(NSInteger)tag forSegmentAtIndex:(NSUInteger)segment;
-(void)setTintColor:(UIColor*)color forTag:(NSInteger)aTag;
-(void)setTextColor:(UIColor*)color forTag:(NSInteger)aTag;
-(void)setShadowColor:(UIColor*)color forTag:(NSInteger)aTag;

@end
