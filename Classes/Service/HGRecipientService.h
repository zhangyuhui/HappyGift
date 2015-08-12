//
//  HGRecipientService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-17.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGRecipientLoader.h"
#import "HGRecipient.h"

@protocol HGRecipientServiceDelegate;

@interface HGRecipientService : NSObject {
    HGRecipientLoader* recipientLoader;
    HGRecipientLoader* recipientUploader;
    NSArray *phoneContacts;
    
    HGRecipient* selectedRecipient;
    NSCondition* _recipientsDBCondition;
}
@property (nonatomic, assign) id<HGRecipientServiceDelegate> delegate;
@property (nonatomic, retain, readwrite) HGRecipient* selectedRecipient;
@property (nonatomic, retain) NSDictionary* provinceCode;

+ (HGRecipientService*)sharedService;

- (NSArray*)listRecipients;
- (NSArray*)listRecipientsLike: (NSString*)pattern;
- (NSArray*)listSuggestedRecipients;
- (int)recipientCount;
- (int)snsRecipientCount;
- (HGRecipient*)getRecipient: (int)recipientId;
- (HGRecipient*)getRecipientWithNetworkId:(int)networkId andProfileId:(NSString*)profileId;
- (BOOL)addOrUpdateRecipient: (HGRecipient*)recipient;
- (BOOL)addRecipient: (HGRecipient*)recipient;
- (BOOL)updateRecipient: (HGRecipient*)recipient;
- (BOOL)removeRecipient: (int)recipientId;
- (BOOL)setSNSRecipientsToDB: (NSArray*) snsRecipients;
- (BOOL)clearSNSRecipients:(int) networkID;
- (void)updateRecipientLabel:(UILabel*)label;
- (void)updateSNSRecipientWithDBData: (HGRecipient*) recipient;

- (void)requestRecipients;
- (NSArray*)importPhoneContacts;
- (void)uploadPhoneContacts;

- (NSInteger) phoneContactsImportStatus;
- (void) updatePhoneContactsImportStatus:(NSInteger)status;
- (void)checkAndUpdateRecipients;

@end

@protocol HGRecipientServiceDelegate
@optional
- (void) didRequestRecipientsSucceed:(NSArray*)recipients;
- (void) didRequestRecipientsFail:(NSString*)error;
- (void) didUploadPhoneContactsSucceed;
- (void) didUploadPhoneContactsFail:(NSString*)error;
@end


