//
//  UIBarButtonItem+Addition.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/16/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Addition)
- (id)initNavigationTextBarButtonItemWithImage:(NSString *)title target:(id)target action:(SEL)action;
- (id)initNavigationImageBarButtonItemWithImage:(NSString *)image target:(id)target action:(SEL)action;
- (id)initNavigationBackTextBarButtonItem:(NSString*)title target:(id)target action:(SEL)action;
- (id)initNavigationBackImageBarButtonItem:(NSString*)image target:(id)target action:(SEL)action;
- (id)initNavigationLeftTextBarButtonItem:(NSString*)title target:(id)target action:(SEL)action;
- (id)initNavigationLeftImageBarButtonItem:(NSString*)image target:(id)target action:(SEL)action;
- (id)initNavigationRightTextBarButtonItem:(NSString*)title target:(id)target action:(SEL)action;
- (id)initNavigationRightImageBarButtonItem:(NSString*)image target:(id)target action:(SEL)action;
@end
