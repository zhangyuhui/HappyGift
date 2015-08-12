//
//  NSString+Addition.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/17/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Addition)
+ (id)stringWithData:(NSData*)data;

- (CGSize)drawInRect:(CGRect)theRect highlightedString:(NSString*)highlightedString normalFont:(UIFont*)normalFont highlightedFont:(UIFont*)highlightedFont normalColor:(UIColor*)normalColor highlightColor:(UIColor*)highlightColor;
- (CGSize)drawInRect:(CGRect)theRect highlightedString:(NSString*)highlightedString normalFont:(UIFont*)normalFont highlightedFont:(UIFont*)highlightedFont;

-(CGPoint)drawInRect:(CGPoint)thePoint followup:(NSString*)theFollowup rect:(CGRect)theRect font:(UIFont*)theFont color:(UIColor*)theColor;

-(NSString*)stringByStrippingHTML;

- (NSString *)stringByURLEncodingAsStringParameter;
- (NSString*)stringByDecodingHTMLEntities;

- (NSString *) stringFromMD5;

/**
 * Doxygen does not handle categories very well, so please refer to the .m file in general
 * for the documentation that is reflected on api.three20.info.
 */
+ (NSString *)generateGuid;

- (BOOL)isWhitespaceAndNewlines;
- (BOOL)isEmptyOrWhitespace;
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding;
- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query;

/**
 * Compares two strings expressing software versions.
 * Examples (?? means undefined):
 *   "3.0" = "3.0"
 *   "3.0a2" = "3.0a2"
 *   "3.0" > "2.5"
 *   "3.1" > "3.0"
 *   "3.0a1" < "3.0"
 *   "3.0a1" < "3.0a4"
 *   "3.0a2" < "3.0a19"  <-- numeric, not lexicographic
 *   "3.0a" < "3.0a1"
 *   "3.02" < "3.03"
 *   "3.0.2" < "3.0.3"
 *   "3.00" ?? "3.0"
 *   "3.02" ?? "3.0.3"
 *   "3.02" ?? "3.0.2"
 */
- (NSComparisonResult)versionStringCompare:(NSString *)other;

+ (NSData *)decodeBase64WithString:(NSString *)strBase64;

+(id) NSNullToNil:(id)text;

/**
 * Calculate the md5 hash of this string using CC_MD5.
 * @return md5 hash of this string
 */
@property (nonatomic, readonly) NSString* md5Hash;

@end
