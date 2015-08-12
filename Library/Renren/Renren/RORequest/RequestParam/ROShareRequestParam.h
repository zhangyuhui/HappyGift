//
//  ROShareRequestParam.h
//  HappyGift
//
//  Created by Yujian Weng on 12-8-6.
//  Copyright 2012 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RORequestParam.h"


@interface ROShareRequestParam : RORequestParam {
	NSString* type;
	NSString* ugcId;
    NSString* ownerId;
    NSString* comment;
}

@property (copy,nonatomic)NSString *type;
@property (copy,nonatomic)NSString *ugcId;
@property (copy,nonatomic)NSString *ownerId;
@property (copy,nonatomic)NSString *comment;

@end
