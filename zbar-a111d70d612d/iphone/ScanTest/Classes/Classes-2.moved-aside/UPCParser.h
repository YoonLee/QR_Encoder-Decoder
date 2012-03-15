//
//  UPCParser.h
//  QR
//
//  Created by Yoon Lee on 9/13/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//



@interface UPCParser : NSObject <NSXMLParserDelegate>
{
	NSMutableString *xml;
	
	NSXMLParser *parser;
}

- (id) initWithUPCCode:(NSString *)_upcCode;

@end
