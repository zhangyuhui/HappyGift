//
//  NSData+Addition.h
//  HappyGift
//
//  Created by Yuhui Zhang on 8/6/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Addition)
/**
 * Calculate the md5 hash of this data using CC_MD5, return md5 hash of this data
 */
@property (nonatomic, readonly) NSString* md5Hash;
@end
