//
//  ROStatusAddCommentRequestParam.m
//  HappyGift
//
//  Created by Yujian Weng on 12-8-2.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "ROStatusAddCommentRequestParam.h"
#import "ROResponse.h"
#import "ROError.h"


@implementation ROStatusAddCommentRequestParam
@synthesize owner_id;
@synthesize content;
@synthesize status_id;

-(id)init {
	if (self = [super init]) {
		self.method = [NSString stringWithFormat:@"status.addComment"];
	}
	
	return self;
}

-(void)addParamToDictionary:(NSMutableDictionary*)dictionary {
	if (dictionary == nil) {
		return;
	}
	
	if (self.owner_id != nil && ![self.owner_id isEqualToString:@""]) {
		[dictionary setObject:self.owner_id forKey:@"owner_id"];
	}
    if (self.content != nil && ![self.content isEqualToString:@""]) {
		[dictionary setObject:self.content forKey:@"content"];
	}
    if (self.status_id != nil && ![self.status_id isEqualToString:@""]) {
		[dictionary setObject:self.status_id forKey:@"status_id"];
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
	self.owner_id = nil;
	self.status_id = nil;
    self.content = nil;
	[super dealloc];
}

@end
