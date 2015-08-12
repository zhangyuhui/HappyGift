//
//  HGAccountService.m
//  HappyGift
//
//  Created by Yuhui Zhang on 4/10/12.
//  Copyright (c) 2012 Ztelic Inc. All rights reserved.
//

#import "HGAccountService.h"
#import "HGConstants.h"
#import "HGAccountLoader.h"
#import <sqlite3.h>
#import "HappyGiftAppDelegate.h"
#import "WBEngine.h"
#import "HGRecipientService.h"
#import "HGLoaderCache.h"
#import "HGPushNotificationService.h"
#import "HGGiftCollectionService.h"
#import "HGFriendRecommandationService.h"
#import "HGGiftOrderService.h"
#import "HGGiftSetsService.h"
#import "HGCreditService.h"
#import "HGAstroTrendService.h"
#import "HGFriendEmotionService.h"

static HGAccountService* accountService = nil;

static NSString *kUsersDBFilename = @"accounts.sqlite";
static sqlite3  *kUsersDB = nil;

static NSString *kUsersDBCreateFormat = @"CREATE TABLE IF NOT EXISTS accounts (user_id TEXT, user_token TEXT, user_name TEXT, user_phone TEXT, user_email TEXT, weibo_user_id TEXT, weibo_user_name TEXT, weibo_user_description TEXT, weibo_user_signature TEXT, weibo_user_icon TEXT, weibo_user_icon_large TEXT, weibo_user_statistics TEXT, weibo_access_token TEXT, weibo_access_token_secret TEXT, weibo_oauth_verifier TEXT, renren_user_id TEXT, renren_user_name TEXT, renren_user_icon TEXT, renren_user_icon_large TEXT, renren_access_token TEXT, renren_access_token_secret TEXT)";
static NSString *kUsersDBIndexFormat =  @"CREATE INDEX IF NOT EXISTS accounts ON accounts (weibo_user_id)";
static NSString *kUsersDBSQLInsertFormat = @"INSERT INTO accounts (user_id, user_token, user_name, user_phone, user_email, weibo_user_id, weibo_user_name, weibo_user_description, weibo_user_signature, weibo_user_icon, weibo_user_icon_large, weibo_user_statistics, weibo_access_token, weibo_access_token_secret, weibo_oauth_verifier, renren_user_id, renren_user_name, renren_user_icon, renren_user_icon_large, renren_access_token, renren_access_token_secret) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
static NSString *kUsersDBSQLUpdateFormat = @"UPDATE accounts SET user_token = ?, user_name = ?, user_phone = ?, user_email = ?, weibo_user_id = ?, weibo_user_name = ?, weibo_user_description = ?, weibo_user_signature = ?, weibo_user_icon = ?, weibo_user_icon_large = ?, weibo_user_statistics = ?, weibo_access_token = ?, weibo_access_token_secret = ?, weibo_oauth_verifier = ?, renren_user_id = ?, renren_user_name = ?, renren_user_icon = ?, renren_user_icon_large = ?, renren_access_token = ?, renren_access_token_secret = ? WHERE user_id = ?";

static NSString *kUsersDBSQLClear = @"DELETE FROM accounts";
static NSString *kUsersDBSQLDeleteFormat = @"DELETE FROM accounts WHERE user_id = ?";
static NSString *kUsersDBSQLQueryAllFormat  = @"SELECT user_id, user_token, user_name, user_phone, user_email, weibo_user_id, weibo_user_name, weibo_user_description, weibo_user_signature, weibo_user_icon, weibo_user_icon_large, weibo_user_statistics, weibo_access_token, weibo_access_token_secret, weibo_oauth_verifier, renren_user_id, renren_user_name, renren_user_icon, renren_user_icon_large, renren_access_token, renren_access_token_secret FROM accounts ORDER BY user_id ASC";

static NSString *kUsersDBSQLQueryAllCountFormat  = @"SELECT count(*) FROM accounts";
static NSString *kUsersDBSQLQueryCountFormat  = @"SELECT count(*) FROM accounts WHERE user_id = ?";
static NSString *kUsersDBSQLQueryFormat  = @"SELECT user_token, user_name, user_phone, user_email, weibo_user_id, weibo_user_name, weibo_user_description, weibo_user_signature, weibo_user_icon, weibo_user_icon_large, weibo_user_statistics, weibo_access_token, weibo_access_token_secret, weibo_oauth_verifier, renren_user_id, renren_user_name, renren_user_icon, renren_user_icon_large, renren_access_token, renren_access_token_secret FROM accounts WHERE user_id = ?";

