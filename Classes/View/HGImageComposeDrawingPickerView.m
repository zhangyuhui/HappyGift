//
//  HGImageComposeDrawingPickerView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/20/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGImageComposeDrawingPickerView.h"
#import "HappyGiftAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define kImageComposeDrawingPickerViewWidth  140
#define kImageComposeDrawingPickerViewHeight  30

@interface HGImageComposeDrawingPickerView()
-(void)initSubViews;
@end

@implementation HGImageComposeDrawingPickerView
@synthesize delegate;
@synthesize type;

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
    [contentView.layer setCornerRadius:2.0f];
    [contentView.layer setMasksToBounds:YES];
    type = -1;
}

- (void)setItems:(NSArray*)theItems{
    if (items != nil){
        [items release];
        items = nil;
    }
    items = [theItems retain];
    [contentTabView reloadData];
}

- (void)dealloc{
    [contentView release];
    [contentTabView release];
    [items release];
    [super dealloc];
}

+ (HGImageComposeDrawingPickerView*)imageComposeDrawingPickerView:(HGImageComposeDrawingPickerType)type{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGImageComposeDrawingPickerView"
                                                      owner:self
                                                    options:nil];
    HGImageComposeDrawingPickerView* imageComposeDrawingPickerView = [nibViews objectAtIndex:0];
    imageComposeDrawingPickerView.type = type;
    return imageComposeDrawingPickerView;      
}

- (void)performShow:(UIView*)view atPoint:(CGPoint)point{
    if (contentView.hidden == YES){
        CGRect imageComposeDrawingPickerViewFrame = self.frame;
        imageComposeDrawingPickerViewFrame.origin.x = 0.0;
        imageComposeDrawingPickerViewFrame.origin.y = 44.0;
        self.frame = imageComposeDrawingPickerViewFrame;
        [view addSubview:self];
        
        CGRect contentViewFrame = contentView.frame;
        
        CGPoint contentViewOrigin = point;
        contentViewOrigin.x -=  contentViewFrame.size.width;
        contentViewOrigin.y -=  contentViewFrame.size.height/2.0 + 20.0;
        contentViewFrame.origin = contentViewOrigin;
        contentView.frame = contentViewFrame;
    
        contentView.alpha = 0.0;
        contentView.hidden = NO;
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             contentView.alpha = 1.0;
                         } 
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)performHide{
    if (contentView.hidden == NO && contentView.alpha == 1.0){
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             contentView.alpha = 0.0;
                         } 
                         completion:^(BOOL finished) {
                             contentView.hidden = YES;
                             [self removeFromSuperview];
                         }];
    }
}

- (void)setType:(HGImageComposeDrawingPickerType)theType{
    if (type != theType){
        type = theType;
        if (items != nil){
            [items release];
            items = nil;
        }
        if (type == HG_IMAGE_COMPOSE_DRAWING_PICKER_TYPE_WIDTH){
            items = [[NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0], 
                      [NSNumber numberWithFloat:2.0], 
                      [NSNumber numberWithFloat:3.0],
                      [NSNumber numberWithFloat:4.0],
                      [NSNumber numberWithFloat:5.0],
                      [NSNumber numberWithFloat:6.0],
                      [NSNumber numberWithFloat:7.0],
                      [NSNumber numberWithFloat:8.0],
                      [NSNumber numberWithFloat:9.0],
                      [NSNumber numberWithFloat:10.0],
                      nil] retain];
        }else if (type == HG_IMAGE_COMPOSE_DRAWING_PICKER_TYPE_COLOR){
            items = [[NSArray arrayWithObjects:[UIColor blackColor], 
                      [UIColor darkGrayColor],
                      [UIColor lightGrayColor],
                      [UIColor whiteColor],
                      [UIColor grayColor],
                      [UIColor redColor],
                      [UIColor greenColor],
                      [UIColor blueColor],
                      [UIColor cyanColor],
                      [UIColor yellowColor],
                      [UIColor magentaColor],
                      [UIColor orangeColor],
                      [UIColor purpleColor],
                      [UIColor brownColor],
                      nil] retain];
        }
        
        [contentTabView reloadData];
    }
}

#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (items != nil){
        return [items count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (type == HG_IMAGE_COMPOSE_DRAWING_PICKER_TYPE_WIDTH){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HGImageComposeDrawingPickerViewWidthCellView"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HGImageComposeDrawingPickerViewWidthCellView"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            UIView* widthIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, kImageComposeDrawingPickerViewWidth - 20.0, kImageComposeDrawingPickerViewHeight)];
            widthIndicatorView.backgroundColor = [UIColor darkGrayColor];
            widthIndicatorView.tag = 100;
            [cell.contentView addSubview:widthIndicatorView];
            [widthIndicatorView release];
        }
        
        NSNumber* widthValue = [items objectAtIndex:indexPath.row];
        
        UIView* widthIndicatorView = [cell.contentView viewWithTag:100];
        CGRect widthIndicatorViewFrame = widthIndicatorView.frame;
        widthIndicatorViewFrame.size.height = [widthValue floatValue];
        widthIndicatorViewFrame.origin.y = (kImageComposeDrawingPickerViewHeight - widthIndicatorViewFrame.size.height)/2.0;
        widthIndicatorView.frame = widthIndicatorViewFrame;
        return cell;
    }else if (type == HG_IMAGE_COMPOSE_DRAWING_PICKER_TYPE_COLOR){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HGImageComposeDrawingPickerViewColorCellView"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HGImageComposeDrawingPickerViewColorCellView"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            UIView* widthIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 5.0, kImageComposeDrawingPickerViewWidth - 20.0, kImageComposeDrawingPickerViewHeight - 10.0)];
            widthIndicatorView.tag = 101;
            [cell.contentView addSubview:widthIndicatorView];
            [widthIndicatorView release];
        }
        
        UIColor* colorValue = [items objectAtIndex:indexPath.row];
        
        UIView* widthIndicatorView = [cell.contentView viewWithTag:101];
        widthIndicatorView.backgroundColor = colorValue;
        return cell;
    }else{
        return nil;
    }
}

#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if (type == HG_IMAGE_COMPOSE_DRAWING_PICKER_TYPE_WIDTH){
        if ([delegate respondsToSelector:@selector(imageComposeDrawingPickerView:didSelectWidth:)]){
            NSNumber* widthValue = [items objectAtIndex:indexPath.row];
            [delegate imageComposeDrawingPickerView:self didSelectWidth:[widthValue floatValue]];
        }
    }else if (type == HG_IMAGE_COMPOSE_DRAWING_PICKER_TYPE_COLOR){
        if ([delegate respondsToSelector:@selector(imageComposeDrawingPickerView:didSelectColor:)]){
            UIColor* colorValue = [items objectAtIndex:indexPath.row];
            [delegate imageComposeDrawingPickerView:self didSelectColor:colorValue];
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (CGRectContainsPoint(contentView.frame, point) == NO){
        if ([delegate respondsToSelector:@selector(imageComposeDrawingPickerViewDidCancel:)]){
            [delegate imageComposeDrawingPickerViewDidCancel:self];
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
