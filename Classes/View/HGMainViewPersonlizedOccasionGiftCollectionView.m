//
//  HGMainViewPersonlizedOccasionGiftCollectionView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/20/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGMainViewPersonlizedOccasionGiftCollectionView.h"
#import "HGPageControl.h"
#import "HGGift.h"
#import "HGGiftOccasion.h"
#import "HGOccasionGiftCollection.h"
#import "HGMainViewPersonlizedOccasionGiftCollectionItemView.h"
#import "HGGiftCollectionService.h"
#import "HGTrackingService.h"
#import <QuartzCore/QuartzCore.h>
#import "HGOccasionCategory.h"
#import "HappyGiftAppDelegate.h"

#define kMainViewGiftCollectionItemViewWidth 255.0
#define kMainViewGiftCollectionItemViewSpacing 10.0

@interface HGMainViewPersonlizedOccasionGiftCollectionView()
-(void)initSubViews;
@end

@implementation HGMainViewPersonlizedOccasionGiftCollectionView
@synthesize giftCollections;
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
    [headOverlayView release];
    [headLogoImageView release];
    [headTitleLabel release];
    [headActionButton release];
    [contentScrollView release];
    [pageControl release];
    [giftCollections release];
    [contentScrollSubViews release];
    [super dealloc];
}

+ (HGMainViewPersonlizedOccasionGiftCollectionView*)mainViewPersonlizedOccasionGiftCollectionView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewPersonlizedOccasionGiftCollectionView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];    
}

- (void)setGiftCollections:(NSArray *)theGiftCollections{
    if (giftCollections != theGiftCollections){
        [giftCollections release];
        giftCollections = [theGiftCollections retain];
        
        if (contentScrollSubViews == nil){
            contentScrollSubViews = [[NSMutableArray alloc] init];
        }else{
            for (UIView* subView in contentScrollSubViews){
                [subView removeFromSuperview];
            }
            [contentScrollSubViews removeAllObjects];
        }
        
        headTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
        headTitleLabel.textColor = [UIColor whiteColor];
        
        if (giftCollections != nil){
            HGOccasionGiftCollection* firstOccasionGiftCollection = [giftCollections objectAtIndex:0];
            
            headTitleLabel.text = firstOccasionGiftCollection.occasion.occasionCategory.name;
            if (firstOccasionGiftCollection.occasion.occasionCategory.headerIcon) {
                headLogoImageView.image = [UIImage imageNamed:firstOccasionGiftCollection.occasion.occasionCategory.headerIcon];
            }
            
            if (firstOccasionGiftCollection.occasion.occasionCategory.headerBackground) {
                headBackgroundImageView.image = [UIImage imageNamed:firstOccasionGiftCollection.occasion.occasionCategory.headerBackground];
            }
            
            if ([giftCollections count] > 1){
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
            CGFloat itemViewWidth = ([giftCollections count] > 1)?kMainViewGiftCollectionItemViewWidth:contentScrollView.frame.size.width - itemViewX*2.0;
            CGFloat itemViewHeight = ([giftCollections count] > 1)?contentScrollView.frame.size.height - 10.0:contentScrollView.frame.size.height - 8.0;
            
            int occasionGiftCollectionIndex = 0;
            for (HGOccasionGiftCollection* occasionGiftCollection in giftCollections) {
                HGMainViewPersonlizedOccasionGiftCollectionItemView* personalizedOccasionGiftCollectionItemView = [HGMainViewPersonlizedOccasionGiftCollectionItemView mainViewPersonlizedOccasionGiftCollectionItemView];
                CGRect personalizedOccasionGiftCollectionItemViewFrame = personalizedOccasionGiftCollectionItemView.frame;
                personalizedOccasionGiftCollectionItemViewFrame.origin.x = itemViewX;
                personalizedOccasionGiftCollectionItemViewFrame.origin.y = itemViewY;
                personalizedOccasionGiftCollectionItemViewFrame.size.width = itemViewWidth;
                personalizedOccasionGiftCollectionItemViewFrame.size.height = itemViewHeight;
                personalizedOccasionGiftCollectionItemView.frame = personalizedOccasionGiftCollectionItemViewFrame;
                
                [personalizedOccasionGiftCollectionItemView addTarget:self action:@selector(handlePersonlizedOccasionGiftCollectionItemView:) forControlEvents:UIControlEventTouchUpInside];
                
                [contentScrollView addSubview:personalizedOccasionGiftCollectionItemView];
                [contentScrollSubViews addObject:personalizedOccasionGiftCollectionItemView];
                
                personalizedOccasionGiftCollectionItemView.giftCollection = occasionGiftCollection;
                personalizedOccasionGiftCollectionItemView.tag = occasionGiftCollectionIndex;
                
                occasionGiftCollectionIndex += 1;
                itemViewX += personalizedOccasionGiftCollectionItemViewFrame.size.width;
                if (occasionGiftCollection != [giftCollections lastObject] && occasionGiftCollectionIndex < 5){
                    itemViewX += kMainViewGiftCollectionItemViewSpacing;
                }else{
                    itemViewX += contentScrollView.frame.size.width - itemViewWidth;
                }
                
                if (occasionGiftCollectionIndex == 5){
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
            
            pageControl.numberOfPages = occasionGiftCollectionIndex;
            pageControl.currentPage = 0;
            if ([giftCollections count] <= 1){
                pageControl.hidden = YES;
            }else{
                pageControl.hidden = NO;
            }
        }
    }
}

- (void)handleHeadActionClick:(id)sender{
    if ([delegate respondsToSelector:@selector(mainViewPersonlizedOccasionGiftCollectionView:didSelectGiftOccasions:)]){
        [delegate mainViewPersonlizedOccasionGiftCollectionView:self didSelectGiftOccasions:giftCollections];
    }
}

- (void)handleHeadActionDown:(id)sender{
    headOverlayView.hidden = NO;
}

- (void)handleHeadActionUp:(id)sender{
    headOverlayView.hidden = YES;
}

- (void)handlePersonlizedOccasionGiftCollectionItemView:(id)sender{
    HGMainViewPersonlizedOccasionGiftCollectionItemView* personalizedOccasionGiftCollectionItemView = (HGMainViewPersonlizedOccasionGiftCollectionItemView*)sender;
    
    HGOccasionGiftCollection* firstOccasionGiftCollection = [giftCollections objectAtIndex:0];
    [HGTrackingService logEvent:kTrackingEventSelectPersonalGiftOccasion withParameters:[NSDictionary dictionaryWithObjectsAndKeys:firstOccasionGiftCollection.occasion.occasionCategory.name, @"occasion", [NSString stringWithFormat:@"%d", personalizedOccasionGiftCollectionItemView.tag], @"index", nil]];
    
    
    if ([delegate respondsToSelector:@selector(mainViewPersonlizedOccasionGiftCollectionView:didSelectPersonlizedOccasionGiftCollection:)]){
        [delegate mainViewPersonlizedOccasionGiftCollectionView:self didSelectPersonlizedOccasionGiftCollection:personalizedOccasionGiftCollectionItemView.giftCollection];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    dragOffsetX = scrollView.contentOffset.x;
    dragOffsetInterval = [[NSDate date] timeIntervalSince1970];
    dragoffsetSpeed = 0;
    
    HGOccasionGiftCollection* firstOccasionGiftCollection = [giftCollections objectAtIndex:0];
    [HGTrackingService logEvent:kTrackingEventBrowsePersonalGiftOccasion withParameters:[NSDictionary dictionaryWithObjectsAndKeys:firstOccasionGiftCollection.occasion.occasionCategory.name, @"occasion", nil]];
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