@interface HGAccountService ()<HGAccountLoaderDelegate> 

@end

@implementation HGAccountService
@synthesize currentAccount;
@synthesize delegate;

+ (void)initialize {
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:kUsersDBFilename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dbPath] == NO) {
		if ([fileManager createFileAtPath:dbPath contents:nil attributes:nil] == YES){
			sqlite3_open([dbPath UTF8String], &kUsersDB);
			//const char *errmsg = nil;
            sqlite3_exec(kUsersDB, [kUsersDBCreateFormat UTF8String], NULL, NULL, NULL);
			//errmsg = sqlite3_errmsg(kUsersDB);
            sqlite3_exec(kUsersDB, [kUsersDBIndexFormat UTF8String], NULL, NULL, NULL);
			//errmsg = sqlite3_errmsg(kUsersDB);
			sqlite3_close(kUsersDB);
			kUsersDB = nil;
        }
	}
}

+ (void)finalize {
    if (kUsersDB != nil) {
        sqlite3_close(kUsersDB);
        kUsersDB = nil;
    }
}

- (id)init {
    if ((self = [super init])) {
		if (kUsersDB == nil) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir = [paths objectAtIndex:0];
            NSString *dbPath = [documentsDir stringByAppendingPathComponent:kUsersDBFilename];
            if (sqlite3_open([dbPath UTF8String], &kUsersDB) != SQLITE_OK) {
                sqlite3_close(kUsersDB);
                kUsersDB = nil;
            }
        }
        
        NSString* accountUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kHGPreferneceKeyAccountUserId];
        if (accountUserId != nil){
            self.currentAccount = [self getAccount:accountUserId];
        }
    }
    
    return self;
}

- (void)dealloc {
    [currentAccount release];
    [accountLoader release];
    
    [super dealloc];
}

+ (HGAccountService*)sharedService{
    if (accountService == nil){
        accountService = [[HGAccountService alloc] init];
    }
    return accountService;
}

- (BOOL)isAllSNSAccountLoggedIn {
    return [[WBEngine sharedWeibo] isLoggedIn] && [[RenrenService sharedRenren] isSessionValid];
}

- (BOOL)hasSNSAccountLoggedIn {
    return [[WBEngine sharedWeibo] isLoggedIn] || [[RenrenService sharedRenren] isSessionValid];
}

