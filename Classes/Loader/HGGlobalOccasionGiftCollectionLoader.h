//
//  HGGlobalOccasionGiftCollectionLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@protocol HGGlobalOccasionGiftCollectionLoaderDelegate;

@interface HGGlobalOccasionGiftCollectionLoader : HGNetworkConnection {
    BOOL running;
}
@property (nonatomic, assign)   id<HGGlobalOccasionGiftCollectionLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestGiftCollection;
-(NSArray*) globalOccasionGiftCollectionsLoaderCache;

@end


@protocol HGGlobalOccasionGiftCollectionLoaderDelegate
- (void)globalOccasionGiftCollectionLoader:(HGGlobalOccasionGiftCollectionLoader *)globalOccasionGiftCollectionLoader didRequestGlobalOccasionGiftCollectionsSucceed:(NSArray*)globalOccasionGiftCollections;
- (void)globalOccasionGiftCollectionLoader:(HGGlobalOccasionGiftCollectionLoader *)globalOccasionGiftCollectionLoader didRequestGlobalOccasionGiftCollectionsFail:(NSString*)error;
@end
