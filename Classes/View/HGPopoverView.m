//
//  HGPopoverView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/20/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGPopoverView.h"
#import "HappyGiftAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface HGPopoverView()
-(void)initSubViews;
@end

@implementation HGPopoverView
@synthesize delegate;
@synthesize items;
@synthesize budyLabel;

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
    [contentView.layer setCornerRadius:10.0f];
    [contentView.layer setMasksToBounds:YES];

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
    [budyLabel release];
    [super dealloc];
}

+ (HGPopoverView*)popoverView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGPopoverView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];      
}

- (void)performShow:(UIView*)view atPoint:(CGPoint)point{
    if (contentView.hidden == YES){
        CGRect popoverViewFrame = self.frame;
        popoverViewFrame.origin.x = 0.0;
        popoverViewFrame.origin.y = 44.0;
        self.frame = popoverViewFrame;
        [view addSubview:self];
        
        
        CGRect contentViewFrame = contentView.frame;
        contentViewFrame.origin = point;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HGPopoverViewCellView"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HGPopoverViewCellView"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.textLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    cell.textLabel.textColor = [UIColor darkGrayColor];
	cell.textLabel.text = [items objectAtIndex:indexPath.row];
	return cell;
}

#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    if ([delegate respondsToSelector:@selector(popoverView:didSelectItem:)]){
        [delegate popoverView:self didSelectItem: [items objectAtIndex:indexPath.row]];
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (CGRectContainsPoint(contentView.frame, point) == NO){
        if ([delegate respondsToSelector:@selector(popoverView:didRejectItem:)]){
            [delegate popoverView:self didRejectItem:-1];
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
