//
//  Detector.m
//  QR
//
//  Created by Yoon Lee on 9/13/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//
#import "Detector.h"


@interface Detector(PrivateMethod)

static NSString *httpID = @"htt";
static NSString *WorldWideWeb   = @"www";

- (void) scanIdentity;

@end


@implementation Detector
@synthesize sentence;
@synthesize delegate;

- (id) initWithEncryption:(NSString *)input
{
	if (self == [super init]) 
	{
		if (!(input == nil || [input isEqualToString:@""]))
		{
			input = [input lowercaseString];
			[self setSentence:input];
		}
	}
	
	return self;
}

- (void) setSentenceForDearchive:(NSString *)_sentence
{
	_sentence = [_sentence lowercaseString];
	[self setSentence:_sentence];
	[self scanIdentity];
}

- (void) scanIdentity
{
	// hyper thread link detection
	// #1 : starts with http
	// #2 : has www
	NSString *httpParse = self.sentence;
	NSMutableString *stringBuffer = [[NSMutableString alloc] init];
	
	for (int i = 0; i < 3; i++) 
		[stringBuffer appendFormat:@"%c", [httpParse characterAtIndex:i]];
	
	if ([stringBuffer isEqualToString:httpID]) 
	{
		[[self delegate] didParseComple:self isMessageHTML:YES];
		
		[stringBuffer release];
		
		return;
	}
	// usually starts with or contains the 'www' is incomplete
	// we load up the default http protocal in this case
	else if ([stringBuffer rangeOfString:WorldWideWeb].location != NSNotFound)
	{
		[self setSentence:[NSString stringWithFormat:@"http://%@", self.sentence]];
		[[self delegate] didParseComple:self isMessageHTML:YES];
		
		[stringBuffer release];
		
		return;
	}
	
	[[self delegate] didParseComple:self isMessageHTML:NO];
	[stringBuffer release];
	
	//NSScanner *scan = [[NSScanner alloc] initWithString:httpParse];
}

- (void) dealloc
{
	[super dealloc];
}

@end
