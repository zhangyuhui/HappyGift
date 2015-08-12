//
//  UISegmentedControl+Addition.m
//  HappyGift
//
//  Created by Zhang Yuhui on 3/16/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "UISegmentedControl+Addition.h"


@implementation UISegmentedControl (Addition)

-(void)setTag:(NSInteger)tag forSegmentAtIndex:(NSUInteger)segment {
	[[[self subviews] objectAtIndex:segment] setTag:tag];
}

-(void)setTintColor:(UIColor*)color forTag:(NSInteger)aTag {
	// must operate by tags.  Subview index is unreliable
	UIView *segment = [self viewWithTag:aTag];
	SEL tint = @selector(setTintColor:);
	
	// UISegment is an undocumented class, so tread carefully
	// if the segment exists and if it responds to the setTintColor message
	if (segment && ([segment respondsToSelector:tint])) {
		[segment performSelector:tint withObject:color];
	}
}

-(void)setTextColor:(UIColor*)color forTag:(NSInteger)aTag {
	UIView *segment = [self viewWithTag:aTag];
	for (UIView *view in segment.subviews) {
		SEL text = @selector(setTextColor:);
		
		// if the sub view exists and if it responds to the setTextColor message
		if (view && ([view respondsToSelector:text])) {
			[view performSelector:text withObject:color];
		}
	}
}

-(void)setShadowColor:(UIColor*)color forTag:(NSInteger)aTag {
	
	// you probably know the drill by now
	// you could also combine setShadowColor and setTextColor
	UIView *segment = [self viewWithTag:aTag];
	for (UIView *view in segment.subviews) {
		SEL shadowColor = @selector(setShadowColor:);
		if (view && ([view respondsToSelector:shadowColor])) {
			[view performSelector:shadowColor withObject:color];
		}
	}
}
@end
