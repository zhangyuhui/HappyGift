//
//  HGDragToUpdateView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 8/16/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HG_DRAG_TO_UPDATE_STATUS_READY_FOR_DRAG,
    HG_DRAG_TO_UPDATE_STATUS_READY_FOR_UPDATE,
    HG_DRAG_TO_UPDATE_STATUS_READY_FOR_CHANGE,
    HG_DRAG_TO_UPDATE_STATUS_READY_FOR_FINISH,
} HGDragToUpdateStatus;

typedef enum {
    HG_DRAG_TO_UPDATE_ARROW_NONE,
    HG_DRAG_TO_UPDATE_ARROW_UP,
    HG_DRAG_TO_UPDATE_ARROW_DOWN
} HGDragToUpdateArrow;

@interface HGDragToUpdateView : UIView{
    IBOutlet UIImageView* arrowImageView; 
    IBOutlet UILabel*     instructionLabel;
    IBOutlet UILabel*     updateDateLabel;
    IBOutlet UIActivityIndicatorView* indicatorView;
    
    HGDragToUpdateStatus status;
    HGDragToUpdateArrow  arrow;
    
    NSDate* updateDate;
    int checkCount;
    BOOL showUpdateDateLabel;
}
@property (nonatomic, assign) HGDragToUpdateStatus status;
@property (nonatomic, assign) HGDragToUpdateArrow arrow;

@property (nonatomic, assign) int     checkCount;

@property (nonatomic, retain) NSDate*     updateDate;
@property (nonatomic, assign) BOOL showUpdateDateLabel;

+ (HGDragToUpdateView*)dragToUpdateView;
@end
