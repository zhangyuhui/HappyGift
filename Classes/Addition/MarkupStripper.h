//
//  MarkupStripper.h
//  HappyGift
//
//  Created by Li Shuai on 5/5/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MarkupStripper : NSObject <NSXMLParserDelegate> {
    NSMutableArray* _strings;
	BOOL hasError;
}
- (NSString*)parse:(NSString*)string;
@end
