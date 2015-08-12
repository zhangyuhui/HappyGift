//
//  HGTweetComment.h
//  HappyGift
//
//  Created by Yujian Weng on 12-8-7.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGTweetComment: NSObject <NSCoding> {
    NSString*  commentId;
    
    NSString*  senderId;
    NSString*  senderName;
    NSString*  senderImageUrl;
    
    NSString*  text;
    NSString*  createTime;
    
    int        originTweetNetwork;
    NSString*  originTweetId;
    int        originTweetType;
}

@property (nonatomic, retain) NSString*  commentId;

@property (nonatomic, retain) NSString*  senderId;
@property (nonatomic, retain) NSString*  senderName;
@property (nonatomic, retain) NSString*  senderImageUrl;
@property (nonatomic, retain) NSString*  text;
@property (nonatomic, retain) NSString*  createTime;

@property (nonatomic, assign) int        originTweetNetwork;
@property (nonatomic, retain) NSString*  originTweetId;
@property (nonatomic, assign) int        originTweetType;

@end