- (NSArray*)loadAccounts{
	//const char *errmsg = nil;
    NSString *queryAll = kUsersDBSQLQueryAllFormat;
    const char *sqlAll = [queryAll cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *selectstmtAll;
    
	NSMutableArray* accounts = [[[NSMutableArray alloc] init] autorelease];
	
	int prep = sqlite3_prepare_v2(kUsersDB, sqlAll, -1, &selectstmtAll, NULL);
    if(prep == SQLITE_OK) {
		while(sqlite3_step(selectstmtAll) == SQLITE_ROW) {
            NSString* userId = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 0)];
            NSString* userToken = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 1)];
            NSString* userName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 2)];
            NSString* userPhone = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 3)];
            NSString* userEmail = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 4)];
            NSString* weiBoUserId = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 5)];
            NSString* weiBoUserName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 6)];
            NSString* weiBoUserDescription = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 7)];
            NSString* weiBoUserSignature = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 8)];
            NSString* weiBoUserIcon = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 9)];
            NSString* weiBoUserIconLarge = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 10)];
            NSString* weiBoUserStatistics = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 11)];
            NSString* weiBoAccessToken = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 12)];
			NSString* weiBoAccessTokenSecret = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 13)];
			NSString* weiBoOauthVerifier = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 14)];
            
            NSString* renrenUserId = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 15)];
            NSString* renrenUserName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 16)];
            NSString* renrenUserIcon = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 17)];
            NSString* renrenUserIconLarge = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 18)];
            NSString* renrenAccessToken = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 19)];
            NSString* renrenAccessTokenSecret = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(selectstmtAll, 20)];
            
			
            HGAccount* account = [[HGAccount alloc] init];
            account.userId = userId;
            account.userToken = userToken;
            account.userName = userName;
            account.userPhone = userPhone;
            account.userEmail = userEmail;
            account.weiBoUserId = weiBoUserId;
            account.weiBoUserName = weiBoUserName;
            account.weiBoUserDescription = weiBoUserDescription;
            account.weiBoUserSignature = weiBoUserSignature;
            account.weiBoUserIcon = weiBoUserIcon;
            account.weiBoUserIconLarge = weiBoUserIconLarge;
            account.weiBoAuthToken = weiBoAccessToken;
            account.weiBoAuthSecret = weiBoAccessTokenSecret;
            account.weiBoAuthVerifier = weiBoOauthVerifier;
			
            NSArray* weiBoUserStatisticsComponents = [weiBoUserStatistics componentsSeparatedByString:@","];
            account.weiboFavoriteCount = [[weiBoUserStatisticsComponents objectAtIndex:0] intValue];
            account.weiboStatusCount = [[weiBoUserStatisticsComponents objectAtIndex:1] intValue];
            account.weiboFriendsCount = [[weiBoUserStatisticsComponents objectAtIndex:2] intValue];
            account.weiboFollowersCount = [[weiBoUserStatisticsComponents objectAtIndex:3] intValue];
            
            account.renrenUserId = renrenUserId;
            account.renrenUserName = renrenUserName;
            account.renrenUserIcon = renrenUserIcon;
            account.renrenUserIconLarge = renrenUserIconLarge;
            account.renrenAuthToken = renrenAccessToken;
            account.renrenAuthSecret = renrenAccessTokenSecret;
            
           [accounts addObject:account];
			
			[account release];
			
            [userId release];
            [userToken release];
            [userName release];
            [userPhone release];
            [userEmail release];
			[weiBoUserId release];
			[weiBoUserName release];
            [weiBoUserDescription release];
            [weiBoUserIcon release];
            [weiBoUserIconLarge release];
			[weiBoAccessToken release];
			[weiBoAccessTokenSecret release];
			[weiBoOauthVerifier release];
            [weiBoUserSignature release];
            [weiBoUserStatistics release];
            
            [renrenUserId release];
            [renrenUserName release];
            [renrenUserIcon release];
            [renrenUserIconLarge release];
            [renrenAccessToken release];
            [renrenAccessTokenSecret release];
		}
    }/*else {
      errmsg = sqlite3_errmsg(kUsersDB);
      }*/
	
	sqlite3_reset(selectstmtAll);
    
    if (selectstmtAll) {
        sqlite3_finalize(selectstmtAll);
        selectstmtAll = nil;
    }
    
	return accounts;
}

