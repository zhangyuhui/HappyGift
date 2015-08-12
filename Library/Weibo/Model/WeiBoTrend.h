//
//  Trend.h
//  HappyGift
//
//  Created by Yuhui Zhang on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WeiBoTrend : NSObject {
    NSString*   name; 
	NSString*   query; 
}

@property (nonatomic, retain) NSString*	name;
@property (nonatomic, retain) NSString* query;

- (id)initWithJsonDictionary:(NSDictionary*)dict;
@end
