//
//  HGRecipientService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-17.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGRecipientService.h"
#import <sqlite3.h>
#import <AddressBook/AddressBook.h>
#import "NSString+Addition.h"
#import "NSObject+SBJSON.h"
#import "NSDate+Addition.h"
#import "HGPinyinService.h"
#import "HappyGiftAppDelegate.h"
#import "WBEngine.h"
#import "HGUtility.h"
#import "HGOccasionGiftCollection.h"
#import "HGGiftCollectionService.h"
#import "HGLogging.h"
#import "HGConstants.h"
#import "HGAccountService.h"

const int kAllSNSNetworkID = 999;
const int kRecipientLimit = 200;

const int DB_VERSION = 2;

static HGRecipientService* recipientService = nil;

static NSString *kRecipientsDBFilename = @"recipients.sqlite";
static sqlite3  *kRecipientsDB = nil;

static NSString *kColumnNameRecipientDisabled = @"text_field_0";

static NSString *kRecipientsDBAlterTableAddDisplayNameFormat = @"ALTER TABLE recipients ADD COLUMN recipient_display_name TEXT";

static NSArray *kRecipientsDBV1ToV2Columns;
static NSArray *kRecipientsDBV0ToV2Columns;

static NSString *kRecipientsDBDropRecipientsTable = @"DROP TABLE IF EXISTS recipients";
static NSString *kRecipientsDBCreateFormat = @"CREATE TABLE IF NOT EXISTS recipients (\
                                                                recipient_id INTEGER PRIMARY KEY AUTOINCREMENT,\
                                                                recipient_name TEXT,\
                                                                recipient_phone TEXT,\
                                                                recipient_email TEXT,\
                                                                recipient_image_url TEXT, \
                                                                recipient_profile_id TEXT,\
                                                                recipient_network_id INTEGER,\
                                                                recipient_birthday TEXT,\
                                                                recipient_pinyin TEXT,\
                                                                recipient_display_name TEXT,\
                                                                recipient_province TEXT,\
                                                                recipient_city TEXT,\
                                                                recipient_street_address TEXT,\
                                                                recipient_post_code TEXT,\
                                                                text_field_0 TEXT,\
                                                                text_field_1 TEXT,\
                                                                text_field_2 TEXT,\
                                                                text_field_3 TEXT,\
                                                                text_field_4 TEXT,\
                                                                text_field_5 TEXT,\
                                                                text_field_6 TEXT,\
                                                                text_field_7 TEXT,\
                                                                text_field_8 TEXT,\
                                                                text_field_9 TEXT\
                                                )";

static NSString *kRecipientsDBSQLQueryAllFormat  = @"SELECT recipient_id,\
                                                            recipient_name,\
                                                            recipient_phone,\
                                                            recipient_email,\
                                                            recipient_image_url,\
                                                            recipient_profile_id,\
                                                            recipient_network_id,\
                                                            recipient_birthday,\
                                                            recipient_display_name,\
                                                            recipient_province,\
                                                            recipient_city,\
                                                            recipient_street_address,\
                                                            recipient_post_code\
                                                            FROM recipients \
                                                            WHERE text_field_0 <> 1 OR text_field_0 IS NULL \
                                                            ORDER BY recipient_name ASC";

static NSString *kRecipientsDBSQLQueryPatternFormat  = @"SELECT recipient_id,\
                                                            recipient_name,\
                                                            recipient_phone,\
                                                            recipient_email,\
                                                            recipient_image_url,\
                                                            recipient_profile_id,\
                                                            recipient_network_id,\
                                                            recipient_birthday,\
                                                            recipient_display_name,\
                                                            recipient_province,\
                                                            recipient_city,\
                                                            recipient_street_address,\
                                                            recipient_post_code\
                                                            FROM recipients \
                                                            WHERE (recipient_name like '%%%@%%' \
                                                            OR recipient_pinyin like '%%%@%%') \
                                                            AND (text_field_0 <> 1 OR text_field_0 IS NULL) \
                                                            ORDER BY recipient_name ASC";

static NSString *kRecipientsDBSQLQueryFormat  = @"SELECT recipient_id,\
                                                            recipient_name,\
                                                            recipient_phone,\
                                                            recipient_email,\
                                                            recipient_image_url,\
                                                            recipient_profile_id,\
                                                            recipient_network_id,\
                                                            recipient_birthday,\
                                                            recipient_display_name,\
                                                            recipient_province,\
                                                            recipient_city,\
                                                            recipient_street_address,\
                                                            recipient_post_code\
                                                            FROM recipients WHERE recipient_id = ?";

static NSString *kRecipientsDBSQLQueryByProfileIdFormat  = @"SELECT recipient_id,\
                                                            recipient_name,\
                                                            recipient_phone,\
                                                            recipient_email,\
                                                            recipient_image_url,\
                                                            recipient_profile_id,\
                                                            recipient_network_id,\
                                                            recipient_birthday,\
                                                            recipient_display_name,\
                                                            recipient_province,\
                                                            recipient_city,\
                                                            recipient_street_address,\
                                                            recipient_post_code\
                                                            FROM recipients WHERE recipient_network_id = ? \
                                                            AND recipient_profile_id = ?";

static NSString *kRecipientsDBSQLInsertFormat = @"INSERT INTO recipients (recipient_name, recipient_phone, recipient_email, recipient_image_url, recipient_profile_id, recipient_network_id, recipient_birthday, recipient_pinyin, recipient_display_name, recipient_province, recipient_city, recipient_street_address, recipient_post_code, text_field_0) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)";

static NSString *kRecipientsDBSQLUpdateFormat = @"UPDATE recipients SET recipient_name = ?, recipient_phone = ?, recipient_email = ?, recipient_image_url = ?, recipient_profile_id = ?, recipient_network_id = ?, recipient_birthday = ?, recipient_pinyin = ?, recipient_display_name = ?, recipient_province = ?, recipient_city = ?, recipient_street_address = ?, recipient_post_code = ?, text_field_0 = 0 WHERE recipient_id = ?";

static NSString *kRecipientsDBSQLQueryCountFormat  = @"SELECT count(*) FROM recipients WHERE recipient_id = ?";

