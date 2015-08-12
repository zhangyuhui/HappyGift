//
//  HGImageService.h
//  HappyGift
//
//  Created by Zhang Yuhui on 8/24/10.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGImageData : NSObject {
	NSString* url;
	UIImage*  image;
    NSData*   data;
}
@property (retain) NSString* url; 
@property (retain) UIImage* image; 
@property (retain) NSData* data; 
@end

@interface HGImageService: NSObject{
	NSMutableArray* _imageLoadingArray;
	NSMutableDictionary* _imageLoadedDictionary;
	NSOperationQueue* _imageLoadingOpertionQueue;
	NSMutableDictionary* _imageLoadingOpertionDictionary;
    NSCondition* _imageStoreCondition;
}

- (UIImage*)requestImage:(NSString*)url;
- (UIImage*)requestImage:(NSString*)url target:(id)target selector:(SEL)selector;
- (HGImageData*)requestImageForRawData:(NSString*)url target:(id)target selector:(SEL)selector;

- (void)cancelImageData;
- (void)clearImageData;
- (void)checkImageData;

- (void)setSuspended:(BOOL)suspended;
- (BOOL)isSuspended;

- (BOOL)clearHistory;
- (BOOL)clearAllHistory;

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;

+ (HGImageService*)sharedService;

@end
