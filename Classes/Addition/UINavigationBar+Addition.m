////
////  UINavigationBar+Addition.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/16/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "UINavigationBar+Addition.h"

@implementation UINavigationBar (Addition)

- (void)awakeFromNib {
    [super awakeFromNib];
	[self initSubViews];
}

//- (id)initWithFrame:(CGRect)frame {
//    if ((self = [super initWithFrame:frame])) {
//		[self initSubViews];
//    }
//    return self;
//}

- (void)initSubViews{
    if([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        [self setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    }else{
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;
        UIImage* backgroundImage = [UIImage imageNamed:@"navigation_background"];
        UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundImageView.frame = CGRectMake(0.0, 0.0, backgroundImage.size.width, backgroundImage.size.height);
        [self addSubview:backgroundImageView];
        [backgroundImageView release];
    }
}

- (void)drawRect:(CGRect)rect {
    if([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] == YES) {
        [super drawRect:rect];
    }
}

@end