static NSString *kRecipientsDBSQLQueryRecipientFormat = @"SELECT recipient_id FROM recipients WHERE recipient_id = ? OR (recipient_network_id = ? AND recipient_profile_id = ?)";

static NSString *kRecipientsDBSQLQueryHasSNSFriendFormat = @"SELECT count(*) FROM recipients WHERE recipient_network_id = ?";

static NSString *kRecipientsDBSQLQueryRecipientCountFormat = @"SELECT count(*) FROM recipients WHERE (text_field_0 <> 1 OR text_field_0 IS NULL)";

static NSString *kRecipientsDBSQLQuerySNSRecipientCountFormat = @"SELECT count(*) FROM recipients WHERE (text_field_0 <> 1 OR text_field_0 IS NULL) AND (recipient_network_id = 1 OR recipient_network_id = 2)";

static NSString *kRecipientsDBSQLDeleteFormat = @"DELETE FROM recipients WHERE recipient_id = ?";

static NSString *kRecipientsDBSQLDeleteSNSFormat = @"DELETE FROM recipients WHERE recipient_network_id = 1 OR recipient_network_id = 2";

static NSString *kRecipientsDBSQLDeleteSpecificSNSFormat = @"DELETE FROM recipients WHERE recipient_network_id = ?";

static NSString *kRecipientsDBSQLDisableSNSFormat = @"UPDATE recipients SET text_field_0 = 1 WHERE recipient_network_id = 1 OR recipient_network_id = 2";

static NSString *kRecipientsDBSQLDisableSpecificSNSFormat = @"UPDATE recipients SET text_field_0 = 1 WHERE recipient_network_id = ?";

@interface HGRecipientService (Private) <HGRecipientLoaderDelegate>

- (void) fillRecipient: (HGRecipient*)recipient withQueryResult: (sqlite3_stmt*) statement;

@end

@implementation HGRecipientService

@synthesize delegate;
@synthesize selectedRecipient;
@synthesize provinceCode;

+ (void)initialize {
    
    kRecipientsDBV1ToV2Columns = [[NSArray alloc] initWithObjects:@"recipient_province", @"recipient_city", @"recipient_street_address", @"recipient_post_code", @"text_field_0", @"text_field_1", @"text_field_2", @"text_field_3", @"text_field_4", @"text_field_5", @"text_field_6", @"text_field_7", @"text_field_8", @"text_field_9", nil];
    
    NSMutableArray* columns = [[NSMutableArray alloc] initWithObjects:@"recipient_display_name", nil];
    [columns addObjectsFromArray:kRecipientsDBV1ToV2Columns];
    kRecipientsDBV0ToV2Columns = [columns retain];
    [columns release];
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:kRecipientsDBFilename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dbPath] == NO) {
		if ([fileManager createFileAtPath:dbPath contents:nil attributes:nil] == YES){
			sqlite3_open([dbPath UTF8String], &kRecipientsDB);
			//const char *errmsg = nil;
            sqlite3_exec(kRecipientsDB, [kRecipientsDBCreateFormat UTF8String], NULL, NULL, NULL);
			//errmsg = sqlite3_errmsg(kRecipientsDB);
			sqlite3_close(kRecipientsDB);
			kRecipientsDB = nil;
            
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSNumber numberWithInt:DB_VERSION] forKey:kHGPreferenceKeyRecipientDBVersion];
            [defaults synchronize];
        }
	} else {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        int currentRecipientDBVersion = [[defaults objectForKey:kHGPreferenceKeyRecipientDBVersion] intValue];
        HGDebug(@"currentRecipientDBVersion: %d", currentRecipientDBVersion);
        
        if (currentRecipientDBVersion == DB_VERSION) {
            return;
        }
        
        BOOL upgradeSucceed = NO;
        
        NSArray* newColumns = nil;
        
        if (currentRecipientDBVersion == 0) {
            newColumns = kRecipientsDBV0ToV2Columns;
        } else if (currentRecipientDBVersion == 1) {
            newColumns = kRecipientsDBV1ToV2Columns;
        }
        
        if (newColumns) {
            sqlite3_open([dbPath UTF8String], &kRecipientsDB);
            
            for (NSString* columnName in newColumns) {
                NSString* alterTableFormat = [NSString stringWithFormat:@"ALTER TABLE recipients ADD COLUMN %@ TEXT", columnName];
                const char *update_stmt = [alterTableFormat UTF8String];
                sqlite3_stmt *statement;
                sqlite3_prepare_v2(kRecipientsDB, update_stmt, -1, &statement, NULL);
                
                if (sqlite3_step(statement) != SQLITE_DONE) {
                    const char *errmsg = sqlite3_errmsg(kRecipientsDB);
                    HGWarning(@"alter table failed: %s", errmsg);
                    upgradeSucceed = NO;
                    break;
                } else {
                    upgradeSucceed = YES;
                }
                
                sqlite3_finalize(statement);
            }
            
            sqlite3_close(kRecipientsDB);
            kRecipientsDB = nil;
        }
        
        if (!upgradeSucceed) {
            sqlite3_open([dbPath UTF8String], &kRecipientsDB);
			sqlite3_exec(kRecipientsDB, [kRecipientsDBDropRecipientsTable UTF8String], NULL, NULL, NULL);
            sqlite3_exec(kRecipientsDB, [kRecipientsDBCreateFormat UTF8String], NULL, NULL, NULL);
			//errmsg = sqlite3_errmsg(kRecipientsDB);
			sqlite3_close(kRecipientsDB);
			kRecipientsDB = nil;
        }
        
        [defaults setObject:[NSNumber numberWithInt:DB_VERSION] forKey:kHGPreferenceKeyRecipientDBVersion];
        [defaults synchronize];
    }
}

+ (void)finalize {
    if (kRecipientsDB != nil) {
        sqlite3_close(kRecipientsDB);
        kRecipientsDB = nil;
    }
}

