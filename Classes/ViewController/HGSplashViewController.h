//
//  HGSplashViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;

@interface HGSplashViewController : UIViewController{
	IBOutlet UIImageView*      splashImageView;
    
    HGProgressView*            progressView;
    int                        splashCount;
    int                        splashIndex;
    NSTimer*                   splashPlayTimer;
    BOOL                       accountReady;
}
@end
