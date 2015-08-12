//
//  HGImageViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 3/4/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HGImageViewController : UIViewController {
    IBOutlet UINavigationBar*  navigationBar;
	IBOutlet UIScrollView* imageScrollView;
    IBOutlet UIScrollView* zoomScrollView;
    IBOutlet UIImageView* zoomImageView;
	IBOutlet UIPageControl* pageControl;
    IBOutlet UILabel* saveLabel;
    UILabel* titleLabel;
	
    UIBarButtonItem* leftBarButtonItem;
	NSArray* images;
	
	UIImage* defaultImage;
	int page;
    
	NSMutableArray* screenshotsView;
	NSMutableDictionary* imagesDataLoadingPool;
    NSMutableDictionary* imagesDataPendingPool;
}

- (id)initWithImages:(NSArray*)images page:(int)page;

@end
