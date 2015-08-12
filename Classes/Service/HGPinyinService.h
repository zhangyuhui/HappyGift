//
//  HGPinyinService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-25.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HGPinyinService : NSObject {
}

//输入中文，返回拼音。
+ (NSString *) convertFrom:(NSString *)hanzi;
+ (void)clearCache;

@end
