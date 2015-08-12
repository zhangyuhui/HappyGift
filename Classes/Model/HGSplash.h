//
//  HGSplash.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGSplash : NSObject <NSCoding>{
    UIImage*  image;
    NSString* url;
    NSString* title;
    NSString* pubDate;
}

@property (nonatomic, retain) UIImage*   image;
@property (nonatomic, retain) NSString*  url;
@property (nonatomic, retain) NSString*  title;
@property (nonatomic, retain) NSString*  pubDate;
@end
