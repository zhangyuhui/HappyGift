#import <sqlite3.h>
#import "WeiBoDBStatement.h"

//
// Interface for Database connector
//
@interface WeiBoDBConnection : NSObject
{
}

+ (void)createEditableCopyOfDatabaseIfNeeded:(BOOL)force;
+ (void)deleteMessageCache;

+ (sqlite3*)getSharedDatabase;
+ (void)closeDatabase;

+ (void)beginTransaction;
+ (void)commitTransaction;

+ (WeiBoDBStatement*)statementWithQuery:(const char*)sql;

+ (void)alert;

@end