- (id)init {
    if ((self = [super init])) {
		if (kRecipientsDB == nil) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir = [paths objectAtIndex:0];
            NSString *dbPath = [documentsDir stringByAppendingPathComponent:kRecipientsDBFilename];
            sqlite3_config(SQLITE_CONFIG_SERIALIZED);
            if (sqlite3_open([dbPath UTF8String], &kRecipientsDB) != SQLITE_OK) {
                sqlite3_close(kRecipientsDB);
                kRecipientsDB = nil;
            }
        }
        _recipientsDBCondition = [[NSCondition alloc] init];
        
        
        NSString *plistURL = [[NSBundle mainBundle] pathForResource:@"ProvinceCities" ofType:@"plist"];
        NSDictionary *provinceCities = [NSDictionary dictionaryWithContentsOfFile:plistURL];
        
        NSMutableDictionary* theProvinceCode = [[NSMutableDictionary alloc] init];
        for (NSString* province in [provinceCities allKeys]) {
            NSString* value = [[provinceCities objectForKey:province] objectForKey:@"value"];
            [theProvinceCode setValue:value forKey:province];
        }
        self.provinceCode = theProvinceCode;
        [theProvinceCode release];
    }
    
    return self;
}

- (void)dealloc {
    [recipientLoader release];
    [recipientUploader release];
    self.selectedRecipient = nil;
    [_recipientsDBCondition release];
    [super dealloc];
}

+ (HGRecipientService*)sharedService {
    @synchronized([HGRecipientService class]) {
        if (recipientService == nil){
            recipientService = [[HGRecipientService alloc] init];
        }
    }
    return recipientService;
}

NSInteger compareByBirthday(id p1, id p2, void *context) {
    HGRecipient* r1 = (HGRecipient*)p1;
    HGRecipient* r2 = (HGRecipient*)p2;
    
    if (r1.recipientNextBirthdayCount != r2.recipientNextBirthdayCount) {
        return r1.recipientNextBirthdayCount < r2.recipientNextBirthdayCount ? NSOrderedAscending : NSOrderedDescending;
    }
    
    return [r1.recipientName compare:r2.recipientName];
}

- (NSArray*)sortRecipientsByBirthday: (NSArray*)recipients {
    for (HGRecipient* recipent in recipients) {
        recipent.recipientNextBirthdayCount = [HGUtility offsetTodayOf:recipent.recipientBirthday];
    }  
    
    recipients = [recipients sortedArrayUsingFunction:compareByBirthday context:NULL];
    return recipients;
}

- (NSArray*)listSuggestedRecipients {
    NSMutableArray* recipients = [[[NSMutableArray alloc] init] autorelease];

    NSArray* personalizedOccasionGiftCollectionsArray = [HGGiftCollectionService sharedService].personalizedOccasionGiftCollectionsArray;
    
    NSMutableSet* addedRecipients = [[NSMutableSet alloc] init];
    
    if (personalizedOccasionGiftCollectionsArray && [personalizedOccasionGiftCollectionsArray count] > 0) {
        for (NSArray* personalizedOccasionGiftCollections in personalizedOccasionGiftCollectionsArray) {
            if (personalizedOccasionGiftCollections && [personalizedOccasionGiftCollections count] > 0) {
                for (HGOccasionGiftCollection* occasionGiftCollection in personalizedOccasionGiftCollections) {
                    NSString* key = [NSString stringWithFormat:@"%d$%@", occasionGiftCollection.occasion.recipient.recipientNetworkId, occasionGiftCollection.occasion.recipient.recipientProfileId];
                    if (![addedRecipients containsObject:key]) {
                        [recipients addObject: occasionGiftCollection.occasion];
                        [addedRecipients addObject:key];
                    }
                }
            }
        }
    }
    [addedRecipients release];
    
    if ([recipients count] == 0) {
        return [self listRecipients];
    } else {
        return recipients;
    }
}

- (NSArray*)listRecipients {
    [_recipientsDBCondition lock];
    NSMutableArray* recipients = [[[NSMutableArray alloc] init] autorelease];
    
    const char *sqlAll = [kRecipientsDBSQLQueryAllFormat cStringUsingEncoding:NSUTF8StringEncoding];
	sqlite3_stmt *selectstmtAll;
	int prep = sqlite3_prepare_v2(kRecipientsDB, sqlAll, -1, &selectstmtAll, NULL);
    
    if (prep == SQLITE_OK) {
		while (sqlite3_step(selectstmtAll) == SQLITE_ROW) {
            HGRecipient* recipient = [[HGRecipient alloc] init];
            [self fillRecipient: recipient withQueryResult: selectstmtAll];
            
            [recipients addObject:recipient];
			[recipient release];
		}
    } else {
        const char *errmsg = sqlite3_errmsg(kRecipientsDB);
        HGDebug(@"error on listRecipients: %s", errmsg);
    }
	
	sqlite3_reset(selectstmtAll);
    
    if (selectstmtAll) {
        sqlite3_finalize(selectstmtAll);
        selectstmtAll = nil;
    }
    [_recipientsDBCondition unlock];
    
	NSArray*result = [self sortRecipientsByBirthday:recipients];
    if ([result count] > kRecipientLimit) {
        NSRange theRange;
        theRange.location = 0;
        theRange.length = kRecipientLimit;
        
        result = [result subarrayWithRange:theRange];
    }
    return result;
}

#define toUTF8String(s) (s) != nil ? [(s) UTF8String] : ""

