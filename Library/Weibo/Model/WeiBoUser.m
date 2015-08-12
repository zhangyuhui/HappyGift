#import "WeiBoUser.h"
#import "WeiBoStringUtil.h"

@implementation WeiBoUser

@synthesize userId;
@synthesize screenName;
@synthesize name;
@synthesize province;
@synthesize city;
@synthesize location;
@synthesize description;
@synthesize url;
@synthesize profileImageUrl;
@synthesize profileLargeImageUrl;
@synthesize domain;
@synthesize gender;
@synthesize followersCount;
@synthesize friendsCount;
@synthesize statusesCount;
@synthesize favoritesCount;
@synthesize createdAt;
@synthesize following;
@synthesize verified;
@synthesize allowAllActMsg;
@synthesize geoEnabled;
@synthesize userKey;

- (id)initWithStatement:(WeiBoDBStatement *)stmt {
    self = [super init];
	if (self) {
		userId = [stmt getInt64:0];
		userKey = [[NSNumber alloc] initWithLongLong:userId];
		screenName = [[stmt getString:1] retain];
		name = [[stmt getString:2] retain];
		province = [[stmt getString:3]retain];
		city = [[stmt getString:4]retain];
		location = [[stmt getString:5]retain];
		description = [[stmt getString:6]retain];
		url = [[stmt getString:7] retain];
		profileImageUrl = [[stmt getString:8]retain];
		profileLargeImageUrl = [[profileImageUrl stringByReplacingOccurrencesOfString:@"/50/" withString:@"/180/"] retain];
		domain = [[stmt getString:9]retain];
		gender = [stmt getInt32:10];
		followersCount = [stmt getInt32:11];
		friendsCount = [stmt getInt32:12];
		statusesCount = [stmt getInt32:13];
		favoritesCount = [stmt getInt32:14];
		createdAt = [stmt getInt32:15];
		following = [stmt getInt32:16];
		verified = [stmt getInt32:17];
		allowAllActMsg = [stmt getInt32:18];
		geoEnabled = [stmt getInt32:19];
	}
	return self;
}

- (WeiBoUser*)initWithJsonDictionary:(NSDictionary*)dict
{
	self = [super init];
    
    [self updateWithJSonDictionary:dict];
	
	return self;
}

