//
//  HGGIFGift.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-27.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGIFGift: NSObject <NSCoding>  {
    NSString* identifier;
    NSString* name;
    NSString* image;
    NSString* gif;
    NSString* wishes;
}

@property (nonatomic, retain) NSString*  identifier;
@property (nonatomic, retain) NSString*  name;
@property (nonatomic, retain) NSString*  image;
@property (nonatomic, retain) NSString*  gif;
@property (nonatomic, retain) NSString*  wishes;

- (id)initWithGIFGiftJsonDictionary:(NSDictionary*)gifGiftJsonDictionary;
@end
