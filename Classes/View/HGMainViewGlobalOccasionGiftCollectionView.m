//
//  HGMainViewGlobalOccasionGiftCollectionView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/20/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGMainViewGlobalOccasionGiftCollectionView.h"
#import "HGPageControl.h"
#import "HGGift.h"
#import "HGOccasionGiftCollection.h"
#import "HGTrackingService.h"
#import "HGMainViewGlobalOccasionGiftCollectionItemView.h"
#import <QuartzCore/QuartzCore.h>
#import "HGOccasionCategory.h"
#import "HGDefines.h"
#import "HappyGiftAppDelegate.h"

#define kMainViewGiftCollectionItemViewWidth 255.0
#define kMainViewGiftCollectionItemViewSpacing 10.0

@interface HGMainViewGlobalOccasionGiftCollectionView()
-(void)initSubViews;
@end

@implementation HGMainViewGlobalOccasionGiftCollectionView
@synthesize giftCollection;
@synthesize delegate;

- (void)awakeFromNib {
	[self initSubViews];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    [headActionButton addTarget:self action:@selector(handleHeadActionClick:) forControlEvents:UIControlEventTouchUpInside];
    [headActionButton addTarget:self action:@selector(handleHeadActionDown:) forControlEvents:UIControlEventTouchDown];
    [headActionButton addTarget:self action:@selector(handleHeadActionUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];    
}

- (void)dealloc{
    [headView release];
    [headLogoImageView release];
    [headBackgroundImageView release];
    [headTitleLabel release];
    [headActionButton release];
    [contentScrollView release];
    [pageControl release];
    [giftCollection release];
    [contentScrollSubViews release];
    [super dealloc];
}

+ (HGMainViewGlobalOccasionGiftCollectionView*)mainViewGlobalOccasionGiftCollectionView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewGlobalOccasionGiftCollectionView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];    
}

- (void)setGiftCollection:(HGOccasionGiftCollection *)theGiftCollection{
    if (giftCollection != theGiftCollection){
        [giftCollection release];
        giftCollection = [theGiftCollection retain];
        
        if (contentScrollSubViews == nil){
            contentScrollSubViews = [[NSMutableArray alloc] init];
        }else{
            for (UIView* subView in contentScrollSubViews){
                [subView removeFromSuperview];
            }
            [contentScrollSubViews removeAllObjects];
        }
        
        headTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        headTitleLabel.text = giftCollection.occasion.occasionCategory.name;
        
        if (giftCollection.occasion.occasionCategory.headerIcon) {
            headLogoImageView.image = [UIImage imageNamed:giftCollection.occasion.occasionCategory.headerIcon];
        }
        
        if (giftCollection.occasion.occasionCategory.headerBackground) {
            headBackgroundImageView.image = [UIImage imageNamed:giftCollection.occasion.occasionCategory.headerBackground];
        }
        
        if (giftCollection.giftSets != nil){
            if ([giftCollection.giftSets count] > 1){
                CGRect contentScrollViewFrame = contentScrollView.frame;
                contentScrollViewFrame.size.height = self.frame.size.height - contentScrollViewFrame.origin.y - 10.0;
                contentScrollView.frame = contentScrollViewFrame;
            }else{
                CGRect contentScrollViewFrame = contentScrollView.frame;
                contentScrollViewFrame.size.height = self.frame.size.height - contentScrollViewFrame.origin.y;
                contentScrollView.frame = contentScrollViewFrame;
            }
            
            CGFloat itemViewX = 2.0;
            CGFloat itemViewY = 5.0;
            CGFloat itemViewWidth = ([giftCollection.giftSets count] > 1)?kMainViewGiftCollectionItemViewWidth:contentScrollView.frame.size.width - itemViewX*2.0;
            CGFloat itemViewHeight = ([giftCollection.giftSets count] > 1)?contentScrollView.frame.size.height - 10.0:contentScrollView.frame.size.height - 8.0;
            
            int giftSetIndex = 0;
            for (HGGiftSet* giftSet in giftCollection.giftSets){
                HGMainViewGlobalOccasionGiftCollectionItemView* globalOccasionGiftCollectionItemView = [HGMainViewGlobalOccasionGiftCollectionItemView mainViewGlobalOccasionGiftCollectionItemView];
                CGRect globalOccasionGiftCollectionItemViewFrame = globalOccasionGiftCollectionItemView.frame;
                globalOccasionGiftCollectionItemViewFrame.origin.x = itemViewX;
                globalOccasionGiftCollectionItemViewFrame.origin.y = itemViewY;
                globalOccasionGiftCollectionItemViewFrame.size.width = itemViewWidth;
                globalOccasionGiftCollectionItemViewFrame.size.height = itemViewHeight;
                globalOccasionGiftCollectionItemView.frame = globalOccasionGiftCollectionItemViewFrame;
                
                [globalOccasionGiftCollectionItemView addTarget:self action:@selector(handleGlobalOccasionGiftCollectionItemView:) forControlEvents:UIControlEventTouchUpInside];
                
                [contentScrollView addSubview:globalOccasionGiftCollectionItemView];
                [contentScrollSubViews addObject:globalOccasionGiftCollectionItemView];
                
                globalOccasionGiftCollectionItemView.giftSet = giftSet;
                globalOccasionGiftCollectionItemView.tag = giftSetIndex;
                
                giftSetIndex += 1;
                itemViewX += globalOccasionGiftCollectionItemViewFrame.size.width;
                if (giftSet != [giftCollection.giftSets lastObject] && giftSetIndex < 5){
                    itemViewX += kMainViewGiftCollectionItemViewSpacing;
                }else{
                    itemViewX += contentScrollView.frame.size.width - itemViewWidth;
                }
                if (giftSetIndex == 5){
                    break;
                }
            }
            
            CGSize contentSize = contentScrollView.contentSize;
            contentSize.width = itemViewX;
            if (contentSize.width <= contentScrollView.frame.size.width){
                contentSize.width = contentScrollView.frame.size.width + 1.0;
            }
            contentSize.height = contentScrollView.frame.size.height;
            [contentScrollView setContentSize:contentSize];
            
            pageControl.numberOfPages = giftSetIndex;
            pageControl.currentPage = 0;
            if ([giftCollection.giftSets count] <= 1){
                pageControl.hidden = YES;
            }else{
                pageControl.hidden = NO;
            }
        }
    }
}

