//
//  ROBlogAddCommentRequestParam.h
//  HappyGift
//
//  Created by Yujian Weng on 12-8-2.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RORequestParam.h"


@interface ROBlogAddCommentRequestParam : RORequestParam {
	NSString *uid;
	NSString *content;
    NSString *blogId;
}

@property (copy,nonatomic)NSString *uid;

@property (copy,nonatomic)NSString *content;

@property (copy,nonatomic)NSString *blogId;

@end
