//
//  Trend.m
//  HappyGift
//
//  Created by Yuhui Zhang on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WeiBoTrend.h"


@implementation WeiBoTrend
@synthesize name;
@synthesize query;

- (void)dealloc {
	[name release];
    [query release];
	[super dealloc];
}

- (id)initWithJsonDictionary:(NSDictionary*)dict{
    self = [super init];
    if (self){
        [name release];
        [query release];
        
        self.name = [dict objectForKey:@"name"];
        self.query = [dict objectForKey:@"query"]; 
    }    
    return self;    
}
@end
