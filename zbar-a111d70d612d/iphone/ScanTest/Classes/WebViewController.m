//
//  WebViewController.m
//  QR
//
//  Created by Yoon Lee on 9/13/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//

#import "WebViewController.h"


// Apple UIWebView's wrapper class that eligible to search inside contents in UIWebView
@interface UIWebView(PRIVATE_RESOURCE)

- (int) highlightAllOccurencesOfString:(NSString*)str;
- (void) removeAllHighlights;

@end

@implementation UIWebView(PRIVATE_RESOURCE)


- (int) highlightAllOccurencesOfString:(NSString*)str
{
	if (str.length < 4) 
		return 0;
	// get the preloaded 'js' script
	NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
	NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	// passes the script to current loaded html
	[self stringByEvaluatingJavaScriptFromString:jsCode];
	
	// access through 'js' script method then do start search through
	NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfString('%@')", str];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
	
	// get the result of evaluavtion
	NSString *result = [self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount"];
	
	return [result intValue];
}

- (void) removeAllHighlights
{
	[self stringByEvaluatingJavaScriptFromString:@"MyApp_RemoveAllHighlights()"];
}

@end

// this is webview controller that represents the webview displays
@implementation WebViewController
@synthesize urlName;

- (id) initWithURLName:(NSString *)_URLName
{
	if (self == [super init])
		[self setUrlName:_URLName];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	return self;
}

- (void) loadView
{
	CGRect screen = [[UIScreen mainScreen] bounds];
	_webview = [[UIWebView alloc] initWithFrame:screen];
	
	NSURL *url = [NSURL URLWithString:urlName];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	self.view = _webview;
	[_webview setDelegate:self];
	[_webview setScalesPageToFit:YES];
	[_webview loadRequest:request];
}

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// when it fully loaded then stop spins
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// if any error cause we need to retry it
	urlName = [NSString stringWithFormat:@"https://%@", urlName];
	NSURL *url = [NSURL URLWithString:urlName];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	[webView loadRequest:request];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

/////////////////////////////////////// END DELEGATES ///////////////////////////////////////

/////////////////////////////////////// MEMORY COLLECT ///////////////////////////////////////

- (void)dealloc 
{
	// just in case if user goes back to the step before even webview finishes its load we need to kill at the end of use this class
	[_webview release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [super dealloc];
}


@end
