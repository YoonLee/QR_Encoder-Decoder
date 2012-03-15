//
//  WebViewController.h
//  QR
//
//  Created by Yoon Lee on 9/13/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//



@interface WebViewController : UIViewController <UIWebViewDelegate, UISearchBarDelegate> 
{
	NSString *urlName;
	UIWebView *_webview;
	UISearchBar *searchBar;
}

@property(nonatomic, retain) NSString *urlName;

- (id) initWithURLName:(NSString *)_URLName;

@end
