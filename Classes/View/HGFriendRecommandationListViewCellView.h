//
//  HGFriendRecommandationListViewCellView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HGUserImageView;
@class HGFriendRecommandation;

@interface HGFriendRecommandationListViewCellView : UITableViewCell {
    IBOutlet UIImageView*     backgroundImageView;
    IBOutlet HGUserImageView*    userImageView;
    IBOutlet UILabel*        nameLabel;
    IBOutlet UILabel*        descriptionLabel;
    HGFriendRecommandation*        friendRecommandation;
}
@property (nonatomic, retain) HGFriendRecommandation* friendRecommandation;
+ (HGFriendRecommandationListViewCellView*)friendRecommandationListViewCellView;

@end