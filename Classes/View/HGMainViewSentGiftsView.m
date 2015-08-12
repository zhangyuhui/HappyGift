//
//  HGMainViewSentGiftsView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/20/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGMainViewSentGiftsView.h"
#import "HGPageControl.h"
#import "HGGift.h"
#import "HGGiftOrder.h"
#import "HGMainViewSentGiftsItemView.h"
#import <QuartzCore/QuartzCore.h>
#import "HappyGiftAppDelegate.h"

#define kMainViewGiftCollectionItemViewWidth 255.0
#define kMainViewGiftCollectionItemViewSpacing 10.0

@interface HGMainViewSentGiftsView()
-(void)initSubViews;
@end

@implementation HGMainViewSentGiftsView
@synthesize giftOrders;
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
    [giftOrders release];
    [contentScrollSubViews release];
    [super dealloc];
}

+ (HGMainViewSentGiftsView*)mainViewSentGiftsView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewSentGiftsView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];    
}

- (void)setGiftOrders:(NSArray *)theGiftOrders{
    if (giftOrders != theGiftOrders){
        [giftOrders release];
        giftOrders = [theGiftOrders retain];
        
        if (contentScrollSubViews == nil){
            contentScrollSubViews = [[NSMutableArray alloc] init];
        }else{
            for (UIView* subView in contentScrollSubViews){
                [subView removeFromSuperview];
            }
            [contentScrollSubViews removeAllObjects];
        }
        
        headTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        headTitleLabel.text = @"已送出的礼物";
        
        if (giftOrders != nil){
            if ([giftOrders count] > 1){
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
            CGFloat itemViewWidth = ([giftOrders count] > 1)?kMainViewGiftCollectionItemViewWidth:contentScrollView.frame.size.width - itemViewX*2.0;
            CGFloat itemViewHeight = ([giftOrders count] > 1)?contentScrollView.frame.size.height - 10.0:contentScrollView.frame.size.height - 8.0;
            
            int giftSetIndex = 0;
            for (HGGiftOrder* giftOrder in giftOrders){
                HGMainViewSentGiftsItemView* mainViewSentGiftsItemView = [HGMainViewSentGiftsItemView mainViewSentGiftsItemView];
                CGRect mainViewSentGiftsItemViewFrame = mainViewSentGiftsItemView.frame;
                mainViewSentGiftsItemViewFrame.origin.x = itemViewX;
                mainViewSentGiftsItemViewFrame.origin.y = itemViewY;
                mainViewSentGiftsItemViewFrame.size.width = itemViewWidth;
                mainViewSentGiftsItemViewFrame.size.height = itemViewHeight;
                mainViewSentGiftsItemView.frame = mainViewSentGiftsItemViewFrame;
                
                [mainViewSentGiftsItemView addTarget:self action:@selector(handleFeaturedGiftCollectionItemViewAction:) forControlEvents:UIControlEventTouchUpInside];
                
                [contentScrollView addSubview:mainViewSentGiftsItemView];
                [contentScrollSubViews addObject:mainViewSentGiftsItemView];
                
                mainViewSentGiftsItemView.giftOrder = giftOrder;
                
                giftSetIndex += 1;
                itemViewX += mainViewSentGiftsItemViewFrame.size.width;
                if (giftOrder != [giftOrders lastObject] && giftSetIndex < 5){
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
            if ([giftOrders count] <= 1){
                pageControl.hidden = YES;
            }else{
                pageControl.hidden = NO;
            }
        }
    }
}

- (void)handleHeadActionClick:(id)sender{
    if ([delegate respondsToSelector:@selector(mainViewSentGiftsView:didSelectSentGiftOrders:)]){
        [delegate mainViewSentGiftsView:self didSelectSentGiftOrders:giftOrders];
    }
}

- (void)handleHeadActionDown:(id)sender{
    headBackgroundImageView.highlighted = YES;
}

- (void)handleHeadActionUp:(id)sender{
    headBackgroundImageView.highlighted = NO;
}

- (void)handleFeaturedGiftCollectionItemViewAction:(id)sender{
    HGMainViewSentGiftsItemView* mainViewSentGiftsItemView = (HGMainViewSentGiftsItemView*)sender;
    if ([delegate respondsToSelector:@selector(mainViewSentGiftsView:didSelectSentGiftOrder:)]){
        [delegate mainViewSentGiftsView:self didSelectSentGiftOrder:mainViewSentGiftsItemView.giftOrder];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    dragOffsetX = scrollView.contentOffset.x;
    dragOffsetInterval = [[NSDate date] timeIntervalSince1970];
    dragoffsetSpeed = 0;
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