- (void)updateWithJSonDictionary:(NSDictionary*)dic
{
	[userKey release];
    [screenName release];
    [name release];
	[province release];
	[city release];
    [location release];
    [description release];
    [url release];
    [profileImageUrl release];
	[domain release];
    
    userId          = [[dic objectForKey:@"id"] longLongValue];
    userKey			= [[NSNumber alloc] initWithLongLong:userId];
	screenName      = [dic objectForKey:@"screen_name"];
    name            = [dic objectForKey:@"name"];
	
	//int provinceId = [[dic objectForKey:@"province"] intValue];
	//int cityId = [[dic objectForKey:@"city"] intValue];
	province		= @"";
	city			= @"";
	
	location        = [dic objectForKey:@"location"];
	description     = [dic objectForKey:@"description"];
	url             = [dic objectForKey:@"url"];
    profileImageUrl = [dic objectForKey:@"profile_image_url"];
	domain			= [dic objectForKey:@"domain"];
	
	NSString *genderChar = [dic objectForKey:@"gender"];
	if ([genderChar isEqualToString:@"m"]) {
		gender = GenderMale;
	}
	else if ([genderChar isEqualToString:@"f"]) {
		gender = GenderFemale;
	}
	else {
		gender = GenderUnknow;
	}

	
    followersCount  = ([dic objectForKey:@"followers_count"] == [NSNull null]) ? 0 : [[dic objectForKey:@"followers_count"] longValue];
    friendsCount    = ([dic objectForKey:@"friends_count"]   == [NSNull null]) ? 0 : [[dic objectForKey:@"friends_count"] longValue];
    statusesCount   = ([dic objectForKey:@"statuses_count"]  == [NSNull null]) ? 0 : [[dic objectForKey:@"statuses_count"] longValue];
    favoritesCount  = ([dic objectForKey:@"favourites_count"]  == [NSNull null]) ? 0 : [[dic objectForKey:@"favourites_count"] longValue];

    following       = ([dic objectForKey:@"following"]       == [NSNull null]) ? 0 : [[dic objectForKey:@"following"] boolValue];
    verified		= ([dic objectForKey:@"verified"]       == [NSNull null]) ? 0 : [[dic objectForKey:@"verified"] boolValue];
    allowAllActMsg	= ([dic objectForKey:@"allow_all_act_msg"]       == [NSNull null]) ? 0 : [[dic objectForKey:@"allow_all_act_msg"] boolValue];  
    geoEnabled		= ([dic objectForKey:@"geo_enabled"]   == [NSNull null]) ? 0 : [[dic objectForKey:@"geo_enabled"] boolValue];
    
	NSString *stringOfCreatedAt   = [dic objectForKey:@"created_at"];
    if ((id)stringOfCreatedAt == [NSNull null]) {
        stringOfCreatedAt = @"";
    }
    
    createdAt = 0;
    struct tm created;
    time_t now;
    time(&now);
    
    if (stringOfCreatedAt) {
		if (strptime([stringOfCreatedAt UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
			strptime([stringOfCreatedAt UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
		}
		createdAt = mktime(&created);
	}
	
    if ((id)screenName == [NSNull null]) screenName = @"";
    if ((id)name == [NSNull null]) name = @"";
    if ((id)province == [NSNull null]) province = @"";
    if ((id)city == [NSNull null]) city = @"";
    if ((id)location == [NSNull null]) location = @"";
    if ((id)description == [NSNull null]) description = @"";
    if ((id)url == [NSNull null]) url = @"";
    if ((id)profileImageUrl == [NSNull null]) profileImageUrl = @"";
    if ((id)domain == [NSNull null]) domain = @"";
    
    [screenName retain];
    [name retain];
	[province retain];
	[city retain];
    location = [[location unescapeHTML] retain];
    description = [[description unescapeHTML] retain];
    [url retain];
    [profileImageUrl retain];
	[domain retain];
	profileLargeImageUrl = [[profileImageUrl stringByReplacingOccurrencesOfString:@"/50/" withString:@"/180/"] retain];
}

+ (WeiBoUser*)userWithScreenName:(NSString *)theScreenName {
	static WeiBoDBStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [WeiBoDBConnection statementWithQuery:"SELECT userId FROM users WHERE screenName = ?"];
        [stmt retain];
    }
    
    [stmt bindString:theScreenName forIndex:1];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        return nil;
    }
    
	int userId = [stmt getInt64:0];
    [stmt reset];
	return [WeiBoUser userWithId:userId];
}

+ (WeiBoUser*)userWithId:(long long)uid
{
    WeiBoUser *user;
	
    static WeiBoDBStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [WeiBoDBConnection statementWithQuery:"SELECT * FROM users WHERE userId = ?"];
        [stmt retain];
    }
    
    [stmt bindInt64:uid forIndex:1];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        return nil;
    }
    
    user = [[[WeiBoUser alloc] initWithStatement:stmt] autorelease];
	
    [stmt reset];
	
	return user;
}

+ (WeiBoUser*)userWithJsonDictionary:(NSDictionary*)dict
{
    WeiBoUser *user = [[WeiBoUser alloc] initWithJsonDictionary:dict];
    return [user autorelease];
}

- (void)dealloc
{
	[userKey release];
    [screenName release];
    [name release];
	[province release];
	[city release];
    [location release];
    [description release];
    [url release];
    [profileImageUrl release];
	[profileLargeImageUrl release];
	[domain release];
   	[super dealloc];
}

