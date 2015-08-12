//
//  HGCardSelectionTemplateListItemView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftCardTemplate;

@interface HGCardSelectionTemplateListItemView : UIControl{
    IBOutlet UIImageView* coverImageView;
    HGGiftCardTemplate* giftCardTemplate;
    BOOL isCoverImageRequestStarted;
}
@property (nonatomic, retain) HGGiftCardTemplate* giftCardTemplate;
@property (nonatomic, assign) BOOL isCoverImageRequestStarted;
- (void)requestCoverImage;
    
+ (HGCardSelectionTemplateListItemView*)cardSelectionTemplateListItemView;
@end
