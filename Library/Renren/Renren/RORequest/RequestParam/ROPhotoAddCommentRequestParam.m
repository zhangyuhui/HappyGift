//
//  ROPhotoAddCommentRequestParam.m
//  HappyGift
//
//  Created by Yujian Weng on 12-8-2.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "ROPhotoAddCommentRequestParam.h"
#import "ROResponse.h"
#import "ROError.h"


@implementation ROPhotoAddCommentRequestParam
@synthesize uid;
@synthesize content;
@synthesize pid;

-(id)init {
	if (self = [super init]) {
		self.method = [NSString stringWithFormat:@"photos.addComment"];
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
    if (self.pid != nil && ![self.pid isEqualToString:@""]) {
		[dictionary setObject:self.pid forKey:@"pid"];
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
	self.pid = nil;
    self.content = nil;
	[super dealloc];
}

@end
