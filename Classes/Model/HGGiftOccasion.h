//
//  HGGiftOccasion.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGOccasionCategory;
@class HGOccasionTag;
@class HGRecipient;
@class HGTweet;

@interface HGGiftOccasion : NSObject <NSCoding> {
    HGOccasionCategory* occasionCategory;
    HGOccasionTag* occasionTag;
    NSString* userId;
    
    HGRecipient* recipient;
    
    NSString* userProvince;
    NSString* userCity;
    NSString* userGender;
    
    NSString* eventType;
    NSString* eventDate;
    NSString* eventDescription;
    
    HGTweet*  tweet;
}
@property (nonatomic, retain) HGOccasionCategory* occasionCategory;
@property (nonatomic, retain) HGOccasionTag* occasionTag;
@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) HGRecipient* recipient;

@property (nonatomic, retain) NSString* userProvince;
@property (nonatomic, retain) NSString* userCity;
@property (nonatomic, retain) NSString* userGender;
@property (nonatomic, retain) NSString* eventType;
@property (nonatomic, retain) NSString* eventDate;
@property (nonatomic, retain) NSString* eventDescription;

@property (nonatomic, retain) HGTweet* tweet;


@end
