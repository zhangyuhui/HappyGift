//
//  HGGiftCategory.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGiftCategory : NSObject <NSCoding>{
    NSString* identifier;
    NSString* name;
    NSString* description;
    NSString* cover;
    NSString* coverSelected;
}
@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* cover;
@property (nonatomic, retain) NSString* coverSelected;
@end
