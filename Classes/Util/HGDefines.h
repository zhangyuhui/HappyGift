//
//  HGDefines.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/17/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define UIColorFromARGB(argbValue) [UIColor \
colorWithRed:((float)((argbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((argbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(argbValue & 0xFF))/255.0 \
alpha:((float)(argbValue & 0xFF000000))/255.0]

#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(2048, 1536), [[UIScreen mainScreen] currentMode].size)) : NO)



