//
//  HGImageComposePickerViewController.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@protocol HGImageComposePickerViewControllerDelegate;

typedef enum {
    HG_IMAGE_COMPOSE_PICKER_TYPE_WIDGET,
    HG_IMAGE_COMPOSE_PICKER_TYPE_TEXT,
    HG_IMAGE_COMPOSE_PICKER_TYPE_OUTLINE,
} HGImageComposePickerType;

@interface HGImageComposePickerViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIScrollView*     imageScrollView;
    HGProgressView* progressView;
    UIBarButtonItem* leftBarButtonItem;
    HGImageComposePickerType pickerType;
    id<HGImageComposePickerViewControllerDelegate> delegate;
}
@property (nonatomic, assign) id<HGImageComposePickerViewControllerDelegate> delegate;

- (id)initWithWidgetPickerType:(HGImageComposePickerType)type;

@end

@protocol HGImageComposePickerViewControllerDelegate<NSObject> 
- (void)imageComposePickerViewController:(HGImageComposePickerViewController *)imageComposePickerViewController didSelectImageWidget:(UIImage*)widget;
- (void)imageComposePickerViewController:(HGImageComposePickerViewController *)imageComposePickerViewController didSelectImageText:(UIImage*)text;
- (void)imageComposePickerViewController:(HGImageComposePickerViewController *)imageComposePickerViewController didSelectImageOutline:(UIImage*)outline;
@end
