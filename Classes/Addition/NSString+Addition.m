//
//  NSString+Addition.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/17/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "NSString+Addition.h"
#import "MarkupStripper.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+Addition.h"

@implementation NSString (Addition)

+ (id)stringWithData:(NSData*)data{
	id result = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
//    if (!result){
//        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);    
//        result = [[[NSString alloc] initWithData: data encoding: encoding] autorelease];
//    }
	if (!result){
        result = [[[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding] autorelease];
    }
	return result;
}

- (CGSize) drawInRect: (CGRect) theRect highlightedString: (NSString*) highlightedString 
					   normalFont: (UIFont*) normalFont highlightedFont: (UIFont*) highlightedFont 
		               normalColor:(UIColor*)normalColor highlightColor:(UIColor*)highlightColor {
	
	NSRange highlightRange = (highlightedString==nil||[highlightedString isEqualToString:@""]) ? NSMakeRange(NSNotFound, 0) : [self rangeOfString: highlightedString options: NSCaseInsensitiveSearch];
	if (highlightRange.location == NSNotFound) {
		[normalColor set];
		return [self drawAtPoint:theRect.origin forWidth:theRect.size.width withFont:normalFont lineBreakMode:UILineBreakModeTailTruncation];
	}
	
	CGSize actualSize = CGSizeMake(0, 0);
	if (highlightRange.location > 0) {
		NSString* substring = [self substringToIndex: highlightRange.location];
		[normalColor set];
		actualSize = [substring drawAtPoint:theRect.origin forWidth:theRect.size.width withFont:normalFont lineBreakMode:UILineBreakModeTailTruncation];
		theRect.origin.x += actualSize.width;
		theRect.size.width -= actualSize.width;
	}
	
	if (theRect.size.width < 10){
		return actualSize;
	}
	
	if (theRect.size.width > 0) {
		NSString* substring = [self substringWithRange:highlightRange];
		CGSize size = [substring sizeWithFont:highlightedFont forWidth:theRect.size.width lineBreakMode:UILineBreakModeTailTruncation];
		if (size.width != 0) {
			[highlightColor set];
			[substring drawAtPoint:theRect.origin forWidth:theRect.size.width withFont:highlightedFont lineBreakMode:UILineBreakModeTailTruncation];
			theRect.origin.x += size.width;
			theRect.size.width -= size.width;
			
			actualSize.width += size.width;
		}
	}
	
	if (theRect.size.width < 10){
		return actualSize;
	}
	
	if (highlightRange.location + highlightRange.length < [self length] && theRect.size.width > 0) {
		NSString* substring = [self substringFromIndex:highlightRange.location + highlightRange.length];
		[normalColor set];
		CGSize size = [substring drawAtPoint:theRect.origin forWidth:theRect.size.width withFont:normalFont lineBreakMode:UILineBreakModeTailTruncation];
		actualSize.width += size.width;
	}
	
	return actualSize;
}

- (CGSize) drawInRect:(CGRect)theRect highlightedString:(NSString*) highlightedString normalFont:(UIFont*)normalFont highlightedFont:(UIFont*)highlightedFont; {
	return [self drawInRect:theRect highlightedString:highlightedString normalFont:normalFont highlightedFont:highlightedFont normalColor:nil highlightColor:nil];
}

-(CGPoint)drawInRect:(CGPoint)thePoint followup:(NSString*)theFollowup rect:(CGRect)theRect font:(UIFont*)theFont color:(UIColor*)theColor{
    if ([self isEqualToString:@""]){
        return thePoint;
    }
    [theColor set];
    if (thePoint.x == 0.0f){
        CGRect drawRect = theRect;
        drawRect.origin.y += thePoint.y;
        drawRect.size.height -= thePoint.y;
        CGSize stringSize = [self drawInRect:drawRect withFont:theFont lineBreakMode:UILineBreakModeCharacterWrap];
        CGSize lineSize = [@"C" sizeWithFont:theFont forWidth:CGFLOAT_MAX lineBreakMode:UILineBreakModeCharacterWrap];
        CGFloat lineHeight = lineSize.height;
        if (stringSize.height > lineHeight){
            CGFloat stringHeight = stringSize.height;
            NSRange wrapRange = NSMakeRange(0, [self length]-1);
            CGFloat wrapHeight = stringSize.height - lineHeight;
            
            while (stringHeight > wrapHeight){
                wrapRange.length -= 1;
                NSString* wrapString = [self substringWithRange:wrapRange];
                CGSize wrapSize = [wrapString sizeWithFont:theFont constrainedToSize:drawRect.size lineBreakMode:UILineBreakModeCharacterWrap];
                stringHeight = wrapSize.height;
            }
            
            NSRange lastLineRange = NSMakeRange(wrapRange.length, [self length] - wrapRange.length);
            NSString* lastLineString = [self substringWithRange:lastLineRange];
            CGSize lastLineSize = [lastLineString sizeWithFont:theFont forWidth:CGFLOAT_MAX lineBreakMode:UILineBreakModeCharacterWrap];
            
            NSString* lastLineWithCharacterString = [lastLineString stringByAppendingString:theFollowup];
            CGSize lastLineWithCharacterSize = [lastLineWithCharacterString sizeWithFont:theFont forWidth:CGFLOAT_MAX lineBreakMode:UILineBreakModeCharacterWrap];
            //NSLog(@"%f %f %@", lastLineWithCharacterSize.width, drawRect.size.width, lastLineWithCharacterString);
            if (lastLineWithCharacterSize.width <= drawRect.size.width){
                return CGPointMake(lastLineSize.width, wrapHeight + thePoint.y);
            }else{
                return CGPointMake(0.0f, stringSize.height + thePoint.y);
            }
            return CGPointMake(lastLineSize.width, wrapHeight + thePoint.y);
        }else{
            return CGPointMake(stringSize.width, thePoint.y);
        }
    }else{
        CGRect drawRect = theRect;
        drawRect.origin.y += thePoint.y;
        drawRect.size.height -= thePoint.y;
        
        CGPoint firstLinePoint = theRect.origin;
        firstLinePoint.x += thePoint.x;
        firstLinePoint.y += thePoint.y;
        
        CGPoint nextLinePoint = CGPointMake(0.0f, 0.0f);
        nextLinePoint.y += thePoint.y;
        
        CGSize lineSize = [@"C" sizeWithFont:theFont forWidth:CGFLOAT_MAX lineBreakMode:UILineBreakModeCharacterWrap];
        CGFloat lineHeight = lineSize.height;
        
        NSRange firstLineRange = NSMakeRange(0, 1);
        NSString* firstLineString = [self substringWithRange:firstLineRange];
        while (firstLineRange.length <= [self length]){
            CGSize firstLineSize = [firstLineString sizeWithFont:theFont forWidth:CGFLOAT_MAX lineBreakMode:UILineBreakModeCharacterWrap];
            if (firstLineSize.width >= drawRect.size.width - thePoint.x){
                if (firstLineSize.width > drawRect.size.width - thePoint.x){
                    firstLineRange.length -= 1;
                    firstLineString = [self substringWithRange:firstLineRange];
                }
                nextLinePoint.y += lineHeight;
                break;
            }else{
                if (firstLineRange.length == [self length]){
                    nextLinePoint.x += thePoint.x + firstLineSize.width;
                    break;
                }else{
                    firstLineRange.length += 1;
                    firstLineString = [self substringWithRange:firstLineRange];
                }
            }
        }
        [firstLineString drawAtPoint:firstLinePoint forWidth:CGFLOAT_MAX withFont:theFont lineBreakMode:UILineBreakModeCharacterWrap];
        
        if (firstLineRange.length < [self length]){
            NSRange otherLinesRange = NSMakeRange(firstLineRange.length, [self length] - firstLineRange.length);
            NSString* otherLinesString = [self substringWithRange:otherLinesRange];
            return [otherLinesString drawInRect:nextLinePoint followup:theFollowup rect:theRect font:theFont color:theColor];
        }else{
            return nextLinePoint; 
        }
    }
}

-(NSString*)stringByStrippingHTML {
	MarkupStripper *stripper = [MarkupStripper new];
	NSString *result = [stripper parse:self];
	[stripper release];
	return result;
}

- (NSString *) stringFromMD5{
    if(self == nil || [self length] == 0){
        return nil;
    }
    const char *value = [self UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [outputString autorelease];
}

- (NSString *)stringByURLEncodingAsStringParameter {
	// NSURL's stringByAddingPercentEscapesUsingEncoding: does not escape
	// some characters that should be escaped in URL parameters, like / and ?; 
	// we'll use CFURL to force the encoding of those
	//
	// We'll explicitly leave spaces unescaped now, and replace them with +'s
	//
	// Reference: http://www.ietf.org/rfc/rfc3986.txt
	
	NSString *resultStr = self;
	
	CFStringRef originalString = (CFStringRef)self;
	CFStringRef leaveUnescaped = CFSTR(" ");
	CFStringRef forceEscaped = CFSTR("!*'();:@&=+$,/?%#[]");
	
	CFStringRef escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                     originalString,
                                                                     leaveUnescaped, 
                                                                     forceEscaped,
                                                                     kCFStringEncodingUTF8);
	
	if (escapedStr) {
		NSMutableString *mutableStr = [NSMutableString stringWithString:(NSString *)escapedStr];
		CFRelease(escapedStr);
		
		// replace spaces with plusses
		[mutableStr replaceOccurrencesOfString:@" "
									withString:@"+"
									   options:0
										 range:NSMakeRange(0, [mutableStr length])];
		resultStr = mutableStr;
	}
    
	return resultStr;
}

- (NSString*)
stringByDecodingHTMLEntities
{
	NSString* s = [self stringByReplacingOccurrencesOfString: @"&quot;" withString: @"\""];
	s = [s stringByReplacingOccurrencesOfString: @"&squot;" withString: @"'"];
	s = [s stringByReplacingOccurrencesOfString: @"&lt;" withString: @"<"];
	s = [s stringByReplacingOccurrencesOfString: @"&gt;" withString: @"?"];
	s = [s stringByReplacingOccurrencesOfString: @"&#39;" withString: @"’"];
	s = [s stringByReplacingOccurrencesOfString: @"&amp;" withString: @"&"];
	return s;
}


+ (NSString *)generateGuid {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
	//get the string representation of the UUID
	NSString	*uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [uuidString autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isWhitespaceAndNewlines {
	NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	for (NSInteger i = 0; i < self.length; ++i) {
		unichar c = [self characterAtIndex:i];
		if (![whitespace characterIsMember:c]) {
			return NO;
		}
	}
	return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isEmptyOrWhitespace {
	return !self.length ||
	![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Copied and pasted from http://www.mail-archive.com/cocoa-dev@lists.apple.com/msg28175.html
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding {
	NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
	NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
	NSScanner* scanner = [[[NSScanner alloc] initWithString:self] autorelease];
	while (![scanner isAtEnd]) {
		NSString* pairString = nil;
		[scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
		[scanner scanCharactersFromSet:delimiterSet intoString:NULL];
		NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
		if (kvPair.count == 2) {
			NSString* key = [[kvPair objectAtIndex:0]
							 stringByReplacingPercentEscapesUsingEncoding:encoding];
			NSString* value = [[kvPair objectAtIndex:1]
							   stringByReplacingPercentEscapesUsingEncoding:encoding];
			[pairs setObject:value forKey:key];
		}
	}
	
	return [NSDictionary dictionaryWithDictionary:pairs];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query {
	NSMutableArray* pairs = [NSMutableArray array];
	for (NSString* key in [query keyEnumerator]) {
		NSString* value = [query objectForKey:key];
		value = [value stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
		value = [value stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
		NSString* pair = [NSString stringWithFormat:@"%@=%@", key, value];
		[pairs addObject:pair];
	}
	
	NSString* params = [pairs componentsJoinedByString:@"&"];
	if ([self rangeOfString:@"?"].location == NSNotFound) {
		return [self stringByAppendingFormat:@"?%@", params];
	} else {
		return [self stringByAppendingFormat:@"&%@", params];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSComparisonResult)versionStringCompare:(NSString *)other {
	NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
	NSArray *twoComponents = [other componentsSeparatedByString:@"a"];
	
	// The parts before the "a"
	NSString *oneMain = [oneComponents objectAtIndex:0];
	NSString *twoMain = [twoComponents objectAtIndex:0];
	
	// If main parts are different, return that result, regardless of alpha part
	NSComparisonResult mainDiff;
	if ((mainDiff = [oneMain compare:twoMain]) != NSOrderedSame) {
		return mainDiff;
	}
	
	// At this point the main parts are the same; just deal with alpha stuff
	// If one has an alpha part and the other doesn't, the one without is newer
	if ([oneComponents count] < [twoComponents count]) {
		return NSOrderedDescending;
	} else if ([oneComponents count] > [twoComponents count]) {
		return NSOrderedAscending;
	} else if ([oneComponents count] == 1) {
		// Neither has an alpha part, and we know the main parts are the same
		return NSOrderedSame;
	}
	
	// At this point the main parts are the same and both have alpha parts. Compare the alpha parts
	// numerically. If it's not a valid number (including empty string) it's treated as zero.
	NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
	NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
	return [oneAlpha compare:twoAlpha];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)md5Hash {
	return [[self dataUsingEncoding:NSUTF8StringEncoding] md5Hash];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
static const short _base64DecodingTable[256] = {
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

+ (NSData *)decodeBase64WithString:(NSString *)strBase64 {
    const char * objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
    int intLength = strlen(objPointer);
    int intCurrent;
    int i = 0, j = 0, k;
    
    unsigned char * objResult;
    objResult = calloc(intLength, sizeof(char));
    
    // Run through the whole string, converting as we go
    while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
        if (intCurrent == '=') {
            if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
                // the padding character is invalid at this point -- so this entire string is invalid
                free(objResult);
                return nil;
            }
            continue;
        }
        
        intCurrent = _base64DecodingTable[intCurrent];
        if (intCurrent == -1) {
            // we're at a whitespace -- simply skip over
            continue;
        } else if (intCurrent == -2) {
            // we're at an invalid character
            free(objResult);
            return nil;
        }
        
        switch (i % 4) {
            case 0:
                objResult[j] = intCurrent << 2;
                break;
                
            case 1:
                objResult[j++] |= intCurrent >> 4;
                objResult[j] = (intCurrent & 0x0f) << 4;
                break;
                
            case 2:
                objResult[j++] |= intCurrent >>2;
                objResult[j] = (intCurrent & 0x03) << 6;
                break;
                
            case 3:
                objResult[j++] |= intCurrent;
                break;
        }
        i++;
    }
    
    // mop things up if we ended on a boundary
    k = j;
    if (intCurrent == '=') {
        switch (i % 4) {
            case 1:
                // Invalid state
                free(objResult);
                return nil;
                
            case 2:
                k++;
                // flow through
            case 3:
                objResult[k] = 0;
        }
    }
    
    // Cleanup and setup the return NSData
    NSData * objData = [[[NSData alloc] initWithBytes:objResult length:j] autorelease];
    free(objResult);
    return objData;
}

+(NSString*) NSNullToNil:(NSString*)text {
    return ((id)text == [NSNull null]) ? nil : text;
}

@end
