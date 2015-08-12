//
//  HGImageComposeViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 07/27/12.
//  Copyright 2011 __MyCompanyName__ Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGTabMenuView;
@class HGProgressView;
@class HGImageComposeView;
@class HGRecipient;
@protocol HGImageComposeViewControllerDelegate;
@class HGImageComposeDrawingPickerView;

@interface HGImageComposeViewController : UIViewController {
    IBOutlet HGImageComposeView* imageComposeView;
    IBOutlet UIButton* backButton;
    IBOutlet UIButton* doneButton;
    IBOutlet UIButton* widgetButton;
    IBOutlet UIButton* textButton;
    IBOutlet UIButton* outlineButton;
    IBOutlet UIButton* drawButton;
    IBOutlet UIButton* drawWidthButton;
    IBOutlet UIButton* drawColorButton;
    IBOutlet UIButton* saveButton;
    HGTabMenuView* menuView;
    HGProgressView*  progressView;
    UIImage* canvasImage;
    HGImageComposeDrawingPickerView* drawingPickerView;
    HGRecipient* recipientForShare;
    id<HGImageComposeViewControllerDelegate> delegate;
}
@property (nonatomic, assign)  id<HGImageComposeViewControllerDelegate>  delegate;

- (id)initWithCanvasImage:(UIImage*)image;

@end


@protocol HGImageComposeViewControllerDelegate<NSObject> 
- (void)imageComposeViewController:(HGImageComposeViewController *)imageComposeViewController didFinishComposeImage:(UIImage*)image;
- (void)imageComposeViewControllerDidCancel:(HGImageComposeViewController *)imageComposeViewController;
@end
