//
//  UIBarButtonItem+Addition.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/16/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "UIBarButtonItem+Addition.h"
#import "UIButton+Addition.h"
#import "HappyGiftAppDelegate.h"

@implementation UIBarButtonItem (Addition)

- (id)initNavigationTextBarButtonItemWithImage:(NSString *)title target:(id)target action:(SEL)action{
    UIImage* buttonBackgroundImage = [[UIImage imageNamed:@"navigation_button"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 55.0f, 32.0f)];
    [button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [button titleLabel].font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    [button titleLabel].textAlignment = UITextAlignmentCenter;
    UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0);
    button.titleEdgeInsets = titleInsets;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self = [self initWithCustomView:button];  
    [button release];
    return self;     
}

- (id)initNavigationImageBarButtonItemWithImage:(NSString *)image target:(id)target action:(SEL)action{
    UIImage* buttonBackgroundImage = [[UIImage imageNamed:@"navigation_button"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
    UIImage* buttonImage = [UIImage imageNamed:image];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 32.0f)];
    [button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self = [self initWithCustomView:button];  
    [button release];
    return self;     
}

- (id)initNavigationBackTextBarButtonItem:(NSString*)title target:(id)target action:(SEL)action{
    UIImage* buttonBackgroundImage = [[UIImage imageNamed:@"navigation_back_button"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 55.0f, 32.0f)];
    [button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [button titleLabel].font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    [button titleLabel].textAlignment = UITextAlignmentCenter;
    UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0);
    button.titleEdgeInsets = titleInsets;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self = [self initWithCustomView:button];  
    [button release];
    return self;
}

- (id)initNavigationBackImageBarButtonItem:(NSString*)image target:(id)target action:(SEL)action{
    UIImage* buttonBackgroundImage = [[UIImage imageNamed:@"navigation_back_button"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
    UIImage* buttonImage = [UIImage imageNamed:image];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 32.0f)];
    [button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self = [self initWithCustomView:button];  
    [button release];
    return self; 
}

- (id)initNavigationLeftTextBarButtonItem:(NSString*)title target:(id)target action:(SEL)action{
    UIImage* buttonBackgroundImage = [[UIImage imageNamed:@"navigation_button"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 55.0f, 32.0f)];
    [button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [button titleLabel].font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    [button titleLabel].textAlignment = UITextAlignmentCenter;
    UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0);
    button.titleEdgeInsets = titleInsets;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self = [self initWithCustomView:button];  
    [button release];
    return self; 
}

- (id)initNavigationLeftImageBarButtonItem:(NSString*)image target:(id)target action:(SEL)action{
    UIImage* buttonBackgroundImage = [[UIImage imageNamed:@"navigation_button"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
    UIImage* buttonImage = [UIImage imageNamed:image];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 32.0f)];
    [button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self = [self initWithCustomView:button];  
    [button release];
    return self;     
}

- (id)initNavigationRightTextBarButtonItem:(NSString*)title target:(id)target action:(SEL)action{
    
    UIImage* buttonBackgroundImage = [[UIImage imageNamed:@"navigation_button"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 32.0f)];
    [button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [button titleLabel].font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    [button titleLabel].textAlignment = UITextAlignmentCenter;
    UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0);
    button.titleEdgeInsets = titleInsets;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self = [self initWithCustomView:button];  
    [button release];
    return self;    
}

- (id)initNavigationRightImageBarButtonItem:(NSString*)image target:(id)target action:(SEL)action{
    UIImage* buttonBackgroundImage = [[UIImage imageNamed:@"navigation_button"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
    UIImage* buttonImage = [UIImage imageNamed:image];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 32.0f)];
    [button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self = [self initWithCustomView:button];  
    [button release];
    return self;     
}


@end
