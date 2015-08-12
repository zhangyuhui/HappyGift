//
//  HGPopoverView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/20/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HGPopoverViewDelegate;

@interface HGPopoverView : UIView {
    IBOutlet UIView*        contentView;
    IBOutlet UITableView*   contentTabView;;
    
    NSArray*           items;
    UILabel*           budyLabel;
    
    id<HGPopoverViewDelegate> delegate;
}
@property (nonatomic, retain) NSArray* items;
@property (nonatomic, retain) UILabel* budyLabel;
@property (nonatomic, assign) id<HGPopoverViewDelegate> delegate;

- (void)performShow:(UIView*)view atPoint:(CGPoint)point;
- (void)performHide;

+ (HGPopoverView*)popoverView;
@end


@protocol HGPopoverViewDelegate <NSObject>
- (void)popoverView:(HGPopoverView *)popoverView didSelectItem:(NSString*)text;
- (void)popoverView:(HGPopoverView *)popoverView didRejectItem:(NSInteger)index;
@end