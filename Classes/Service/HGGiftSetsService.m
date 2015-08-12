//
//  HGGiftSetsService.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftSetsService.h"
#import "HGGiftSetsLoader.h"
#import "HGGiftCategoryService.h"
#import "HGGiftCategory.h"
#import "HappyGiftAppDelegate.h"
#import "HGFavoriteLoader.h"
#import "HGLogging.h"
#import "HGGift.h"
#import "HGGiftSet.h"
#import "HGConstants.h"

static HGGiftSetsService* giftSetsService;

@interface HGGiftSetsService () <HGGiftSetsLoaderDelegate, HGFavoriteLoaderDelegate>

@end

@implementation HGGiftSetsService
@synthesize delegate;
@synthesize giftSets;
@synthesize myLikeProducts;
@synthesize myLikeIds;

+ (HGGiftSetsService*)sharedService{
    if (giftSetsService == nil){
        giftSetsService = [[HGGiftSetsService alloc] init];
    }
    return giftSetsService;
}

- (void)dealloc{
    [giftSetsLoader release];
    [giftSets release];
    [myLikeProducts release];
    [myLikeIds release];
    [favoriteLoader release];
    [likeLoader release];
    [unLikeLoader release];
    [super dealloc];
}

- (void)requestGiftSets{
    if (giftSetsLoader != nil){
        [giftSetsLoader cancel];
    }else{
        giftSetsLoader = [[HGGiftSetsLoader alloc] init];
        giftSetsLoader.delegate = self;
        if (giftSets != nil){
            [giftSets release];
            giftSets = nil;
        }
        giftSets = [[giftSetsLoader giftSetsLoaderCache] retain];
    }
    
    NSArray* giftCategories = [HGGiftCategoryService sharedService].giftCategories;
    NSMutableArray* giftCategoriesForRequest = [[NSMutableArray alloc] init];
    for (HGGiftCategory* giftCategory in giftCategories){
        [giftCategoriesForRequest addObject:giftCategory.identifier];
    }
    [giftSetsLoader requestGiftSets:giftCategoriesForRequest];
    [giftCategoriesForRequest release];
}

- (void) requestGiftDetail:(NSString *)giftId {
    if (giftDetailLoader != nil) {
        [giftDetailLoader cancel];
    }else{
        giftDetailLoader = [[HGGiftSetsLoader alloc] init];
        giftDetailLoader.delegate = self;
    }
    
    [giftDetailLoader requestGiftDetail:giftId];
}

- (void)requestGiftLike:(NSString*) giftId{
    if (likeLoader != nil){
        [likeLoader cancel];
    }else{
        likeLoader = [[HGFavoriteLoader alloc] init];
        likeLoader.delegate = self;
    }
    [myLikeIds addObject:giftId];
    [likeLoader requestGiftLike:giftId];
}

- (void)requestGiftUnLike:(NSString*) giftId{
    if (unLikeLoader != nil){
        [unLikeLoader cancel];
    }else{
        unLikeLoader = [[HGFavoriteLoader alloc] init];
        unLikeLoader.delegate = self;
    }
    [myLikeIds removeObject:giftId];
    [unLikeLoader requestGiftUnLike:giftId];
}

- (void)requestMyLikeProducts {
    if (favoriteLoader != nil) {
        [favoriteLoader cancel];
    } else {
        favoriteLoader = [[HGFavoriteLoader alloc] init];
        favoriteLoader.delegate = self;
    }
    [favoriteLoader requestMyLikeProducts];
}

- (void)requestMyLikeIds {
    if (favoriteLoader != nil) {
        [favoriteLoader cancel];
    } else {
        favoriteLoader = [[HGFavoriteLoader alloc] init];
        favoriteLoader.delegate = self;
    }
    [favoriteLoader requestMyLikeIds];
}

- (BOOL) isMyLike:(HGGift*)gift {
    return ([myLikeIds containsObject:[NSNumber numberWithInt:[gift.identifier intValue]]] || [myLikeIds containsObject:gift.identifier]);
} 

-(void) clearMyLikesCache {
    self.myLikeIds = nil;
    self.myLikeProducts = nil;
}

#pragma mark　- HGGiftSetsLoaderDelegate
- (void)giftSetsLoader:(HGGiftSetsLoader *)theGiftSetsLoader didRequestGiftSetsSucceed:(NSDictionary*)theGiftSets{
    if (giftSets != nil){
        [giftSets release];
        giftSets = nil;
    }
    giftSets = [theGiftSets retain];
    if ([delegate respondsToSelector:@selector(giftSetsService:didRequestGiftSetsSucceed:)]){
        [delegate giftSetsService:self didRequestGiftSetsSucceed:theGiftSets];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationGiftSetsUpdated object:self];
}

