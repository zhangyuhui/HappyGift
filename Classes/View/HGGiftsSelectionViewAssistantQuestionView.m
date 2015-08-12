//
//  HGGiftsSelectionViewAssistantQuestionView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftsSelectionViewAssistantQuestionView.h"
#import "HappyGiftAppDelegate.h"
#import "HGGiftAssistantQuestion.h"
#import "HGGiftAssistantOption.h"
#import "HGGiftsSelectionViewAssistantOptionView.h"

@interface HGGiftsSelectionViewAssistantQuestionView()
-(void)initSubViews;
@end


@implementation HGGiftsSelectionViewAssistantQuestionView
@synthesize giftAssistantQuestion;
@synthesize delegate;
@synthesize optionsScrollView;

-(id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
		[self initSubViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    
}

- (void)dealloc{
    [titleLabel release];
    [optionsScrollView release];
    [optionViews release];
    [super dealloc];
}

- (void)setGiftAssistantQuestion:(HGGiftAssistantQuestion *)theGiftAssistantQuestion{
    if (giftAssistantQuestion != theGiftAssistantQuestion){
        [giftAssistantQuestion release];
        giftAssistantQuestion = [theGiftAssistantQuestion retain];
        
        if (optionViews == nil){
            optionViews = [[NSMutableArray alloc] init];
        }else{
            for (UIView* subView in optionViews) {
                [subView removeFromSuperview];
            }
            [optionViews removeAllObjects];
        }
        
        if (giftAssistantQuestion != nil){
            titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
            titleLabel.text = giftAssistantQuestion.name;
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.numberOfLines = 0;
            
            CGSize titleLabelSize = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabel.frame.size.width, 100.0) lineBreakMode:UILineBreakModeClip];
            CGRect titleLabelFrame = titleLabel.frame;
            titleLabelFrame.origin.y = (48.0 - titleLabelSize.height)/2.0;
            titleLabelFrame.size.height = titleLabelSize.height;
            titleLabel.frame = titleLabelFrame;
            
            CGFloat viewX = 5.0;
            CGFloat viewY = 0.0;
            for (HGGiftAssistantOption* giftAssistantQption in giftAssistantQuestion.options){
                HGGiftsSelectionViewAssistantOptionView* giftsSelectionViewAssistantOptionView = [HGGiftsSelectionViewAssistantOptionView giftsSelectionViewAssistantOptionView];
                CGRect viewFrame = giftsSelectionViewAssistantOptionView.frame;
                viewFrame.origin.x = viewX;
                viewFrame.origin.y = viewY;
                giftsSelectionViewAssistantOptionView.frame = viewFrame;
                
                [giftsSelectionViewAssistantOptionView addTarget:self action:@selector(handlegiftsSelectionViewAssistantOptionViewAction:) forControlEvents:UIControlEventTouchUpInside];
                
                [optionsScrollView addSubview:giftsSelectionViewAssistantOptionView];
                [optionViews addObject:giftsSelectionViewAssistantOptionView];
                
                giftsSelectionViewAssistantOptionView.giftAssistantOption = giftAssistantQption;
                giftsSelectionViewAssistantOptionView.selected = giftAssistantQption.selected;
                
                if (viewX == 5.0){
                    viewX += 0.0 + giftsSelectionViewAssistantOptionView.frame.size.width;
                    if (giftAssistantQption == [giftAssistantQuestion.options lastObject]){
                        viewY += viewFrame.size.height;
                    }
                }else{
                    viewX = 5.0;
                    viewY += viewFrame.size.height;
                    if (giftAssistantQption != [giftAssistantQuestion.options lastObject]){
                    }
                }
            }
            
            viewY += 0.0;
            
            CGSize contentSize = optionsScrollView.contentSize;
            contentSize.width = optionsScrollView.frame.size.width;
            if (viewY <= optionsScrollView.frame.size.height){
                viewY = optionsScrollView.frame.size.height + 1.0;
            }
            contentSize.height = viewY;
            [optionsScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
            [optionsScrollView setContentSize:contentSize];
        }
    }
}

+ (HGGiftsSelectionViewAssistantQuestionView*)giftsSelectionViewAssistantQuestionView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGGiftsSelectionViewAssistantQuestionView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}

- (void)handlegiftsSelectionViewAssistantOptionViewAction:(id)sender{
    HGGiftsSelectionViewAssistantOptionView* giftsSelectionViewAssistantOptionView = (HGGiftsSelectionViewAssistantOptionView*)sender;
    for (HGGiftsSelectionViewAssistantOptionView* theGiftsSelectionViewAssistantOptionView in optionViews) {
        if (theGiftsSelectionViewAssistantOptionView == giftsSelectionViewAssistantOptionView){
            theGiftsSelectionViewAssistantOptionView.selected = YES;
            theGiftsSelectionViewAssistantOptionView.giftAssistantOption.selected = YES;
        }else{
            theGiftsSelectionViewAssistantOptionView.selected = NO;
            theGiftsSelectionViewAssistantOptionView.giftAssistantOption.selected = NO;
        }
    }
    if ([delegate respondsToSelector:@selector(giftsSelectionViewAssistantQuestionView:didSelecteGiftAssistantOption:)]){
        [delegate giftsSelectionViewAssistantQuestionView:self didSelecteGiftAssistantOption:giftsSelectionViewAssistantOptionView.giftAssistantOption];
    }
}

@end
