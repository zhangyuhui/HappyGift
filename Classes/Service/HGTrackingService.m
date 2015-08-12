//
//  HGTrackingService.m
//  HappyGift
//
//  Created by Yuhui Zhang on 4/10/12.
//  Copyright (c) 2012 Ztelic Inc. All rights reserved.
//

#import "HGTrackingService.h"
#import "HGTrackingLoader.h"
#import "HappyGiftAppDelegate.h"
#import "FlurryAnalytics.h"
#import "HGAccountService.h"
#import "HGAppConfigurationService.h"

NSString * const kTrackingEventBrowseFeaturedGiftOccasion = @"BrowseFeaturedGiftOccasion";
NSString * const kTrackingEventSelectFeaturedGiftOccasion = @"SelectFeaturedGiftOccasion";
NSString * const kTrackingEventBrowseGlobalGiftOccasion = @"BrowseGlobalGiftOccasion";
NSString * const kTrackingEventSelectGlobalGiftOccasion = @"SelectGlobalGiftOccasion";
NSString * const kTrackingEventBrowsePersonalGiftOccasion = @"BrowsePersonalGiftOccasion";
NSString * const kTrackingEventSelectPersonalGiftOccasion = @"SelectPersonalGiftOccasion";
NSString * const kTrackingEventSelectFriendRecommendation = @"SelectFriendRecommendation";

NSString * const kTrackingEventEnterSetting = @"EnterSetting";
NSString * const kTrackingEventLoginAccount = @"LoginAccount";
NSString * const kTrackingEventLogoutAccount = @"LogoutAccount";
NSString * const kTrackingEventShareApp = @"ShareApp";

NSString * const kTrackingEventEnterGiftSelection = @"EnterGiftSelection";
NSString * const kTrackingEventSelectGiftCategory = @"SelectGiftCategory";
NSString * const kTrackingEventSelectGiftPrice = @"SelectGiftPrice";
NSString * const kTrackingEventSelectGiftAssistant = @"SelectGiftAssistant";
NSString * const kTrackingEventSubmitGiftAssistant = @"SubmitGiftAssistant";

NSString * const kTrackingEventEnterGiftDetail = @"EnterGiftDetail";
NSString * const kTrackingEventLikeProduct = @"LikeProduct";
NSString * const kTrackingEventShareProduct = @"ShareProduct";

NSString * const kTrackingEventEnterFriendRecommendationList = @"EnterFriendRecommendationList";
NSString * const kTrackingEventEnterRecipientSelection = @"EnterRecipientSelection";

NSString * const kTrackingEventEnterGiftGroupDetail = @"EnterGiftGroupDetail";

NSString * const kTrackingEventEnterGiftCard = @"EnterGiftCard";
NSString * const kTrackingEventSelectGiftCardCategory = @"SelectGiftCardCategory";
NSString * const kTrackingEventSelectGiftCardTemplate = @"SelectGiftCardTemplate";

NSString * const kTrackingEventEnterGiftDelivery = @"EnterGiftDelivery";
NSString * const kTrackingEventEnableEmailNotify = @"EnableEmailNotify";
NSString * const kTrackingEventEnablePhoneNotify = @"EnablePhoneNotify";
NSString * const kTrackingEventEnableDelayNotify = @"EnableDelayNotify";

NSString * const kTrackingEventEnterGiftOrderDetail = @"EnterGiftOrderDetail";
NSString * const kTrackingEventSendGiftOrder = @"SendGiftOrder";

NSString * const kTrackingEventEnterSentGiftDetail = @"EnterSentGiftDetail";
NSString * const kTrackingEventPayGiftOrder = @"PayGiftOrder";
NSString * const kTrackingEventCancelGiftOrder = @"CancelGiftOrder";
NSString * const kTrackingEventShareOrder = @"ShareOrder";

NSString * const kTrackingEventEnterSentGiftList = @"EnterSentGiftList";

NSString * const kTrackingEventEnterOccasionDetail = @"EnterOccasionDetail";
NSString * const kTrackingEventOccasionDetailLoadMoreGifts = @"OccasionDetailLoadMoreGifts";

