//
//  HGImageComposeViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 07/27/12.
//  Copyright 2011 __MyCompanyName__ Inc. All rights reserved.
//

#import "HGImageComposeViewController.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "HGProgressView.h"
#import "QuartzCore/QuartzCore.h"
#import "UINavigationBar+Addition.h"
#import "UIBarButtonItem+Addition.h"
#import "HGImageComposeView.h"
#import "HGImageComposePickerViewController.h"
#import "HGTrackingService.h"
#import "HGRecipientService.h"
#import "HGRecipientSelectionViewController.h"
#import "HGImageComposeViewController.h"
#import "HGImageComposeDrawingPickerView.h"

@interface HGImageComposeViewController()<HGImageComposePickerViewControllerDelegate, HGRecipientSelectionViewControllerDelegate, HGImageComposeDrawingPickerViewDelegate>
@end

@implementation HGImageComposeViewController
@synthesize delegate;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (id)initWithCanvasImage:(UIImage *)image{
    self = [super initWithNibName:@"HGImageComposeViewController" bundle:nil];
    if (self){
        canvasImage = [image retain];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    [backButton addTarget:self action:@selector(handleBackAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [doneButton addTarget:self action:@selector(handleDoneAction:) forControlEvents:UIControlEventTouchUpInside];
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;

    [widgetButton addTarget:self action:@selector(handleWidgetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [textButton addTarget:self action:@selector(handleTextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [outlineButton addTarget:self action:@selector(handleOutlineButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton addTarget:self action:@selector(handleSaveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [drawButton addTarget:self action:@selector(handleDrawButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [drawWidthButton addTarget:self action:@selector(handleDrawWidthButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [drawColorButton addTarget:self action:@selector(handleDrawColorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [imageComposeView addCanvas:canvasImage];
    
    imageComposeView.drawingWidth = 2.0;
    imageComposeView.drawingColor = [UIColor blackColor];
    
    drawWidthButton.hidden = YES;
    drawColorButton.hidden = YES;
    
    [self performButtonsShowUp];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [menuView removeFromSuperview];
    [menuView release];
    menuView = nil;
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (recipientForShare != nil){
        [HGRecipientService sharedService].selectedRecipient = recipientForShare;
        [recipientForShare release];
        recipientForShare = nil;
        
        UIGraphicsBeginImageContext(imageComposeView.frame.size);
        CGContextScaleCTM( UIGraphicsGetCurrentContext(), 1.0f, 1.0f );
        [imageComposeView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage* imageComposed = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if ([delegate respondsToSelector:@selector(imageComposeViewController:didFinishComposeImage:)]){
            [delegate imageComposeViewController:self didFinishComposeImage:imageComposed];
        }
        
        [self dismissModalViewControllerAnimated:YES];
    }
}


- (void)dealloc {
    [backButton release];
    [doneButton release];
    [widgetButton release];
    [textButton release];
    [outlineButton release];
    [saveButton release];
    [drawButton release];
    [drawWidthButton release];
    [drawColorButton release];
    [menuView release];
    [imageComposeView release];
    [canvasImage release];
    [super dealloc];
}

- (void)handleBackAction:(id)sender{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:@"放弃当前正在制作的贺卡吗？"
                                                        delegate:self 
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:@"取消", nil];
    
    [alertView show];
    [alertView release];
}

- (void)handleDoneAction:(id)sender{
    if (imageComposeView.drawing){
        imageComposeView.drawing = NO;
    }
    [imageComposeView clearSelected];
    HGRecipient* selectedRecipient = [HGRecipientService sharedService].selectedRecipient;
    if (selectedRecipient != nil && (selectedRecipient.recipientNetworkId == NETWORK_SNS_WEIBO || selectedRecipient.recipientNetworkId == NETWORK_SNS_RENREN)){
        UIGraphicsBeginImageContext(imageComposeView.frame.size);
        CGContextScaleCTM( UIGraphicsGetCurrentContext(), 1.0f, 1.0f );
        [imageComposeView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage* imageComposed = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if ([delegate respondsToSelector:@selector(imageComposeViewController:didFinishComposeImage:)]){
            [delegate imageComposeViewController:self didFinishComposeImage:imageComposed];
        }
        
        [self dismissModalViewControllerAnimated:YES];
    }else{
        [HGRecipientService sharedService].selectedRecipient = nil;
        HGRecipientSelectionViewController* viewController = [[HGRecipientSelectionViewController alloc] initWithRecipientSelectionType:kRecipientSelectionTypeSNSUsers];
        viewController.delegate = self;
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
    }
}

- (void)handleWidgetButtonAction:(id)sender{
    if (imageComposeView.drawing){
        imageComposeView.drawing = NO;
    }
    [imageComposeView clearSelected];
    HGImageComposePickerViewController* viewController = [[HGImageComposePickerViewController alloc] initWithWidgetPickerType:HG_IMAGE_COMPOSE_PICKER_TYPE_WIDGET];
    viewController.delegate = self;
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)handleTextButtonAction:(id)sender{
    if (imageComposeView.drawing){
        imageComposeView.drawing = NO;
    }
    [imageComposeView clearSelected];
    HGImageComposePickerViewController* viewController = [[HGImageComposePickerViewController alloc] initWithWidgetPickerType:HG_IMAGE_COMPOSE_PICKER_TYPE_TEXT];
    viewController.delegate = self;
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)handleOutlineButtonAction:(id)sender{
    if (imageComposeView.drawing){
        imageComposeView.drawing = NO;
    }
    [imageComposeView clearSelected];
    HGImageComposePickerViewController* viewController = [[HGImageComposePickerViewController alloc] initWithWidgetPickerType:HG_IMAGE_COMPOSE_PICKER_TYPE_OUTLINE];
    viewController.delegate = self;
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)handleSaveButtonAction:(id)sender{
    [progressView startAnimation];
    if (imageComposeView.drawing){
        imageComposeView.drawing = NO;
    }
    [imageComposeView clearSelected];
    
    UIGraphicsBeginImageContext(imageComposeView.frame.size);
    CGContextScaleCTM( UIGraphicsGetCurrentContext(), 1.0f, 1.0f );
    [imageComposeView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* imageComposed = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(imageComposed, self, 
                                   @selector(handleSaveNotification:didFinishSavingWithError:contextInfo:), nil);
}

- (void)handleDrawButtonAction:(id)sender{
    [imageComposeView clearSelected];
    if (imageComposeView.drawing == YES){
        [self performDrawingButtonsHideDown];
    }else{
        [self performNoneDrawingButtonsHideDown];
    }
    imageComposeView.drawing = !imageComposeView.drawing;    
}

- (void)handleDrawWidthButtonAction:(id)sender{
    drawingPickerView = [HGImageComposeDrawingPickerView imageComposeDrawingPickerView:HG_IMAGE_COMPOSE_DRAWING_PICKER_TYPE_WIDTH];
    drawingPickerView.delegate = self;
    [drawingPickerView performShow:self.view atPoint:drawWidthButton.frame.origin];
}

- (void)handleDrawColorButtonAction:(id)sender{
    drawingPickerView = [HGImageComposeDrawingPickerView imageComposeDrawingPickerView:HG_IMAGE_COMPOSE_DRAWING_PICKER_TYPE_COLOR];
    drawingPickerView.delegate = self;
    [drawingPickerView performShow:self.view atPoint:drawColorButton.frame.origin];
}


- (void)handleSaveNotification:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    [progressView stopAnimation];
    if (!error){
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:@"自制图片保存成功"];
    }else{
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:[error description]];
    }
}

- (void)performButtonsShowUp{
    CGRect saveButtonFrame = saveButton.frame;
    outlineButton.frame = saveButtonFrame;
    widgetButton.frame = saveButtonFrame;
    textButton.frame = saveButtonFrame;
    drawButton.frame = saveButtonFrame;
    [UIView animateWithDuration:0.2 
                          delay:0.8 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect widgetButtonFrame = widgetButton.frame;
                         widgetButtonFrame.origin.y = saveButtonFrame.origin.y - 180.0;
                         widgetButton.frame = widgetButtonFrame;
                         CGRect textButtonFrame = textButton.frame;
                         textButtonFrame.origin.y = saveButtonFrame.origin.y - 135.0;
                         textButton.frame = textButtonFrame; 
                         CGRect outlineButtonFrame = outlineButton.frame;
                         outlineButtonFrame.origin.y = saveButtonFrame.origin.y - 90.0;
                         outlineButton.frame = outlineButtonFrame; 
                         CGRect drawButtonFrame = drawButton.frame;
                         drawButtonFrame.origin.y = saveButtonFrame.origin.y - 45.0;
                         drawButton.frame = drawButtonFrame; 
                     } 
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)performDrawingButtonsShowUp{
    CGRect drawButtonFrame = drawButton.frame;
    drawWidthButton.frame = drawButtonFrame;
    drawColorButton.frame = drawButtonFrame;
    drawWidthButton.hidden = NO;
    drawColorButton.hidden = NO;
    [UIView animateWithDuration:0.15 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect drawWidthButtonFrame = drawWidthButton.frame;
                         drawWidthButtonFrame.origin.y = drawButtonFrame.origin.y - 90.0;
                         drawWidthButton.frame = drawWidthButtonFrame;
                         CGRect drawColorButtonFrame = drawColorButton.frame;
                         drawColorButtonFrame.origin.y = drawButtonFrame.origin.y - 45.0;
                         drawColorButton.frame = drawColorButtonFrame; 
                     } 
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)performDrawingButtonsHideDown{
    [UIView animateWithDuration:0.15 
                           delay:0.0 
                         options:UIViewAnimationOptionCurveEaseInOut
                      animations:^{
                          drawWidthButton.frame = drawButton.frame;
                          drawColorButton.frame = drawButton.frame;
                      } 
                      completion:^(BOOL finished) {
                          [drawButton setImage:[UIImage imageNamed:@"compose_draw"] forState:UIControlStateNormal];
                          drawWidthButton.hidden = YES;
                          drawColorButton.hidden = YES;
                          [self performNoneDrawingButtonsShowUp];
                      }];
}

- (void)performNoneDrawingButtonsShowUp{
    CGRect drawButtonFrame = drawButton.frame;
    outlineButton.frame = drawButtonFrame;
    widgetButton.frame = drawButtonFrame;
    textButton.frame = drawButtonFrame;
    outlineButton.hidden = NO;
    widgetButton.hidden = NO;
    textButton.hidden = NO;
    [UIView animateWithDuration:0.2 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect widgetButtonFrame = widgetButton.frame;
                         widgetButtonFrame.origin.y = drawButtonFrame.origin.y - 135.0;
                         widgetButton.frame = widgetButtonFrame;
                         CGRect textButtonFrame = textButton.frame;
                         textButtonFrame.origin.y = drawButtonFrame.origin.y - 90.0;
                         textButton.frame = textButtonFrame; 
                         CGRect outlineButtonFrame = outlineButton.frame;
                         outlineButtonFrame.origin.y = drawButtonFrame.origin.y - 45.0;
                         outlineButton.frame = outlineButtonFrame; 
                     } 
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)performNoneDrawingButtonsHideDown{
    [UIView animateWithDuration:0.2 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         outlineButton.frame = drawButton.frame;
                         widgetButton.frame = drawButton.frame;
                         textButton.frame = drawButton.frame;
                     } 
                     completion:^(BOOL finished) {
                         [drawButton setImage:[UIImage imageNamed:@"compose_move"] forState:UIControlStateNormal];
                         outlineButton.hidden = YES;
                         widgetButton.hidden = YES;
                         textButton.hidden = YES;
                         [self performDrawingButtonsShowUp];
                     }];
}

#pragma mark HGTabMenuViewDelegate
- (void)menuView:(HGTabMenuView *)theMenuView didSelectMenu:(int)index;{

}

#pragma mark HGImageComposePickerViewControllerDelegate 
- (void)imageComposePickerViewController:(HGImageComposePickerViewController *)imageComposePickerViewController didSelectImageWidget:(UIImage*)widget{
    [imageComposeView addWidget:widget];
}

- (void)imageComposePickerViewController:(HGImageComposePickerViewController *)imageComposePickerViewController didSelectImageText:(UIImage*)text{
    [imageComposeView addText:text];
}

- (void)imageComposePickerViewController:(HGImageComposePickerViewController *)imageComposePickerViewController didSelectImageOutline:(UIImage*)outline{
    [imageComposeView addOutline:outline];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([delegate respondsToSelector:@selector(imageComposeViewControllerDidCancel)]){
            [delegate imageComposeViewControllerDidCancel:self];
        }
        
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - HGRecipientSelectionViewControllerDelegate
- (void)didRecipientSelected: (HGRecipient*)recipient{
    recipientForShare = [recipient retain];
}

#pragma mark - HGImageComposeDrawingPickerViewDelegate 
- (void)imageComposeDrawingPickerView:(HGImageComposeDrawingPickerView *)imageComposeDrawingPickerView didSelectWidth:(CGFloat)width{
    imageComposeView.drawingWidth = width;
    [drawingPickerView performHide];
    drawingPickerView = nil;
}

- (void)imageComposeDrawingPickerView:(HGImageComposeDrawingPickerView *)imageComposeDrawingPickerView didSelectColor:(UIColor*)color{
    imageComposeView.drawingColor = color; 
    [drawingPickerView performHide];
    drawingPickerView = nil;
}

- (void)imageComposeDrawingPickerViewDidCancel:(HGImageComposeDrawingPickerView *)imageComposeDrawingPickerView{
    [drawingPickerView performHide];
    drawingPickerView = nil;
}
@end
