//
//  HGProgressView.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/17/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//
#import "HGDragToUpdateTableView.h"
#import <QuartzCore/QuartzCore.h>

#define kTopicViewControllerDragToChangeOffsetMax 70.0

@interface HGDragToUpdateTableView () 
-(void)initSubViews;
@end

@implementation HGDragToUpdateTableView
@synthesize dragToUpdateDelegate;
@synthesize topDragToUpdateRunning;
@synthesize bottomDragToUpdateRunning;
@synthesize topDragToUpdateViewHeight;
@synthesize topDragToUpdateDate;
@synthesize bottomDragToUpdateDate;
@synthesize topDragToUpdateCheckCount;
@synthesize topDragToUpdateVisbile;
@synthesize bottomDragToUpdateVisbile;

- (void) dealloc {
    [topDragToUpdateView release];
    [bottomDragToUpdateView release];
	[super dealloc];
}

#pragma mark View Controller

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
    topDragToUpdateView = [[HGDragToUpdateView dragToUpdateView] retain];
    CGRect topDragToUpdateViewFrame = topDragToUpdateView.frame;
    topDragToUpdateViewFrame.origin.x = 0.0;
    topDragToUpdateViewFrame.origin.y = -topDragToUpdateViewFrame.size.height;
    topDragToUpdateView.frame = topDragToUpdateViewFrame;
    topDragToUpdateView.arrow = HG_DRAG_TO_UPDATE_ARROW_DOWN;
    [self addSubview:topDragToUpdateView];
    
    bottomDragToUpdateView = [[HGDragToUpdateView dragToUpdateView] retain];
    CGRect bottomDragToUpdateViewFrame = bottomDragToUpdateView.frame;
    bottomDragToUpdateViewFrame.origin.x = 0.0;
    bottomDragToUpdateViewFrame.origin.y = self.frame.size.height;
    bottomDragToUpdateView.frame = bottomDragToUpdateViewFrame;
    bottomDragToUpdateView.arrow = HG_DRAG_TO_UPDATE_ARROW_UP;
    [self addSubview:bottomDragToUpdateView];
}

-(void)setShowTopUpdateDateLabel:(BOOL)showTopUpdateDateLabel {
    topDragToUpdateView.showUpdateDateLabel = showTopUpdateDateLabel;
}

-(void)setShowBottomUpdateDateLabel:(BOOL)showBottomUpdateDateLabel {
    bottomDragToUpdateView.showUpdateDateLabel = showBottomUpdateDateLabel;
}

- (void)setContentSize:(CGSize)contentSize{
    [super setContentSize:contentSize];
    if (self.tableFooterView == nil){
        CGRect bottomDragToUpdateViewFrame = bottomDragToUpdateView.frame; 
        if (contentSize.height >= self.frame.size.height){
            bottomDragToUpdateViewFrame.origin.y = contentSize.height;
        }else{
            bottomDragToUpdateViewFrame.origin.y = self.frame.size.height;
        }
        bottomDragToUpdateView.frame = bottomDragToUpdateViewFrame;
    }
}

- (void)setTableHeaderView:(UIView *)tableHeaderView{
    [super setTableHeaderView:tableHeaderView];
    if (tableHeaderView == nil){
        CGRect topDragToUpdateViewFrame = topDragToUpdateView.frame;
        topDragToUpdateViewFrame.origin.x = 0.0;
        topDragToUpdateViewFrame.origin.y = -topDragToUpdateViewFrame.size.height;
        topDragToUpdateView.frame = topDragToUpdateViewFrame;
        topDragToUpdateView.arrow = HG_DRAG_TO_UPDATE_ARROW_DOWN;
        [self addSubview:topDragToUpdateView];
    }
}

- (void)setTableFooterView:(UIView *)tableFooterView{
    [super setTableFooterView:tableFooterView];
    if (tableFooterView == nil){
        CGRect bottomDragToUpdateViewFrame = bottomDragToUpdateView.frame; 
        if (self.contentSize.height >= self.frame.size.height){
            bottomDragToUpdateViewFrame.origin.y = self.contentSize.height;
        }else{
            bottomDragToUpdateViewFrame.origin.y = self.frame.size.height;
        }
        bottomDragToUpdateView.frame = bottomDragToUpdateViewFrame;
        bottomDragToUpdateView.arrow = HG_DRAG_TO_UPDATE_ARROW_UP;
        [self addSubview:bottomDragToUpdateView];
    }
}

