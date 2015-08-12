//
//  HGTutorialViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 3/4/11.
//  Copyright 2011 __MyCompanyName__ Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGTutorialViewController : UIViewController {
	IBOutlet UIScrollView* imageScrollView;
    
    BOOL fromStartup;
    CGFloat dragOffsetX;
}



@end