- (BOOL)addAccount:(HGAccount*)account{
    const char *errmsg = nil;
    const char *querySQL = [kUsersDBSQLQueryCountFormat cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *queryStmt;
    int query = 0;
	int prep = sqlite3_prepare_v2(kUsersDB, querySQL, -1, &queryStmt, NULL);
    if(prep == SQLITE_OK) {
        sqlite3_bind_text(queryStmt, 1, [account.userId UTF8String], -1, NULL);
        if(sqlite3_step(queryStmt) == SQLITE_ROW) {
            query = sqlite3_column_int(queryStmt, 0);
        }else {
			errmsg = sqlite3_errmsg(kUsersDB);
		}
    }else {
        errmsg = sqlite3_errmsg(kUsersDB);
    }
    
    if (query == 0){
        const char *insertSQL = [kUsersDBSQLInsertFormat cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_stmt *insertStmt = nil;
        int insertDbrc = sqlite3_prepare_v2(kUsersDB, insertSQL, -1, &insertStmt, nil);
        if (insertDbrc == SQLITE_OK)  {
            sqlite3_bind_text(insertStmt, 1, [account.userId UTF8String], -1, NULL);
            sqlite3_bind_text(insertStmt, 2, [account.userToken UTF8String], -1, NULL);
            sqlite3_bind_text(insertStmt, 3, account.userName != nil?[account.userName UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 4, account.userPhone != nil?[account.userPhone UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 5, account.userEmail != nil?[account.userEmail UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 6, account.weiBoUserId != nil?[account.weiBoUserId UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 7, account.weiBoUserName != nil?[account.weiBoUserName UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 8, account.weiBoUserDescription != nil?[account.weiBoUserDescription UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 9, account.weiBoUserSignature != nil?[account.weiBoUserSignature UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 10, account.weiBoUserIcon != nil?[account.weiBoUserIcon UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 11, account.weiBoUserIconLarge != nil?[account.weiBoUserIconLarge UTF8String]:"", -1, NULL);
            NSString* weiboUserStatistics = [NSString stringWithFormat:@"%d,%d,%d,%d", account.weiboFavoriteCount, account.weiboStatusCount, account.weiboFriendsCount, account.weiboFollowersCount];
            sqlite3_bind_text(insertStmt, 12, [weiboUserStatistics UTF8String], -1, NULL);
            sqlite3_bind_text(insertStmt, 13, account.weiBoAuthToken != nil?[account.weiBoAuthToken UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 14, account.weiBoAuthSecret != nil?[account.weiBoAuthSecret UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 15, account.weiBoAuthVerifier != nil?[account.weiBoAuthVerifier UTF8String]:"", -1, NULL);
            
            sqlite3_bind_text(insertStmt, 16, account.renrenUserId != nil?[account.renrenUserId UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 17, account.renrenUserName != nil?[account.renrenUserName UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 18, account.renrenUserIcon != nil?[account.renrenUserIcon UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 19, account.renrenUserIconLarge != nil?[account.renrenUserIconLarge UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 20, account.renrenAuthToken != nil?[account.renrenAuthToken UTF8String]:"", -1, NULL);
            sqlite3_bind_text(insertStmt, 21, account.renrenAuthSecret != nil?[account.renrenAuthSecret UTF8String]:"", -1, NULL);
            if (sqlite3_step(insertStmt) != SQLITE_DONE) {
                errmsg = sqlite3_errmsg(kUsersDB);
            }
            sqlite3_reset(insertStmt);
        }else {
            errmsg = sqlite3_errmsg(kUsersDB);
        }
        
        if (insertStmt) {
            sqlite3_finalize(insertStmt);
            insertStmt = nil;
        }
    }else{
        const char *updateSQL = [kUsersDBSQLUpdateFormat cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_stmt *updateStmt = nil;
        int updateDbrc = sqlite3_prepare_v2(kUsersDB, updateSQL, -1, &updateStmt, nil);
        if (updateDbrc == SQLITE_OK)  {
            
            sqlite3_bind_text(updateStmt, 1, [account.userToken UTF8String], -1, NULL);
            sqlite3_bind_text(updateStmt, 2, account.userName != nil?[account.userName UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 3, account.userPhone != nil?[account.userPhone UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 4, account.userEmail != nil?[account.userEmail UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 5, account.weiBoUserId != nil?[account.weiBoUserId UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 6, account.weiBoUserName != nil?[account.weiBoUserName UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 7, account.weiBoUserDescription != nil?[account.weiBoUserDescription UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 8, account.weiBoUserSignature != nil?[account.weiBoUserSignature UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 9, account.weiBoUserIcon != nil?[account.weiBoUserIcon UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 10, account.weiBoUserIconLarge != nil?[account.weiBoUserIconLarge UTF8String]:"", -1, NULL);
            NSString* weiboUserStatistics = [NSString stringWithFormat:@"%d,%d,%d,%d", account.weiboFavoriteCount, account.weiboStatusCount, account.weiboFriendsCount, account.weiboFollowersCount];
            sqlite3_bind_text(updateStmt, 11, [weiboUserStatistics UTF8String], -1, NULL);
            sqlite3_bind_text(updateStmt, 12, account.weiBoAuthToken != nil?[account.weiBoAuthToken UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 13, account.weiBoAuthSecret != nil?[account.weiBoAuthSecret UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 14, account.weiBoAuthVerifier != nil?[account.weiBoAuthVerifier UTF8String]:"", -1, NULL);
            
            sqlite3_bind_text(updateStmt, 15, account.renrenUserId != nil?[account.renrenUserId UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 16, account.renrenUserName != nil?[account.renrenUserName UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 17, account.renrenUserIcon != nil?[account.renrenUserIcon UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 18, account.renrenUserIconLarge != nil?[account.renrenUserIconLarge UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 19, account.renrenAuthToken != nil?[account.renrenAuthToken UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 20, account.renrenAuthSecret != nil?[account.renrenAuthSecret UTF8String]:"", -1, NULL);
            sqlite3_bind_text(updateStmt, 21, [account.userId UTF8String], -1, NULL);
            
            if (sqlite3_step(updateStmt) != SQLITE_DONE) {
                errmsg = sqlite3_errmsg(kUsersDB);
            }
            sqlite3_reset(updateStmt);
        }else {
            errmsg = sqlite3_errmsg(kUsersDB);
        }
        
        if (updateStmt) {
            sqlite3_finalize(updateStmt);
            updateStmt = nil;
        }
    }
	
    return errmsg == nil;
}

- (BOOL)updateAccount:(HGAccount*)account{
    return [self addAccount:account];
}

- (BOOL)removeAccount:(NSString*)userId{
    const char *deleteSql = [kUsersDBSQLDeleteFormat cStringUsingEncoding:NSUTF8StringEncoding];
    const char *errmsg = nil;
    sqlite3_stmt *deleteStmt = nil;
    int deleteDbrc = sqlite3_prepare_v2(kUsersDB, deleteSql, -1, &deleteStmt, nil);
    if (deleteDbrc == SQLITE_OK)  {
        sqlite3_bind_text(deleteStmt, 1, [userId UTF8String], -1, NULL);
        if (sqlite3_step(deleteStmt) != SQLITE_DONE) {
            errmsg = sqlite3_errmsg(kUsersDB);
        }
    }
    sqlite3_reset(deleteStmt);
    if (deleteStmt) {
        sqlite3_finalize(deleteStmt);
        deleteStmt = nil;
    }
    return errmsg == nil;
}

- (HGAccount*)getAccount:(NSString*)userId{
    //const char *errmsg = nil;
    
	NSString *queryUser = kUsersDBSQLQueryFormat;
    const char *querySQL = [queryUser cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *queryUserStmt;
    HGAccount* account = nil;
    int prep = sqlite3_prepare_v2(kUsersDB, querySQL, -1, &queryUserStmt, NULL);
    if(prep == SQLITE_OK) {
        sqlite3_bind_text(queryUserStmt, 1, [userId UTF8String], -1, NULL);
		if (sqlite3_step(queryUserStmt) == SQLITE_ROW) {
            NSString* userToken = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 0)];
            NSString* userName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 1)];
            NSString* userPhone = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 2)];
            NSString* userEmail = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 3)];
			NSString* weiBoUser = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 4)];
            NSString* weiBoUserName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 5)];
            NSString* weiBoUserDescription = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 6)];
            NSString* weiBoUserSignature = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 7)];
            NSString* weiBoUserIcon = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 8)];
            NSString* weiBoUserIconLarge = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 9)];
            NSString* weiBoUserStatistics = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 10)];
            NSString* weiBoAccessToken = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 11)];
			NSString* weiBoAccessTokenSecret = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 12)];
			NSString* weiBoAuthVerifier = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 13)];

            NSString* renrenUserId = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 14)];
            NSString* renrenUserName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 15)];
            NSString* renrenUserIcon = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 16)];
            NSString* renrenUserIconLarge = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 17)];
            NSString* renrenAccessToken = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 18)];
            NSString* renrenAccessTokenSecret = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(queryUserStmt, 19)];
            
            
            account = [[[HGAccount alloc] init] autorelease];
            account.userId = userId;
            account.userToken = userToken;
            account.userName = userName;
            account.userPhone = userPhone;
            account.userEmail = userEmail;
            account.weiBoUserId = weiBoUser;
            account.weiBoUserName = weiBoUserName;
            account.weiBoUserDescription = weiBoUserDescription;
            account.weiBoUserSignature = weiBoUserSignature;
            account.weiBoUserIcon = weiBoUserIcon;
            account.weiBoUserIconLarge = weiBoUserIconLarge;
            account.weiBoAuthToken = weiBoAccessToken;
            account.weiBoAuthSecret = weiBoAccessTokenSecret;
            account.weiBoAuthVerifier = weiBoAuthVerifier;
            
            NSArray* weiBoUserStatisticsComponents = [weiBoUserStatistics componentsSeparatedByString:@","];
            account.weiboFavoriteCount = [[weiBoUserStatisticsComponents objectAtIndex:0] intValue];
            account.weiboStatusCount = [[weiBoUserStatisticsComponents objectAtIndex:1] intValue];
            account.weiboFriendsCount = [[weiBoUserStatisticsComponents objectAtIndex:2] intValue];
            account.weiboFollowersCount = [[weiBoUserStatisticsComponents objectAtIndex:3] intValue];
            
            account.renrenUserId = renrenUserId;
            account.renrenUserName = renrenUserName;
            account.renrenUserIcon = renrenUserIcon;
            account.renrenUserIconLarge = renrenUserIconLarge;
            account.renrenAuthToken = renrenAccessToken;
            account.renrenAuthSecret = renrenAccessTokenSecret;
			
            [userToken release];
            [userName release];
            [userPhone release];
            [userEmail release];
            
			[weiBoUser release];
			[weiBoUserName release];
            [weiBoUserDescription release];
            [weiBoUserIcon release];
            [weiBoUserIconLarge release];
            [weiBoUserSignature release];
            [weiBoUserStatistics release];
			[weiBoAccessToken release];
			[weiBoAccessTokenSecret release];
			[weiBoAuthVerifier release];
            
            [renrenUserId release];
            [renrenUserName release];
            [renrenUserIcon release];
            [renrenUserIconLarge release];
            [renrenAccessToken release];
            [renrenAccessTokenSecret release];
        }/*else {
            errmsg = sqlite3_errmsg(kUsersDB);
        }*/
    }/*else {
      errmsg = sqlite3_errmsg(kUsersDB);
    }*/
	
	sqlite3_reset(queryUserStmt);
    
    if (queryUserStmt) {
        sqlite3_finalize(queryUserStmt);
        queryUserStmt = nil;
    }
    
	return account;  
}

