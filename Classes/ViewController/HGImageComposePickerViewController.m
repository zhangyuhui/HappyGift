//
//  HGImageComposePickerViewController.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HGImageComposePickerViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGProgressView.h"
#import "QuartzCore/QuartzCore.h"
#import "UINavigationBar+Addition.h"
#import "UIBarButtonItem+Addition.h"
#import "HGImageComposePickerItemView.h"

#define kHGImageComposePickerWidgetCount     48
#define kHGImageComposePickerTextCount       12
#define kHGImageComposePickerOutlineCount    12

@interface HGImageComposePickerViewController ()

@end

@implementation HGImageComposePickerViewController
@synthesize delegate;

- (id)initWithWidgetPickerType:(HGImageComposePickerType)type{
    self = [super initWithNibName:@"HGImageComposePickerViewController" bundle:nil];
    if (self) {
        pickerType = type;
    }
    return self;
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad{
    [super viewDidLoad];
	self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleBackAction:)];
    
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    navigationBar.topItem.rightBarButtonItem = nil;
    
    CGRect titleViewFrame = CGRectMake(20, 0, 180, 44);
    UIView* titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    
    CGRect titleLabelFrame = CGRectMake(0, 0, 180, 40);
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate naviagtionTitleFontSize]];
    titleLabel.minimumFontSize = 20.0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
    if (pickerType == HG_IMAGE_COMPOSE_PICKER_TYPE_WIDGET){
        titleLabel.text = @"图片选择";
    }else if (pickerType == HG_IMAGE_COMPOSE_PICKER_TYPE_TEXT){
        titleLabel.text = @"文字选择";
    }else if (pickerType == HG_IMAGE_COMPOSE_PICKER_TYPE_OUTLINE){
        titleLabel.text = @"边框选择";
    }else{
        titleLabel.text = @"";
    }
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    NSString* itemNameFormat = nil;
    int itemsCount = 0;
    if (pickerType == HG_IMAGE_COMPOSE_PICKER_TYPE_WIDGET){
        itemNameFormat = @"widget_%d";
        itemsCount = kHGImageComposePickerWidgetCount;
    }else if (pickerType == HG_IMAGE_COMPOSE_PICKER_TYPE_TEXT){
        itemNameFormat = @"text_%d";
        itemsCount = kHGImageComposePickerTextCount;
    }else if (pickerType == HG_IMAGE_COMPOSE_PICKER_TYPE_OUTLINE){
        itemNameFormat = @"outline_%d";
        itemsCount = kHGImageComposePickerOutlineCount;
    }else{
        return;
    }
    
    CGFloat itemX = 10;
    CGFloat itemY = 10;
    CGFloat itemSpacingX = 7;
    CGFloat itemSpacingY = 5;
    int itemPageCount = 1;
    for(int imageIndex=1; imageIndex <= itemsCount; imageIndex ++){
        HGImageComposePickerItemView* itemView = [HGImageComposePickerItemView imageComposePickerItemView];
        CGRect itemViewFrame = itemView.frame;
        itemViewFrame.origin.x = itemX;
        itemViewFrame.origin.y = itemY;
        itemView.frame = itemViewFrame;
        [imageScrollView addSubview:itemView];
        
        [itemView addTarget:self action:@selector(handleItemViewAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (pickerType == HG_IMAGE_COMPOSE_PICKER_TYPE_OUTLINE){
            if (imageIndex == 1){
                UILabel* noneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, itemView.frame.size.height/2.0 - 15.0,  itemView.frame.size.width, 30.0)];
                noneLabel.text = @"无边框";
                noneLabel.textAlignment = UITextAlignmentCenter;
                noneLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
                noneLabel.textColor = [UIColor darkGrayColor];
                noneLabel.backgroundColor = [UIColor clearColor];
                [itemView addSubview:noneLabel];
                [noneLabel release];
            }else{
                itemView.coverImageView.image = [UIImage imageNamed:[NSString stringWithFormat:itemNameFormat, imageIndex - 1]];
            }
        }else{
            itemView.coverImageView.image = [UIImage imageNamed:[NSString stringWithFormat:itemNameFormat, imageIndex]];
        }
        if (imageIndex%3 == 0 && imageIndex != 0 && imageIndex != itemsCount){
            itemX = 10;
            itemY += itemViewFrame.size.height + itemSpacingY;
            if (imageIndex%12 == 0 && imageIndex < itemsCount){
                itemY = (imageIndex/12)*imageScrollView.frame.size.height + 10;
                itemPageCount += 1;
            }
        }else{
            itemX += itemViewFrame.size.width;
            itemX += itemSpacingX;
        }
    }
    
    CGSize contentSize = imageScrollView.contentSize;
    contentSize.height = itemPageCount*imageScrollView.frame.size.height;
    [imageScrollView setContentSize:contentSize];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    [leftBarButtonItem release];
    leftBarButtonItem = nil;
}

- (void)dealloc {
    [navigationBar release];
    [imageScrollView release];
    [leftBarButtonItem release];
    [progressView release];
    [super dealloc];
}

- (void)handleBackAction:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)handleItemViewAction:(id)sender{
    if (pickerType == HG_IMAGE_COMPOSE_PICKER_TYPE_WIDGET){
        if ([delegate respondsToSelector:@selector(imageComposePickerViewController:didSelectImageWidget:)]){
            HGImageComposePickerItemView* imageComposePickerItemView = (HGImageComposePickerItemView*)sender;
            [delegate imageComposePickerViewController:self didSelectImageWidget:imageComposePickerItemView.coverImageView.image];
        }
    }else if (pickerType == HG_IMAGE_COMPOSE_PICKER_TYPE_TEXT){
        if ([delegate respondsToSelector:@selector(imageComposePickerViewController:didSelectImageText:)]){
            HGImageComposePickerItemView* imageComposePickerItemView = (HGImageComposePickerItemView*)sender;
            [delegate imageComposePickerViewController:self didSelectImageText:imageComposePickerItemView.coverImageView.image];
        }
    }else if (pickerType == HG_IMAGE_COMPOSE_PICKER_TYPE_OUTLINE){
        if ([delegate respondsToSelector:@selector(imageComposePickerViewController:didSelectImageOutline:)]){
            HGImageComposePickerItemView* imageComposePickerItemView = (HGImageComposePickerItemView*)sender;
            [delegate imageComposePickerViewController:self didSelectImageOutline:imageComposePickerItemView.coverImageView.image];
        }
    }
    
    [self dismissModalViewControllerAnimated:YES];
}



@end
