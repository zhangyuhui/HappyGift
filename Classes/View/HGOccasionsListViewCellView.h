//
//  HGOccasionsListViewCellView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGOccasionGiftCollection.h"
@class HGUserImageView;

@interface HGOccasionsListViewCellView : UITableViewCell{
    IBOutlet UIImageView*     backgroundImageView;
    IBOutlet HGUserImageView*    coverImageView;
    IBOutlet UILabel*        nameLabel;
    IBOutlet UILabel*        contentLabel;
    
    HGOccasionGiftCollection*  giftCollection;
}
@property (nonatomic, retain) HGOccasionGiftCollection* giftCollection;

+ (HGOccasionsListViewCellView*)occasionsListViewCellView;

@end