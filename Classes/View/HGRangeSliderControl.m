//
//  HGRangeSliderControl.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-18.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGRangeSliderControl.h"
#import "HGDefines.h"
#import "HappyGiftAppDelegate.h"

@interface HGRangeSliderControl (PrivateMethods)
-(float)xForValue:(float)value;
-(float)valueForX:(float)x;
-(void)updateTrackHighlight;
@end

@implementation HGRangeSliderControl

@synthesize minValue, maxValue, minRange, selectedMinValue, selectedMaxValue;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _minThumbOn = false;
        _maxThumbOn = false;
        _padding = 55;
        
        UIImageView* trackBackground = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"sliderbar_background"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0]];
        trackBackground.frame = CGRectMake(_padding, (self.frame.size.height - 8.0) / 2, self.frame.size.width - _padding*2.0, 8.0);
        trackBackground.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:trackBackground];
        [trackBackground release];
        
        _track = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"sliderbar_indicator_background"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0]];
        _track.frame = CGRectMake(_padding, (self.frame.size.height - 8.0) / 2, self.frame.size.width - _padding*2.0, 8.0);
        _track.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_track];
        
        _minThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sliderbar_arrow"] highlightedImage:[UIImage imageNamed:@"sliderbar_arrow_selected"]];
        _minThumb.contentMode = UIViewContentModeCenter;
        _minThumb.frame = CGRectMake(_padding - 25.0/2.0, (self.frame.size.height - 25.0) / 2, 25.0, 25.0);
        [self addSubview:_minThumb];
        
        _maxThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sliderbar_arrow"] highlightedImage:[UIImage imageNamed:@"sliderbar_arrow_selected"]];
        _maxThumb.contentMode = UIViewContentModeCenter;
        _maxThumb.frame = CGRectMake(self.frame.size.width - _padding - 25.0/2.0, (self.frame.size.height - 25.0) / 2, 25.0, 25.0);
        [self addSubview:_maxThumb];
        
        _minValueLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 9, 50, 25)];
        _minValueLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeTiny]];
        _minValueLabel.backgroundColor = [UIColor clearColor];
        _minValueLabel.textColor = [UIColor blackColor];
        _minValueLabel.contentMode = UIViewContentModeCenter;
        _minValueLabel.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:_minValueLabel];
        
        _maxValueLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.frame.size.width - 50.0, 9, 50, 25)];
        _maxValueLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeTiny]];
        _maxValueLabel.backgroundColor = [UIColor clearColor];
        _maxValueLabel.textColor = [UIColor blackColor];
        _maxValueLabel.contentMode = UIViewContentModeCenter;
        _maxValueLabel.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:_maxValueLabel];
        
        self.clipsToBounds = NO;
        
    }
    
    return self;
}

-(void) dealloc {
    [_track release];
    [_minThumb release];
    [_maxThumb release];
    [_minValueLabel release];
    [_maxValueLabel release];
    [super dealloc];
}

-(BOOL) isUnlimited {
    return fabs(selectedMaxValue - maxValue) <= 0.5;
}

-(void)layoutSubviews {
    if (selectedMinValue < 0.005){
        _minValueLabel.text = @"免费";
    }else{
        _minValueLabel.text = [NSString stringWithFormat:@"¥%.0f", selectedMinValue];
    }
    if ([self isUnlimited]) {
        _maxValueLabel.text = [NSString stringWithFormat:@"¥%.0f+", selectedMaxValue];
    } else {
        _maxValueLabel.text = [NSString stringWithFormat:@"¥%.0f", selectedMaxValue];
    }
    [self updateTrackHighlight];
}

-(float)xForValue:(float)value{
    return (self.frame.size.width-(_padding*2))*((value - minValue) / (maxValue - minValue))+_padding;
}

-(float) valueForX:(float)x{
    return minValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (maxValue - minValue);
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if(!_minThumbOn && !_maxThumbOn){
        return YES;
    }
    CGPoint touchPoint = [touch locationInView:self];
    if (_minThumbOn) {
        float x = MAX([self xForValue:minValue],MIN(touchPoint.x - distanceFromCenter, [self xForValue:selectedMaxValue - minRange]));
        if (_maxThumb.center.x - x >= 15.0) {
            _minThumb.center = CGPointMake(x, _minThumb.center.y);
            selectedMinValue = [self valueForX:_minThumb.center.x];
        }
    }
    if(_maxThumbOn){
        float x = MIN([self xForValue:maxValue], MAX(touchPoint.x - distanceFromCenter, [self xForValue:selectedMinValue + minRange]));
        if (x - _minThumb.center.x >= 15.0) {
            _maxThumb.center = CGPointMake(x, _maxThumb.center.y);
            selectedMaxValue = [self valueForX:_maxThumb.center.x];
        }
    }
    [self updateTrackHighlight];
    [self setNeedsLayout];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touch locationInView:self];
    CGRect touchMinThumbRect = _minThumb.frame;
    touchMinThumbRect = CGRectInset(touchMinThumbRect, -10.0, -10.0);
    CGRect touchMaxThumbRect = _maxThumb.frame;
    touchMaxThumbRect = CGRectInset(touchMaxThumbRect, -10.0, -10.0);
    if(CGRectContainsPoint(touchMinThumbRect, touchPoint)) {
        _minThumbOn = true;
        _minThumb.highlighted = YES;
        distanceFromCenter = touchPoint.x - _minThumb.center.x;
    }
    else if(CGRectContainsPoint(touchMaxThumbRect, touchPoint)) {
        _maxThumbOn = true;
        _maxThumb.highlighted = YES;
        distanceFromCenter = touchPoint.x - _maxThumb.center.x;
        
    }
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if (_minThumbOn || _maxThumbOn) {
        if ([(id)self.delegate respondsToSelector:@selector(didRangesSliderChanged:)]) {
            [self.delegate didRangesSliderChanged:self];
        }        
    }
    _minThumbOn = false;
    _maxThumbOn = false;
    _minThumb.highlighted = NO;
    _maxThumb.highlighted = NO;
}

-(void)updateTrackHighlight{
	_track.frame = CGRectMake(
                              _minThumb.center.x,
                              _track.center.y - (_track.frame.size.height/2),
                              _maxThumb.center.x - _minThumb.center.x,
                              _track.frame.size.height
                              );
}

@end
