//
//  UPCParser.h
//  QR
//
//  Created by Yoon Lee on 9/13/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//

#import "UPCParser.h"
@interface UPCParser(PrivateMethods)

@end


@implementation UPCParser
@synthesize contents;
@synthesize hasXMLDone;


enum XML_CATEGORIES 
{
	ITEMNAME = 0,
	DESCRIPTION,
	PRICE,
	RATING,
	MODE_NULL,
};

// api key provides by http://www.upcdatabase.org/api.php
static NSString *_key = @"6869aa78716439fe8ff025ceeac988b0";


- (id) init
{
	if (self == [super init])
	{	
		parser = nil;
		mode = MODE_NULL;
		[self setHasXMLDone:YES];
	}
	
	return self;
}

- (void) searchUPC:(NSString *)_upcCode
{
	if (!hasXMLDone)
	{
		return;
	}
	
	// preparation for the URL address and hand over to the NSXMLParser class 
	NSString *archiveURLAddress = [NSString stringWithFormat:@"http://www.upcdatabase.org/api/xml/%@/%@", _key, _upcCode];
	NSURL *url = [NSURL URLWithString:archiveURLAddress];
	
	if (!parser) 
	{
		parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
		contents = [[NSMutableDictionary alloc] init];
		[parser setDelegate:self];
	}
	else
	{
		[parser initWithContentsOfURL:url];
		[contents removeAllObjects];
	}
	
	// contents architecture
	// value				key
	// 'upc numbers'	   'upc'
	// 'product names'	   'itemname'
	
	// we simply add upc number
	[contents setValue:_upcCode	forKey:@"upc"];
	[self setHasXMLDone:NO];
	
	[parser parse];
}

#pragma mark -
#pragma mark - NSXMLParserDelegate
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	// we already know xml-database feeds the element name as itemname so we are good to go
	if ([elementName isEqualToString:@"itemname"]) 
		mode = ITEMNAME;
	else if ([elementName isEqualToString:@"description"])
		mode = DESCRIPTION;
	else if ([elementName isEqualToString:@"price"])
		mode = PRICE;
	else if ([elementName isEqualToString:@"ratingsup"])
		mode = RATING;
}

// sent when the parser has completed parsing. If this is encountered, the parse was successful.
- (void) parserDidEndDocument:(NSXMLParser *)parser
{
	hasXMLDone = YES;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	NSString *aKey = nil;
	
	switch (mode)
	{
		case ITEMNAME:
			aKey = @"itemname";
			break;
		case DESCRIPTION:
			aKey = @"description";
			break;
		case PRICE:
			aKey = @"price";
			break;
		case RATING:
			aKey = @"rating";
			break;
	}
	
	if (aKey)
		[contents setValue:string forKey:aKey];
	
	// we reset the mode
	mode = MODE_NULL;
}

- (void) dealloc
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[parser release];
	[contents release];
	[super dealloc];
}

@end
