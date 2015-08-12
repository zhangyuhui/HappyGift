//
//  HGWish.h
//  HappyGift
//
//  Created by Zhang Yuhui on 12-7-9.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGWish: NSObject <NSCoding>  {
    NSString* content;
}
@property (nonatomic, retain) NSString*  content;
@end
