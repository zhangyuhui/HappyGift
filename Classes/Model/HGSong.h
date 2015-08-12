//
//  HGSong.h
//  HappyGift
//
//  Created by Zhang Yuhui on 12-7-9.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGSong: NSObject <NSCoding>  {
    NSString* name;
    NSString* artist;
    NSString* link;
}
@property (nonatomic, retain) NSString*  name;
@property (nonatomic, retain) NSString*  artist;
@property (nonatomic, retain) NSString*  link;
@end
