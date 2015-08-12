//
//  HGGiftSet.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGiftSet : NSObject <NSCoding>{
    NSString* identifier;
    NSString* name;
    NSString* cover;
    NSString* thumb;
    NSString* description;
    NSString* manufacturer;
    BOOL      canLetThemChoose;
    NSArray*  gifts;
}

-(id)initWithProductJsonDictionary:(NSDictionary*)productJsonDictionary;

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* cover;
@property (nonatomic, retain) NSString* thumb;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* manufacturer;
@property (nonatomic, assign) BOOL canLetThemChoose;
@property (nonatomic, retain) NSArray*  gifts;

@end
