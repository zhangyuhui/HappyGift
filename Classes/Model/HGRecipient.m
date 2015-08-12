//
//  HGRecipient.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-17.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGRecipient.h"
#import "HGRecipientService.h"

NSString* const kRecipientRecipientId = @"recipient_recipient_id";
NSString* const kRecipientRecipientName = @"recipient_recipient_name";
NSString* const kRecipientRecipientDisplayName = @"recipient_recipient_display_name";
NSString* const kRecipientRecipientPhone = @"recipient_recipient_phone";
NSString* const kRecipientRecipientEmail = @"recipient_recipient_email";
NSString* const kRecipientRecipientImageUrl = @"recipient_recipient_image_url";
NSString* const kRecipientRecipientProfileId = @"recipient_recipient_profile_id";
NSString* const kRecipientRecipientNetworkId = @"recipient_recipient_network_id";
NSString* const kRecipientRecipientBirthday = @"recipient_recipient_birthday";
NSString* const kRecipientRecipientNextBirthdayCount = @"recipient_recipient_next_birthday_count";
NSString* const kRecipientRecipientProvince = @"recipient_recipient_province";
NSString* const kRecipientRecipientCity = @"recipient_recipient_city";
NSString* const kRecipientRecipientStreetAddress = @"recipient_recipient_street_address";
NSString* const kRecipientRecipientPostCode = @"recipient_recipient_post_code";

@interface HGRecipient(SBJson)
    -(id)proxyForJson;
@end

@implementation HGRecipient

const int NETWORK_ALL_SNS = 999;
const int NETWORK_PHONE_CONTACT = -1;
const int NETWORK_LOCAL_CONTACT = 0;
const int NETWORK_SNS_WEIBO = 1;
const int NETWORK_SNS_RENREN = 2;

@synthesize recipientId;
@synthesize recipientName;
@synthesize recipientDisplayName;
@synthesize recipientPhone;
@synthesize recipientEmail;
@synthesize recipientImageUrl;
@synthesize recipientProfileId;
@synthesize recipientNetworkId;
@synthesize recipientBirthday;
@synthesize recipientNextBirthdayCount;
@synthesize recipientProvince;
@synthesize recipientCity;
@synthesize recipientStreetAddress;
@synthesize recipientPostCode;

- (void)dealloc {
    [recipientName release];
    [recipientDisplayName release];
    [recipientPhone release];
    [recipientEmail release];
    [recipientImageUrl release];
    [recipientProfileId release];
    [recipientBirthday release];
    [recipientProvince release];
    [recipientCity release];
    [recipientStreetAddress release];
    [recipientPostCode release];
    [super dealloc];
}

- (NSString*) recipientDisplayName {
    if (recipientDisplayName && ![@"" isEqualToString:recipientDisplayName]) {
        return recipientDisplayName;
    } else {
        return recipientName;
    }
}

- (NSString*)description {
    NSMutableString * description = [NSMutableString string];
	[description appendString:@"recipient = {\n"];
	[description appendFormat:@"recipientId=%d\n", self.recipientId];
	[description appendFormat:@"recipientName=%@\n", self.recipientName];
    [description appendFormat:@"recipientDisplayName=%@\n", self.recipientDisplayName];
	[description appendFormat:@"recipientPhone=%@\n", self.recipientPhone];
	[description appendFormat:@"recipientEmail=%@\n", self.recipientEmail];
    [description appendFormat:@"recipientImageUrl=%@\n", self.recipientImageUrl];
    [description appendFormat:@"recipientProfileId=%@\n", self.recipientProfileId];
    [description appendFormat:@"recipientNetworkId=%d\n", self.recipientNetworkId];
    [description appendFormat:@"recipientBirthday=%@\n", self.recipientBirthday];
    [description appendFormat:@"recipientProvince=%@\n", self.recipientProvince];
    [description appendFormat:@"recipientCity=%@\n", self.recipientCity];
    [description appendFormat:@"recipientStreetAddress=%@\n", self.recipientStreetAddress];
    [description appendFormat:@"recipientPostCode=%@\n", self.recipientPostCode];
	[description appendString:@"}\n"];
	return description;
}

// this is for upload, only include part of data
-(id)proxyForJson {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            recipientName, @"name",
            recipientPhone, @"phone",
            recipientEmail, @"email",
            recipientBirthday, @"birthday",
            recipientProfileId, @"phone_contact_id",
            nil];
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        recipientId = [coder decodeIntForKey:kRecipientRecipientId];
        recipientName = [[coder decodeObjectForKey:kRecipientRecipientName] retain];
        recipientDisplayName = [[coder decodeObjectForKey:kRecipientRecipientDisplayName] retain];
        recipientPhone = [[coder decodeObjectForKey:kRecipientRecipientPhone] retain];
        recipientEmail = [[coder decodeObjectForKey:kRecipientRecipientEmail] retain];
        recipientImageUrl = [[coder decodeObjectForKey:kRecipientRecipientImageUrl] retain];
        recipientProfileId = [[coder decodeObjectForKey:kRecipientRecipientProfileId] retain];
        recipientNetworkId = [coder decodeIntForKey:kRecipientRecipientNetworkId];
        recipientBirthday = [[coder decodeObjectForKey:kRecipientRecipientBirthday] retain];
        recipientNextBirthdayCount = [coder decodeIntForKey:kRecipientRecipientNextBirthdayCount];
        recipientProvince = [[coder decodeObjectForKey:kRecipientRecipientProvince] retain];
        recipientCity = [[coder decodeObjectForKey:kRecipientRecipientCity] retain];
        recipientStreetAddress = [[coder decodeObjectForKey:kRecipientRecipientStreetAddress] retain];
        recipientPostCode = [[coder decodeObjectForKey:kRecipientRecipientPostCode] retain];
        
        [[HGRecipientService sharedService] updateSNSRecipientWithDBData:self];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeInt:recipientId forKey:kRecipientRecipientId]; 
    [encoder encodeObject:recipientName forKey:kRecipientRecipientName]; 
    [encoder encodeObject:recipientDisplayName forKey:kRecipientRecipientDisplayName];
    [encoder encodeObject:recipientPhone forKey:kRecipientRecipientPhone]; 
    [encoder encodeObject:recipientEmail forKey:kRecipientRecipientEmail];
    [encoder encodeObject:recipientImageUrl forKey:kRecipientRecipientImageUrl];
    [encoder encodeObject:recipientProfileId forKey:kRecipientRecipientProfileId]; 
    [encoder encodeInt:recipientNetworkId forKey:kRecipientRecipientNetworkId]; 
    [encoder encodeObject:recipientBirthday forKey:kRecipientRecipientBirthday]; 
    [encoder encodeInt:recipientNextBirthdayCount forKey:kRecipientRecipientNextBirthdayCount]; 
    [encoder encodeObject:recipientProvince forKey:kRecipientRecipientProvince];
    [encoder encodeObject:recipientCity forKey:kRecipientRecipientCity];
    [encoder encodeObject:recipientStreetAddress forKey:kRecipientRecipientStreetAddress];
    [encoder encodeObject:recipientPostCode forKey:kRecipientRecipientPostCode];
}

@end