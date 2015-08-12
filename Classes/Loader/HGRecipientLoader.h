//
//  HGRecipientLoader.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-18.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"
#import "HGFeaturedGiftCollection.h"
#import "HGRecipient.h"

@protocol HGRecipientLoaderDelegate;

@interface HGRecipientLoader : HGNetworkConnection {
    BOOL running;
    int requestType;
}
@property (nonatomic, assign)   id<HGRecipientLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestRecipients;
- (void)requestPhoneContactsHash;
- (void)uploadPhoneContacts:(NSString*)contactsJson;

@end


@protocol HGRecipientLoaderDelegate
- (void)recipientLoader:(HGRecipientLoader *)recipientLoader didRequestRecipientsSucceed:(NSArray*)recipients;
- (void)recipientLoader:(HGRecipientLoader *)recipientLoader didRequestRecipientsFail:(NSString*)error;

- (void)recipientLoader:(HGRecipientLoader *)recipientLoader didRequestPhoneContactsHashSucceed:(NSString*)hash;
- (void)recipientLoader:(HGRecipientLoader *)recipientLoader didRequestPhoneContactsHashFail:(NSString*)error;

- (void)recipientLoader:(HGRecipientLoader *)recipientLoader didUploadPhoneContactsSucceed:(NSString*)result;
- (void)recipientLoader:(HGRecipientLoader *)recipientLoader didUploadPhoneContactsFail:(NSString*)error;
@end

