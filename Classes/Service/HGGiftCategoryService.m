//
//  HGGiftCategoryService.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftCategoryService.h"
#import "HGGiftCategoryLoader.h"
#import "HappyGiftAppDelegate.h"
#import "HGGiftCategory.h"
#import "HGAppConfigurationService.h"

static HGGiftCategoryService* giftCategoryService;

@interface HGGiftCategoryService () <HGGiftCategoryLoaderDelegate>

@end

@implementation HGGiftCategoryService
@synthesize delegate;
@synthesize giftCategories;


+ (HGGiftCategoryService*)sharedService{
    if (giftCategoryService == nil){
        giftCategoryService = [[HGGiftCategoryService alloc] init];
    }
    return giftCategoryService;
}

- (void)dealloc{
    [giftCategoryLoader release];
    [giftCategories release];
    [super dealloc];
}

- (void)requestGiftCategories{
    if (giftCategoryLoader != nil){
        [giftCategoryLoader cancel];
    }else{
        giftCategoryLoader = [[HGGiftCategoryLoader alloc] init];
        giftCategoryLoader.delegate = self;
    }
    [giftCategoryLoader requestGiftCategories];
}

- (NSArray*)giftCategories{
    if (giftCategories == nil) { 
        giftCategories = [[[HGAppConfigurationService sharedService] giftCategories] retain];
    }
    return giftCategories;
}
 
#pragma mark　- HGGiftCategoryLoaderDelegate 
- (void)giftCategoryLoader:(HGGiftCategoryLoader *)theGiftCategoryLoader didRequestGiftCategoriesSucceed:(NSArray*)theGiftCategories{
    if (giftCategories != nil){
        [giftCategories release];
        giftCategories = nil;
    }
    giftCategories = [[NSArray alloc] initWithArray:theGiftCategories];
    if ([delegate respondsToSelector:@selector(giftCategoryService:didRequestGiftCategoriesSucceed:)]){
        [delegate giftCategoryService:self didRequestGiftCategoriesSucceed:theGiftCategories];
    }
}

- (void)giftCategoryLoader:(HGGiftCategoryLoader *)theGiftCategoryLoader didRequestRequestGiftCategoriesFail:(NSString*)theError{
    if ([delegate respondsToSelector:@selector(giftCategoryService:didRequestGiftCategoriesFail:)]){
        [delegate giftCategoryService:self didRequestGiftCategoriesFail:theError];
    }
}
@end
