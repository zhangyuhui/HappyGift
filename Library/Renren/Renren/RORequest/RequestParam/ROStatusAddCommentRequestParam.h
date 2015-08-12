//
//  ROStatusAddCommentRequestParam.h
//  HappyGift
//
//  Created by Yujian Weng on 12-8-2.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RORequestParam.h"


@interface ROStatusAddCommentRequestParam : RORequestParam {
	NSString *owner_id;
	NSString *content;
    NSString *status_id;
}

@property (copy,nonatomic)NSString *owner_id;

@property (copy,nonatomic)NSString *content;

@property (copy,nonatomic)NSString *status_id;

@end
