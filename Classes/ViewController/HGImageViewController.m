//
//  HGImageViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 3/4/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGImageViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGImageService.h"
#import "UIBarButtonItem+Addition.h"
#import "QuartzCore/QuartzCore.h"

#define ICON_SCROLL_VIEW_ICON_MARGIN_X 10
#define ICON_SCROLL_VIEW_ICON_MARGIN_Y 8
#define ICON_SCROLL_VIEW_ICON_WIDTH 300
#define ICON_SCROLL_VIEW_ICON_HEIGHT 400

@interface HGImageViewController(private)
- (void)handleBackAction;
- (void)handleHomeAction;
@end

@interface HGImageViewController()<UIScrollViewDelegate>
@end

@implementation HGImageViewController


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

- (id)initWithImages:(NSArray*)theImages page:(int)thePage{
    self = [super initWithNibName:@"HGImageViewController" bundle:nil];
    if (self){
        images = [theImages retain];
        page = thePage;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleBackAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    navigationBar.topItem.rightBarButtonItem = nil;
    
    CGRect titleViewFrame = CGRectMake(20, 0, 180, 44);
    UIView* titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    
    CGRect titleLabelFrame = CGRectMake(0, 0, 180, 40);
    
	titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate naviagtionTitleFontSize]];;
    titleLabel.minimumFontSize = 20.0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
    
    NSString* titleText = @"";
    if (images) {
        titleText = [NSString stringWithFormat:@"%d/%d", page + 1, [images count]];
    }
    
	titleLabel.text = titleText;
    [titleView addSubview:titleLabel];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    navigationBar.hidden = YES;
    
    saveLabel.layer.masksToBounds = YES;
    saveLabel.layer.cornerRadius = 5.0;
    saveLabel.hidden = YES;
    
	imagesDataLoadingPool = [[NSMutableDictionary alloc] init];
	screenshotsView = [[NSMutableArray alloc] init];
	
	if (images != nil){
		CGFloat iconX = ICON_SCROLL_VIEW_ICON_MARGIN_X;
		CGFloat iconY = ICON_SCROLL_VIEW_ICON_MARGIN_Y;
		int iconIndex = 0;
		HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        while (iconIndex<[images count]) {
			
			UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY, ICON_SCROLL_VIEW_ICON_WIDTH, ICON_SCROLL_VIEW_ICON_HEIGHT)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
			imageView.userInteractionEnabled = YES;
			imageView.tag = iconIndex + 100;
			
            id object = [images objectAtIndex:iconIndex];
            if ([object isKindOfClass:[NSString class]]){
                NSString* screenshot = (NSString*)object;
                if (appDelegate.wifiReachable == YES || object == [images objectAtIndex:page]){
                    BOOL imageViewsInPoolExist = YES;
                    NSMutableArray* imageViewsInPool = [imagesDataLoadingPool objectForKey:screenshot];
                    if (imageViewsInPool == nil){
                        imageViewsInPoolExist = NO;
                        imageViewsInPool = [[NSMutableArray alloc] init];
                    }
                    [imageViewsInPool addObject:imageView];
                    
                    UIImage *imageData = [[HGImageService sharedService] requestImage:screenshot target:self selector:@selector(didImagesDataLoaded:)];
                    if (imageData != nil){
                        [imageView setImage:imageData];
                        CATransition *animation = [CATransition animation];
                        [animation setDelegate:self];
                        [animation setType:kCATransitionFade];
                        [animation setDuration:0.3];
                        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                        [imageView.layer addAnimation:animation forKey:@"updateImageAnimation"];
                    }else {
                        [imagesDataLoadingPool setObject:imageViewsInPool forKey:screenshot];
                        [imageView setImage:defaultImage];
                    }
                    
                    if (imageViewsInPoolExist == NO){
                        [imageViewsInPool release];
                    }
                }else {
                    if (imagesDataPendingPool == nil){
                        imagesDataPendingPool = [[NSMutableDictionary alloc] init];
                    }
                    imageView.image = defaultImage;
                    [imagesDataPendingPool setObject:imageView forKey:[NSNumber numberWithInt:iconIndex]];
                }
            }else if ([object isKindOfClass:[UIImage class]]){
                UIImage *screenshot = (UIImage*)object;
                [imageView setImage:screenshot];
                CATransition *animation = [CATransition animation];
                [animation setDelegate:self];
                [animation setType:kCATransitionFade];
                [animation setDuration:0.3];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [imageView.layer addAnimation:animation forKey:@"updateImageAnimation"];
            }
			
			[imageScrollView addSubview:imageView];
			
			[screenshotsView addObject:imageView];
            
            [imageView release];
			
			iconIndex+=1;
			
			iconX += ICON_SCROLL_VIEW_ICON_WIDTH + ICON_SCROLL_VIEW_ICON_MARGIN_X*2;
			
		}
		imageScrollView.contentSize = CGSizeMake(imageScrollView.frame.size.width*[images count], imageScrollView.frame.size.height);
	}else {
		imageScrollView.contentSize = CGSizeMake(imageScrollView.frame.size.width, imageScrollView.frame.size.height);
	}
	
    pageControl.numberOfPages = [images count];
    pageControl.currentPage = page;
	if (page > 0){
        [imageScrollView setContentOffset:CGPointMake(imageScrollView.frame.size.width*page, 0) animated:NO];
	}

    pageControl.hidden = ([images count] == 1);
    
    UITapGestureRecognizer *singleTapA = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
    singleTapA.numberOfTapsRequired = 1;
    singleTapA.numberOfTouchesRequired = 1;
    [imageScrollView addGestureRecognizer:singleTapA];
    
    UITapGestureRecognizer *doubleTapA = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleDoubleTap:)];
    doubleTapA.numberOfTapsRequired = 2;
    doubleTapA.numberOfTouchesRequired = 1;
    [imageScrollView addGestureRecognizer:doubleTapA];


    [singleTapA requireGestureRecognizerToFail:doubleTapA];
    
    [singleTapA release];
    [doubleTapA release];
    
    UITapGestureRecognizer *singleTapB = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
    singleTapB.numberOfTapsRequired = 1;
    singleTapB.numberOfTouchesRequired = 1;
    [zoomScrollView addGestureRecognizer:singleTapB];
    
    UITapGestureRecognizer *doubleTapB = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleDoubleTap:)];
    doubleTapB.numberOfTapsRequired = 2;
    doubleTapB.numberOfTouchesRequired = 1;
    [zoomScrollView addGestureRecognizer:doubleTapB];
    
    
    [singleTapB requireGestureRecognizerToFail:doubleTapB];
    
    [singleTapB release];
    [doubleTapB release];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)handleBackAction:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)handleSaveAction:(id)sender{
    UIImage * imageSave = [images objectAtIndex:pageControl.currentPage];
    UIImageWriteToSavedPhotosAlbum(imageSave, self, 
                                   @selector(handleSaveNotification:didFinishSavingWithError:contextInfo:), nil);
}

