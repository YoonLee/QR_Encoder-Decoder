//
//  RootViewController.h
//  ScanTest
//
//  Created by Yoon Lee on 9/5/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "RGBColorPaletteViewController.h"
#import "SoundEffect.h"

@interface RootViewController : UIViewController <ZBarReaderDelegate, ZBarReaderViewControllerDelegate, 
												  UITextViewDelegate, RGBColorPaletteDelegate,
												  UIGestureRecognizerDelegate, UIActionSheetDelegate,
												  MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate,
												  DetectorDelegate> 
{
	NSString *message;
	UIActivityIndicatorView *encodeIndicator;
	UIActivityIndicatorView *decodeIndicator;
	UIActionSheet *actionSheet;
	
	SoundEffect *snapSound;
	UIImage *tmpImage;
	
	Color4f white;
	Detector *detector;
}

@property(nonatomic, retain) NSString *message;

@end
