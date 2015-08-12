//
//  HGProgressView.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/17/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGDragToUpdateView.h"

@protocol HGProgressViewDelegate;

@interface HGDragToUpdateTableView: UITableView{
@private    
    HGDragToUpdateView*               topDragToUpdateView;
    HGDragToUpdateView*               bottomDragToUpdateView;
    CGFloat dragOffsetY;
    id<HGProgressViewDelegate> dragToUpdateDelegate;
}
@property (nonatomic, assign) id<HGProgressViewDelegate> dragToUpdateDelegate;
@property (nonatomic, readonly) CGFloat topDragToUpdateViewHeight;
@property (nonatomic, assign) int  topDragToUpdateCheckCount;
@property (nonatomic, assign) BOOL topDragToUpdateRunning;
@property (nonatomic, assign) BOOL bottomDragToUpdateRunning;
@property (nonatomic, assign) BOOL topDragToUpdateVisbile;
@property (nonatomic, assign) BOOL bottomDragToUpdateVisbile;
@property (nonatomic, retain) NSDate* topDragToUpdateDate;
@property (nonatomic, retain) NSDate* bottomDragToUpdateDate;

- (void)handleScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)handleScrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)handleScrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
- (void)handleTopDragUpdateFinished;
- (void)handleBottomDragUpdateFinished;
- (void)performTopDragUpdate;
-(void)setShowTopUpdateDateLabel:(BOOL)showTopUpdateDateLabel;
-(void)setShowBottomUpdateDateLabel:(BOOL)showBottomUpdateDateLabel;
@end

@protocol HGProgressViewDelegate<NSObject>
- (void)dragToUpdateTableView:(HGDragToUpdateTableView *)dragToUpdateTableView didRequestTopUpdate:(HGDragToUpdateView *)topDragToUpdateView;
- (void)dragToUpdateTableView:(HGDragToUpdateTableView *)dragToUpdateTableView didRequestBottomUpdate:(HGDragToUpdateView *)bottomDragToUpdateView;
@end
