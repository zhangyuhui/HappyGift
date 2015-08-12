//
//  HGTrackingService.h
//  HappyGift
//
//  Created by Yuhui Zhang on 4/10/12.
//  Copyright (c) 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * const kTrackingEventBrowseFeaturedGiftOccasion;
NSString * const kTrackingEventSelectFeaturedGiftOccasion;
NSString * const kTrackingEventBrowseGlobalGiftOccasion;
NSString * const kTrackingEventSelectGlobalGiftOccasion;
NSString * const kTrackingEventBrowsePersonalGiftOccasion;
NSString * const kTrackingEventSelectPersonalGiftOccasion;
NSString * const kTrackingEventSelectFriendRecommendation;

NSString * const kTrackingEventEnterSetting;
NSString * const kTrackingEventLoginAccount;
NSString * const kTrackingEventLogoutAccount;
NSString * const kTrackingEventShareApp;

NSString * const kTrackingEventEnterGiftSelection;
NSString * const kTrackingEventSelectGiftCategory;
NSString * const kTrackingEventSelectGiftPrice;
NSString * const kTrackingEventSelectGiftAssistant;
NSString * const kTrackingEventSubmitGiftAssistant;

NSString * const kTrackingEventEnterGiftDetail;
NSString * const kTrackingEventLikeProduct;
NSString * const kTrackingEventShareProduct;

NSString * const kTrackingEventEnterFriendRecommendationList;
NSString * const kTrackingEventEnterRecipientSelection;

NSString * const kTrackingEventEnterGiftGroupDetail;

NSString * const kTrackingEventEnterGiftCard;
NSString * const kTrackingEventSelectGiftCardCategory;
NSString * const kTrackingEventSelectGiftCardTemplate;

NSString * const kTrackingEventEnterGiftDelivery;
NSString * const kTrackingEventEnablePhoneNotify;
NSString * const kTrackingEventEnableEmailNotify;
NSString * const kTrackingEventEnableDelayNotify;

NSString * const kTrackingEventEnterGiftOrderDetail;
NSString * const kTrackingEventSendGiftOrder;

NSString * const kTrackingEventEnterSentGiftDetail;
NSString * const kTrackingEventPayGiftOrder;
NSString * const kTrackingEventCancelGiftOrder;
NSString * const kTrackingEventShareOrder;

NSString * const kTrackingEventEnterSentGiftList;

NSString * const kTrackingEventEnterOccasionDetail;
NSString * const kTrackingEventOccasionDetailLoadMoreGifts;

NSString * const kTrackingEventEnterAstroTrendList;
NSString * const kTrackingEventEnterAstroTrendDetail;

NSString * const kTrackingEventEnterSongsList;
NSString * const kTrackingEventEnterWishesList;

NSString * const kTrackingEventShareVirtualGift;
NSString * const kTrackingEventShareDIYGift;
NSString * const kTrackingEventShareGIFGift;
NSString * const kTrackingEventCommentTweet;
NSString * const kTrackingEventForwardTweet;
NSString * const kTrackingEventShareAstroTrend;

NSString * const kTrackingEventEnterFriendEmotionList;
NSString * const kTrackingEventEnterFriendEmotionDetail;

NSString * const kTrackingEventEnterOccasionList;

NSString * const kTrackingEventEnterMyLikes;

NSString * const kTrackingEventEnterShare;
NSString * const kTrackingEventEnterGIFGifts;
NSString * const kTrackingEventEnterLoginView;

NSString * const kTrackingEventEnterRecipientAddressView;
NSString * const kTrackingEventEnterRecipientContactView;

@class HGTrackingLoader;
@interface HGTrackingService : NSObject{
@private
    //HGTrackingLoader* trackingLoader;
}

+ (void)startSession;

+ (void)logEvent:(NSString *)eventName;
+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters;

+ (void)logAllPageViews:(UINavigationController*)navigationController;	
+ (void)logPageView;

@end


