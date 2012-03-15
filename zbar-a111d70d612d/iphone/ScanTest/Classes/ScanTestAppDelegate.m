//
//  ScanTestAppDelegate.m
//  ScanTest
//
//  Created by Yoon Lee on 9/5/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//

#import "ScanTestAppDelegate.h"


@implementation ScanTestAppDelegate

@synthesize window;
@synthesize rootViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
    // Override point for customization after app launch    
	CGRect screen = [[UIScreen mainScreen] bounds];
    window = [[UIWindow alloc] initWithFrame:screen];
	rootViewController = [[RootViewController alloc] init];
	naviController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	
	[window addSubview:naviController.view];
    [window makeKeyAndVisible];
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Save data if appropriate
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	[naviController release];
	[rootViewController release];
	[window release];
	[super dealloc];
}


@end

