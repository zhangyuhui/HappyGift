//
//  HGNotificationView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 8/16/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGNotificationView : UIView{
    IBOutlet UILabel*  notificationLabel;
    NSString* notification;
}

@property (nonatomic, retain) NSString*  notification;

+ (HGNotificationView*)notificationView;
@end
