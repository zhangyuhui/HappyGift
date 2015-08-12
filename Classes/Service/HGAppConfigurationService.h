//
//  HGAppConfigurationService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-6.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAppConfigurationKeyNewVersion                 @"new_version"
#define kAppConfigurationKeyNewVersionDescription      @"new_version_description"
#define kAppConfigurationKeyNewVersionDownloadUrl      @"new_version_download_url"

#define kAppConfigurationKeyEnableFriendRecommendation @"enable_friend_recommendation"

#define kAppConfigurationKeyServerList                 @"ip_list"

#define kAppConfigurationKeyAboutUsContent             @"about_us_content"
#define kAppConfigurationKeyAboutUsWeibo               @"about_us_weibo"
#define kAppConfigurationKeyAboutUsPhone               @"about_us_phone"
#define kAppConfigurationKeyAboutUsWebSite             @"about_us_web_site"
#define kAppConfigurationKeyAboutUsEmail               @"about_us_email"

#define kAppConfigurationKeyGiftCategories             @"gift_categories"
#define kAppConfigurationKeyOccasionCategories         @"occasion_categories"

#define kAppConfigurationKeyBucketId                   @"bucket_id"

#define kAppConfigurationKeyCreditExchange             @"credit_exchange"

#define kAppConfigurationKeyMainPageSections           @"main_page_sections"

@class HGAppConfigurationLoader;
@protocol HGAppConfigurationServiceDelegate;

@interface HGAppConfigurationService : NSObject {
    HGAppConfigurationLoader* appConfigurationLoader;
    id<HGAppConfigurationServiceDelegate> delegate;
}

@property (nonatomic, assign) id<HGAppConfigurationServiceDelegate> delegate;
@property (nonatomic, retain, readonly) NSDictionary* appConfiguration;
+ (HGAppConfigurationService*)sharedService;

- (void)requestAppConfiguration;
- (id)configurationForKey:(NSString*)key;
- (NSDictionary*) defaultAppConfiguration;

- (BOOL)isFriendRecommendationEnabled;
- (NSArray*)serverList;
- (NSString*)aboutUsContent;
- (NSString*)aboutUsPhone;
- (NSString*)aboutUsEmail;
- (NSString*)aboutUsWebSite;
- (NSString*)aboutUsWeibo;
- (NSArray*)giftCategories;
- (NSDictionary*)occasionCategories;
- (NSArray*)mainPageSections;

@end

@protocol HGAppConfigurationServiceDelegate <NSObject>
- (void)appConfigurationService:(HGAppConfigurationService *)appConfigurationService didRequestAppConfigurationSucceed:(NSDictionary*)appConfiguration;

- (void)appConfigurationService:(HGAppConfigurationService *)appConfigurationService didAppConfigurationFail:(NSString*)error;
@end

