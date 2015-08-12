//
//  HGCreditHistory.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGCreditHistory.h"

NSString* const kCreditHistoryIdentifier = @"credit_history_identifier";
NSString* const kCreditHistoryType = @"credit_history_type";
NSString* const kCreditHistoryDate = @"credit_history_date";
NSString* const kCreditHistoryValue = @"credit_history_value";

@implementation HGCreditHistory
@synthesize identifier;
@synthesize type;
@synthesize date;
@synthesize value;


-(void)dealloc{
    [identifier release];
    [date release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        identifier = [[coder decodeObjectForKey:kCreditHistoryIdentifier] retain]; 
        type = [coder decodeIntForKey:kCreditHistoryType]; 
        date = [[coder decodeObjectForKey:kCreditHistoryDate] retain];
        value = [coder decodeIntForKey:kCreditHistoryValue];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:identifier forKey:kCreditHistoryIdentifier]; 
    [encoder encodeInt:type forKey:kCreditHistoryType];
    [encoder encodeObject:date forKey:kCreditHistoryDate]; 
    [encoder encodeInt:value forKey:kCreditHistoryValue];
}
@end
