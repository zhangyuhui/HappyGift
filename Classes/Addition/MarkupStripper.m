//
//  MarkupStripper.m
//  HappyGift
//
//  Created by Li Shuai on 5/5/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "MarkupStripper.h"


@implementation MarkupStripper

- (void)dealloc {
	[_strings release];
	[super dealloc];
}


- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
	[_strings addObject:string];
}

static NSDictionary *entityTable = nil;

- (NSData*)             parser: (NSXMLParser*)parser
     resolveExternalEntityName: (NSString*)entityName
                      systemID: (NSString*)systemID {
	if (!entityTable) {
		entityTable = [[NSDictionary alloc] initWithObjectsAndKeys:
					   [NSData dataWithBytes:"\"" length:1], @"quot",
					   [NSData dataWithBytes:"'" length:1], @"apos",
					   [NSData dataWithBytes:"&" length:1], @"amp",
					   [NSData dataWithBytes:"<" length:1], @"lt",
					   [NSData dataWithBytes:">" length:1], @"gt",
					   [NSData dataWithBytes:" " length:1], @"nbsp",
					   
					   [@" " dataUsingEncoding:NSUTF8StringEncoding], @"nbsp",
					   [@"¡" dataUsingEncoding:NSUTF8StringEncoding], @"iexcl",
					   [@"¢" dataUsingEncoding:NSUTF8StringEncoding], @"cent",
					   [@"£" dataUsingEncoding:NSUTF8StringEncoding], @"pound",
					   [@"¤" dataUsingEncoding:NSUTF8StringEncoding], @"curren",
					   [@"¥" dataUsingEncoding:NSUTF8StringEncoding], @"yen",
					   [@"¦" dataUsingEncoding:NSUTF8StringEncoding], @"brvbar",
					   [@"§" dataUsingEncoding:NSUTF8StringEncoding], @"sect",
					   [@"¨" dataUsingEncoding:NSUTF8StringEncoding], @"uml",
					   [@"©" dataUsingEncoding:NSUTF8StringEncoding], @"copy",
					   [@"ª" dataUsingEncoding:NSUTF8StringEncoding], @"ordf",
					   [@"«" dataUsingEncoding:NSUTF8StringEncoding], @"laquo",
					   [@"¬" dataUsingEncoding:NSUTF8StringEncoding], @"not",
					   [@"®" dataUsingEncoding:NSUTF8StringEncoding], @"reg",
					   [@"¯" dataUsingEncoding:NSUTF8StringEncoding], @"macr",
					   [@"°" dataUsingEncoding:NSUTF8StringEncoding], @"deg",
					   [@"±" dataUsingEncoding:NSUTF8StringEncoding], @"plusmn",
					   [@"²" dataUsingEncoding:NSUTF8StringEncoding], @"sup2",
					   [@"³" dataUsingEncoding:NSUTF8StringEncoding], @"sup3",
					   [@"´" dataUsingEncoding:NSUTF8StringEncoding], @"acute",
					   [@"µ" dataUsingEncoding:NSUTF8StringEncoding], @"micro",
					   [@"¶" dataUsingEncoding:NSUTF8StringEncoding], @"para",
					   [@"·" dataUsingEncoding:NSUTF8StringEncoding], @"middot",
					   [@"¸" dataUsingEncoding:NSUTF8StringEncoding], @"cedil",
					   [@"¹" dataUsingEncoding:NSUTF8StringEncoding], @"sup1",
					   [@"º" dataUsingEncoding:NSUTF8StringEncoding], @"ordm",
					   [@"»" dataUsingEncoding:NSUTF8StringEncoding], @"raquo",
					   [@"¼" dataUsingEncoding:NSUTF8StringEncoding], @"frac14",
					   [@"½" dataUsingEncoding:NSUTF8StringEncoding], @"frac12",
					   [@"¾" dataUsingEncoding:NSUTF8StringEncoding], @"frac34",
					   [@"¿" dataUsingEncoding:NSUTF8StringEncoding], @"iquest",
					   [@"×" dataUsingEncoding:NSUTF8StringEncoding], @"times",
					   [@"÷" dataUsingEncoding:NSUTF8StringEncoding], @"divide",
					   
					   [@"À" dataUsingEncoding:NSUTF8StringEncoding], @"Agrave",
					   [@"Á" dataUsingEncoding:NSUTF8StringEncoding], @"Aacute",
					   [@"Â" dataUsingEncoding:NSUTF8StringEncoding], @"Acirc",
					   [@"Ã" dataUsingEncoding:NSUTF8StringEncoding], @"Atilde",
					   [@"Ä" dataUsingEncoding:NSUTF8StringEncoding], @"Auml",
					   [@"Å" dataUsingEncoding:NSUTF8StringEncoding], @"Aring",
					   [@"Æ" dataUsingEncoding:NSUTF8StringEncoding], @"AElig",
					   [@"Ç" dataUsingEncoding:NSUTF8StringEncoding], @"Ccedil",
					   [@"È" dataUsingEncoding:NSUTF8StringEncoding], @"Egrave",
					   [@"É" dataUsingEncoding:NSUTF8StringEncoding], @"Eacute",
					   [@"Ê" dataUsingEncoding:NSUTF8StringEncoding], @"Ecirc",
					   [@"Ë" dataUsingEncoding:NSUTF8StringEncoding], @"Euml",
					   [@"Ì" dataUsingEncoding:NSUTF8StringEncoding], @"Igrave",
					   [@"Í" dataUsingEncoding:NSUTF8StringEncoding], @"Iacute",
					   [@"Î" dataUsingEncoding:NSUTF8StringEncoding], @"Icirc",
					   [@"Ï" dataUsingEncoding:NSUTF8StringEncoding], @"Iuml",
					   [@"Ð" dataUsingEncoding:NSUTF8StringEncoding], @"ETH",
					   [@"Ñ" dataUsingEncoding:NSUTF8StringEncoding], @"Ntilde",
					   [@"Ò" dataUsingEncoding:NSUTF8StringEncoding], @"Ograve",
					   [@"Ó" dataUsingEncoding:NSUTF8StringEncoding], @"Oacute",
					   [@"Ô" dataUsingEncoding:NSUTF8StringEncoding], @"Ocirc",
					   [@"Õ" dataUsingEncoding:NSUTF8StringEncoding], @"Otilde",
					   [@"Ö" dataUsingEncoding:NSUTF8StringEncoding], @"Ouml",
					   [@"Ø" dataUsingEncoding:NSUTF8StringEncoding], @"Oslash",
					   [@"Ù" dataUsingEncoding:NSUTF8StringEncoding], @"Ugrave",
					   [@"Ú" dataUsingEncoding:NSUTF8StringEncoding], @"Uacute",
					   [@"Û" dataUsingEncoding:NSUTF8StringEncoding], @"Ucirc",
					   [@"Ü" dataUsingEncoding:NSUTF8StringEncoding], @"Uuml",
					   [@"Ý" dataUsingEncoding:NSUTF8StringEncoding], @"Yacute",
					   [@"Þ" dataUsingEncoding:NSUTF8StringEncoding], @"THORN",
					   [@"ß" dataUsingEncoding:NSUTF8StringEncoding], @"szlig",
					   [@"à" dataUsingEncoding:NSUTF8StringEncoding], @"agrave",
					   [@"á" dataUsingEncoding:NSUTF8StringEncoding], @"aacute",
					   [@"â" dataUsingEncoding:NSUTF8StringEncoding], @"acirc",
					   [@"ã" dataUsingEncoding:NSUTF8StringEncoding], @"atilde",
					   [@"ä" dataUsingEncoding:NSUTF8StringEncoding], @"auml",
					   [@"å" dataUsingEncoding:NSUTF8StringEncoding], @"aring",
					   [@"æ" dataUsingEncoding:NSUTF8StringEncoding], @"aelig",
					   [@"ç" dataUsingEncoding:NSUTF8StringEncoding], @"ccedil",
					   [@"è" dataUsingEncoding:NSUTF8StringEncoding], @"egrave",
					   [@"é" dataUsingEncoding:NSUTF8StringEncoding], @"eacute",
					   [@"ê" dataUsingEncoding:NSUTF8StringEncoding], @"ecirc",
					   [@"ë" dataUsingEncoding:NSUTF8StringEncoding], @"euml",
					   [@"ì" dataUsingEncoding:NSUTF8StringEncoding], @"igrave",
					   [@"í" dataUsingEncoding:NSUTF8StringEncoding], @"iacute",
					   [@"î" dataUsingEncoding:NSUTF8StringEncoding], @"icirc",
					   [@"ï" dataUsingEncoding:NSUTF8StringEncoding], @"iuml",
					   [@"ð" dataUsingEncoding:NSUTF8StringEncoding], @"eth",
					   [@"ñ" dataUsingEncoding:NSUTF8StringEncoding], @"ntilde",
					   [@"ò" dataUsingEncoding:NSUTF8StringEncoding], @"ograve",
					   [@"ó" dataUsingEncoding:NSUTF8StringEncoding], @"oacute",
					   [@"ô" dataUsingEncoding:NSUTF8StringEncoding], @"ocirc",
					   [@"õ" dataUsingEncoding:NSUTF8StringEncoding], @"otilde",
					   [@"ö" dataUsingEncoding:NSUTF8StringEncoding], @"ouml",
					   [@"ø" dataUsingEncoding:NSUTF8StringEncoding], @"oslash",
					   [@"ù" dataUsingEncoding:NSUTF8StringEncoding], @"ugrave",
					   [@"ú" dataUsingEncoding:NSUTF8StringEncoding], @"uacute",
					   [@"û" dataUsingEncoding:NSUTF8StringEncoding], @"ucirc",
					   [@"ü" dataUsingEncoding:NSUTF8StringEncoding], @"uuml",
					   [@"ý" dataUsingEncoding:NSUTF8StringEncoding], @"yacute",
					   [@"þ" dataUsingEncoding:NSUTF8StringEncoding], @"thorn",
					   [@"ÿ" dataUsingEncoding:NSUTF8StringEncoding], @"yuml",
					   
					   nil];

	}
	return [entityTable objectForKey:entityName];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	hasError = YES;
}

- (NSString*)parse:(NSString*)text {
	_strings = [[NSMutableArray alloc] init];
	
	NSString*     document  = [NSString stringWithFormat:@"<y>%@</y>", text];
	NSData*       data      = [document dataUsingEncoding:text.fastestEncoding];
	NSXMLParser*  parser    = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
	hasError = NO;
	[parser parse];
	[parser release];
	
	if (!hasError) {
		NSString* result = [_strings componentsJoinedByString:@""];
		[_strings release];
		_strings = nil;
		return result;
	} else {
		[_strings release];
		_strings = nil;
		return text;
	}
}



@end
