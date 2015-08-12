//
//  HGFriendRecommandation.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGRecipient;
@class HGGift;

@interface HGFriendRecommandation: NSObject <NSCoding>  {
    HGRecipient* recipient;
    HGGift* gift;
}

@property (nonatomic, retain) HGRecipient*  recipient;
@property (nonatomic, retain) HGGift*       gift;

@end
