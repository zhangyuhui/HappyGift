//
//  HGPageControl.h
//  HappyGift
//
//  Created by Yuhui Zhang on 5/7/12.
//  Copyright (c) 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGPageControl : UIView {
    int numberOfPages;
    int currentPage;
    UIColor* selectedColor;
    UIColor* deselectedColor;
}

@property (assign) int numberOfPages;
@property (assign) int currentPage;
@property (nonatomic, retain) UIColor* selectedColor;
@property (nonatomic, retain) UIColor* deselectedColor;

@end
