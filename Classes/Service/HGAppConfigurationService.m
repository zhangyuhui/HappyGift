//
//  HGAppConfigurationService.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-6.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGAppConfigurationService.h"
#import "HGAppConfigurationLoader.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "HGLoaderCache.h"
#import "HGUtility.h"
#import "HGLogging.h"
#import "HGGiftCategory.h"
#import "HGOccasionCategory.h"
#import "UIDevice+Addition.h"

static HGAppConfigurationService* appConfigurationService;

@interface HGAppConfigurationService () <HGAppConfigurationLoaderDelegate>

@property (nonatomic, retain) NSDictionary* appConfiguration;

@end

@implementation HGAppConfigurationService
@synthesize delegate;
@synthesize appConfiguration;

+ (HGAppConfigurationService*)sharedService {
    if (appConfigurationService == nil) {
        appConfigurationService = [[HGAppConfigurationService alloc] init];
        [appConfigurationService loadAppConfiguration];
    }
    return appConfigurationService;
}

- (void)dealloc {
    if (appConfigurationLoader && appConfigurationLoader.delegate == self) {
        appConfigurationLoader.delegate = nil;
    }
    
    [appConfigurationLoader release];
    appConfigurationLoader.delegate = nil;
    self.appConfiguration = nil;

    [super dealloc];
}

- (void)requestAppConfiguration {
    if (appConfigurationLoader != nil) {
        [appConfigurationLoader cancel];
    } else {
        appConfigurationLoader = [[HGAppConfigurationLoader alloc] init];
        appConfigurationLoader.delegate = self;
    }
    
    [appConfigurationLoader requestAppConfigurationForVersion:[HGUtility appVersion] andBuild:[HGUtility appBuild] andDeviceId:[[UIDevice currentDevice] uniqueDeviceIdentifier]];
}

// app configuration interfaces 
- (id)configurationForKey:(NSString *)key {
    return [appConfiguration objectForKey:key];
}

- (BOOL)isFriendRecommendationEnabled {
    return 1 == [[self configurationForKey:kAppConfigurationKeyEnableFriendRecommendation] intValue];
}

- (NSArray*) serverList {
    return [self configurationForKey:kAppConfigurationKeyServerList];
}

- (NSString*)aboutUsContent {
    return [self configurationForKey:kAppConfigurationKeyAboutUsContent];
}

- (NSString*)aboutUsPhone {
    return [self configurationForKey:kAppConfigurationKeyAboutUsPhone];
}

- (NSString*)aboutUsEmail {
    return [self configurationForKey:kAppConfigurationKeyAboutUsEmail];
}

- (NSString*)aboutUsWebSite {
    return [self configurationForKey:kAppConfigurationKeyAboutUsWebSite];
}

- (NSString*)aboutUsWeibo {
    return [self configurationForKey:kAppConfigurationKeyAboutUsWeibo];
}

- (NSArray*)mainPageSections {
    return [self configurationForKey:kAppConfigurationKeyMainPageSections];
}

- (NSArray*)defaultMainPageSections {
    return [NSArray arrayWithObjects:@"personalizedOccasion", @"astroTrend", @"friendEmotion", @"friendRecommendation", @"globalOccasion", @"virtualGifts", @"featuredGifts", @"sentGifts", nil];
}