- (CGFloat)topDragToUpdateViewHeight{
    return topDragToUpdateView.frame.size.height;
}

- (void)setTopDragToUpdateDate:(NSDate *)theTopDragToUpdateDate{
    topDragToUpdateView.updateDate = theTopDragToUpdateDate;
}

- (void)setBottomDragToUpdateDate:(NSDate *)theBottomDragToUpdateDate{
    bottomDragToUpdateView.updateDate = theBottomDragToUpdateDate;
}

- (void)reloadData{
    [super reloadData];
}

- (void)performTopDragUpdate{
    if (topDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE||
        topDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_FINISH){
        return;
    }
    [self setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    topDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE;
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:(UIViewAnimationCurveEaseOut) 
                     animations:^{
                         [self setContentOffset:CGPointMake(0.0, -topDragToUpdateView.frame.size.height) animated:NO];
                     } 
                     completion:^(BOOL finished) {
                         self.tableHeaderView = topDragToUpdateView;
                         [self setContentOffset:CGPointMake(0.0,0.0) animated:NO];
                         if ([dragToUpdateDelegate respondsToSelector:@selector(dragToUpdateTableView:didRequestTopUpdate:)]){
                             [dragToUpdateDelegate dragToUpdateTableView:self didRequestTopUpdate:topDragToUpdateView];
                         }
                     }];
}

- (void)setTopDragToUpdateRunning:(BOOL)theTopDragToUpdateRunning{
    if (theTopDragToUpdateRunning == YES){
        if (topDragToUpdateView.status != HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE){
            topDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE;
            CGPoint contentOffset = self.contentOffset;
            self.tableHeaderView = topDragToUpdateView;
            if ([self.dataSource tableView:self numberOfRowsInSection:0] > 0){
                contentOffset.y = topDragToUpdateView.frame.size.height;
                [self setContentOffset:contentOffset animated:NO];
            }
        }
    }else{
        if (topDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE){
            topDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
            CGPoint contentOffset = self.contentOffset;
            contentOffset.y = 0;
            self.tableHeaderView = nil;
            [self setContentOffset:contentOffset animated:NO];
        }
    }
}

- (BOOL)topDragToUpdateRunning{
    return (topDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE);
}

- (void)setBottomDragToUpdateRunning:(BOOL)theBottomDragToUpdateRunning{
    if (theBottomDragToUpdateRunning == YES){
        if (bottomDragToUpdateView.status != HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE){
            bottomDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE;
            if (self.contentSize.height >= self.frame.size.height){
                self.tableFooterView = bottomDragToUpdateView;
            }else{
                UIView* theTableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height - self.contentSize.height + bottomDragToUpdateView.frame.size.height)];
                theTableFooterView.backgroundColor = [UIColor clearColor];
                CGRect bottomDragToUpdateViewFrame = bottomDragToUpdateView.frame;
                bottomDragToUpdateViewFrame.origin.y = self.frame.size.height - self.contentSize.height;
                bottomDragToUpdateView.frame = bottomDragToUpdateViewFrame;
                [theTableFooterView addSubview:bottomDragToUpdateView];
                self.tableFooterView = theTableFooterView;
                [theTableFooterView release];
            }
        }
    }else{
        if (bottomDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE){
            bottomDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
            self.tableFooterView = nil;
        }
    }   
}

- (BOOL)bottomDragToUpdateRunning{
    return (bottomDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE);
}

- (void)setTopDragToUpdateCheckCount:(int)theTopDragToUpdateCheckCount{
    topDragToUpdateView.checkCount = theTopDragToUpdateCheckCount;
}

- (int)topDragToUpdateCheckCount{
    return topDragToUpdateView.checkCount;
}

- (void)setTopDragToUpdateVisbile:(BOOL)theTopDragToUpdateVisbile{
    topDragToUpdateView.hidden = (theTopDragToUpdateVisbile == NO);
    topDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
}

- (BOOL)topDragToUpdateVisbile{
    return (topDragToUpdateView.hidden == NO);
}

- (void)setBottomDragToUpdateVisbile:(BOOL)theBottomDragToUpdateVisbile{
    if (bottomDragToUpdateView.hidden == theBottomDragToUpdateVisbile){
        bottomDragToUpdateView.hidden = (theBottomDragToUpdateVisbile == NO);
        if (bottomDragToUpdateView.hidden == YES){
            self.tableFooterView = nil;
            CGSize theContentSize = self.contentSize;
            theContentSize.height = bottomDragToUpdateView.frame.origin.y;
            [self setContentSize:theContentSize];
            bottomDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
        }
    }
}