- (void)setCurrentAccount:(HGAccount *)theCurrentAccount{
    if (currentAccount != nil){
        [currentAccount release];
        currentAccount = nil;
    }
    currentAccount = [theCurrentAccount retain];
    if (currentAccount != nil){
        [[NSUserDefaults standardUserDefaults] setObject:currentAccount.userId forKey:kHGPreferneceKeyAccountUserId];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kHGPreferneceKeyAccountUserId];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)createAccount {
    if (accountLoader == nil){
        accountLoader = [[HGAccountLoader alloc] init];
        accountLoader.delegate = self;
    }
    [self localLogout:NETWORK_ALL_SNS];
    
    [accountLoader requestNewUserIgnoreCookie:YES];
}

- (void)bindRenrenAccount:(HGAccount*)account andExpireTime: (NSUInteger)expires {
    if (accountLoader == nil){
        accountLoader = [[HGAccountLoader alloc] init];
        accountLoader.delegate = self;
    }
    [accountLoader requestBindRenrenUser:account andExpireTime: expires];
}

- (void)bindWeiboAccount:(HGAccount*)account andExpireTime: (NSUInteger)exipres {
    if (accountLoader == nil){
        accountLoader = [[HGAccountLoader alloc] init];
        accountLoader.delegate = self;
    }
    [accountLoader requestBindWeiboUser:account andExpireTime: exipres];
}

