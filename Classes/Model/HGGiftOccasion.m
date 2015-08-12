//
//  HGGiftOccasion.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftOccasion.h"

NSString* const kGiftOccasionOccasionCategory = @"gift_occasion_occasion_category";
NSString* const kGiftOccasionOccasionTag = @"gift_occasion_occasion_tag";
NSString* const kGiftOccasionIdentifier = @"gift_occasion_identifier";
NSString* const kGiftOccasionName = @"gift_occasion_name";
NSString* const kGiftOccasionEventDescription = @"gift_occasion_event_description";
NSString* const kGiftOccasionUserId = @"gift_occasion_userid";
NSString* const kGiftOccasionRecipient = @"gift_occasion_recipient";
NSString* const kGiftOccasionUserCity = @"gift_occasion_usercity";
NSString* const kGiftOccasionUserProvince = @"gift_occasion_userprovince";
NSString* const kGiftOccasionUserGender = @"gift_occasion_usergender";
NSString* const kGiftOccasionEventType = @"gift_occasion_eventtype";
NSString* const kGiftOccasionEventDate = @"gift_occasion_eventdate";
NSString* const kGiftOccasionTweet = @"gift_occasion_tweet";

@implementation HGGiftOccasion
@synthesize occasionCategory;
@synthesize occasionTag;
@synthesize userId;
@synthesize recipient;
@synthesize userCity;
@synthesize userProvince;
@synthesize userGender;
@synthesize eventType;
@synthesize eventDate;
@synthesize eventDescription;
@synthesize tweet;

-(void)dealloc{
    [occasionCategory release];
    [occasionTag release];
    [userId release];
    [userProvince release];
    [userCity release];
    [userGender release];
    [eventType release];
    [eventDate release];
    [eventDescription release];
    [tweet release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        occasionCategory = [[coder decodeObjectForKey:kGiftOccasionOccasionCategory] retain];
        occasionTag = [[coder decodeObjectForKey:kGiftOccasionOccasionTag] retain];
        userId = [[coder decodeObjectForKey:kGiftOccasionUserId] retain];  
        recipient = [[coder decodeObjectForKey:kGiftOccasionRecipient] retain]; 
        userProvince = [[coder decodeObjectForKey:kGiftOccasionUserProvince] retain];
        userCity = [[coder decodeObjectForKey:kGiftOccasionUserCity] retain];
        userGender = [[coder decodeObjectForKey:kGiftOccasionUserGender] retain];
        eventType = [[coder decodeObjectForKey:kGiftOccasionEventType] retain]; 
        eventDate = [[coder decodeObjectForKey:kGiftOccasionEventDate] retain]; 
        eventDescription = [[coder decodeObjectForKey:kGiftOccasionEventDescription] retain];
        tweet = [[coder decodeObjectForKey:kGiftOccasionTweet] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:occasionCategory forKey:kGiftOccasionOccasionCategory];
    [encoder encodeObject:occasionTag forKey:kGiftOccasionOccasionTag];
    [encoder encodeObject:userId forKey:kGiftOccasionUserId];
    [encoder encodeObject:recipient forKey:kGiftOccasionRecipient];
    [encoder encodeObject:userProvince forKey:kGiftOccasionUserProvince];
    [encoder encodeObject:userCity forKey:kGiftOccasionUserCity];
    [encoder encodeObject:userGender forKey:kGiftOccasionUserGender];
    [encoder encodeObject:eventType forKey:kGiftOccasionEventType];
    [encoder encodeObject:eventDate forKey:kGiftOccasionEventDate];
    [encoder encodeObject:eventDescription forKey:kGiftOccasionEventDescription];
    [encoder encodeObject:tweet forKey:kGiftOccasionTweet];
}
@end
