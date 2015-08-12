//
//  HGDragToUpdateView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 8/16/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGDragToUpdateView.h"
#import "HGProgressView.h"
#import "NSDate+Addition.h"
#import "NSString+Addition.h"
#import "HappyGiftAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define kDragToUpdateViewLabelMarginY     5.0
#define kDragToUpdateViewArrowMarginY     5.0
#define kDragToUpdateViewProgressMarginY  7.0

@interface HGDragToUpdateView(private)
-(void)initSubViews;
@end

@implementation HGDragToUpdateView
@synthesize status;
@synthesize arrow;
@synthesize updateDate;
@synthesize checkCount;
@synthesize showUpdateDateLabel;

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
    status = HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG;
    arrow = HG_DRAG_TO_UPDATE_ARROW_NONE;
    
    instructionLabel.text = @"拖动可以更新";
    instructionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    instructionLabel.textColor = [UIColor darkGrayColor];
    
    updateDateLabel.text = @"最近无更新";
    updateDateLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    updateDateLabel.textColor = [UIColor darkGrayColor];
    
    self.autoresizesSubviews = NO;
}

- (void)dealloc{
    [arrowImageView release];
    [instructionLabel release];
    [updateDateLabel release];
    [indicatorView release];
    [updateDate release];
    [super dealloc];
}

- (void)setShowUpdateDateLabel:(BOOL)theShowUpdateDateLabel {
    showUpdateDateLabel = theShowUpdateDateLabel;
    if (showUpdateDateLabel) {
        updateDateLabel.hidden = NO;
        CGRect frame = instructionLabel.frame;
        frame.origin.y = kDragToUpdateViewArrowMarginY;
        instructionLabel.frame = frame;
    } else {
        updateDateLabel.hidden = YES;
        CGRect frame = instructionLabel.frame;
        frame.origin.y = (self.frame.size.height - frame.size.height) / 2.0;
        instructionLabel.frame = frame;
    }
}

- (void)setStatus:(HGDragToUpdateStatus)theStatus{
    if (status != theStatus){
        status = theStatus;
        if (status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_UPDATE){
            [indicatorView stopAnimating];
            
            arrowImageView.hidden = NO;
            
            if (arrow == HG_DRAG_TO_UPDATE_ARROW_DOWN){
                if (checkCount > 0){
                    instructionLabel.text = [NSString stringWithFormat:@"松开即可加载最新%d篇", checkCount];
                }else{
                    instructionLabel.text = @"松开即可加载最新";
                }
            }else{
                if (checkCount > 0){
                    instructionLabel.text = [NSString stringWithFormat:@"松开即可加载更多%d篇", checkCount];
                }else{
                    instructionLabel.text = @"松开即可加载更多";
                }
            }
            
            [UIView animateWithDuration:0.15f 
                                  delay:0.0f 
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 CATransform3D transform = arrowImageView.layer.transform;
                                 transform = CATransform3DRotate(transform, M_PI, 0.0f, 0.0f, 1.0f);
                                 arrowImageView.layer.transform = transform;
                             } completion:^(BOOL finished) {
                                 
                             }];
            
        }else if (status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG){
            [indicatorView stopAnimating];
            arrowImageView.hidden = NO;
            
            if (arrow == HG_DRAG_TO_UPDATE_ARROW_DOWN){
                if (checkCount > 0){
                    instructionLabel.text = [NSString stringWithFormat:@"向下拖动加载最新%d篇", checkCount];
                }else{
                    instructionLabel.text = @"向下拖动加载最新";
                }
            }else{
                if (checkCount > 0){
                    instructionLabel.text = [NSString stringWithFormat:@"向上拖动加载更多%d篇", checkCount];
                }else{
                    instructionLabel.text = @"向上拖动加载更多";
                }
            }
            
            [UIView animateWithDuration:0.15f 
                                  delay:0.0f 
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 CATransform3D transform = arrowImageView.layer.transform;
                                 transform = CATransform3DRotate(transform, -M_PI, 0, 0, 1.0f);
                                 arrowImageView.layer.transform = transform;
                             } completion:^(BOOL finished) {
                                 
                             }];
            
        }else if(status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE){
            arrowImageView.hidden = YES;
            [indicatorView startAnimating];
            indicatorView.hidden = NO;
           
            if (arrow == HG_DRAG_TO_UPDATE_ARROW_DOWN){
                instructionLabel.text = @"正在加载最新......";
            }else{
                instructionLabel.text = @"正在加载更多......";
            }
            
            arrowImageView.layer.transform = CATransform3DRotate(CATransform3DIdentity, -M_PI, 0, 0, 1.0f);

        }else if (status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_FINISH){
            [indicatorView stopAnimating];
            arrowImageView.hidden = NO;
            
            arrowImageView.layer.transform = CATransform3DRotate(CATransform3DIdentity, -M_PI, 0, 0, 1.0f);

        }
    }
}

