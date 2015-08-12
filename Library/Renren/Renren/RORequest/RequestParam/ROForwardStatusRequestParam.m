//
//  ROForwardStatusRequestParam.m
//  HappyGift
//
//  Created by Yujian Weng on 12-8-6.
//  Copyright 2012 Ztelic Inc Inc. All rights reserved.
//

#import "ROForwardStatusRequestParam.h"
#import "ROResponse.h"
#import "ROError.h"


@implementation ROForwardStatusRequestParam
@synthesize forwardId;
@synthesize status;
@synthesize forwardOwner;

-(id)init {
	if (self = [super init]) {
		self.method = [NSString stringWithFormat:@"status.forward"];
	}
	
	return self;
}

-(void)addParamToDictionary:(NSMutableDictionary*)dictionary {
	if (dictionary == nil) {
		return;
	}
	
	if (self.status != nil && ![self.status isEqualToString:@""]) {
		[dictionary setObject:self.status forKey:@"status"];
	}
    if (self.forwardId != nil && ![self.forwardId isEqualToString:@""]) {
		[dictionary setObject:self.forwardId forKey:@"forward_id"];
	}
    if (self.forwardOwner != nil && ![self.forwardOwner isEqualToString:@""]) {
		[dictionary setObject:self.forwardOwner forKey:@"forward_owner"];
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
	self.status = nil;
	self.forwardId = nil;
    self.forwardOwner = nil;
	[super dealloc];
}

@end
