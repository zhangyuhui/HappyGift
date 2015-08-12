//
//  ROBlogAddCommentRequestParam.m
//  HappyGift
//
//  Created by Yujian Weng on 12-8-2.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "ROBlogAddCommentRequestParam.h"
#import "ROResponse.h"
#import "ROError.h"


@implementation ROBlogAddCommentRequestParam
@synthesize uid;
@synthesize content;
@synthesize blogId;

-(id)init {
	if (self = [super init]) {
		self.method = [NSString stringWithFormat:@"blog.addComment"];
	}
	
	return self;
}

-(void)addParamToDictionary:(NSMutableDictionary*)dictionary {
	if (dictionary == nil) {
		return;
	}
	
	if (self.uid != nil && ![self.uid isEqualToString:@""]) {
		[dictionary setObject:self.uid forKey:@"uid"];
	}
    if (self.content != nil && ![self.content isEqualToString:@""]) {
		[dictionary setObject:self.content forKey:@"content"];
	}
    if (self.blogId != nil && ![self.blogId isEqualToString:@""]) {
		[dictionary setObject:self.blogId forKey:@"id"];
	}
}

-(ROResponse*)requestResultToResponse:(id)result {
	id responseObject = nil;
	if ([result isKindOfClass:[NSArray class]]) {
		return [ROResponse responseWithRootObject:result];
	} else {
		if ([result objectForKey:@"error_code"] != nil) {
			responseObject = [ROError errorWithRestInfo:result];
			return [ROResponse responseWithError:responseObject];
		}
		
		return [ROResponse responseWithRootObject:responseObject];
	}
}

-(void)dealloc {
	self.uid = nil;
	self.blogId = nil;
    self.content = nil;
	[super dealloc];
}

@end
