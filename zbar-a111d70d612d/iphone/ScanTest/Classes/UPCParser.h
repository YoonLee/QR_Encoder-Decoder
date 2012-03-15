//
//  UPCParser.h
//  QR
//
//  Created by Yoon Lee on 9/13/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//



@interface UPCParser : NSObject <NSXMLParserDelegate>
{
	NSMutableDictionary *contents;
	NSXMLParser *parser;
	
	int mode;
	BOOL hasXMLDone;
}

@property(nonatomic, retain) NSMutableDictionary *contents;
@property(nonatomic, assign) BOOL hasXMLDone;

- (void) searchUPC:(NSString *)_upcCode;

@end
