//
//  HGGiftSetsLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@class HGGift;
@protocol HGGiftSetsLoaderDelegate;

@interface HGGiftSetsLoader : HGNetworkConnection {
    BOOL running;
    int  requestType;
}
@property (nonatomic, assign)   id<HGGiftSetsLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestGiftSets:(NSArray*)categories;
- (NSDictionary*) giftSetsLoaderCache;
- (void)requestGiftDetail:(NSString*)giftId;
@end


@protocol HGGiftSetsLoaderDelegate
- (void)giftSetsLoader:(HGGiftSetsLoader *)giftSetsLoader didRequestGiftSetsSucceed:(NSDictionary*)giftSets;
- (void)giftSetsLoader:(HGGiftSetsLoader *)giftSetsLoader didRequestGiftSetsFail:(NSString*)error;

- (void)giftSetsLoader:(HGGiftSetsLoader *)giftSetsLoader didRequestGiftDetailSucceed:(HGGift*)gift;
- (void)giftSetsLoader:(HGGiftSetsLoader *)giftSetsLoader didRequestGiftDetailFail:(NSString *)error;
@end
