//
//  HGNotificationView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 8/16/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGNotificationView.h"
#import "HappyGiftAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface HGNotificationView(private)
-(void)initSubViews;
@end

@implementation HGNotificationView
@synthesize notification;

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
    notificationLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    notificationLabel.textColor = [UIColor blackColor];
    notificationLabel.lineBreakMode = UILineBreakModeCharacterWrap;
}

- (void)dealloc{
    [notification release];
    [notificationLabel release];
    [super dealloc];
}

- (void)setNotification:(NSString *)theNotification{
    if (notification != nil){
        [notification release];
        notification = nil;
    }
    notification = [[NSString alloc] initWithString:theNotification];
    if (notification != nil){
        notificationLabel.text = notification;
    }else{
        notificationLabel.text = @"";
    }
    
    CGSize notificationLabelSize = [notificationLabel.text sizeWithFont:notificationLabel.font constrainedToSize:CGSizeMake(notificationLabel.frame.size.width, 100.0f) lineBreakMode:UILineBreakModeCharacterWrap];
    if (notificationLabelSize.height < 40.0){
        notificationLabelSize.height = 40.0;
    }
    CGRect notificationLabelFrame = notificationLabel.frame;
    notificationLabelFrame.size.height = notificationLabelSize.height;
    notificationLabel.frame = notificationLabelFrame;

    CGRect notificationViewFrame = self.frame;
    notificationViewFrame.size.height = notificationLabelSize.height;
    self.frame = notificationViewFrame;
}

+ (HGNotificationView*)notificationView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGNotificationView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}



@end
