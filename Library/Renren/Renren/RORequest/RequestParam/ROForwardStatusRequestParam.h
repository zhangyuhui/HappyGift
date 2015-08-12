//
//  ROForwardStatusRequestParam.h
//  HappyGift
//
//  Created by Yujian Weng on 12-8-6.
//  Copyright 2012 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RORequestParam.h"


@interface ROForwardStatusRequestParam : RORequestParam {
	NSString *forwardId;
	NSString *status;
    NSString *forwardOwner;
}

@property (copy,nonatomic)NSString *forwardId;

@property (copy,nonatomic)NSString *status;

@property (copy,nonatomic)NSString *forwardOwner;

@end
