//
//  HGLogging.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/18/11.
//  Copyright 2012 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HGVerbose(s,...) [HGLogging performLog:HGLoggingLevelVerbose file:__FILE__ methodName:NSStringFromSelector(_cmd) lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define HGDebug(s,...) [HGLogging performLog:HGLoggingLevelDebug file:__FILE__ methodName:NSStringFromSelector(_cmd) lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define HGInfo(s,...) [HGLogging performLog:HGLoggingLevelInfo file:__FILE__ methodName:NSStringFromSelector(_cmd) lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define HGWarning(s,...) [HGLogging performLog:HGLoggingLevelWarning file:__FILE__ methodName:NSStringFromSelector(_cmd) lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define HGError(s,...) [HGLogging performLog:HGLoggingLevelError file:__FILE__ methodName:NSStringFromSelector(_cmd) lineNumber:__LINE__ format:(s),##__VA_ARGS__]

typedef enum {
    HGLoggingLevelUndefined = 0,
    HGLoggingLevelVerbose,
    HGLoggingLevelDebug,
    HGLoggingLevelInfo,
    HGLoggingLevelWarning,
    HGLoggingLevelError
} HGLoggingLevel;

@interface HGLogging : NSObject {
    
}

+(BOOL)performLog:(HGLoggingLevel) level file:(char*)sourceFile methodName:(NSString *) methodName lineNumber:(int)lineNumber format:(NSString*)format, ...;



@end