- (void)updateDB
{
    BOOL hasUser = NO;
    static WeiBoDBStatement *selectStmt = nil;
    if (selectStmt == nil) {
        selectStmt = [WeiBoDBConnection statementWithQuery:"SELECT * FROM users WHERE userId = ?"];
        [selectStmt retain];
    }
    [selectStmt bindInt64:self.userId forIndex:1];
    int ret = [selectStmt step];
    if (ret == SQLITE_ROW) {
        hasUser = YES;
    }
    [selectStmt reset];

    if (hasUser){
        static WeiBoDBStatement *updateStmt = nil;
        if (updateStmt == nil) {
            updateStmt = [WeiBoDBConnection statementWithQuery:"REPLACE INTO users VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
            [updateStmt retain];
        }
        [updateStmt bindInt64:userId              forIndex:1];
        [updateStmt bindString:screenName               forIndex:2];
        [updateStmt bindString:name         forIndex:3];
        [updateStmt bindString:province         forIndex:4];
        [updateStmt bindString:city         forIndex:5];
        [updateStmt bindString:location           forIndex:6];
        [updateStmt bindString:description        forIndex:7];
        [updateStmt bindString:url                forIndex:8];
        [updateStmt bindString:profileImageUrl    forIndex:9];
        [updateStmt bindString:domain forIndex:10];
        [updateStmt bindInt32:gender forIndex:11];
        [updateStmt bindInt32:followersCount      forIndex:12];
        [updateStmt bindInt32:friendsCount forIndex:13];
        [updateStmt bindInt32:statusesCount forIndex:14];
        [updateStmt bindInt32:favoritesCount forIndex:15];
        [updateStmt bindInt32:createdAt forIndex:16];
        [updateStmt bindInt32:following forIndex:17];
        [updateStmt bindInt32:verified forIndex:18];
        [updateStmt bindInt32:allowAllActMsg forIndex:19];
        [updateStmt bindInt32:geoEnabled           forIndex:20];
        
        int step = [updateStmt step];
        if (step != SQLITE_DONE) {
            //NSLog(@"update error username: %lld.%@,%@,%@", userId, screenName, province, city);
            [WeiBoDBConnection alert];
        }
        [updateStmt reset];
    }else{
        static WeiBoDBStatement *insertStmt = nil;
        if (insertStmt == nil) {
            insertStmt = [WeiBoDBConnection statementWithQuery:"REPLACE INTO users VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
            [insertStmt retain];
        }
        [insertStmt bindInt64:userId              forIndex:1];
        [insertStmt bindString:screenName               forIndex:2];
        [insertStmt bindString:name         forIndex:3];
        [insertStmt bindString:province         forIndex:4];
        [insertStmt bindString:city         forIndex:5];
        [insertStmt bindString:location           forIndex:6];
        [insertStmt bindString:description        forIndex:7];
        [insertStmt bindString:url                forIndex:8];
        [insertStmt bindString:profileImageUrl    forIndex:9];
        [insertStmt bindString:domain forIndex:10];
        [insertStmt bindInt32:gender forIndex:11];
        [insertStmt bindInt32:followersCount      forIndex:12];
        [insertStmt bindInt32:friendsCount forIndex:13];
        [insertStmt bindInt32:statusesCount forIndex:14];
        [insertStmt bindInt32:favoritesCount forIndex:15];
        [insertStmt bindInt32:createdAt forIndex:16];
        [insertStmt bindInt32:following forIndex:17];
        [insertStmt bindInt32:verified forIndex:18];
        [insertStmt bindInt32:allowAllActMsg forIndex:19];
        [insertStmt bindInt32:geoEnabled           forIndex:20];
        
        int step = [insertStmt step];
        if (step != SQLITE_DONE) {
            //NSLog(@"update error username: %lld.%@,%@,%@", userId, screenName, province, city);
            [WeiBoDBConnection alert];
        }
        [insertStmt reset];
    }
}

// Convert timestamp string to UNIX time
time_t convertTimeStamp(NSString *stringTime) {

	time_t createdAt = 0;
    struct tm created;
    time_t now;
    time(&now);
    
    if (stringTime) {
		if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
			strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
		}
		createdAt = mktime(&created);
	}
	return createdAt;
}

@end
