//
//  ROShareRequestParam.m
//  HappyGift
//
//  Created by Yujian Weng on 12-8-6.
//  Copyright 2012 Ztelic Inc Inc. All rights reserved.
//

#import "ROShareRequestParam.h"
#import "ROResponse.h"
#import "ROError.h"

@implementation ROShareRequestParam
@synthesize type;
@synthesize ugcId;
@synthesize ownerId;
@synthesize comment;

-(id)init {
	if (self = [super init]) {
		self.method = [NSString stringWithFormat:@"share.share"];
	}
	
	return self;
}

-(void)addParamToDictionary:(NSMutableDictionary*)dictionary {
	if (dictionary == nil) {
		return;
	}
	
	if (self.type != nil && ![self.type isEqualToString:@""]) {
		[dictionary setObject:self.type forKey:@"type"];
	}
    if (self.ugcId != nil && ![self.ugcId isEqualToString:@""]) {
		[dictionary setObject:self.ugcId forKey:@"ugc_id"];
	}
    if (self.ownerId != nil && ![self.ownerId isEqualToString:@""]) {
		[dictionary setObject:self.ownerId forKey:@"user_id"];
	}
    if (self.comment != nil && ![self.comment isEqualToString:@""]) {
		[dictionary setObject:self.comment forKey:@"comment"];
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
	self.ugcId = nil;
	self.ownerId = nil;
    self.comment = nil;
    self.type = nil;
	[super dealloc];
}

@end