- (void)handleSaveNotification:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error != NULL){
        saveLabel.text = error.description;
    }else{
        saveLabel.text = @"成功保存图片";
    }
    
    if (saveLabel.hidden == YES){
        saveLabel.alpha = 0.0;
        saveLabel.hidden = NO;
        [UIView animateWithDuration:0.2 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             saveLabel.alpha = 0.8;
                         } 
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.2 
                                                   delay:1.0 
                                                 options:UIViewAnimationOptionCurveEaseInOut 
                                              animations:^{
                                                  saveLabel.alpha = 0.0;
                                              } 
                                              completion:^(BOOL finished) {
                                                  saveLabel.hidden = YES;
                                              }];
                         }];
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [leftBarButtonItem release];
    leftBarButtonItem = nil;
    
    [imagesDataLoadingPool release];
    imagesDataLoadingPool = nil;
    
    [screenshotsView release];
    screenshotsView = nil;
}


- (void)dealloc {
    [navigationBar release];
	[screenshotsView release];
	[imagesDataLoadingPool release];
    [zoomScrollView release];
	[defaultImage release];
	[pageControl release];
    [saveLabel release];
    [leftBarButtonItem release];
    [titleLabel release];
    [imagesDataPendingPool release];
    [super dealloc];
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender {
    
    imageScrollView.userInteractionEnabled = NO;
    zoomScrollView.userInteractionEnabled = NO;
    
    if (navigationBar.hidden == YES){
       CGRect viewFrame = navigationBar.frame;
       viewFrame.origin.y = -44.0;
       navigationBar.frame = viewFrame;
       navigationBar.hidden = NO;
       [UIView animateWithDuration:0.1 
                             delay:0.0 
                           options:UIViewAnimationOptionCurveEaseInOut 
                        animations:^{
                            CGRect viewFrame = navigationBar.frame;
                            viewFrame.origin.y = 0.0;
                            navigationBar.frame = viewFrame;
                        } 
                        completion:^(BOOL finished) {
                            imageScrollView.userInteractionEnabled = YES;
                            zoomScrollView.userInteractionEnabled = YES;
                        }]; 
    }else{
        CGRect viewFrame = navigationBar.frame;
        if (viewFrame.origin.y == 0){
            [UIView animateWithDuration:0.2 
                                  delay:0.0 
                                options:UIViewAnimationOptionCurveEaseInOut 
                             animations:^{
                                 CGRect viewFrame = navigationBar.frame;
                                 viewFrame.origin.y = -44;
                                 navigationBar.frame = viewFrame;
                             } 
                             completion:^(BOOL finished) {
                                 navigationBar.hidden = YES;
                                 imageScrollView.userInteractionEnabled = YES;
                                 zoomScrollView.userInteractionEnabled = YES;
                             }]; 
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)sender {
    if (zoomScrollView.hidden == YES){
        UIImageView* imageView = (UIImageView*)[imageScrollView viewWithTag:(100 + pageControl.currentPage)];
        
        CGSize imageSize = imageView.image.size;
        if (imageSize.width > 320.0 || imageSize.height > 460.0){
            CGRect viewFrame = zoomImageView.frame;
            CGPoint contentOffset = zoomScrollView.contentOffset;
            if (imageSize.width < 320.0){
                viewFrame.origin.x = (320.0 - imageSize.width)/2.0;
                contentOffset.x = 0.0;
            }else{
                viewFrame.origin.x = 0.0;
                contentOffset.x = (320.0 - imageSize.width)/2.0;
            }
            
            if (imageSize.height < 460.0){
                viewFrame.origin.y = (460.0 - imageSize.height)/2.0;
                contentOffset.y = 0.0;
            }else{
                viewFrame.origin.y = 0.0;
                contentOffset.y = (460.0 - imageSize.height)/2.0;
            }
            
            viewFrame.size = imageSize;
            zoomImageView.frame = viewFrame;
            
            zoomScrollView.contentSize = imageSize;
            
        }else{
            CGRect viewFrame = zoomImageView.frame;
            viewFrame.origin = CGPointMake(0.0, 0.0);
            viewFrame.size = CGSizeMake(320.0, 460.0);
            zoomImageView.frame = viewFrame;
            
            zoomScrollView.contentSize = CGSizeMake(320.0, 460.0);
            zoomScrollView.contentOffset = CGPointMake(0.0, 0.0);
        }
        
        zoomImageView.image = imageView.image;
        
        zoomScrollView.hidden = NO;
        imageScrollView.hidden = YES;
        pageControl.hidden = YES;
    }else{
        imageScrollView.hidden = NO;
        zoomScrollView.hidden = YES;
        pageControl.hidden = ([images count] == 1);
    }
}


#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	CGFloat imageScrollViewWidth = imageScrollView.frame.size.width;
    int currentPage = floor((scrollView.contentOffset.x - imageScrollViewWidth / 2) / imageScrollViewWidth) + 1;
    if (currentPage != pageControl.currentPage){
        pageControl.currentPage = currentPage;
        page = currentPage;
        NSString* titleText = @"";
        if (images) {
            titleText = [NSString stringWithFormat:@"%d/%d", page + 1, [images count]];
        }
        titleLabel.text = titleText;
        
        if (imagesDataPendingPool != nil){
            UIImageView* imageView = [imagesDataPendingPool objectForKey:[NSNumber numberWithInt:currentPage]];
            if (imageView != nil){
                NSString* screenshot =  [images objectAtIndex:currentPage];
                BOOL imageViewsInPoolExist = YES;
                NSMutableArray* imageViewsInPool = [imagesDataLoadingPool objectForKey:screenshot];
                if (imageViewsInPool == nil){
                    imageViewsInPoolExist = NO;
                    imageViewsInPool = [[NSMutableArray alloc] init];
                }
                [imageViewsInPool addObject:imageView];
                
                UIImage *imageData = [[HGImageService sharedService] requestImage:screenshot target:self selector:@selector(didImagesDataLoaded:)];
                if (imageData != nil){
                    [imageView setImage:imageData];
                    CATransition *animation = [CATransition animation];
                    [animation setDelegate:self];
                    [animation setType:kCATransitionFade];
                    [animation setDuration:0.3];
                    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                    [imageView.layer addAnimation:animation forKey:@"updateImageAnimation"];
                }else {
                    [imagesDataLoadingPool setObject:imageViewsInPool forKey:screenshot];
                    [imageView setImage:defaultImage];
                }
                
                if (imageViewsInPoolExist == NO){
                    [imageViewsInPool release];
                }
                [imagesDataPendingPool removeObjectForKey:[NSNumber numberWithInt:currentPage]];
                if ([imagesDataPendingPool count] == 0){
                    [imagesDataPendingPool release];
                    imagesDataPendingPool = nil;
                }
            }
        }
    }
}

#pragma mark  ImagesDataLoader selector
- (void) didImagesDataLoaded:(HGImageData*)data{
	NSMutableArray* imageViewsInPool = [imagesDataLoadingPool objectForKey:data.url];
	if (imageViewsInPool != nil){
		for (UIImageView* imageView in imageViewsInPool){
			[imageView setImage:data.image];
		}
		[imagesDataLoadingPool removeObjectForKey:data.url];
	}
}

@end
