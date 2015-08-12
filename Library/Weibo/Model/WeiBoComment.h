//
//  WeiBoComment.h
//  HappyGift
//
//  Created by Yuhui Zhang on 11-10-6.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "NSDictionary+Addition.h"
#import "WeiBoUser.h"
#import "WeiBoStatus.h"

@interface WeiBoComment : NSObject {
	long long		commentId; // 评论ID
	NSNumber*		commentKey;
	NSString*		text; //评论内容
	time_t			createdAt; //评论时间
	NSString*		source; //评论来源
	NSString*		sourceUrl; 
	BOOL			favorited; //是否收藏
	BOOL			truncated; //是否被截断
	WeiBoUser*			user; //评论人信息
	WeiBoStatus*			status; //评论的微博
	WeiBoComment*		replyComment; //评论来源
}

@property (nonatomic, assign) long long		commentId; // 评论ID
@property (nonatomic, retain) NSNumber*		commentKey;
@property (nonatomic, readonly) NSString*         timestamp;
@property (nonatomic, retain) NSString*		text; //评论内容
@property (nonatomic, assign) time_t			createdAt; //评论时间
@property (nonatomic, retain) NSString*		source; //评论来源
@property (nonatomic, retain) NSString*		sourceUrl; //评论来源
@property (nonatomic, assign) BOOL			favorited; //是否收藏
@property (nonatomic, assign) BOOL			truncated; //是否被截断
@property (nonatomic, retain) WeiBoUser*			user; //评论人信息
@property (nonatomic, retain) WeiBoStatus*			status; //评论的微博
@property (nonatomic, retain) WeiBoComment*		replyComment; //评论来源


- (WeiBoComment*)initWithJsonDictionary:(NSDictionary*)dic;

+ (WeiBoComment*)commentWithJsonDictionary:(NSDictionary*)dic;

@end
