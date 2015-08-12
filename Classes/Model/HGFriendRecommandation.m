//
//  HGFriendRecommandation.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFriendRecommandation.h"
#import "HGRecipient.h"

NSString* const kRecommandationRecipient = @"friend_recommandation_recipient";
NSString* const kRecommandationGift = @"friend_recommandation_gift";

@implementation HGFriendRecommandation

@synthesize recipient;
@synthesize gift;

- (void)dealloc {
    [recipient release];
    [gift release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        recipient = [[coder decodeObjectForKey:kRecommandationRecipient] retain];
        gift = [[coder decodeObjectForKey:kRecommandationGift] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:recipient forKey:kRecommandationRecipient]; 
    [encoder encodeObject:gift forKey:kRecommandationGift]; 
}

@end