- (BOOL)bottomDragToUpdateVisbile{
    return (bottomDragToUpdateView.hidden == NO);
}

#pragma mark - UIScrollViewDelegate
- (void)handleScrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat currentScrollViewOffsetY = scrollView.contentOffset.y;  
    if (currentScrollViewOffsetY > dragOffsetY){
        if (currentScrollViewOffsetY > 0){
            if (self.bottomDragToUpdateVisbile){
                if (scrollView.contentSize.height >= scrollView.frame.size.height){
                    CGFloat extendOffsetY = currentScrollViewOffsetY + scrollView.frame.size.height - scrollView.contentSize.height;
                    if (extendOffsetY >= kTopicViewControllerDragToChangeOffsetMax){
                        if (bottomDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG){
                            bottomDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_UPDATE;
                        }
                    }
                }else{
                    CGFloat extendOffsetY = currentScrollViewOffsetY;
                    if (extendOffsetY >= kTopicViewControllerDragToChangeOffsetMax){
                        if (bottomDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG){
                            bottomDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_UPDATE;
                        }
                    }
                }
            }
        }else{
            if (self.topDragToUpdateVisbile){
                if (topDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_UPDATE){
                    topDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
                }
            }
        }
    }else if (currentScrollViewOffsetY < dragOffsetY){
        CGFloat extendOffsetY = -currentScrollViewOffsetY;
        if (extendOffsetY >= kTopicViewControllerDragToChangeOffsetMax){
            if (self.topDragToUpdateVisbile){
                if (topDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG){
                    topDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_UPDATE;
                }
            }
        }else{
            if (currentScrollViewOffsetY + scrollView.frame.size.height - scrollView.contentSize.height < kTopicViewControllerDragToChangeOffsetMax && 
                self.bottomDragToUpdateVisbile){
                if (bottomDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_UPDATE){
                    bottomDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
                }
            }
        }
    }
    dragOffsetY = currentScrollViewOffsetY;
}

- (void)handleScrollViewWillBeginDragging:(UIScrollView *)scrollView{
    dragOffsetY = scrollView.contentOffset.y;
}

- (void)handleScrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (bottomDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE ||
        topDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE){
        return;
    }
    if (bottomDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_UPDATE){
        bottomDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE;
        
        CGPoint contentOffset = scrollView.contentOffset;
        [scrollView setContentOffset:contentOffset animated:NO];
        
        CGFloat contentOffsetBottomY;
        if (scrollView.contentSize.height >= scrollView.frame.size.height){
            contentOffsetBottomY = scrollView.contentSize.height - scrollView.frame.size.height;
        }else{
            contentOffsetBottomY = 0.0;
        }
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:(UIViewAnimationCurveEaseOut) 
                         animations:^{
                             [self setContentOffset:CGPointMake(0.0, contentOffsetBottomY + bottomDragToUpdateView.frame.size.height) animated:NO];
                         } 
                         completion:^(BOOL finished) {
                             if (scrollView.contentSize.height >= scrollView.frame.size.height){
                                 self.tableFooterView = bottomDragToUpdateView;
                                 [scrollView setContentOffset:CGPointMake(0.0, contentOffsetBottomY + bottomDragToUpdateView.frame.size.height) animated:NO];
                             }else{
                                 UIView* theTableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, scrollView.frame.size.height - scrollView.contentSize.height + bottomDragToUpdateView.frame.size.height)];
                                 theTableFooterView.backgroundColor = [UIColor clearColor];
                                 CGRect bottomDragToUpdateViewFrame = bottomDragToUpdateView.frame;
                                 bottomDragToUpdateViewFrame.origin.y = scrollView.frame.size.height - scrollView.contentSize.height;
                                 bottomDragToUpdateView.frame = bottomDragToUpdateViewFrame;
                                 [theTableFooterView addSubview:bottomDragToUpdateView];
                                 
                                 self.tableFooterView = theTableFooterView;
                                 [theTableFooterView release];
                                 [scrollView setContentOffset:CGPointMake(0.0, bottomDragToUpdateView.frame.size.height) animated:NO];
                             }
                             if ([dragToUpdateDelegate respondsToSelector:@selector(dragToUpdateTableView:didRequestBottomUpdate:)]){
                                 [dragToUpdateDelegate dragToUpdateTableView:self didRequestBottomUpdate:bottomDragToUpdateView];
                             }
                         }];
        
        
    }else if (topDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_UPDATE){
        topDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE;
        
        CGPoint contentOffset = scrollView.contentOffset;
        [scrollView setContentOffset:contentOffset animated:NO];
        
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:(UIViewAnimationCurveEaseOut) 
                         animations:^{
                             [self setContentOffset:CGPointMake(0.0, -topDragToUpdateView.frame.size.height) animated:NO];
                         } 
                         completion:^(BOOL finished) {
                             self.tableHeaderView = topDragToUpdateView;
                             [scrollView setContentOffset:CGPointMake(0.0,0.0) animated:NO];
                             if ([dragToUpdateDelegate respondsToSelector:@selector(dragToUpdateTableView:didRequestTopUpdate:)]){
                                 [dragToUpdateDelegate dragToUpdateTableView:self didRequestTopUpdate:topDragToUpdateView];
                             }
                         }];
    }
    
    if (topDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE){
        return;
    }
    if (topDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_UPDATE){
        topDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE;
        
        CGPoint contentOffset = scrollView.contentOffset;
        [scrollView setContentOffset:contentOffset animated:NO];
        
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:(UIViewAnimationCurveEaseOut) 
                         animations:^{
                             [self setContentOffset:CGPointMake(0.0, -topDragToUpdateView.frame.size.height) animated:NO];
                         } 
                         completion:^(BOOL finished) {
                             self.tableHeaderView = topDragToUpdateView;
                             [scrollView setContentOffset:CGPointMake(0.0,0.0) animated:NO];
                             if ([dragToUpdateDelegate respondsToSelector:@selector(dragToUpdateTableView:didRequestTopUpdate:)]){
                                 [dragToUpdateDelegate dragToUpdateTableView:self didRequestTopUpdate:topDragToUpdateView];
                             }
                         }];
    }
}

