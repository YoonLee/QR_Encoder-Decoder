//
//  ScanTestAppDelegate.h
//  ScanTest
//
//  Created by Yoon Lee on 9/5/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface ScanTestAppDelegate : NSObject <UIApplicationDelegate> 
{
    RootViewController *rootViewController;
	UINavigationController *naviController;
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

@end