- (NSDictionary*)occasionCategories {
    NSString *theOccassionCategoriesConfigFile = [[NSBundle mainBundle] pathForResource:@"OccasionCategoriesConfig" ofType:@"plist"];
    NSDictionary *theOccasionCategoriesConfigDictionary = [NSDictionary dictionaryWithContentsOfFile:theOccassionCategoriesConfigFile];
    NSArray *theOccassionCategoriesConfigArray = [theOccasionCategoriesConfigDictionary objectForKey:@"kOcassionCategories"];
    
    NSMutableDictionary* localOccasionCategories = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary* theOccasionDictionary in theOccassionCategoriesConfigArray) {
        HGOccasionCategory* theOccasionCategory = [[HGOccasionCategory alloc] init];
        
        theOccasionCategory.identifier = [theOccasionDictionary objectForKey:@"kOcassionId"];
        theOccasionCategory.name = [theOccasionDictionary objectForKey:@"kOcassionName"];
        theOccasionCategory.longName = [theOccasionDictionary objectForKey:@"kOcassionLongName"];
        theOccasionCategory.icon = [theOccasionDictionary objectForKey:@"kOcassionIcon"];
        theOccasionCategory.headerIcon = [theOccasionDictionary objectForKey:@"kOcassionHeaderIcon"];
        theOccasionCategory.headerBackground = [theOccasionDictionary objectForKey:@"kOcassionHeaderBackground"];
        
        [localOccasionCategories setObject:theOccasionCategory forKey:theOccasionCategory.identifier];
        [theOccasionCategory release];
    }
    
    NSMutableDictionary* theOccasionCategories = [[NSMutableDictionary alloc] init];
    
    NSArray* remoteOccasionCategories = [self configurationForKey:kAppConfigurationKeyOccasionCategories];
    for (NSDictionary* theOccasionDictionary in remoteOccasionCategories) {
        NSString* occasionId = [theOccasionDictionary objectForKey:@"occasion_id"];
        
        if (!occasionId || [@"" isEqualToString:occasionId]) {
            HGWarning(@"empty occasion id");
            continue;
        }
        
        NSString* occasionName = [theOccasionDictionary objectForKey:@"name"];
        NSString* occasionLongName = [theOccasionDictionary objectForKey:@"long_name"];
        
        HGOccasionCategory* theOccasionCategory = [[localOccasionCategories objectForKey:occasionId] retain];
        
        if (theOccasionCategory == nil) {
            theOccasionCategory = [[HGOccasionCategory alloc] init];
            theOccasionCategory.identifier = occasionId;
            theOccasionCategory.icon = @"occasion_holiday_icon_general";
            theOccasionCategory.headerIcon = @"occasion_holiday_header_icon_general";
            theOccasionCategory.headerBackground = @"occasion_holiday_header_background_general";
        }
        
        if (occasionName && ![@"" isEqualToString:occasionName]) {
            theOccasionCategory.name = occasionName;
        }
        
        if (occasionLongName && ![@"" isEqualToString:occasionLongName]) {
            theOccasionCategory.longName = occasionLongName;
        }
        
        [theOccasionCategories setValue:theOccasionCategory forKey:occasionId];
        [theOccasionCategory release];
    }
    
    [localOccasionCategories release];
    return [theOccasionCategories autorelease];
}

- (NSArray*)defaultOccasionCategories {
    NSMutableArray* theOccasionCategories = [[NSMutableArray alloc] init];
    
    NSString *theOccassionCategoriesConfigFile = [[NSBundle mainBundle] pathForResource:@"OccasionCategoriesConfig" ofType:@"plist"];
    NSDictionary *theOccasionCategoriesConfigDictionary = [NSDictionary dictionaryWithContentsOfFile:theOccassionCategoriesConfigFile];
    NSArray *theOccassionCategoriesConfigArray = [theOccasionCategoriesConfigDictionary objectForKey:@"kOcassionCategories"];
    
    for (NSDictionary* theOccasionDictionary in theOccassionCategoriesConfigArray) {
        NSString* occasionId = [theOccasionDictionary objectForKey:@"kOcassionId"];
        NSString* name = [theOccasionDictionary objectForKey:@"kOcassionName"];
        NSString* longName = [theOccasionDictionary objectForKey:@"kOcassionLongName"];
        
        NSDictionary* categoryDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:occasionId, @"occasion_id", name, @"name", longName, @"long_name", nil];
        [theOccasionCategories addObject:categoryDictionary];
        [categoryDictionary release];
    }
    
    return [theOccasionCategories autorelease];
}


- (NSArray*)giftCategories {
    NSString *theGiftCategoriesConfigFile = [[NSBundle mainBundle] pathForResource:@"GiftCategoriesConfig" ofType:@"plist"];
    NSDictionary *theGiftCategoriesConfigDicionary = [NSDictionary dictionaryWithContentsOfFile:theGiftCategoriesConfigFile];
    NSArray *theGiftCategoriesConfigArray = [theGiftCategoriesConfigDicionary objectForKey:@"kGiftCategories"];
    
    NSMutableDictionary* localGiftCategoriesDictionary = [[NSMutableDictionary alloc] init];
    for (NSDictionary* theGiftCategoryDictionary in theGiftCategoriesConfigArray) {
        NSString* categoryId = [theGiftCategoryDictionary objectForKey:@"kCategoryIdentifier"];
        
        HGGiftCategory* theGiftCategory = [[HGGiftCategory alloc] init];
        theGiftCategory.identifier = categoryId;
        theGiftCategory.name = [theGiftCategoryDictionary objectForKey:@"kCategoryName"];
        theGiftCategory.description = [theGiftCategoryDictionary objectForKey:@"kCategoryDescription"];
        theGiftCategory.cover = [theGiftCategoryDictionary objectForKey:@"kCategoryCover"];
        theGiftCategory.coverSelected = [theGiftCategoryDictionary objectForKey:@"kCategoryCoverSelected"];
        
        [localGiftCategoriesDictionary setValue:theGiftCategory forKey:categoryId];
        
        [theGiftCategory release];
    }
    
    NSMutableArray* theGiftCategories = [[NSMutableArray alloc] init];
    NSArray* remoteGiftCategories = [self configurationForKey:kAppConfigurationKeyGiftCategories];
    
    for (NSDictionary* theGiftCategoryDictionary in remoteGiftCategories) {
        NSString* categoryId = [theGiftCategoryDictionary objectForKey:@"category_id"];
        NSString* name = [theGiftCategoryDictionary objectForKey:@"name"];
        
        HGGiftCategory* theGiftCategory = [[localGiftCategoriesDictionary objectForKey:categoryId] retain];
        if (theGiftCategory == nil) {
            theGiftCategory = [[HGGiftCategory alloc] init];
            theGiftCategory.identifier = categoryId;
            theGiftCategory.cover = @"gift_selection_category_69";
            theGiftCategory.coverSelected = @"gift_selection_category_selected_69"; 
        }
        
        theGiftCategory.name = name;
        
        [theGiftCategories addObject: theGiftCategory];
        [theGiftCategory release];
    }
    
    [localGiftCategoriesDictionary release];
    return [theGiftCategories autorelease];
}

