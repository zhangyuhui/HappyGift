//
//  HGGiftCardService.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftCardService.h"
#import "HGGiftCardLoader.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"

static HGGiftCardService* giftCardService;

@interface HGGiftCardService () <HGGiftCardLoaderDelegate>

@end

@implementation HGGiftCardService
@synthesize delegate;
@synthesize giftCardCategories;

+ (HGGiftCardService*)sharedService{
    if (giftCardService == nil){
        giftCardService = [[HGGiftCardService alloc] init];
    }
    return giftCardService;
}

- (void)dealloc{
    [giftCardLoader release];
    [giftCardCategories release];
    [super dealloc];
}

- (void)requestGiftCards{
    if (giftCardLoader != nil){
        [giftCardLoader cancel];
    }else{
        giftCardLoader = [[HGGiftCardLoader alloc] init];
        giftCardLoader.delegate = self;
    }
    [giftCardLoader requestGiftCards];
}

+ (NSArray*)titleWords{
    return [NSArray arrayWithObjects:@"嗨", @"亲", @"嘿", @"你好", @"亲爱的", @"尊敬的", nil];
}

+ (NSArray*)enclosureWords{
    return [NSArray arrayWithObjects:@"来自", @"爱你的", @"牵挂你的", @"真诚的",  nil];    
}
 
#pragma mark　- HGGiftCardLoaderDelegate 
- (void)giftCardLoader:(HGGiftCardLoader *)theGiftCardLoader didRequestGiftCardsSucceed:(NSArray*)theGiftCardCategories{
    self.giftCardCategories = theGiftCardCategories;
    if ([delegate respondsToSelector:@selector(giftCardService:didRequestGiftCardsSucceed:)]){
        [delegate giftCardService:self didRequestGiftCardsSucceed:theGiftCardCategories];
    }
}

- (void)giftCardLoader:(HGGiftCardLoader *)theGiftCardLoader didRequestRequestGiftCardsFail:(NSString*)theError{
    NSArray* theGiftCardCategories = [theGiftCardLoader giftCardCategoriesLoaderCache];
    if (theGiftCardCategories) {
        HGDebug(@"giftCardLoader request failed, use cached data");
        self.giftCardCategories = theGiftCardCategories;
    }
    
    if ([delegate respondsToSelector:@selector(giftCardService:didRequestGiftCardsFail:)]){
        [delegate giftCardService:self didRequestGiftCardsFail:theError];
    }
}

@end