- (void)handleHeadActionClick:(id)sender{
    if ([delegate respondsToSelector:@selector(mainViewGlobalOccasionGiftCollectionView:didSelectGlobalOccasionGiftCollection:)]){
        [delegate mainViewGlobalOccasionGiftCollectionView:self didSelectGlobalOccasionGiftCollection:giftCollection];
    }
}

- (void)handleHeadActionDown:(id)sender{
    headBackgroundImageView.highlighted = YES;
}

- (void)handleHeadActionUp:(id)sender{
    headBackgroundImageView.highlighted = NO;
}

- (void)handleGlobalOccasionGiftCollectionItemView:(id)sender{
    HGMainViewGlobalOccasionGiftCollectionItemView* globalOccasionGiftCollectionItemView = (HGMainViewGlobalOccasionGiftCollectionItemView*)sender;
    
    [HGTrackingService logEvent:kTrackingEventSelectGlobalGiftOccasion withParameters:[NSDictionary dictionaryWithObjectsAndKeys:giftCollection.occasion.occasionCategory.name, @"occasion", [NSString stringWithFormat:@"%d", globalOccasionGiftCollectionItemView.tag], @"index", nil]];
    
    
    if ([delegate respondsToSelector:@selector(mainViewGlobalOccasionGiftCollectionView:didSelectGlobalOccasionGiftSet:)]){
        [delegate mainViewGlobalOccasionGiftCollectionView:self didSelectGlobalOccasionGiftSet:globalOccasionGiftCollectionItemView.giftSet];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    dragOffsetX = scrollView.contentOffset.x;
    dragOffsetInterval = [[NSDate date] timeIntervalSince1970];
    dragoffsetSpeed = 0;
    
    [HGTrackingService logEvent:kTrackingEventBrowseGlobalGiftOccasion withParameters:[NSDictionary dictionaryWithObjectsAndKeys:giftCollection.occasion.occasionCategory.name, @"occasion", nil]];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO) {
        CGFloat theDragOffsetX = scrollView.contentOffset.x;
        int theCurrentPage = floor((theDragOffsetX - (kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing) / 2) / (kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing)) + 1;
        if (theCurrentPage < pageControl.numberOfPages){
            if ((theCurrentPage*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing) - theDragOffsetX) < ((theCurrentPage + 1)*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing) - theDragOffsetX)){
                if (theDragOffsetX != theCurrentPage*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing)){
                    CGPoint contentOffsetX = scrollView.contentOffset;
                    contentOffsetX.x = theCurrentPage*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing);
                    [scrollView setContentOffset:contentOffsetX animated:YES];
                }
            }else{
                if (theDragOffsetX != (theCurrentPage + 1)*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing)){
                    CGPoint contentOffsetX = scrollView.contentOffset;
                    contentOffsetX.x = (theCurrentPage + 1)*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing);
                    [scrollView setContentOffset:contentOffsetX animated:YES];
                }
            }
        }else{
            if (theDragOffsetX != pageControl.numberOfPages*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing)){
                CGPoint contentOffsetX = scrollView.contentOffset;
                contentOffsetX.x = pageControl.numberOfPages*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing);
                [scrollView setContentOffset:contentOffsetX animated:YES];
            }
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (dragoffsetSpeed > 0){
        if (dragoffsetSpeed > 1500.0){
            if ((pageControl.numberOfPages - pageControl.currentPage) >= 3){
                CGPoint contentOffset = scrollView.contentOffset;
                [scrollView setContentOffset:contentOffset animated:NO];
                CGPoint contentOffsetX = scrollView.contentOffset;
                contentOffsetX.x = (pageControl.currentPage + 2)*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing);
                [scrollView setContentOffset:contentOffsetX animated:YES];
            }
        }else{
            if ((pageControl.numberOfPages - pageControl.currentPage) >= 2){
                CGPoint contentOffset = scrollView.contentOffset;
                [scrollView setContentOffset:contentOffset animated:NO];
                CGPoint contentOffsetX = scrollView.contentOffset;
                contentOffsetX.x = (pageControl.currentPage + 1)*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing);
                [scrollView setContentOffset:contentOffsetX animated:YES];
            }
        }
    }else{
        if (dragoffsetSpeed < -1500.0){
            if (pageControl.currentPage >= 2){
                CGPoint contentOffset = scrollView.contentOffset;
                [scrollView setContentOffset:contentOffset animated:NO];
                CGPoint contentOffsetX = scrollView.contentOffset;
                contentOffsetX.x = (pageControl.currentPage - 2)*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing);
                [scrollView setContentOffset:contentOffsetX animated:YES];
            }
        }else{
            if (pageControl.currentPage >= 1){
                CGPoint contentOffset = scrollView.contentOffset;
                [scrollView setContentOffset:contentOffset animated:NO];
                CGPoint contentOffsetX = scrollView.contentOffset;
                contentOffsetX.x = (pageControl.currentPage - 1)*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing);
                [scrollView setContentOffset:contentOffsetX animated:YES];
            }
        }
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    /*CGFloat theDragOffsetX = scrollView.contentOffset.x;
    int theCurrentPage = floor((theDragOffsetX - (kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing) / 2) / (kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing)) + 1;
    if (theCurrentPage < pageControl.numberOfPages){
        if ((theCurrentPage*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing) - theDragOffsetX) < ((theCurrentPage + 1)*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing) - theDragOffsetX)){
            if (theDragOffsetX != theCurrentPage*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing)){
                CGPoint contentOffsetX = scrollView.contentOffset;
                contentOffsetX.x = theCurrentPage*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing);
                [scrollView setContentOffset:contentOffsetX animated:YES];
            }
        }else{
            if (theDragOffsetX != (theCurrentPage + 1)*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing)){
                CGPoint contentOffsetX = scrollView.contentOffset;
                contentOffsetX.x = (theCurrentPage + 1)*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing);
                [scrollView setContentOffset:contentOffsetX animated:YES];
            }
        }
    }else{
        if (theDragOffsetX != pageControl.numberOfPages*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing)){
            CGPoint contentOffsetX = scrollView.contentOffset;
            contentOffsetX.x = pageControl.numberOfPages*(kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing);
            [scrollView setContentOffset:contentOffsetX animated:YES];
        }
    }*/
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat lastDragOffset = dragOffsetX;
    NSTimeInterval lastDragOffsetInterval = dragOffsetInterval;
    dragOffsetX = scrollView.contentOffset.x;
    dragOffsetInterval = [[NSDate date] timeIntervalSince1970];
    dragoffsetSpeed = (dragOffsetX - lastDragOffset)/(dragOffsetInterval - lastDragOffsetInterval);
    
    int currentPage = floor((dragOffsetX - (kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing) / 2) / (kMainViewGiftCollectionItemViewWidth + kMainViewGiftCollectionItemViewSpacing)) + 1;
    pageControl.currentPage = currentPage;
}

@end
