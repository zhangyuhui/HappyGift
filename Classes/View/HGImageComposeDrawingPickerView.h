//
//  HGImageComposeDrawingPickerView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/20/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HGImageComposeDrawingPickerViewDelegate;

typedef enum {
    HG_IMAGE_COMPOSE_DRAWING_PICKER_TYPE_WIDTH,
    HG_IMAGE_COMPOSE_DRAWING_PICKER_TYPE_COLOR
} HGImageComposeDrawingPickerType;

@interface HGImageComposeDrawingPickerView : UIView {
    IBOutlet UIView*        contentView;
    IBOutlet UITableView*   contentTabView;;
    
    NSArray*           items;
    HGImageComposeDrawingPickerType type;
    
    id<HGImageComposeDrawingPickerViewDelegate> delegate;
}
@property (nonatomic, assign) HGImageComposeDrawingPickerType type;
@property (nonatomic, assign) id<HGImageComposeDrawingPickerViewDelegate> delegate;

- (void)performShow:(UIView*)view atPoint:(CGPoint)point;
- (void)performHide;

+ (HGImageComposeDrawingPickerView*)imageComposeDrawingPickerView:(HGImageComposeDrawingPickerType)type;
@end


@protocol HGImageComposeDrawingPickerViewDelegate <NSObject>
- (void)imageComposeDrawingPickerView:(HGImageComposeDrawingPickerView *)imageComposeDrawingPickerView didSelectWidth:(CGFloat)width;
- (void)imageComposeDrawingPickerView:(HGImageComposeDrawingPickerView *)imageComposeDrawingPickerView didSelectColor:(UIColor*)color;
- (void)imageComposeDrawingPickerViewDidCancel:(HGImageComposeDrawingPickerView *)imageComposeDrawingPickerView;
@end