- (NSArray*)defaultGiftCategories {
    NSMutableArray* theGiftCategories = [[NSMutableArray alloc] init];
    
    NSString *theGiftCategoriesConfigFile = [[NSBundle mainBundle] pathForResource:@"GiftCategoriesConfig" ofType:@"plist"];
    NSDictionary *theGiftCategoriesConfigDicionary = [NSDictionary dictionaryWithContentsOfFile:theGiftCategoriesConfigFile];
    NSArray *theGiftCategoriesConfigArray = [theGiftCategoriesConfigDicionary objectForKey:@"kGiftCategories"];
    
    for (NSDictionary* theGiftCategoryDictionary in theGiftCategoriesConfigArray) {
        NSString* categoryId = [theGiftCategoryDictionary objectForKey:@"kCategoryIdentifier"];
        NSString* categoryName = [theGiftCategoryDictionary objectForKey:@"kCategoryName"];
        
        NSDictionary* categoryDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:categoryId, @"category_id", categoryName, @"name", nil];
        
        [theGiftCategories addObject:categoryDictionary];
        [categoryDictionary release];
    }
    
    return [theGiftCategories autorelease];
}

- (NSDictionary*) defaultAppConfiguration {
    NSMutableDictionary* configuration = [[NSMutableDictionary alloc] init];
    
    // default config 1. friend recommendation
    [configuration setValue:0 forKey: kAppConfigurationKeyEnableFriendRecommendation];
    
    // default config 2. backend host list
    NSString *backendServiceHostsConfigFile = [[NSBundle mainBundle] pathForResource:@"BackendHostsConfig" ofType:@"plist"];
    NSDictionary *backendServiceHostsConfigDicionary = [NSDictionary dictionaryWithContentsOfFile:backendServiceHostsConfigFile];
    NSArray* appServerList = [backendServiceHostsConfigDicionary objectForKey:@"kBackendHosts"];
    [configuration setValue:appServerList forKey:kAppConfigurationKeyServerList];
    
    // default config 3. about us content
    [configuration setValue:@"乐送是一款即时创意礼品赠送手机应用。乐送帮助用户随时随地发现亲朋好友的重要时刻，并运用其专利所有的智能推荐技术，根据赠送对象的行为数据即时奉上精心挑选的礼品。" forKey:kAppConfigurationKeyAboutUsContent];
    
    // default config 4. about us email
    [configuration setValue:@"help@lesongapp.cn" forKey:kAppConfigurationKeyAboutUsEmail];
    
    // default config 5. about us web site
    [configuration setValue:@"http://lesongapp.cn" forKey:kAppConfigurationKeyAboutUsWebSite];
    
    // default config 6. about us phone
    [configuration setValue:@"(010)5114-8955" forKey:kAppConfigurationKeyAboutUsPhone];
    
    // default config 7. about us weibo
    [configuration setValue:@"乐送App" forKey:kAppConfigurationKeyAboutUsWeibo];
    
    // default config 8. gift categories
    [configuration setValue:[self defaultGiftCategories] forKey:kAppConfigurationKeyGiftCategories];
    
    // default config 9. occasion categories 
    [configuration setValue:[self defaultOccasionCategories] forKey:kAppConfigurationKeyOccasionCategories];
    
    // default config 10. credit exchange
    [configuration setValue:[NSNumber numberWithFloat:0.1] forKey:kAppConfigurationKeyCreditExchange];
    
    // default config 11. main page sections
    [configuration setValue:[self defaultMainPageSections] forKey:kAppConfigurationKeyMainPageSections];
    
    return [configuration autorelease];
}

