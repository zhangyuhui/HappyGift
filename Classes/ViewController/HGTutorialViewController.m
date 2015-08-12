//
//  HGTutorialViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 3/4/11.
//  Copyright 2011 __MyCompanyName__ Inc. All rights reserved.
//

#import "HGTutorialViewController.h"
#import "HGSplashViewController.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "QuartzCore/QuartzCore.h"

#define kDragToChangeOffsetMax 90.0f

@interface HGTutorialViewController()<UIScrollViewDelegate>
@end

@implementation HGTutorialViewController

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSArray* screenshotImages = [NSArray arrayWithObjects:@"tutorial_1.jpg", @"tutorial_2.jpg", @"tutorial_3.jpg"/*, @"tutorial_4.jpg"*/, nil];;
    if (self.navigationController != nil){
        fromStartup = YES;
    }else{
        fromStartup = NO;
    }
    
	if (screenshotImages != nil){
		CGFloat iconX = 0;
		CGFloat iconY = 0;
		
		int iconIndex = 0;
		while (iconIndex<[screenshotImages count]) {
			
			UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY, 320, 460)];
            imageView.contentMode = UIViewContentModeScaleToFill;
			imageView.userInteractionEnabled = YES;
		    NSString* screenshot = [screenshotImages objectAtIndex:iconIndex];
            [imageView setImage:[UIImage imageNamed:screenshot]];
        	[imageScrollView addSubview:imageView];
            [imageView release];
            
            if (iconIndex == [screenshotImages count] - 1){
                if (fromStartup == YES){
                    UIButton* loginButton = [[UIButton alloc] initWithFrame:CGRectMake(iconX + (320.0 - 293.0)/2.0, 410.0, 293.0 , 35.0)];
                    [loginButton setImage:[UIImage imageNamed:@"turtorial_login"] forState:UIControlStateNormal];
                    [loginButton addTarget:self action:@selector(handleLoginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    [imageScrollView addSubview:loginButton];
                    [loginButton release]; 
                } else {
                    UIButton* skipButton = [[UIButton alloc] initWithFrame:CGRectMake(iconX + (320.0 - 193.0)/2.0, 410.0, 193.0 , 35.0)];
                    [skipButton setImage:[UIImage imageNamed:@"tutorial_close"] forState:UIControlStateNormal];
                    [skipButton addTarget:self action:@selector(handleSkipButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    [imageScrollView addSubview:skipButton];
                    [skipButton release]; 
                }
            }
            
			iconIndex+=1;
			iconX += 320;
		}
		imageScrollView.contentSize = CGSizeMake(imageScrollView.frame.size.width*[screenshotImages count], imageScrollView.frame.size.height);
	}else {
		imageScrollView.contentSize = CGSizeMake(imageScrollView.frame.size.width, imageScrollView.frame.size.height);
	}
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [imageScrollView release];
    [super dealloc];
}

- (void)handleLoginButtonAction:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:kHGPreferneceKeyTutorialLogin];
    
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CGSize frameSize = self.view.frame.size;
    UIImageView* snapShotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 20.0, frameSize.width, frameSize.height)];
    snapShotImageView.hidden = YES;
    [appDelegate.window addSubview:snapShotImageView];
    
    UIGraphicsBeginImageContext(frameSize);
    CGContextScaleCTM( UIGraphicsGetCurrentContext(), 1.0f, 1.0f );
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [snapShotImageView setImage:viewImage];
    snapShotImageView.hidden = NO;
    
    HGSplashViewController* splashViewController = [[HGSplashViewController alloc] init];
    [self.navigationController pushViewController:splashViewController animated:NO];
    [splashViewController release];
    
    [UIView animateWithDuration:0.4
                          delay:0.0 
                        options:UIViewAnimationOptionCurveLinear 
                     animations:^{
                         CGRect snapShotImageViewFrame = snapShotImageView.frame;
                         snapShotImageViewFrame.origin.y = 480.0;
                         snapShotImageView.frame = snapShotImageViewFrame;
                     } 
                     completion:^(BOOL finished) {
                         snapShotImageView.hidden = YES;
                         [snapShotImageView removeFromSuperview];
                         [snapShotImageView release];
                     }];
}

- (void)handleSkipButtonAction:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:NO] forKey:kHGPreferneceKeyTutorialLogin];

    if (fromStartup == YES){
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        CGSize frameSize = self.view.frame.size;
        UIImageView* snapShotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 20.0, frameSize.width, frameSize.height)];
        snapShotImageView.hidden = YES;
        [appDelegate.window addSubview:snapShotImageView];
        
        UIGraphicsBeginImageContext(frameSize);
        CGContextScaleCTM( UIGraphicsGetCurrentContext(), 1.0f, 1.0f );
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [snapShotImageView setImage:viewImage];
        snapShotImageView.hidden = NO;
        
        HGSplashViewController* splashViewController = [[HGSplashViewController alloc] init];
        [self.navigationController pushViewController:splashViewController animated:NO];
        [splashViewController release];
        
        [UIView animateWithDuration:0.4
                              delay:0.0 
                            options:UIViewAnimationOptionCurveLinear 
                         animations:^{
                             CGRect snapShotImageViewFrame = snapShotImageView.frame;
                             snapShotImageViewFrame.origin.y = 480.0;
                             snapShotImageView.frame = snapShotImageViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             snapShotImageView.hidden = YES;
                             [snapShotImageView removeFromSuperview];
                             [snapShotImageView release];
                         }];
    }else{
        [self dismissModalViewControllerAnimated:YES];
    }
}

//#pragma mark - Scroll View Delegate
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (fromStartup == NO){
//        CGFloat currentScrollViewOffsetX = scrollView.contentOffset.x;  
//        if (imageScrollView.userInteractionEnabled == YES){
//            if (currentScrollViewOffsetX > dragOffsetX){
//                CGFloat extendOffsetX = currentScrollViewOffsetX + scrollView.frame.size.width - scrollView.contentSize.width;
//                if (extendOffsetX >= kDragToChangeOffsetMax){
//                    imageScrollView.userInteractionEnabled = NO;
//                    [imageScrollView setContentOffset:CGPointMake(currentScrollViewOffsetX, 0) animated:NO];
//                    [self dismissModalViewControllerAnimated:YES];
//                }
//            }
//        }
//        dragOffsetX = currentScrollViewOffsetX;
//    }
//}
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    if (fromStartup == NO){
//        dragOffsetX = scrollView.contentOffset.x;
//    }
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//	CGFloat imageScrollViewWidth = imageScrollView.frame.size.width;
//    int currentPage = floor((scrollView.contentOffset.x - imageScrollViewWidth / 2) / imageScrollViewWidth) + 1;
//    if (fromStartup == YES && currentPage == 4){
//        [self handleSkipAction:nil];
//    }
//}

@end