- (void)handleTopDragUpdateFinished{
    if (topDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE){
        CGPoint contentOffset = self.contentOffset;
        if (contentOffset.y <= topDragToUpdateView.frame.size.height){
            [UIView animateWithDuration:0.3 
                                  delay:0.0 
                                options:(UIViewAnimationCurveEaseOut) 
                             animations:^{
                                 [self setContentOffset:CGPointMake(0.0, topDragToUpdateView.frame.size.height) animated:NO];
                             } 
                             completion:^(BOOL finished) {
                                 topDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
                                 self.tableHeaderView = nil;
                                 [self setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
                             }];
        }else{
            topDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
            contentOffset.y -= topDragToUpdateView.frame.size.height;
            self.tableHeaderView = nil;
            [self setContentOffset:contentOffset animated:NO];
        }
    }
}

- (void)handleBottomDragUpdateFinished{
    if (bottomDragToUpdateView.status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE){
        CGPoint contentOffset = self.contentOffset;
        
        if ([self.tableFooterView isKindOfClass:[HGDragToUpdateView class]]){
            if (self.contentSize.height - contentOffset.y - self.frame.size.height < bottomDragToUpdateView.frame.size.height){
                [UIView animateWithDuration:0.3 
                                      delay:0.0 
                                    options:(UIViewAnimationCurveEaseOut) 
                                 animations:^{
                                     [self setContentOffset:CGPointMake(0.0, self.contentSize.height - self.frame.size.height - bottomDragToUpdateView.frame.size.height) animated:NO];
                                 } 
                                 completion:^(BOOL finished) {
                                     bottomDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
                                     self.tableFooterView = nil;
                                 }];
            }else{
                bottomDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
                self.tableFooterView = nil;
            }
        }else{
            if (self.contentSize.height - contentOffset.y - self.frame.size.height < bottomDragToUpdateView.frame.size.height){
                [UIView animateWithDuration:0.3 
                                      delay:0.0 
                                    options:(UIViewAnimationCurveEaseOut) 
                                 animations:^{
                                     [self setContentOffset:CGPointMake(0.0, self.contentSize.height - self.frame.size.height - bottomDragToUpdateView.frame.size.height) animated:NO];
                                 } 
                                 completion:^(BOOL finished) {
                                     bottomDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
                                     self.tableFooterView = nil;
                                 }];
            }else{
                bottomDragToUpdateView.status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
                self.tableFooterView = nil;
            }
        }
    }
}

@end
