//
//  RootViewController.m
//  ScanTest
//
//  Created by Yoon Lee on 9/5/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//

#import "RootViewController.h"
#import "WebViewController.h"
#import "GradientButton.h"
#import "QREncoder.h"
#import "DataMatrix.h"
#import "UPCParser.h"

#pragma mark PRIVATEMETHODS
@interface RootViewController(PrivateMethods)
UPCParser *parser;

- (void) mashupQRImage:(UIImage *)image;

- (UIImage *) encodeQRCode:(NSString *)_string withRGBAColor:(Color4f)aColor withBackgroundColor:(Color4f)bColor;

@end


@implementation RootViewController
@synthesize message;
#define IMAGE_DIMENSION_SIZE 150

enum VIEW_TAGS
{
	ENCODE_BUTTON = 1,
	DECODE_BUTTON,
	WRITER_BUTTON,
	DECODE_IMAGE_VIEW,
	DECODE_IMAGE_VIEW_ACTIONSHEET,
	TEXTFIELD,
};



- (void) loadView
{
	// get the directory of where sound locates
	NSString *path = [[NSBundle mainBundle] pathForResource:@"noise" ofType:@"caf"];
	// send over to the soundeffect class
	snapSound = [[SoundEffect alloc] initWithContentsOfFile:path];
	parser = [[UPCParser alloc] init];
	
	self.view = [[UIView alloc] init];	
	actionSheet = [[UIActionSheet alloc] initWithTitle:@"Use this QR as:"
											  delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"MMS", @"Save", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	
	white = Color4fWhite;
}

- (void)viewDidLoad 
{	
	detector = [[Detector alloc] initWithEncryption:nil];
	[detector setDelegate:self];
	
	message = [[NSString alloc] init];
	[self setMessage:@""];
	[super viewDidLoad];
	CGRect screen = [[UIScreen mainScreen] bounds];
	CGFloat x = screen.size.width / 2;
	CGFloat y = screen.size.height / 2;
	
	[self.view setBackgroundColor:[UIColor whiteColor]];
	
	encodeIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	decodeIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	
	GradientButton *encodeButton = [[GradientButton alloc] initWithFrame:CGRectMake(0, 0, 280.0f, 37.0f)];
	[encodeButton setHighlighted:YES];
	[encodeButton setCenter:CGPointMake(x, y - 5.0f)];
	[encodeButton useGreenConfirmStyle];
	[encodeButton.titleLabel setTextAlignment:UITextAlignmentCenter];
	[encodeButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
	[encodeButton setTitle:@"QR Capture" forState:UIControlStateNormal];
	[encodeIndicator setCenter:CGPointMake(encodeButton.frame.size.width/2, encodeButton.frame.size.height/2)];
	[encodeButton addSubview:encodeIndicator];
	[encodeButton addTarget:self action:@selector(scanPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:encodeButton];
	[encodeButton setTag:ENCODE_BUTTON];
	[encodeButton release];
	
	GradientButton *decodeButton = [[GradientButton alloc] initWithFrame:CGRectMake(0, 0, 280.0f, 37.0f)];
	[decodeButton setCenter:CGPointMake(x, 40.0f + y)];
	[decodeButton useBlackActionSheetStyle];
	[decodeButton addSubview:decodeIndicator];
	[decodeButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
	[decodeButton setTitle:@"Look Up" forState:UIControlStateNormal];
	[decodeButton addTarget:self action:@selector(scanPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:decodeButton];
	[decodeButton setTag:DECODE_BUTTON];
	[decodeButton release];
	
	GradientButton *writerButton = [[GradientButton alloc] initWithFrame:CGRectMake(0, 0, 280.0f, 37.0f)];
	[writerButton setCenter:CGPointMake(x, 85.0f + y)];
	[writerButton useSimpleOrangeStyle];
	[writerButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
	[writerButton setTitle:@"QR Color" forState:UIControlStateNormal];
	[writerButton addTarget:self action:@selector(scanPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:writerButton];
	[writerButton setTag:WRITER_BUTTON];
	[writerButton release];
	
	NSString *str = @"mother fucker";
	UIImage *image = [self encodeQRCode:str withRGBAColor:Color4fMake(0.804f, 0.898, 0.494, 1.0f) withBackgroundColor:white];
	[self mashupQRImage:image];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	[imageView setCenter:CGPointMake(x - 80.0f, y - 160.0f)];
	[imageView setTag:DECODE_IMAGE_VIEW];
	[imageView.layer setBorderColor:[UIColor blackColor].CGColor];
	[imageView.layer setBorderWidth:1.0f];
	[self.view addSubview:imageView];
	
	UIImageView *actionsheetImageView = [[UIImageView alloc] initWithImage:image];
	[actionsheetImageView setFrame:CGRectMake(220.0f, 3.5f, 38.5f, 38.5f)];
	[actionsheetImageView setTag:DECODE_IMAGE_VIEW_ACTIONSHEET];
	[actionsheetImageView.layer setBorderColor:[UIColor blackColor].CGColor];
	[actionsheetImageView.layer setBorderWidth:1.0f];
	[actionSheet addSubview:actionsheetImageView];
	[actionsheetImageView release];
	
	UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHold:)];
	[gesture setDelegate:self];
	[gesture setMinimumPressDuration:0.35f];
	[imageView setUserInteractionEnabled:YES];
	[imageView addGestureRecognizer:gesture];
	[gesture release];
	
	[imageView release];
	
	UITextView *textfield = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150.0f, 170.0f)];
	[textfield setDelegate:self];
	UIFont *font = [UIFont fontWithName:@"Vanilla" size:9.0f];
	[textfield setFont:font];
	[textfield setTextAlignment:UITextAlignmentLeft];
	[textfield.layer setBorderWidth:1.0f];
	[textfield.layer setBorderColor:[UIColor blackColor].CGColor];
	[textfield setCenter:CGPointMake(x + 79.0f, y - 150.0f)];
	[textfield setBackgroundColor:[UIColor lightGrayColor]];
	[textfield setTag:TEXTFIELD];
	[self.view addSubview:textfield];
	[textfield release];
}

- (void) indicatorSpin
{
	[encodeIndicator startAnimating];
}

- (void) barcodePerformSelector:(id)sender
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *str = self.message;
	// look up part
	[parser searchUPC:str];
	NSLog(@"%@", [parser.contents description]);
	
	[pool release];
}

- (void) scanPressed:(id)sender 
{
	UIButton *button = (UIButton*)sender;
	
	// decoding part
	ZBarReaderViewController *decoder = nil;
	ZBarImageScanner *scanImage = nil;
	
	// palette controller
	RGBColorPaletteViewController *colorRGBpicker = nil;
	Color4f color = Color4fMake(0.656f, 0.826f, 0.953f, 1.0f);
	
	switch ([button tag])
	{
		case ENCODE_BUTTON:
			[encodeIndicator startAnimating];
			decoder = [[ZBarReaderViewController alloc] init];
			[decoder setReaderDelegate:self];
			[decoder setCancelDelegate:self];
			[decoder setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
			[decoder setSupportedOrientationsMask:ZBarOrientationMaskAll];
			scanImage = decoder.scanner;
			[scanImage setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
			[self presentModalViewController:decoder animated:YES];
			[decoder release];
			break;
		case DECODE_BUTTON:
			if (self.message != nil || [self.message isEqualToString:@""])
			{
				[NSThread detachNewThreadSelector:@selector(barcodePerformSelector:) toTarget:self withObject:nil];
				[NSThread setThreadPriority:0.4f];
			}
			break;
		case WRITER_BUTTON:
			colorRGBpicker = [[RGBColorPaletteViewController alloc] init];
			[colorRGBpicker setDelegate:self];
			[colorRGBpicker setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
			[self.navigationController pushViewController:colorRGBpicker animated:YES];
			break;
	}
}

- (void) handleHold:(UITapGestureRecognizer *)recognizer
{
	if (!actionSheet.visible) 
	{
		UIImageView *imageView = (UIImageView*)[self.view viewWithTag:DECODE_IMAGE_VIEW];
		
		if (imageView.image) 
		{
			UIImageView *actionsheetImageView = (UIImageView*)[self.view viewWithTag:DECODE_IMAGE_VIEW_ACTIONSHEET];
			[actionsheetImageView setImage:imageView.image];
			
			[actionSheet showInView:self.view];
		}
	}
}

- (UIImage *) encodeQRCode:(NSString *)_string withRGBAColor:(Color4f)aColor withBackgroundColor:(Color4f)bColor
{
	DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_H version:QR_VERSION_AUTO string:_string];
	UIImage *image = [QREncoder renderDataMatrix:qrMatrix imageDimension:IMAGE_DIMENSION_SIZE red:aColor.red green:aColor.green blue:aColor.blue backRed:bColor.red backGreen:bColor.green backBlue:bColor.blue alpha:aColor.alpha backAlpha:bColor.alpha];
	return image;
}

- (void) mashupQRImage:(UIImage *)image
{
	UIImageView *imageView = (UIImageView*)[self.view viewWithTag:DECODE_IMAGE_VIEW];
	[imageView setImage:image];
}

#pragma mark -
#pragma mark - RGBColorPaletteDelegate
/////////////////////////////////////// DELEGATES ///////////////////////////////////////
//  custom delegate pattern method
//  after user choose the color from the palette class, it will send through protocal 
//  with status with choosen color
- (void) didUserCompletedSelectColor:(BOOL)completed withRGBAColor:(Color4f)aColor withBackGroundColor:(Color4f)bColor
{
	if (completed && message != NULL && ![message isEqualToString:@""]) 
	{
		UIImage *image = [self encodeQRCode:self.message withRGBAColor:aColor withBackgroundColor:bColor];
		[self mashupQRImage:image];
	}
}

#pragma mark -
#pragma mark - UIImagePickerControllerDelegate
- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
	[snapSound play];
	UITextView *textField = (UITextView *)[self.view viewWithTag:TEXTFIELD];
	
    // ADD: get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
	Color4f aDefaultColor = Color4fMake(0.0f, 0.0f, 0.0f, 1.0f);
	
    ZBarSymbol *symbol = nil;
    for(symbol in results)
	{
        [textField setText:symbol.data];
		[self setMessage:symbol.data];
		UIImage *image = [self encodeQRCode:self.message withRGBAColor:aDefaultColor withBackgroundColor:white];
		[self mashupQRImage:image];
        break;
	}
	
	// custom set method
	[detector setSentenceForDearchive:self.message];
	
	// stop
	[encodeIndicator stopAnimating];
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
}

#pragma mark -
#pragma mark - ZBarReaderViewControllerDelegate
// invokes from ZBarReaderViewControllerDelegate when user tabs the cancel button
- (void) didUserTabTheCancelButton
{
	[encodeIndicator stopAnimating];
}

#pragma mark -
#pragma mark - UITouchDelegate
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint touch = [[touches anyObject] locationInView:self.view];
	// keyboard portrait mode 320 width and 216 height
	CGRect keyboard = CGRectMake(0.0f, 264.0f, 320.0f, 216.0f);
	
	// if the touch point isn't in that area, then we want to dismiss the keyboard
	if (!CGRectContainsPoint(keyboard, touch)) 
	{
		UITextView *textField = (UITextView *)[self.view viewWithTag:TEXTFIELD];
		[textField resignFirstResponder];
	}
}

#pragma mark -
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	return true;
}

#pragma mark -
#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView
{
	Color4f defaultColor = Color4fMake(0.0f, 0.0f, 0.0f, 1.0f);
	self.message = textView.text;
	UIImage *image = [self encodeQRCode:self.message withRGBAColor:defaultColor withBackgroundColor:white];
	[self mashupQRImage:image];
}

enum ACTIONSHEET_TAGS
{
	EMAIL = 0,
	MMS,
	SAVE,
};

#pragma mark -
#pragma mark - UIActionSheetDelegate
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	MFMailComposeViewController* email = nil;
	MFMessageComposeViewController * mms = nil;
	UIImageView *imageView = (UIImageView*)[self.view viewWithTag:DECODE_IMAGE_VIEW];
	
	NSData *data = nil;
	
	switch (buttonIndex)
	{
		case EMAIL:
			data = UIImagePNGRepresentation(imageView.image);
			email = [[MFMailComposeViewController alloc] init];
			[email setMailComposeDelegate:self];
			[email addAttachmentData:data mimeType:@"image/png" fileName:@"filename"];
			[self presentModalViewController:email animated:YES];
			[email release];
			break;
		case MMS:
			mms = [[MFMessageComposeViewController alloc] init];
			[mms setMessageComposeDelegate:self];
			[mms setBody:@"HELLO WORLD"];
			[self presentModalViewController:mms animated:YES];
			[mms release];
			break;
		case SAVE:
			UIImageWriteToSavedPhotosAlbum(imageView.image, self, nil, nil);
			break;
	}
}

#pragma mark -
#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0)
{
	switch (result) 
	{
		case MFMailComposeResultCancelled:
			[controller dismissModalViewControllerAnimated:YES];
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) 
	{
		case MessageComposeResultCancelled:
			[controller dismissModalViewControllerAnimated:YES];
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark - DetectorDelegate
- (void) didParseComple:(Detector *)_detector isMessageHTML:(BOOL)isHTML
{
	if (isHTML) 
	{
		WebViewController *webViewController = [[WebViewController alloc] initWithURLName:[_detector sentence]];
		[self.navigationController pushViewController:webViewController animated:YES];
		[webViewController release];
	}
}

/////////////////////////////////////// END DELEGATES ///////////////////////////////////////

/////////////////////////////////////// MEMORY COLLECT ///////////////////////////////////////
- (void)dealloc 
{
	[message release];
	[actionSheet release];
	[encodeIndicator release];
	[decodeIndicator release];
	[snapSound release];
	[super dealloc];
}


@end

