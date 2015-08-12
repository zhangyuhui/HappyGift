//
//  HGRecipientSelectionViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGRecipientSelectionViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGRecipientService.h"
#import "HGRecipientSelectionViewCellView.h"
#import "NSString+Addition.h"
#import "HGDefines.h"
#import "HGTrackingService.h"
#import "HGUserImageView.h"
#import "HGUtility.h"
#import "HGGiftOccasion.h"
#import "HGOccasionCategory.h"

#define kPhoneContactsNew 0
#define kPhoneContactsImported 1
#define kPhoneContactsUploaded 2

#define kRecipientTableViewHeight 363
#define kImportContactsAlertViewTag  123

@interface HGRecipientSelectionViewController(Private) <UITextFieldDelegate, UITableViewDelegate>

- (void) handleSearchTimer: (NSTimer *) timer;
- (BOOL) isEmptyResultWithKeyword; 
@end

@implementation HGRecipientSelectionViewController

@synthesize recipientDataItems;
@synthesize delegate;

- (id)initWithRecipientSelectionType:(int)type {
    self = [super initWithNibName:@"HGRecipientSelectionViewController" bundle:nil];
    if (self) {
        recipientSelectionType = type;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (kPhoneContactsNew == [[HGRecipientService sharedService] phoneContactsImportStatus]) {
        [self showImportContactDialog];
    }
    
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleCancelAction:)];
    
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    navigationBar.topItem.rightBarButtonItem = nil;
 
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    
    searchTextField.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    [searchTextField setValue:[UIColor grayColor]
                    forKeyPath:@"_placeholderLabel.textColor"]; 
    searchTextField.delegate = self;
    
    if (recipientSelectionType == kRecipientSelectionTypeInviteUser) {
        tableHeaderLabel.text = @"我的联系人";
    } else {
        tableHeaderLabel.text = @"可能要送的人";
    }
    if (recipientSelectionType == kRecipientSelectionTypeSNSUsers) {
        [self updateSearchTextFieldPlaceHolder:[[HGRecipientService sharedService] snsRecipientCount]];
    } else {
        [self updateSearchTextFieldPlaceHolder:[[HGRecipientService sharedService] recipientCount]];
    }
    tableHeaderLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    tableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(didSearchKeywordChanged)
     name:UITextFieldTextDidChangeNotification 
     object:searchTextField];
    
    [self refreshRecipientsView];
    [[HGRecipientService sharedService] checkAndUpdateRecipients];
}

- (void) showImportContactDialog {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:@"是否允许乐送上传手机联系人至服务器以获得更为个性化的服务？" 
                                                        delegate:self 
                                               cancelButtonTitle:@"允许" 
                                               otherButtonTitles:@"取消",nil];
    [alertView setTag:kImportContactsAlertViewTag];
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == kImportContactsAlertViewTag) {
        if (alertView.firstOtherButtonIndex == buttonIndex) {
            [[HGRecipientService sharedService] updatePhoneContactsImportStatus:kPhoneContactsImported];
            [[HGRecipientService sharedService] importPhoneContacts];
        } else if (alertView.cancelButtonIndex == buttonIndex) {
            [[HGRecipientService sharedService] updatePhoneContactsImportStatus:kPhoneContactsUploaded];
            [progressView startAnimation];
            [HGRecipientService sharedService].delegate = self;
            [[HGRecipientService sharedService] uploadPhoneContacts];
        }
        [self refreshRecipientsView];
	}
}