- (NSArray*)listRecipientsLike: (NSString*)pattern {
    [_recipientsDBCondition lock];
    NSMutableArray* recipients = [[[NSMutableArray alloc] init] autorelease];
    
    // remove ', %, and spaces
    NSString * filteredPattern = [[pattern componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString: @""];
    
    filteredPattern = [[filteredPattern stringByReplacingOccurrencesOfString:@"'" withString:@""]
                       stringByReplacingOccurrencesOfString:@"%%" withString:@""];
    
    NSString *strSearchSql = [NSString stringWithFormat:kRecipientsDBSQLQueryPatternFormat, filteredPattern, filteredPattern];
    
    const char *sqlAll = [strSearchSql cStringUsingEncoding:NSUTF8StringEncoding];
	sqlite3_stmt *selectstmtAll;
	int prep = sqlite3_prepare_v2(kRecipientsDB, sqlAll, -1, &selectstmtAll, NULL);
    
    if (prep == SQLITE_OK) {

		while (sqlite3_step(selectstmtAll) == SQLITE_ROW) {
            HGRecipient* recipient = [[HGRecipient alloc] init];
            [self fillRecipient: recipient withQueryResult: selectstmtAll];
            
            [recipients addObject:recipient];
			[recipient release];
		}
    } else {
        const char *errmsg = sqlite3_errmsg(kRecipientsDB);
        HGDebug(@"error on listRecipients: %s", errmsg);
    }
	
	sqlite3_reset(selectstmtAll);
    
    if (selectstmtAll) {
        sqlite3_finalize(selectstmtAll);
        selectstmtAll = nil;
    }
    [_recipientsDBCondition unlock];
    
    NSArray*result = [self sortRecipientsByBirthday:recipients];
    if ([result count] > kRecipientLimit) {
        NSRange theRange;
        theRange.location = 0;
        theRange.length = kRecipientLimit;
        
        result = [result subarrayWithRange:theRange];
    }
    return result;
}

- (int)recipientCount {
    [_recipientsDBCondition lock];
    const char *querySQL = [kRecipientsDBSQLQueryRecipientCountFormat cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *queryRecipientStmt;
    
    int prep = sqlite3_prepare_v2(kRecipientsDB, querySQL, -1, &queryRecipientStmt, NULL);
    int result = 0;
    if (prep == SQLITE_OK) {
		if (sqlite3_step(queryRecipientStmt) == SQLITE_ROW) {
            result = sqlite3_column_int(queryRecipientStmt, 0);
        }
    }
	
	sqlite3_reset(queryRecipientStmt);
    
    if (queryRecipientStmt) {
        sqlite3_finalize(queryRecipientStmt);
        queryRecipientStmt = nil;
    }
    [_recipientsDBCondition unlock];
    
    HGDebug(@"recipient count: %d", result);
	return result;  
}

- (int)snsRecipientCount {
    [_recipientsDBCondition lock];
    const char *querySQL = [kRecipientsDBSQLQuerySNSRecipientCountFormat cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *queryRecipientStmt;
    
    int prep = sqlite3_prepare_v2(kRecipientsDB, querySQL, -1, &queryRecipientStmt, NULL);
    int result = 0;
    if (prep == SQLITE_OK) {
		if (sqlite3_step(queryRecipientStmt) == SQLITE_ROW) {
            result = sqlite3_column_int(queryRecipientStmt, 0);
        }
    }
	
	sqlite3_reset(queryRecipientStmt);
    
    if (queryRecipientStmt) {
        sqlite3_finalize(queryRecipientStmt);
        queryRecipientStmt = nil;
    }
    [_recipientsDBCondition unlock];
    
    HGDebug(@"sns recipient count: %d", result);
	return result;  
}

- (HGRecipient*)getRecipient:(int)recipientId{
    [_recipientsDBCondition lock];
    const char *errmsg = nil;
    
	NSString *queryUser = kRecipientsDBSQLQueryFormat;
    const char *querySQL = [queryUser cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *queryRecipientStmt;
    HGRecipient* recipient = nil;
    int prep = sqlite3_prepare_v2(kRecipientsDB, querySQL, -1, &queryRecipientStmt, NULL);
    
    if(prep == SQLITE_OK) {
        sqlite3_bind_int(queryRecipientStmt, 1, recipientId);
		if (sqlite3_step(queryRecipientStmt) == SQLITE_ROW) {
            recipient = [[[HGRecipient alloc] init] autorelease];
            [self fillRecipient: recipient withQueryResult: queryRecipientStmt];
        }else {
            errmsg = sqlite3_errmsg(kRecipientsDB);
            HGDebug(@"getRecipient db error: %s", errmsg);
        }
    }else {
        errmsg = sqlite3_errmsg(kRecipientsDB);
        HGDebug(@"getRecipient db error: %s", errmsg);
    }
	
	sqlite3_reset(queryRecipientStmt);
    
    if (queryRecipientStmt) {
        sqlite3_finalize(queryRecipientStmt);
        queryRecipientStmt = nil;
    }
    [_recipientsDBCondition unlock];
    
	return recipient;  
}

- (HGRecipient*)getRecipientWithNetworkId:(int)networkId andProfileId:(NSString*)profileId {
    if (profileId == nil || [@"" isEqualToString:profileId]) {
        return nil;
    }
    [_recipientsDBCondition lock];
    
    const char *querySQL = [kRecipientsDBSQLQueryByProfileIdFormat cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *queryRecipientStmt;
    HGRecipient* recipient = nil;
    int prep = sqlite3_prepare_v2(kRecipientsDB, querySQL, -1, &queryRecipientStmt, NULL);
    if(prep == SQLITE_OK) {
        sqlite3_bind_int(queryRecipientStmt, 1, networkId);
        sqlite3_bind_text(queryRecipientStmt, 2, toUTF8String(profileId), -1, NULL);
        if (sqlite3_step(queryRecipientStmt) == SQLITE_ROW) {
            recipient = [[[HGRecipient alloc] init] autorelease];
            [self fillRecipient: recipient withQueryResult: queryRecipientStmt];
        }
    }
    
    if (queryRecipientStmt) {
        sqlite3_finalize(queryRecipientStmt);
        queryRecipientStmt = nil;
    }
        
    
    [_recipientsDBCondition unlock];
    
	return recipient; 
}

- (BOOL)addOrUpdateRecipient:(HGRecipient *)recipient {
    const char *querySQL = [kRecipientsDBSQLQueryRecipientFormat cStringUsingEncoding:NSUTF8StringEncoding];
    [_recipientsDBCondition lock];
    sqlite3_stmt *queryStmt;
    int recipientId = -1;
	int prep = sqlite3_prepare_v2(kRecipientsDB, querySQL, -1, &queryStmt, NULL);
    if(prep == SQLITE_OK) {
        sqlite3_bind_int(queryStmt, 1, recipient.recipientId);
        sqlite3_bind_int(queryStmt, 2, recipient.recipientNetworkId);
        sqlite3_bind_text(queryStmt, 3, toUTF8String(recipient.recipientProfileId), -1, NULL);
        
        if(sqlite3_step(queryStmt) == SQLITE_ROW) {
            recipientId = sqlite3_column_int(queryStmt, 0);
        }
    }
    [_recipientsDBCondition unlock];
    
    if (recipientId == -1) {
        return [self addRecipient:recipient];
    } else {
        recipient.recipientId = recipientId;
        return [self updateRecipient:recipient];
    }
}

- (BOOL)addRecipient:(HGRecipient *)recipient {
    if (!recipient.recipientName || [@"" isEqualToString:recipient.recipientName]) {
        return NO;
    }
    [_recipientsDBCondition lock];
    
    const char *errmsg = nil;
    recipient.recipientId = -1;
    const char *insertSQL = [kRecipientsDBSQLInsertFormat cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *insertStmt = nil;
    int insertDbrc = sqlite3_prepare_v2(kRecipientsDB, insertSQL, -1, &insertStmt, nil);
    if (insertDbrc == SQLITE_OK)  {
        sqlite3_bind_text(insertStmt, 1, toUTF8String(recipient.recipientName), -1, NULL);
        sqlite3_bind_text(insertStmt, 2, toUTF8String(recipient.recipientPhone), -1, NULL);
        sqlite3_bind_text(insertStmt, 3, toUTF8String(recipient.recipientEmail), -1, NULL);
        sqlite3_bind_text(insertStmt, 4, toUTF8String(recipient.recipientImageUrl), -1, NULL);
        sqlite3_bind_text(insertStmt, 5, toUTF8String(recipient.recipientProfileId), -1, NULL);
        sqlite3_bind_int(insertStmt, 6, recipient.recipientNetworkId);
        sqlite3_bind_text(insertStmt, 7, toUTF8String(recipient.recipientBirthday), -1, NULL);
        NSString* pinyin = [HGPinyinService convertFrom:recipient.recipientName];
        sqlite3_bind_text(insertStmt, 8, toUTF8String(pinyin), -1, NULL);
        sqlite3_bind_text(insertStmt, 9, toUTF8String(recipient.recipientDisplayName), -1, NULL);
        
        sqlite3_bind_text(insertStmt, 10, toUTF8String(recipient.recipientProvince), -1, NULL);
        sqlite3_bind_text(insertStmt, 11, toUTF8String(recipient.recipientCity), -1, NULL);
        sqlite3_bind_text(insertStmt, 12, toUTF8String(recipient.recipientStreetAddress), -1, NULL);
        sqlite3_bind_text(insertStmt, 13, toUTF8String(recipient.recipientPostCode), -1, NULL);
        
        if (sqlite3_step(insertStmt) != SQLITE_DONE) {
            errmsg = sqlite3_errmsg(kRecipientsDB);
        } else {
            recipient.recipientId = sqlite3_last_insert_rowid(kRecipientsDB);
        }
        sqlite3_reset(insertStmt);
    }else {
        errmsg = sqlite3_errmsg(kRecipientsDB);
    }
    
    if (insertStmt) {
        sqlite3_finalize(insertStmt);
        insertStmt = nil;
    }
    
    [_recipientsDBCondition unlock];
    return errmsg == nil;
}

- (BOOL)updateRecipient:(HGRecipient*)recipient{
    [_recipientsDBCondition lock];
    const char *errmsg = nil;
    const char *updateSQL = [kRecipientsDBSQLUpdateFormat cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *updateStmt = nil;
    int updateDbrc = sqlite3_prepare_v2(kRecipientsDB, updateSQL, -1, &updateStmt, nil);
    if (updateDbrc == SQLITE_OK)  {
        sqlite3_bind_text(updateStmt, 1, toUTF8String(recipient.recipientName), -1, NULL);
        sqlite3_bind_text(updateStmt, 2, toUTF8String(recipient.recipientPhone), -1, NULL);
        sqlite3_bind_text(updateStmt, 3, toUTF8String(recipient.recipientEmail), -1, NULL);
        sqlite3_bind_text(updateStmt, 4, toUTF8String(recipient.recipientImageUrl), -1, NULL);
        sqlite3_bind_text(updateStmt, 5, toUTF8String(recipient.recipientProfileId), -1, NULL);
        sqlite3_bind_int(updateStmt, 6, recipient.recipientNetworkId);
        sqlite3_bind_text(updateStmt, 7, toUTF8String(recipient.recipientBirthday), -1, NULL);
        NSString* pinyin = [HGPinyinService convertFrom:recipient.recipientName];
        sqlite3_bind_text(updateStmt, 8, toUTF8String(pinyin), -1, NULL);
        sqlite3_bind_text(updateStmt, 9, toUTF8String(recipient.recipientDisplayName), -1, NULL);
        
        sqlite3_bind_text(updateStmt, 10, toUTF8String(recipient.recipientProvince), -1, NULL);
        sqlite3_bind_text(updateStmt, 11, toUTF8String(recipient.recipientCity), -1, NULL);
        sqlite3_bind_text(updateStmt, 12, toUTF8String(recipient.recipientStreetAddress), -1, NULL);
        sqlite3_bind_text(updateStmt, 13, toUTF8String(recipient.recipientPostCode), -1, NULL);
        
        sqlite3_bind_int(updateStmt, 14, recipient.recipientId);
        
        if (sqlite3_step(updateStmt) != SQLITE_DONE) {
            errmsg = sqlite3_errmsg(kRecipientsDB);
        }
        sqlite3_reset(updateStmt);
    }else {
        errmsg = sqlite3_errmsg(kRecipientsDB);
    }
    
    if (updateStmt) {
        sqlite3_finalize(updateStmt);
        updateStmt = nil;
    }
    
    [_recipientsDBCondition unlock];
    return errmsg == nil;
}

- (BOOL)removeRecipient:(int)recipientId {
    [_recipientsDBCondition lock];
    const char *deleteSql = [kRecipientsDBSQLDeleteFormat cStringUsingEncoding:NSUTF8StringEncoding];
    const char *errmsg = nil;
    sqlite3_stmt *deleteStmt = nil;
    int deleteDbrc = sqlite3_prepare_v2(kRecipientsDB, deleteSql, -1, &deleteStmt, nil);
    if (deleteDbrc == SQLITE_OK)  {
        sqlite3_bind_int(deleteStmt, 1, recipientId);
        if (sqlite3_step(deleteStmt) != SQLITE_DONE) {
            errmsg = sqlite3_errmsg(kRecipientsDB);
        }
    }
    sqlite3_reset(deleteStmt);
    if (deleteStmt) {
        sqlite3_finalize(deleteStmt);
        deleteStmt = nil;
    }
    [_recipientsDBCondition unlock];
    return errmsg == nil;
}

- (BOOL)hasSNSFriends:(int)networkId {
    [_recipientsDBCondition lock];
    const char *querySQL = [kRecipientsDBSQLQueryHasSNSFriendFormat cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *queryRecipientStmt;
    
    int prep = sqlite3_prepare_v2(kRecipientsDB, querySQL, -1, &queryRecipientStmt, NULL);
    int result = 0;
    if (prep == SQLITE_OK) {
        sqlite3_bind_int(queryRecipientStmt, 1, networkId);
		if (sqlite3_step(queryRecipientStmt) == SQLITE_ROW) {
            result = sqlite3_column_int(queryRecipientStmt, 0);
        }
    }
	
	sqlite3_reset(queryRecipientStmt);
    
    if (queryRecipientStmt) {
        sqlite3_finalize(queryRecipientStmt);
        queryRecipientStmt = nil;
    }
    [_recipientsDBCondition unlock];
    
    HGDebug(@"sns count: %d", result);
	return result > 0 ? YES : NO;  
}

- (BOOL)setSNSRecipientsToDB: (NSArray*) snsRecipients {
    BOOL result = YES;
    sqlite3_exec(kRecipientsDB, "BEGIN", 0, 0, 0);
    if ([self clearSNSRecipients:kAllSNSNetworkID] == YES) {
        for (HGRecipient* recipient in snsRecipients) {
            HGRecipient* dbRecipient = [self getRecipientWithNetworkId:recipient.recipientNetworkId andProfileId:recipient.recipientProfileId];
            if (dbRecipient) {
                [dbRecipient retain];
                // use local data
                recipient.recipientId = dbRecipient.recipientId;
                recipient.recipientDisplayName = dbRecipient.recipientDisplayName;
                recipient.recipientProvince = dbRecipient.recipientProvince;
                recipient.recipientCity = dbRecipient.recipientCity;
                recipient.recipientStreetAddress = dbRecipient.recipientStreetAddress;
                recipient.recipientPostCode = dbRecipient.recipientPostCode;
                
                // use local data when local data is not empty
                if (dbRecipient.recipientEmail && ![@"" isEqualToString:dbRecipient.recipientEmail]) {
                    recipient.recipientEmail = dbRecipient.recipientEmail;
                }
                if (dbRecipient.recipientPhone && ![@"" isEqualToString:dbRecipient.recipientPhone]) {
                    recipient.recipientPhone = dbRecipient.recipientPhone;
                }
                
                // use local data only when remote data is empty
                if (recipient.recipientImageUrl == nil || [@"" isEqualToString:recipient.recipientImageUrl]) {
                    recipient.recipientImageUrl = dbRecipient.recipientImageUrl;
                }
                if (recipient.recipientName == nil || [@"" isEqualToString:recipient.recipientName]) {
                    recipient.recipientName = dbRecipient.recipientName;
                }
                if (recipient.recipientBirthday == nil || [@"" isEqualToString:recipient.recipientBirthday]) {
                    recipient.recipientBirthday = dbRecipient.recipientBirthday;
                }
                
                [dbRecipient release];
                
                [self updateRecipient:recipient];
            } else {
                [self addRecipient:recipient];
            }
        }        
        result = YES;
    } else {
        sqlite3_exec(kRecipientsDB, "ROLLBACK", 0, 0, 0);
        result = NO;
    }
    sqlite3_exec(kRecipientsDB, "COMMIT", 0, 0, 0);
    return result;
}

- (BOOL)setPhoneContactRecipientsToDB: (NSArray*) phoneContactRecipients {
    BOOL result = YES;
    sqlite3_exec(kRecipientsDB, "BEGIN", 0, 0, 0);
    if ([self clearSNSRecipients:NETWORK_PHONE_CONTACT] == YES) {
        for (HGRecipient* recipient in phoneContactRecipients) {
            HGRecipient* dbRecipient = [self getRecipientWithNetworkId:recipient.recipientNetworkId andProfileId:recipient.recipientProfileId];
            if (dbRecipient) {
                [dbRecipient retain];
                // use local data
                recipient.recipientId = dbRecipient.recipientId;
                recipient.recipientDisplayName = dbRecipient.recipientDisplayName;
                recipient.recipientProvince = dbRecipient.recipientProvince;
                recipient.recipientCity = dbRecipient.recipientCity;
                recipient.recipientStreetAddress = dbRecipient.recipientStreetAddress;
                recipient.recipientPostCode = dbRecipient.recipientPostCode;
                
                // use local data when local data is not empty
                if (dbRecipient.recipientEmail && ![@"" isEqualToString:dbRecipient.recipientEmail]) {
                    recipient.recipientEmail = dbRecipient.recipientEmail;
                }
                if (dbRecipient.recipientPhone && ![@"" isEqualToString:dbRecipient.recipientPhone]) {
                    recipient.recipientPhone = dbRecipient.recipientPhone;
                }
                
                // use local data only when remote data is empty
                if (recipient.recipientImageUrl == nil || [@"" isEqualToString:recipient.recipientImageUrl]) {
                    recipient.recipientImageUrl = dbRecipient.recipientImageUrl;
                }
                if (recipient.recipientName == nil || [@"" isEqualToString:recipient.recipientName]) {
                    recipient.recipientName = dbRecipient.recipientName;
                }
                if (recipient.recipientBirthday == nil || [@"" isEqualToString:recipient.recipientBirthday]) {
                    recipient.recipientBirthday = dbRecipient.recipientBirthday;
                }
                
                [dbRecipient release];
                
                [self updateRecipient:recipient];
            } else {
                [self addRecipient:recipient];
            }
        }        
        result = YES;
    } else {
        sqlite3_exec(kRecipientsDB, "ROLLBACK", 0, 0, 0);
        result = NO;
    }
    sqlite3_exec(kRecipientsDB, "COMMIT", 0, 0, 0);
    return result;
}

- (void)requestRecipients {
    if (!recipientLoader) {
        recipientLoader = [[HGRecipientLoader alloc] init];
    }
    recipientLoader.delegate = self;
    [recipientLoader requestRecipients];
    [self updateLastSNSRecipientRefreshTime];
}

- (void)checkAndUpdateRecipients {
    if (recipientLoader.running) {
        // already refreshing
        return;
    }
    
    if (![[HGAccountService sharedService] hasSNSAccountLoggedIn]) {
        // no SNS connected;
        return;
    }

    // daily refresh
    NSTimeInterval lastTime = [self lastSNSRecipientRefreshTime];
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    if (currentTime - lastTime > 86400) {
        HGDebug(@"refresh sns recipients");
        [self requestRecipients];
        [self importPhoneContacts];
    }
}

- (NSTimeInterval) lastSNSRecipientRefreshTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults doubleForKey:@"lastSNSRecipientRefreshTime"];
}

- (void) updateLastSNSRecipientRefreshTime {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:currentTime forKey:@"lastSNSRecipientRefreshTime"];
    [defaults synchronize];
}

- (NSInteger) phoneContactsImportStatus {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:@"phoneContactsImportStatus"];
}

- (void) updatePhoneContactsImportStatus:(NSInteger)status {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:status forKey:@"phoneContactsImportStatus"];
    [defaults synchronize];
}

- (NSArray*) importPhoneContacts {
    NSMutableArray* recipients = [[[NSMutableArray alloc] init] autorelease];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
    int count = CFArrayGetCount(results);
    
    for (int i = 0; i < count; ++i) {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        HGRecipient *recipient = [[HGRecipient alloc] init];
        recipient.recipientNetworkId = NETWORK_PHONE_CONTACT;
        
        ABRecordID recordId = ABRecordGetRecordID(person);
        recipient.recipientProfileId = [NSString stringWithFormat:@"%d", recordId];
        
        NSString* displayName = nil;
       
        //读取firstname
        NSString *tmpFirstName = (NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *firstName = [tmpFirstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [tmpFirstName release];
        
        //读取lastname
        NSString *tmpLastName = (NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString *lastName = [tmpLastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [tmpLastName release];
        
        if ([HGUtility isEnglishNameFirstName:firstName andLastName:lastName]) {
            if (firstName) {
                displayName = firstName;
            } 
            
            if (lastName && ![@"" isEqualToString:lastName]) {
                displayName = displayName ? [displayName stringByAppendingFormat:@" %@", lastName] : lastName;
            }
        } else {
            if (lastName) {
                displayName = lastName;
            }
            
            if (firstName && ![@"" isEqualToString:firstName]) {
                displayName = displayName ? [displayName stringByAppendingFormat:@"%@", firstName] : firstName;
            }
        }
        
        recipient.recipientName = displayName;
        
        //获取email
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        if (email) {
            int emailCount = ABMultiValueGetCount(email);
            if (emailCount > 0) {
                NSString* emailContent = (NSString*)ABMultiValueCopyValueAtIndex(email, 0);
                recipient.recipientEmail = emailContent;
                [emailContent release];
            }
            CFRelease(email);
        }
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if (phone) {
            int phoneCount = ABMultiValueGetCount(phone);
            if (phoneCount > 0) {
                NSString * phoneNumber = (NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
                recipient.recipientPhone = [HGUtility normalizeMobileNumber:phoneNumber];
                [phoneNumber release];
            }
            CFRelease(phone);
        }
        
        NSDate *birthday = (NSDate*)ABRecordCopyValue(person, kABPersonBirthdayProperty);
        if (birthday) {
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            recipient.recipientBirthday = [formatter stringFromDate:birthday];
            [formatter release];
        }
        
        if (recipient.recipientName && ![recipient.recipientName isEqualToString: @""]) {
            [recipients addObject:recipient];
        }
        
        [birthday release];
        [recipient release];
    }
    
    [self setPhoneContactRecipientsToDB:recipients];
    
    CFRelease(results);
    CFRelease(addressBook);
    return recipients;
}

-(void) uploadPhoneContacts {
    phoneContacts = [self importPhoneContacts];
    [phoneContacts retain];
    if (!recipientUploader) {
        recipientUploader = [[HGRecipientLoader alloc] init];
    }
    recipientUploader.delegate = self;
    [recipientUploader requestPhoneContactsHash];
}

#pragma mark HGRecipientLoaderDelegate
- (void)recipientLoader:(HGRecipientLoader *)recipientLoader didRequestRecipientsSucceed:(NSArray*)recipients {
    HGDebug(@"didRequestRecipientsSucceed");
    [self setSNSRecipientsToDB: recipients];
    
    if ([(id)self.delegate respondsToSelector:@selector(didRequestRecipientsSucceed:)]) {
        [self.delegate didRequestRecipientsSucceed:recipients];
    }
}

- (void)recipientLoader:(HGRecipientLoader *)recipientLoader didRequestRecipientsFail:(NSString*)error{
    HGDebug(@"didRequestRecipientsFail: %@", error);
    
    if ([(id)self.delegate respondsToSelector:@selector(didRequestRecipientsFail:)]) {
        [self.delegate didRequestRecipientsFail:error];
    }
}

- (void)recipientLoader:(HGRecipientLoader *)theRecipientLoader didRequestPhoneContactsHashSucceed:(NSString*)hash {
    HGDebug(@"didRequestPhoneContactsHashSucceed");
    
    NSDictionary* contactsDict = [NSDictionary dictionaryWithObject:phoneContacts forKey:@"contacts"];
    NSString* contactsJson = [contactsDict JSONRepresentation];
    
    NSString* newHash = [contactsJson md5Hash];
    HGDebug(@"new hash %@", newHash);
    
    if ([newHash isEqualToString:hash]) {
        HGDebug(@"equal hash, not need to upload");
        if ([(id)self.delegate respondsToSelector:@selector(didUploadPhoneContactsSucceed)]) {
            [self.delegate didUploadPhoneContactsSucceed];
        }
    } else {
        HGDebug(@"going to upload phone contacts");
        [theRecipientLoader uploadPhoneContacts:contactsJson];
    }
}

- (void)recipientLoader:(HGRecipientLoader *)recipientLoader didRequestPhoneContactsHashFail:(NSString*)error {
    HGDebug(@"didRequestPhoneContactsHashFail");
    
    if ([(id)self.delegate respondsToSelector:@selector(didUploadPhoneContactsFail:)]) {
        [self.delegate didUploadPhoneContactsFail:error];
    }
}

- (void)recipientLoader:(HGRecipientLoader *)recipientLoader didUploadPhoneContactsSucceed:(NSString*)result {
    HGDebug(@"didUploadPhoneContactsSucceed");
    
    if ([(id)self.delegate respondsToSelector:@selector(didUploadPhoneContactsSucceed)]) {
        [self.delegate didUploadPhoneContactsSucceed];
    }
}

- (void)recipientLoader:(HGRecipientLoader *)recipientLoader didUploadPhoneContactsFail:(NSString*)error {
    HGDebug(@"didUploadPhoneContactsFail");
    
    if ([(id)self.delegate respondsToSelector:@selector(didUploadPhoneContactsFail:)]) {
        [self.delegate didUploadPhoneContactsFail:error];
    }
}

- (void) fillRecipient: (HGRecipient*)recipient withQueryResult: (sqlite3_stmt*) statement {
    recipient.recipientId = sqlite3_column_int(statement, 0);
    
    NSString* recipientName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
    recipient.recipientName = recipientName;
    [recipientName release];
    
    NSString* recipientPhone = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
    recipient.recipientPhone = recipientPhone;
    [recipientPhone release];
    
    NSString* recipientEmail = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
    recipient.recipientEmail = recipientEmail;
    [recipientEmail release];
    
    NSString* recipientImageUrl = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
    recipient.recipientImageUrl = recipientImageUrl;
    [recipientImageUrl release];
    
    NSString* recipientProfileId = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
    recipient.recipientProfileId = recipientProfileId;
    [recipientProfileId release];
    
    recipient.recipientNetworkId = sqlite3_column_int(statement, 6);
    
    NSString* recipientBirthday = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
    recipient.recipientBirthday = recipientBirthday;
    [recipientBirthday release];
    
    char * recipientDisplayNameBuf = (char *)sqlite3_column_text(statement, 8);
    NSString* recipientDisplayName = recipientDisplayNameBuf == NULL ? nil : [[NSString alloc] initWithUTF8String:recipientDisplayNameBuf];
    recipient.recipientDisplayName = recipientDisplayName;
    [recipientDisplayName release];
    
    char * recipientProvinceBuf = (char *)sqlite3_column_text(statement, 9);
    NSString* recipientProvince = recipientProvinceBuf == NULL ? nil : [[NSString alloc] initWithUTF8String:recipientProvinceBuf];
    recipient.recipientProvince = recipientProvince;
    [recipientProvince release];
    
    char * recipientCityBuf = (char *)sqlite3_column_text(statement, 10);
    NSString* recipientCity = recipientCityBuf == NULL ? nil : [[NSString alloc] initWithUTF8String:recipientCityBuf];
    recipient.recipientCity = recipientCity;
    [recipientCity release];
    
    char * recipientStreetAddressBuf = (char *)sqlite3_column_text(statement, 11);
    NSString* recipientStreetAddress = recipientStreetAddressBuf == NULL ? nil : [[NSString alloc] initWithUTF8String:recipientStreetAddressBuf];
    recipient.recipientStreetAddress = recipientStreetAddress;
    [recipientStreetAddress release];
    
    char * recipientPostCodeBuf = (char *)sqlite3_column_text(statement, 12);
    NSString* recipientPostCode = recipientPostCodeBuf == NULL ? nil : [[NSString alloc] initWithUTF8String:recipientPostCodeBuf];
    recipient.recipientPostCode = recipientPostCode;
    [recipientPostCode release];
}

- (BOOL) clearSNSRecipients: (int)networkID {
    [_recipientsDBCondition lock];
    // remove existing sns data
    const char *deleteSql;
    if (networkID == kAllSNSNetworkID) {
        deleteSql = [kRecipientsDBSQLDisableSNSFormat cStringUsingEncoding:NSUTF8StringEncoding];
    } else {
        deleteSql = [kRecipientsDBSQLDisableSpecificSNSFormat cStringUsingEncoding:NSUTF8StringEncoding];
    }
    
    const char *errmsg = nil;
    sqlite3_stmt *deleteStmt = nil;
    int deleteDbrc = sqlite3_prepare_v2(kRecipientsDB, deleteSql, -1, &deleteStmt, nil);
    if (deleteDbrc == SQLITE_OK)  {
        if (networkID != kAllSNSNetworkID) {
            sqlite3_bind_int(deleteStmt, 1, networkID);
        }
        
        if (sqlite3_step(deleteStmt) != SQLITE_DONE) {
            errmsg = sqlite3_errmsg(kRecipientsDB);
        }
    }
    
    sqlite3_reset(deleteStmt);
    if (deleteStmt) {
        sqlite3_finalize(deleteStmt);
        deleteStmt = nil;
    }
    [_recipientsDBCondition unlock];
    return errmsg == nil;
}

- (void)updateSNSRecipientWithDBData: (HGRecipient*) recipient {
    HGRecipient* dbRecipient = [self getRecipientWithNetworkId:recipient.recipientNetworkId andProfileId:recipient.recipientProfileId];
    if (dbRecipient) {
        [dbRecipient retain];
        if (recipient.recipientImageUrl == nil || [@"" isEqualToString:recipient.recipientImageUrl]) {
            recipient.recipientImageUrl = dbRecipient.recipientImageUrl;
        }
        if (recipient.recipientName == nil || [@"" isEqualToString:recipient.recipientName]) {
            recipient.recipientName = dbRecipient.recipientName;
        }
        
        recipient.recipientId = dbRecipient.recipientId;
        recipient.recipientEmail = dbRecipient.recipientEmail;
        recipient.recipientPhone = dbRecipient.recipientPhone;
        recipient.recipientBirthday = dbRecipient.recipientBirthday;
        recipient.recipientDisplayName = dbRecipient.recipientDisplayName;
        recipient.recipientProvince = dbRecipient.recipientProvince;
        recipient.recipientCity = dbRecipient.recipientCity;
        recipient.recipientStreetAddress = dbRecipient.recipientStreetAddress;
        recipient.recipientPostCode = dbRecipient.recipientPostCode;
        [dbRecipient release];
    }
}

- (void)updateRecipientLabel:(UILabel*)label {
    if (selectedRecipient) {
        label.text = [NSString stringWithFormat:@"送给%@的礼物", selectedRecipient.recipientName];
    } else {
        label.text = @"选择礼物接收人";
    }
}

@end