NSString * const kTrackingEventEnterAstroTrendList = @"EnterAstroTrendList";
NSString * const kTrackingEventEnterAstroTrendDetail = @"EnterAstroTrendDetail";

NSString * const kTrackingEventEnterSongsList = @"EnterSongsList";
NSString * const kTrackingEventEnterWishesList = @"EnterWishesList";

NSString * const kTrackingEventShareVirtualGift = @"ShareVirtualGift";
NSString * const kTrackingEventShareDIYGift = @"ShareDIYGift";
NSString * const kTrackingEventShareGIFGift = @"ShareGIFGift";

NSString * const kTrackingEventCommentTweet = @"CommentTweet";
NSString * const kTrackingEventForwardTweet = @"ForwardTweet";
NSString * const kTrackingEventShareAstroTrend = @"ShareAstroTrend";

NSString * const kTrackingEventEnterFriendEmotionList = @"EnterFriendEmotionList";
NSString * const kTrackingEventEnterFriendEmotionDetail = @"EnterFriendEmotionDetail";

NSString * const kTrackingEventEnterOccasionList = @"EnterOccasionList";

NSString * const kTrackingEventEnterMyLikes = @"EnterMyLikes";

NSString * const kTrackingEventEnterShare = @"EnterShare";

NSString * const kTrackingEventEnterGIFGifts = @"EnterGIFGiftList";

NSString * const kTrackingEventEnterLoginView = @"EnterLoginView";

NSString * const kTrackingEventEnterRecipientAddressView = @"EnterRecipientAddressView";
NSString * const kTrackingEventEnterRecipientContactView = @"EnterRecipientContactView";

static HGTrackingService* trackingService = nil;

@interface HGTrackingService ()<HGTrackingLoaderDelegate> 

@end

@implementation HGTrackingService

- (id)init {
    if ((self = [super init])) {
		
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
    
}

+ (HGTrackingService*)sharedService{
    if (trackingService == nil){
        trackingService = [[HGTrackingService alloc] init];
    }
    return trackingService;
}

+ (void)startSession{
     [FlurryAnalytics startSession:@"AS2K15YNXM2BCM5U1JG9"];
}

+ (void)logEvent:(NSString *)eventName{
    NSString* bucketId = [[HGAppConfigurationService sharedService].appConfiguration objectForKey:kAppConfigurationKeyBucketId];
    if (bucketId != nil && [bucketId isEqualToString:@""] == NO){
        [FlurryAnalytics logEvent:eventName withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[HGAccountService sharedService].currentAccount.userId, @"user", bucketId, @"bucket", nil]];
    }else {
        [FlurryAnalytics logEvent:eventName withParameters:[NSDictionary dictionaryWithObject:[HGAccountService sharedService].currentAccount.userId forKey:@"user"]];
    }
}

+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters{
    NSMutableDictionary* theParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    [theParameters setObject:[HGAccountService sharedService].currentAccount.userId forKey:@"user"];
    NSString* bucketId = [[HGAppConfigurationService sharedService].appConfiguration objectForKey:kAppConfigurationKeyBucketId];
    if (bucketId != nil && [bucketId isEqualToString:@""] == NO){
        [theParameters setObject:bucketId forKey:@"bucket"];
    }
        
    [FlurryAnalytics logEvent:eventName withParameters:theParameters];
    [theParameters release];
}

+ (void)logAllPageViews:(UINavigationController*)navigationController{
    [FlurryAnalytics logAllPageViews:navigationController];
}

+ (void)logPageView{
   [FlurryAnalytics logPageView]; 
}

#pragma mark HGAccountLoaderDelegate
- (void)trackingLoader:(HGTrackingLoader *)theTrackingLoader didRequestTrackingUploadSucceed:(NSString*)nothing{
    
}

- (void)trackingLoader:(HGTrackingLoader *)theTrackingLoader didRequestTrackingUploadFail:(NSString*)error{
    
}
@end