- (void)unbindSNSAccount:(int)networkId andProfileId:(NSString*)profileId {
    if (!unbindSNSAccountLoader) {
        unbindSNSAccountLoader = [[HGAccountLoader alloc] init];
        unbindSNSAccountLoader.delegate = self;
    }
    [unbindSNSAccountLoader requestUnbindSNSUser:networkId andProfileId:profileId];
}

- (void)clearPersonalCache {
    [HGRecipientService sharedService].selectedRecipient = nil;
    [[HGGiftCollectionService sharedService] clearPersonalizedOccasionCache];
    [HGFriendRecommandationService sharedService].friendRecommandations = nil;
    [[HGGiftOrderService sharedService] clearMyGiftsCache];
    [[HGGiftSetsService sharedService] clearMyLikesCache];
    [[HGCreditService sharedService] clearCreditTotal];
    [[HGAstroTrendService sharedService] clearAstroTrends];
    [[HGFriendEmotionService sharedService] clearFriendEmotions];
}

- (void)localLogout:(int)networkId {
    if (networkId == NETWORK_SNS_WEIBO || networkId == NETWORK_SNS_RENREN || networkId == NETWORK_ALL_SNS) {
        if (networkId == NETWORK_SNS_WEIBO || networkId == NETWORK_ALL_SNS) {
            [[HGRecipientService sharedService] clearSNSRecipients:NETWORK_SNS_WEIBO];
            if ([[WBEngine sharedWeibo] isLoggedIn]){
                [[WBEngine sharedWeibo] logOut];
            }
        } 
        
        if (networkId == NETWORK_SNS_RENREN || networkId == NETWORK_ALL_SNS) {
            [[HGRecipientService sharedService] clearSNSRecipients:NETWORK_SNS_RENREN];
            if ([[RenrenService sharedRenren] isSessionValid]){
                [[RenrenService sharedRenren] logout:nil];
            }
        }
        
        [self clearPersonalCache];
    }
}

