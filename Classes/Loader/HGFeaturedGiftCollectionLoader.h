//
//  HGGiftCollectionLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"
#import "HGFeaturedGiftCollection.h"

@protocol HGFeaturedGiftCollectionLoaderDelegate;

@interface HGFeaturedGiftCollectionLoader : HGNetworkConnection {
    BOOL running;
}
@property (nonatomic, assign)   id<HGFeaturedGiftCollectionLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestGiftCollection;
- (HGFeaturedGiftCollection*) featuredGiftCollectionLoaderCache;

@end


@protocol HGFeaturedGiftCollectionLoaderDelegate
- (void)featuredGiftCollectionLoader:(HGFeaturedGiftCollectionLoader *)featuredGiftCollectionLoader didRequestFeaturedGiftCollectionSucceed:(HGFeaturedGiftCollection*)featuredGiftCollection;
- (void)featuredGiftCollectionLoader:(HGFeaturedGiftCollectionLoader *)featuredGiftCollectionLoader didRequestFeaturedGiftCollectionsFail:(NSString*)error;
@end
