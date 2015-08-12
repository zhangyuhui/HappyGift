//
//  HGGiftsSelectionViewAssistantQuestionView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftAssistantQuestion;
@class HGGiftAssistantOption;
@protocol HGGiftsSelectionViewAssistantQuestionViewDelegate;

@interface HGGiftsSelectionViewAssistantQuestionView : UIView{
    IBOutlet UILabel*     titleLabel;
    IBOutlet UIScrollView* optionsScrollView;
    
    HGGiftAssistantQuestion* giftAssistantQuestion;
    NSMutableArray* optionViews;
    id<HGGiftsSelectionViewAssistantQuestionViewDelegate> delegate;
}
@property (nonatomic, retain) UIScrollView* optionsScrollView;
@property (nonatomic, retain) HGGiftAssistantQuestion* giftAssistantQuestion;
@property (nonatomic, assign) id<HGGiftsSelectionViewAssistantQuestionViewDelegate> delegate;

+ (HGGiftsSelectionViewAssistantQuestionView*)giftsSelectionViewAssistantQuestionView;
@end


@protocol HGGiftsSelectionViewAssistantQuestionViewDelegate<NSObject>
- (void)giftsSelectionViewAssistantQuestionView:(HGGiftsSelectionViewAssistantQuestionView *)giftsSelectionViewAssistantQuestionView didSelecteGiftAssistantOption:(HGGiftAssistantOption*)giftAssistantOption;
@end
