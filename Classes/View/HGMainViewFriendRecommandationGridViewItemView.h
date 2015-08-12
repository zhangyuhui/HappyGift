//
//  HGMainViewFriendRecommandationGridViewItemView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGUserImageView;
@class HGFriendRecommandation;

@interface HGMainViewFriendRecommandationGridViewItemView : UIControl{
    IBOutlet HGUserImageView* recipientImageView;
    IBOutlet UILabel*     recipientNameLabel;
    IBOutlet UIView*      overLayView;
    
    HGFriendRecommandation*  recommandation;
}
@property (nonatomic, retain) HGFriendRecommandation* recommandation;
    
+ (HGMainViewFriendRecommandationGridViewItemView*)mainViewRecommandationGridViewItemView;
@end