- (void)updateSearchTextFieldPlaceHolder:(int)count {
    if (recipientSelectionType == kRecipientSelectionTypeInviteUser) {
        if (count > 0) {
            searchTextField.placeholder = [NSString stringWithFormat:@"搜索联系人（%d人）", count];
        } else {
            searchTextField.placeholder = @"搜索联系人";
        }
    } else {
        if (count > 0) {
            searchTextField.placeholder = [NSString stringWithFormat:@"搜索礼物接收人（%d人）", count];
        } else {
            searchTextField.placeholder = @"搜索礼物接收人";
        }
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    [leftBarButtonItem release];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [progressView release];
    [leftBarButtonItem release];
    [searchTextField release];
    
    HGRecipientService* recipientsService = [HGRecipientService sharedService];
    if (recipientsService.delegate == self) {
        recipientsService.delegate = nil;
    }
    
	[super dealloc];
}

- (void)handleCancelAction:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didSearchKeywordChanged {
    if (searchTimer != nil) {
        [searchTimer invalidate];
        searchTimer = nil;
    }
    
    searchTimer = [NSTimer scheduledTimerWithTimeInterval: 0.3
                                     target: self
                                   selector: @selector(handleSearchTimer:)
                                   userInfo: nil
                                    repeats: NO];
}

- (NSArray*) filterSNSRecipients:(NSArray*)input {
    NSMutableArray* recipients = [[NSMutableArray alloc] init];
    for (id object in input) {
        HGRecipient* recipient = nil;
        if ([object isKindOfClass:HGRecipient.class]) {
            recipient = (HGRecipient*)object;
        } else if ([object isKindOfClass:HGGiftOccasion.class]) {
            recipient = ((HGGiftOccasion*)object).recipient;
        }
        if (recipient.recipientNetworkId == NETWORK_SNS_RENREN || recipient.recipientNetworkId == NETWORK_SNS_WEIBO) {
            [recipients addObject:object];
        }
    }
    return [recipients autorelease];
}

- (void) handleSearchTimer: (NSTimer *) timer {
    [searchTimer invalidate];
    searchTimer = nil;
    
    NSString* pattern = [searchTextField.text stringByTrimmingCharactersInSet:
    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray* recipients;
    if (pattern && [@"" isEqualToString: pattern]) {
        recipients = [[HGRecipientService sharedService] listSuggestedRecipients];
    } else {
        recipients = [[HGRecipientService sharedService] listRecipientsLike:pattern];
    }
    if (recipientSelectionType == kRecipientSelectionTypeSNSUsers) {
        recipients = [self filterSNSRecipients:recipients];
    }
    self.recipientDataItems = recipients;
    if ([self isEmptyResultWithoutKeyword]) {
        tableView.hidden = YES;
    } else {
        tableView.hidden = NO;
    }
    [tableView reloadData];
}

- (void) updateRecipientsView:(NSDictionary*)recipients {
    [progressView stopAnimation];
    self.recipientDataItems = [recipients objectForKey:@"recipients"];
    if ([self isEmptyResultWithoutKeyword]) {
        tableView.hidden = YES;
    } else {
        tableView.hidden = NO;
    }
    [tableView reloadData];
}

- (void) refreshRecipientsInBackground {
    NSArray* recipients;
    if (recipientSelectionType == kRecipientSelectionTypeInviteUser) {
        recipients = [[HGRecipientService sharedService] listRecipients];
    } else {
        recipients = [[HGRecipientService sharedService] listSuggestedRecipients];
    }
    if (recipientSelectionType == kRecipientSelectionTypeSNSUsers) {
        recipients = [self filterSNSRecipients:recipients];
    }
    [self performSelectorOnMainThread:@selector(updateRecipientsView:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:recipients, @"recipients", nil] waitUntilDone:NO];
}

- (void) refreshRecipientsView {
    [progressView startAnimation];
    [self performSelectorInBackground:@selector(refreshRecipientsInBackground) withObject:nil];
}

- (BOOL) isEmptyResultWithoutKeyword {
    return [searchTextField.text isEmptyOrWhitespace] && (!recipientDataItems || [recipientDataItems count] == 0) ? YES : NO;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HGRecipient* recipient = nil;
    NSUInteger row = [indexPath row];
    if (!recipientDataItems || row >= [recipientDataItems count]) {
        recipient = [[[HGRecipient alloc] init] autorelease];
        recipient.recipientName = searchTextField.text;
        recipient.recipientNetworkId = 0;
        [[HGRecipientService sharedService] addRecipient:recipient];
    } else {
        NSObject* object = [recipientDataItems objectAtIndex:row];
        if ([object isKindOfClass:HGRecipient.class]) {
            recipient = (HGRecipient*)object;
        } else if ([object isKindOfClass:HGGiftOccasion.class]) {
            recipient = ((HGGiftOccasion*)object).recipient;
        }
    }
    
    if (recipientSelectionType != kRecipientSelectionTypeInviteUser) {
        [HGRecipientService sharedService].selectedRecipient = recipient;
    }
    
    if ([delegate respondsToSelector:@selector(didRecipientSelected:)]) {
        [delegate didRecipientSelected:recipient];
    }
    
    [theTableView deselectRowAtIndexPath: indexPath animated: YES];
    [self dismissModalViewControllerAnimated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = recipientDataItems ? [recipientDataItems count] : 0;
    if (![searchTextField.text isEmptyOrWhitespace] && recipientSelectionType != kRecipientSelectionTypeSNSUsers) {
        ++count;
    }
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *viewIdentifier=@"HGRecipientSelectionViewCellView";
    HGRecipientSelectionViewCellView *cell = [theTableView dequeueReusableCellWithIdentifier:viewIdentifier];
    if (cell == nil) {
        cell = [HGRecipientSelectionViewCellView recipientCellView];
        cell.userNameLabelView.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        cell.userNameLabelView.textColor = [UIColor blackColor];
        cell.userBirthdayView.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
        cell.userBirthdayView.textColor = UIColorFromRGB(0x6c6c6c);
    }
    
    NSUInteger row = [indexPath row];
    if (!recipientDataItems || row >= [recipientDataItems count]) {
        cell.userNameLabelView.text = [NSString stringWithFormat:@"添加接收人：%@", searchTextField.text];
        cell.addRecipientView.hidden = NO;
        cell.userImageView.hidden = YES;
        cell.userBirthdayView.hidden = YES;
    } else {
        cell.addRecipientView.hidden = YES;
        cell.userImageView.hidden = NO;
        NSObject* object = [recipientDataItems objectAtIndex:row];
        HGRecipient* recipient = nil;
        HGGiftOccasion* giftOccasion = nil;
        if ([object isKindOfClass:HGRecipient.class]) {
            recipient = (HGRecipient*)object;
        } else if ([object isKindOfClass:HGGiftOccasion.class]) {
            recipient = ((HGGiftOccasion*)object).recipient;
            giftOccasion = (HGGiftOccasion*)object;
        }
                                  
        cell.userNameLabelView.text = recipient.recipientName;
        [cell updateUserImageViewWithRecipient:recipient];
        
        if (giftOccasion && ![@"birthday" isEqualToString: giftOccasion.occasionCategory.identifier]) {
            cell.userBirthdayView.text = giftOccasion.occasionCategory.name;
            cell.userBirthdayView.hidden = YES;
        } else {
            NSString* birthday = [HGUtility formatBirthdayText:recipient.recipientBirthday forShortDescription:NO];
            if (birthday) {
                cell.userBirthdayView.hidden = NO;
                cell.userBirthdayView.text = birthday;
            } else {
                cell.userBirthdayView.hidden = YES;
            }
        }
    }
    
    return cell;
}

- (UIView*) recipientSelectionFootView {    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 296, 40)];
    
    UIImage* image = [UIImage imageNamed:@"recipient_selection_footer_bg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 296, 40);
    
    [view addSubview:imageView];
    
    [imageView release];
    return [view autorelease];
}

#pragma mark HGRecipientServiceDelegate

- (void) didUploadPhoneContactsSucceed {
    [progressView stopAnimation];
}

- (void) didUploadPhoneContactsFail:(NSString*)error {
    [progressView stopAnimation];
}

#pragma mark UITextFieldDelegate implementation
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([searchTextField isFirstResponder]) {
        [searchTextField resignFirstResponder];
    }
    return YES;
}

-(IBAction)backgroundTap:(id)sender {
    if ([searchTextField isFirstResponder]){
        [searchTextField resignFirstResponder];
    }
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    CGRect viewFrame = [tableView frame];
    NSDictionary* info = [aNotification userInfo];

    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    viewFrame.size.height = kRecipientTableViewHeight - keyboardSize.height;
    tableView.frame = viewFrame;
}


// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardWasHidden:(NSNotification*)aNotification {
    CGRect viewFrame = [tableView frame];
    viewFrame.size.height = kRecipientTableViewHeight;
    tableView.frame = viewFrame;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    dragOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    CGFloat currentScrollViewOffsetY = scrollView.contentOffset.y;
    
    if (dragOffsetY - currentScrollViewOffsetY >= 90) {
        if ([searchTextField isFirstResponder]){
            [searchTextField resignFirstResponder];
        }
    }
    
    dragOffsetY = currentScrollViewOffsetY;
}

@end