- (void) saveAppConfiguration:(NSDictionary*)config {
    if (config) {
        NSString* key = [HGLoaderCache appConfigurationCacheKey];
        [HGLoaderCache saveDataToLoaderCache:config forKey:key];
    }
}

-(NSDictionary*) validateConfig:(NSDictionary*)config {
    NSMutableDictionary* newConfig = [[NSMutableDictionary alloc] initWithDictionary:config];
    
    id serverList = [newConfig objectForKey:kAppConfigurationKeyServerList];
    if (!(serverList && [serverList isKindOfClass:NSArray.class] && [(NSArray*)serverList count] > 0)) {
        HGWarning(@"invalid server config:%@ for %@", serverList, kAppConfigurationKeyServerList);
        [newConfig removeObjectForKey:kAppConfigurationKeyServerList];
    }
    
    id giftCategories = [newConfig objectForKey:kAppConfigurationKeyGiftCategories];
    if (!(giftCategories && [giftCategories isKindOfClass:NSArray.class] && [(NSArray*)giftCategories count] > 0)) {
        HGWarning(@"invalid server config:%@ for %@", giftCategories, kAppConfigurationKeyGiftCategories);
        [newConfig removeObjectForKey:kAppConfigurationKeyGiftCategories];
    }
    
    id mainSections = [newConfig objectForKey:kAppConfigurationKeyMainPageSections];
    if (!(mainSections && [mainSections isKindOfClass:NSArray.class] && [(NSArray*)mainSections count] > 0)) {
        HGWarning(@"invalid server config:%@ for %@", mainSections, kAppConfigurationKeyMainPageSections);
        [newConfig removeObjectForKey:kAppConfigurationKeyMainPageSections];
    }
    
    
    return [newConfig autorelease];
}

-(NSDictionary*) mergeAppConfigurationWithDefaultConfig:(NSDictionary*)config {
    NSMutableDictionary* newConfig = [[NSMutableDictionary alloc] initWithDictionary:[self defaultAppConfiguration]];
    NSDictionary* validatedConfig = [self validateConfig:config];
    
    for (NSString* key in [validatedConfig allKeys]) {
        [newConfig setValue:[validatedConfig objectForKey:key] forKey:key];
    }
    
    return [newConfig autorelease];
}

- (void) loadAppConfiguration {
    NSString* key = [HGLoaderCache appConfigurationCacheKey];
    NSDictionary* config = [HGLoaderCache loadDataFromLoaderCache:key];
    
    if (config == nil) {
        config = [self defaultAppConfiguration];
        self.appConfiguration = config;
    } else {
        self.appConfiguration = [self mergeAppConfigurationWithDefaultConfig:config];
    }
}

- (void) checkForNewVersionUpgrade {
    if (!appConfiguration) {
        return;
    }
    
    NSString* newVersion = [appConfiguration objectForKey:kAppConfigurationKeyNewVersion];
    NSString* newVersionDescription = [appConfiguration objectForKey:kAppConfigurationKeyNewVersionDescription];
    NSString* newVersionDownloadUrl = [appConfiguration objectForKey:kAppConfigurationKeyNewVersionDownloadUrl];

    NSString *appVersion = [HGUtility appVersion];  
    
    if (newVersion && ![@"" isEqualToString:newVersion] && ![appVersion isEqualToString:newVersion] &&
        newVersionDescription && ![@"" isEqualToString:newVersionDescription] &&
        newVersionDownloadUrl && ![@"" isEqualToString:newVersionDownloadUrl]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationNewVersionAvailable object:appConfiguration];
    }
}

#pragma mark HGAppConfigurationLoaderDelegate
- (void)appConfigurationLoader:(HGAppConfigurationLoader *)appConfigurationLoader didRequestAppConfigurationSucceed:(NSDictionary*)theAppConfiguration {
    self.appConfiguration = [self mergeAppConfigurationWithDefaultConfig:theAppConfiguration];
    [self checkForNewVersionUpgrade];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationAppConfigurationUpdated object:appConfiguration];
    
    if ([delegate respondsToSelector:@selector(appConfigurationService:didRequestAppConfigurationSucceed:)]){
        [delegate appConfigurationService:self didRequestAppConfigurationSucceed:theAppConfiguration];
    }
    [self saveAppConfiguration:theAppConfiguration];
}

- (void)appConfigurationLoader:(HGAppConfigurationLoader *)appConfigurationLoader didRequestAppConfigurationFail:(NSString*)error {
    
    if ([delegate respondsToSelector:@selector(appConfigurationService:didAppConfigurationFail:)]){
        [delegate appConfigurationService:self didAppConfigurationFail:error];
    }
}

@end
