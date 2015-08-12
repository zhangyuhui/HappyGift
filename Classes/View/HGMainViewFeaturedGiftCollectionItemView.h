//
//  HGMainViewFeaturedGiftCollectionItemView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftSet;           

@interface HGMainViewFeaturedGiftCollectionItemView : UIControl{
    IBOutlet UIImageView* coverImageView;
    IBOutlet UIView*      coverOverLayView;
    IBOutlet UILabel*     titleLabel;
    IBOutlet UIView*      overLayView;
    
    HGGiftSet*  giftSet;
    NSTimer* highlightTimer;
    UIImage* defaultImage;
}
@property (nonatomic, retain) HGGiftSet* giftSet;
    
+ (HGMainViewFeaturedGiftCollectionItemView*)featuredGiftCollectionItemView;
@end