//- (void)createAccount:(NSString*)userId{
//    if (accountLoader == nil){
//        accountLoader = [[HGAccountLoader alloc] init];
//        accountLoader.delegate = self;
//    }
//    if (userId == nil || [userId isEqualToString:@""] == YES){
//        [accountLoader requestNewUser];
//    }else{
//        [accountLoader requestUserInterests:userId];
//    }
//}


#pragma mark HGAccountLoaderDelegate
- (void)accountLoader:(HGAccountLoader *)theAccountLoader didUserCreateSucceed:(NSString*)userId userToken:(NSString *)userToken{
    HGAccount* theAccount = [[HGAccount alloc] init];
    theAccount.userId = userId;
    theAccount.userToken = userToken;
    if ([delegate respondsToSelector:@selector(accountService:didAccountCreateSucceed:)]){
        [delegate accountService:self didAccountCreateSucceed:theAccount];
    }
    [theAccount release];
}

- (void)accountLoader:(HGAccountLoader *)theAccountLoader didUserCreateFail:(NSString *)error{
    if ([delegate respondsToSelector:@selector(accountService:didAccountCreateFail:)]){
        [delegate accountService:self didAccountCreateFail:error];
    }
}

- (void)accountLoader:(HGAccountLoader *)theAccountLoader didUserBindSucceed:(NSString*)userId userToken:(NSString*)userToken userName:(NSString*)userName userEmail:(NSString*)userEmail userPhone:(NSString*)userPhone{
    HGAccount* theAccount = [[HGAccount alloc] init];
    theAccount.userId = userId;
    theAccount.userToken = userToken;
    theAccount.userName = userName;
    theAccount.userEmail = userEmail;
    theAccount.userPhone = userPhone;
    if ([delegate respondsToSelector:@selector(accountService:didAccountBindSucceed:)]){
        [delegate accountService:self didAccountBindSucceed:theAccount];
    }
    [theAccount release];
}

- (void)accountLoader:(HGAccountLoader *)theAccountLoader didUserBindFail:(NSString *)error{
    if ([delegate respondsToSelector:@selector(accountService:didAccountBindFail:)]){
        [delegate accountService:self didAccountBindFail:error];
    }
}

- (void)accountLoader:(HGAccountLoader *)accountLoader didUserUnbindSucceed:(int)networkId withNewUserId:(NSString *)userId andToken:(NSString *)token {
    
    HGAccount* theAccount = nil;
    if (userId && ![@"" isEqualToString:userId] && token && ![@"" isEqualToString:token]) {
        theAccount = [[HGAccount alloc] init];
        theAccount.userId = userId;
        theAccount.userToken = token;
    }
    
    if (theAccount) {
        [accountService addAccount:theAccount];
        accountService.currentAccount = theAccount;
        
        /*NSMutableDictionary *tokenCookie = [NSMutableDictionary dictionary];
        [tokenCookie setObject:[NSString stringWithFormat:@"user_id=%@;token=%@", accountService.currentAccount.userId, accountService.currentAccount.userToken] forKey:NSHTTPCookieValue];
        [tokenCookie setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:tokenCookie];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];*/
        
        HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.deviceToken != nil){
            [[HGPushNotificationService sharedService] requestRegisterDeviceToken:appDelegate.deviceToken];
        }
    }

    [self localLogout:networkId];
    if ([delegate respondsToSelector:@selector(accountService:didAccountUnbindSucceed:withUpdatedAccount:)]) {
        [delegate accountService:self didAccountUnbindSucceed:networkId withUpdatedAccount:theAccount];
    }
    
    if (networkId == NETWORK_SNS_RENREN || networkId == NETWORK_SNS_WEIBO || networkId == NETWORK_ALL_SNS) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationAccountUpdated object:nil];
    }
    
    [theAccount release];
}

- (void)accountLoader:(HGAccountLoader *)accountLoader didUserUnbindFail:(int)networkId withError:(NSString *)error {
    if ([delegate respondsToSelector:@selector(accountService:didAccountUnbindFail:withError:)]) {
        [delegate accountService:self didAccountUnbindFail:networkId withError:error];
    }
}
@end
