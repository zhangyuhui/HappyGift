//
//  HGPersonlizedOccasionGiftCollectionLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@protocol HGPersonlizedOccasionGiftCollectionLoaderDelegate;

@interface HGPersonlizedOccasionGiftCollectionLoader : HGNetworkConnection {
    BOOL running;
    int requestType;
}
@property (nonatomic, assign)   id<HGPersonlizedOccasionGiftCollectionLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestGiftCollection;
- (void)requestGiftsForOccasion:(NSString*)occasion andNetworkId:(int)networkId andProfileId:(NSString*)profileId withOffset:(int)offset andTagId:(NSString*)tagId;
- (void)requestGIFGiftsForOccasion:(NSString*)occasion andNetworkId:(int)networkId andProfileId:(NSString*)profileId withOffset:(int)offset andTagId:(NSString*)tagId;
-(NSArray*) personalizedOccasionGiftCollectionsLoaderCache;

@end

@protocol HGPersonlizedOccasionGiftCollectionLoaderDelegate
@required
- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)personlizedOccasionGiftCollectionLoader didRequestPersonlizedOccasionGiftCollectionsSucceed:(NSArray*)personlizedOccasionGiftCollectionsArray;
- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)personlizedOccasionGiftCollectionLoader didRequestPersonlizedOccasionGiftCollectionsFail:(NSString*)error;

- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)personlizedOccasionGiftCollectionLoader didRequestGiftsForOccasionSucceed:(NSArray*)giftsForOccasion;
- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)personlizedOccasionGiftCollectionLoader didRequestGiftsForOccasionFail:(NSString*)error;

- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)personlizedOccasionGiftCollectionLoader didRequestGIFGiftsForOccasionSucceed:(NSArray*)giftsForOccasion;
- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)personlizedOccasionGiftCollectionLoader didRequestGIFGiftsForOccasionFail:(NSString*)error;


@optional
- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)personlizedOccasionGiftCollectionLoader didRequestPersonlizedOccasionAccessTokenFailed:(int)tokenNetwork;
@end