- (void)setArrow:(HGDragToUpdateArrow)theArrow{
    if (arrow != theArrow){
        arrow = theArrow;
        if (arrow == HG_DRAG_TO_UPDATE_ARROW_UP){
            [arrowImageView setImage:[UIImage imageNamed:@"drag_update_arrow_up"]];
            CGRect arrowImageViewFrame = arrowImageView.frame;
            arrowImageViewFrame.origin.y = (self.frame.size.height - arrowImageViewFrame.size.height) / 2.0;
            arrowImageView.frame = arrowImageViewFrame;
            
            CGRect instructionLabelFrame = instructionLabel.frame;
            CGRect updateDateLabelFrame = updateDateLabel.frame;
            updateDateLabelFrame.origin.y = instructionLabelFrame.origin.y + instructionLabelFrame.size.height;
            updateDateLabel.frame = updateDateLabelFrame;
            
            if (checkCount > 0){
                instructionLabel.text = [NSString stringWithFormat:@"向上拖动加载更多%d篇", checkCount];
            }else{
                instructionLabel.text = @"向上拖动加载更多";
            }
            updateDateLabel.text = @"最近无加载";
            
        }else if (arrow == HG_DRAG_TO_UPDATE_ARROW_DOWN){
            [arrowImageView setImage:[UIImage imageNamed:@"drag_update_arrow_down"]];
            CGRect arrowImageViewFrame = arrowImageView.frame;
            arrowImageViewFrame.origin.y = (self.frame.size.height - arrowImageViewFrame.size.height) / 2.0;
            arrowImageView.frame = arrowImageViewFrame;
            
            CGRect instructionLabelFrame = instructionLabel.frame;
            CGRect updateDateLabelFrame = updateDateLabel.frame;
            updateDateLabelFrame.origin.y = instructionLabelFrame.origin.y - updateDateLabelFrame.size.height;
            updateDateLabel.frame = updateDateLabelFrame;
            
            if (checkCount > 0){
                instructionLabel.text = [NSString stringWithFormat:@"向下拖动加载最新%d篇", checkCount];
            }else{
                instructionLabel.text = @"向下拖动加载最新";
            }
            updateDateLabel.text = @"最近无加载";
        }
    }
}

- (void)setUpdateDate:(NSDate *)theUpdateDate{
    if (updateDate != theUpdateDate){
        [updateDate release];
        updateDate = [theUpdateDate retain];
        if (updateDate != nil){
            NSString*  updateDisplay;    
            int interval = [updateDate timeIntervalSinceNow];
            
            if (interval < 0){
                interval = -interval;
            }
            if (interval >= 86400){
                updateDisplay = @"最近无加载";
            }else if (interval < 60){
                updateDisplay = @"刚刚完成加载";
            }else{
                int minutes, hours, days;
                minutes = hours = days = 0;
                if (interval >= 60) {
                    minutes = (interval / 60) % 60;
                }
                if (interval >= 3600) {
                    hours = (interval / 3600);
                }
                if (interval >= 86400) {
                    days = interval / 86400;
                }
                if (days > 10) {
                    updateDisplay = @"最近无加载";
                }else if (days > 0) {
                    updateDisplay = [NSString stringWithFormat:@"最近加载: %@", (days == 1) ? NSLocalizedString(@"1 day ago", nil) : [NSString stringWithFormat: NSLocalizedString(@"%i days ago", nil), days]];
                }else if (hours > 0) {
                    updateDisplay = [NSString stringWithFormat:@"最近加载: %@", (hours == 1) ? NSLocalizedString(@"1 hour ago", nil) : [NSString stringWithFormat: NSLocalizedString(@"%i hours ago", nil), hours]];
                }else if (minutes > 0) {
                    updateDisplay = [NSString stringWithFormat:@"最近加载: %@", (minutes == 1) ? NSLocalizedString(@"1 minute ago", nil) : [NSString stringWithFormat: NSLocalizedString(@"%i minutes ago", nil), minutes]];
                }else {
                    updateDisplay = @"刚刚完成加载";
                }
            } 
            updateDateLabel.text = updateDisplay;
        }
    }
}

- (void)setCheckCount:(int)theCheckCount{
    checkCount = theCheckCount;
    if (status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_UPDATE){
        if (arrow == HG_DRAG_TO_UPDATE_ARROW_DOWN){
            if (checkCount > 0){
                instructionLabel.text = [NSString stringWithFormat:@"松开即可加载最新%d篇", checkCount];
            }else{
                instructionLabel.text = @"松开即可加载最新";
            }
        }else{
            if (checkCount > 0){
                instructionLabel.text = [NSString stringWithFormat:@"松开即可加载最新%d篇", checkCount];
            }else{
                instructionLabel.text = @"松开即可加载最新";
            }
        }
    }else if (status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG){
        if (arrow == HG_DRAG_TO_UPDATE_ARROW_DOWN){
            if (checkCount > 0){
                instructionLabel.text = [NSString stringWithFormat:@"向下拖动加载最新%d篇", checkCount];
            }else{
                instructionLabel.text = @"向下拖动加载最新";
            }
        }else{
            if (checkCount > 0){
                instructionLabel.text = [NSString stringWithFormat:@"向上拖动加载更多%d篇", checkCount];
            }else{
                instructionLabel.text = @"向上拖动加载更多";
            }
        }
    }else if(status == HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE){
        if (arrow == HG_DRAG_TO_UPDATE_ARROW_DOWN){
            instructionLabel.text = @"正在加载最新......";
        }else{
            instructionLabel.text = @"正在加载更多......";
        }
    }
}

+ (HGDragToUpdateView*)dragToUpdateView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGDragToUpdateView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}



@end
