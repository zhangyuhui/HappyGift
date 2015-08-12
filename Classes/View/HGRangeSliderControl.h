//
//  HGRangeSliderControl.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-18.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HGRangeSliderControlDelegate;

@interface HGRangeSliderControl : UIControl {
    float minValue;
    float maxValue;
    float minRange;
    float selectedMinValue;
    float selectedMaxValue;
    float distanceFromCenter;
    
    float _padding;
    
    BOOL _maxThumbOn;
    BOOL _minThumbOn;
    
    UIImageView * _minThumb;
    UIImageView * _maxThumb;
    UIImageView * _track;
    
    UILabel* _minValueLabel;
    UILabel* _maxValueLabel;
}

@property(nonatomic) float minValue;
@property(nonatomic) float maxValue;
@property(nonatomic) float minRange;
@property(nonatomic) float selectedMinValue;
@property(nonatomic) float selectedMaxValue;
@property (nonatomic, assign) id<HGRangeSliderControlDelegate> delegate;

-(BOOL)isUnlimited;

@end

@protocol HGRangeSliderControlDelegate
    - (void)didRangesSliderChanged:(HGRangeSliderControl*)slider;
@end