- (void)giftSetsLoader:(HGGiftSetsLoader *)theGiftSetsLoader didRequestGiftSetsFail:(NSString*)error{
    NSDictionary* theGiftSets = [theGiftSetsLoader giftSetsLoaderCache];
    if (theGiftSets) {
        HGDebug(@"giftSetsLoader request failed, use cached data");
        if (giftSets != nil){
            [giftSets release];
            giftSets = nil;
        }
        giftSets = [theGiftSets retain];
    }
    
    if ([delegate respondsToSelector:@selector(giftSetsService:didRequestGiftSetsFail:)]){
        [delegate giftSetsService:self didRequestGiftSetsFail:error];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationGiftSetsUpdated object:self];
}

- (void)giftSetsLoader:(HGGiftSetsLoader *)giftSetsLoader didRequestGiftDetailSucceed:(HGGift*)gift {
    if ([self.delegate respondsToSelector:@selector(giftSetsService:didRequestGiftDetailSucceed:)]) {
        [self.delegate giftSetsService:self didRequestGiftDetailSucceed:gift];
    }
}

- (void)giftSetsLoader:(HGGiftSetsLoader *)giftSetsLoader didRequestGiftDetailFail:(NSString *)error {
    if ([self.delegate respondsToSelector:@selector(giftSetsService:didRequestGiftDetailFail:)]) {
        [self.delegate giftSetsService:self didRequestGiftDetailFail:error];
    }
}

#pragma mark　- HGFavoriteLoaderDelegate
- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestGiftLikeSucceed:(NSString*)giftId{
    if ([self.delegate respondsToSelector:@selector(giftSetsService:didRequestGiftLikeSucceed:)]) {
        [self.delegate giftSetsService:self didRequestGiftLikeSucceed:giftId];
    }
}

- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestGiftLikeFail:(NSString*)error forGiftId:(NSString *)giftId {
    [myLikeIds removeObject:giftId];
    if ([self.delegate respondsToSelector:@selector(giftSetsService:didRequestGiftLikeFail:)]) {
        [self.delegate giftSetsService:self didRequestGiftLikeFail:error];
    }
}

- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestGiftUnLikeSucceed:(NSString*)giftId{
    if ([self.delegate respondsToSelector:@selector(giftSetsService:didRequestGiftUnLikeSucceed:)]) {
        [self.delegate giftSetsService:self didRequestGiftUnLikeSucceed:giftId];
    }
}

- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestGiftUnLikeFail:(NSString*)error forGiftId:(NSString *)giftId {
    [myLikeIds addObject:giftId];
    if ([self.delegate respondsToSelector:@selector(giftSetsService:didRequestGiftUnLikeFail:)]) {
        [self.delegate giftSetsService:self didRequestGiftUnLikeFail:error];
    }
}

- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestMyLikeProductsSucceed:(NSArray*)theMyLikes {
    if (myLikeProducts != nil) {
        [myLikeProducts release];
        myLikeProducts = nil;
    }
    
    myLikeProducts = [theMyLikes retain];
    
    if (!myLikeIds) {
        myLikeIds = [[NSMutableSet alloc] init];
    } else {
        [myLikeIds removeAllObjects];
    }
    
    for (HGGiftSet* giftSet in myLikeProducts) {
        for (HGGift* gift in giftSet.gifts) {
            [myLikeIds addObject:gift.identifier];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(giftSetsService:didRequestMyLikeProductsSucceed:)]) {
        [self.delegate giftSetsService:self didRequestMyLikeProductsSucceed:myLikeProducts];
    }
}

- (void)favoriteLoader:(HGFavoriteLoader *)theFavoriteLoader didRequestMyLikeProductsFail:(NSString *)error {
    NSArray* theMyLikes = [theFavoriteLoader myLikeProductsLoaderCache];
    if (theMyLikes) {
        HGDebug(@"my likes request failed, use cached data");
        if (myLikeProducts != nil) {
            [myLikeProducts release];
            myLikeProducts = nil;
        }
        myLikeProducts = [theMyLikes retain];
    }
    
    if ([self.delegate respondsToSelector:@selector(giftSetsService:didRequestMyLikeProductsFail:)]) {
        [self.delegate giftSetsService:self didRequestMyLikeProductsFail:error];
    }
}

- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestMyLikeIdsSucceed:(NSSet*)theMyLikesId {
    if (myLikeIds) {
        [myLikeIds release];
        myLikeIds = nil;
    }
    
    myLikeIds = [[NSMutableSet alloc] initWithSet:theMyLikesId];
}

- (void)favoriteLoader:(HGFavoriteLoader *)theFavoriteLoader didRequestMyLikeIdsFail:(NSString *)error {
    NSSet* theMyLikeIds = [theFavoriteLoader myLikeIdsLoaderCache];
    if (theMyLikeIds) {
        HGDebug(@"my like Ids request failed, use cached data");
        if (myLikeIds != nil) {
            [myLikeIds release];
            myLikeIds = nil;
        }
        myLikeIds = [[NSMutableSet alloc] initWithSet:theMyLikeIds];
    }
}

@end
