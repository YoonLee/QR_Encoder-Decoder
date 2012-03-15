//
//  RGBColorPaletteViewController.m
//  QR
//
//  Created by Yoon Lee on 9/5/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//

#import "RGBColorPaletteViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Yoon.h"

#define QR_DIMENTION_UIBARBUTTON 30.0f

enum RGB_TAGS
{
	RED = 1,
	GREEN,
	BLUE,
	PALETTE,
	RED_LABEL,
	GREEN_LABEL,
	BLUE_LABEL,
	RED_NAME,
	GREEN_NAME,
	BLUE_NAME,
	
	ALPHA,
	ALPHA_LABEL,
	ALPHA_NAME,
};

enum MODE
{
	QR_MODE = 0,
	BACKGROUND_MODE,
};

@interface RGBColorPaletteViewController(PrivateMethod)

- (void) colorControlloer:(id)sender;

- (int) percentTORGBValue:(float)percent;

@end

@implementation RGBColorPaletteViewController
@synthesize delegate;
static CGFloat alphaValue, redValue, greenValue, blueValue = 0.0f;
// represents for qr line color
Color4f aColor;
// represents for qr background color
Color4f bColor;


- (void) loadView
{
	mode = QR_MODE;
	[self.delegate didUserCompletedSelectColor:NO withRGBAColor:Color4fZero withBackGroundColor:Color4fWhite];
	CGRect screen = [[UIScreen mainScreen] bounds];
	CGFloat x = screen.size.width / 2;
	CGFloat y = screen.size.height / 2;
	
	self.view = [[UIView alloc] initWithFrame:screen];
	[self.view setBackgroundColor:[UIColor whiteColor]];
	UIImage *bigImage = [UIImage imageNamed:@"slider.png"];
	[bigImage setSpriteSheetPlist:@"slider"];
	
	UIImage *redImage = [bigImage imageWithSprite:@"red.png"];
	UIImage *greenImage = [bigImage imageWithSprite:@"green.png"];
	UIImage *blueImage = [bigImage imageWithSprite:@"blue.png"];
	
	UISlider *alpha = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 255.0f, 10.0f)];
	UISlider *red = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 255.0f, 10.0f)];
	UISlider *green = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 255.0f, 10.0f)];
	UISlider *blue = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 255.0f, 10.0f)];
	
	[alpha addTarget:self action:@selector(colorControlloer:) forControlEvents:UIControlEventValueChanged];
	[red addTarget:self action:@selector(colorControlloer:) forControlEvents:UIControlEventValueChanged];
	[green addTarget:self action:@selector(colorControlloer:) forControlEvents:UIControlEventValueChanged];
	[blue addTarget:self action:@selector(colorControlloer:) forControlEvents:UIControlEventValueChanged];
	
	[alpha setTag:ALPHA];
	[red setTag:RED];
	[green setTag:GREEN];
	[blue setTag:BLUE];
	
	[red setMinimumTrackImage:[redImage stretchableImageWithLeftCapWidth:10.0f topCapHeight:0.0f] forState:UIControlStateNormal];
	[green setMinimumTrackImage:[greenImage stretchableImageWithLeftCapWidth:10.0f topCapHeight:0.0f] forState:UIControlStateNormal];
	[blue setMinimumTrackImage:[blueImage stretchableImageWithLeftCapWidth:10.0f topCapHeight:0.0f] forState:UIControlStateNormal];
	
	[alpha setCenter:CGPointMake(x, 10.0f + y)];
	[red setCenter:CGPointMake(x, 60.0f + y)];
	[green setCenter:CGPointMake(x, 110.0f + y)];
	[blue setCenter:CGPointMake(x, 160.0f + y)];
	
	[alpha setMaximumValue:1.0f];
	[alpha setMinimumValue:0.0f];
	[alpha setValue:1.0f];
	alphaValue = 1.0f;
	
	[red setMaximumValue:1.0f];
	[red setMinimumValue:0.0f];
	[red setValue:0.5f];
	redValue = 0.5f;
	
	[green setMaximumValue:1.0f];
	[green setMinimumValue:0.0f];
	[green setValue:0.5f];
	greenValue = 0.5f;
	
	[blue setMaximumValue:1.0f];
	[blue setMinimumValue:0.0f];
	[blue setValue:0.5f];
	blueValue = 0.5f;
	
	[self.view addSubview:alpha];
	[self.view addSubview:red];
	[self.view addSubview:green];
	[self.view addSubview:blue];
	
	[alpha release];
	[red release];
	[green release];
	[blue release];
	
	// setting for palette color view
	UIView *colorPalette = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300.0f, 200.0f)];
	[colorPalette.layer setBorderColor:[UIColor blackColor].CGColor];
	[colorPalette.layer setBorderWidth:1.0f];
	[colorPalette setCenter:CGPointMake(x, y - 120.0f)];
	[colorPalette setTag:PALETTE];
	[self.view addSubview:colorPalette];
	[colorPalette release];
	
	UIFont *font = [UIFont fontWithName:@"Vanilla" size:10];
	
	UILabel *alphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 20.0f)];
	[alphaLabel setBackgroundColor:[UIColor clearColor]];
	[alphaLabel setFont:font];
	[alphaLabel setTextColor:[UIColor lightGrayColor]];
	[alphaLabel setCenter:CGPointMake(x - 80.0f, alpha.frame.origin.y - 10.0f)];
	[alphaLabel setTextAlignment:UITextAlignmentLeft];
	[alphaLabel setText:@"ALPHA"];
	[alphaLabel setTag:ALPHA_NAME];
	
	UILabel *redLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 20.0f)];
	[redLabel setBackgroundColor:[UIColor clearColor]];
	[redLabel setFont:font];
	[redLabel setTextColor:[UIColor redColor]];
	[redLabel setCenter:CGPointMake(x - 80.0f, red.frame.origin.y - 10.0f)];
	[redLabel setTextAlignment:UITextAlignmentLeft];
	[redLabel setText:@"RED"];
	[redLabel setTag:RED_NAME];
	
	UILabel *greenLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 20.0f)];
	[greenLabel setBackgroundColor:[UIColor clearColor]];
	[greenLabel setFont:font];
	[greenLabel setTextColor:[UIColor greenColor]];
	[greenLabel setCenter:CGPointMake(30.0f, 50.0f)];
	[greenLabel setCenter:CGPointMake(x - 80.0f, green.frame.origin.y - 10.0f)];
	[greenLabel setTextAlignment:UITextAlignmentLeft];
	[greenLabel setText:@"GREEN"];
	[greenLabel setTag:GREEN_NAME];
	
	UILabel *blueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 20.0f)];
	[blueLabel setBackgroundColor:[UIColor clearColor]];
	[blueLabel setFont:font];
	[blueLabel setTextColor:[UIColor blueColor]];
	[blueLabel setCenter:CGPointMake(x - 80.0f, blue.frame.origin.y - 10.0f)];
	[blueLabel setTextAlignment:UITextAlignmentLeft];
	[blueLabel setText:@"BLUE"];
	[blueLabel setTag:BLUE_NAME];
	
	[self.view addSubview:alphaLabel];
	[self.view addSubview:redLabel];
	[self.view addSubview:greenLabel];
	[self.view addSubview:blueLabel];
	
	[alphaLabel release];
	[blueLabel release];
	[greenLabel release];
	[redLabel release];
	
	[colorPalette setBackgroundColor:[UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:alphaValue]];
	
	aColor = Color4fMake(redValue, greenValue, blueValue, alphaValue);
	bColor = Color4fWhite;
}

- (void) colorControlloer:(id)sender
{
	UISlider *slider = (UISlider *)sender;
	UIView *colorPalette = [self.view viewWithTag:PALETTE];
	
	UILabel *redLabel = (UILabel *)[self.view viewWithTag:RED_LABEL];
	UILabel *greenLabel = (UILabel *)[self.view viewWithTag:GREEN_LABEL];
	UILabel *blueLabel = (UILabel *)[self.view viewWithTag:BLUE_LABEL];
	UILabel *alphaLabel = (UILabel *)[self.view viewWithTag:ALPHA_LABEL];
	
	switch (slider.tag)
	{
		case RED:
			redValue = [slider value];
			[redLabel setText:[NSString stringWithFormat:@"%d", [self percentTORGBValue:redValue]]];
			break;
		case GREEN:
			greenValue = [slider value];
			[greenLabel setText:[NSString stringWithFormat:@"%d", [self percentTORGBValue:greenValue]]];
			break;
		case BLUE:
			blueValue = [slider value];
			[blueLabel setText:[NSString stringWithFormat:@"%d", [self percentTORGBValue:blueValue]]];
			break;
		case ALPHA:
			alphaValue = [slider value];
			[alphaLabel setText:[NSString stringWithFormat:@"%d", [self percentTORGBValue:alphaValue]]];
			break;

		default:
			redValue = [slider value];
			greenValue = [slider value];
			blueValue = [slider value];
			break;
	}
	
	[colorPalette setBackgroundColor:[UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:alphaValue]];
	
	
	switch (mode) 
	{
		case QR_MODE:
			aColor = Color4fMake(redValue, greenValue, blueValue, alphaValue);
			break;
		case BACKGROUND_MODE:
			bColor = Color4fMake(redValue, greenValue, blueValue, alphaValue);
			break;
	}
}

enum UIBARBUTTON_CONTENTSVIEW_TAGS
{
	FRONT = 0,
	BACK,
};

- (void) modeSelector:(id)sender
{
	UIButton *contentsControl = (UIButton *)sender;
	UIImage *image = nil;
	// UIView animation initialization
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
	
	// exchange mode at this moment
	switch (mode)
	{
		case QR_MODE:
			image = [UIImage imageNamed:@"back.png"];
			mode = BACKGROUND_MODE;
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:contentsControl cache:YES];
			break;
		case BACKGROUND_MODE:
			image = [UIImage imageNamed:@"front.png"];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:contentsControl cache:YES];
			mode = QR_MODE;
			break;
	}
	
	[contentsControl setImage:image forState:UIControlStateNormal];
	[UIView commitAnimations];
}

- (void) viewDidLoad 
{
	// load viewDidLoad method in default super UIViewController configuration
    [super viewDidLoad];
	
	// 
	// colorSelector->  +++++++++++UIButton++++++++++
	//					+							+
	//					+   Subview #1 : image		+
	//					+   Subview #2 : image		+
	//					+							+
	//					+++++++++++++++++++++++++++++
	//
	// navigation right bar contents view configuration
	UIButton *contentsControl = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QR_DIMENTION_UIBARBUTTON, QR_DIMENTION_UIBARBUTTON)];
	[contentsControl.layer setBorderColor:[UIColor blackColor].CGColor];
	[contentsControl.layer setBorderWidth:1.0f];
	[contentsControl setImage:[UIImage imageNamed:@"front.png"] forState:UIControlStateNormal];
	[contentsControl addTarget:self action:@selector(modeSelector:) forControlEvents:UIControlEventTouchUpInside];

	// right barbutton declaration
	UIBarButtonItem *colorSelector = [[UIBarButtonItem alloc] initWithCustomView:contentsControl];
	[contentsControl release];
	
	[colorSelector setStyle:UIBarButtonItemStyleBordered];	
	[self.navigationItem setRightBarButtonItem:colorSelector animated:YES];
	[colorSelector release];
	
	// displays current numbers in RGB
	UILabel *alphaNumberDigit = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 218.5f, 50.0f, 20.0f)];
	UILabel *redNumberDigit = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 268.5f, 50.0f, 20.0f)];
	UILabel *greenNumberDigit = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 318.5, 50.0f, 20.0f)];
	UILabel *blueNumberDigit = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 368.5, 50.0f, 20.0f)];
	
	[alphaNumberDigit setTextAlignment:UITextAlignmentLeft];
	[redNumberDigit setTextAlignment:UITextAlignmentLeft];
	[greenNumberDigit setTextAlignment:UITextAlignmentLeft];
	[blueNumberDigit setTextAlignment:UITextAlignmentLeft];
	
	[self.view addSubview:alphaNumberDigit];
	[self.view addSubview:redNumberDigit];
	[self.view addSubview:greenNumberDigit];
	[self.view addSubview:blueNumberDigit];
	
	UIFont *font = [UIFont fontWithName:@"Vanilla" size:10];
	
	[alphaNumberDigit setTag:ALPHA_LABEL];
	[redNumberDigit setTag:RED_LABEL];
	[greenNumberDigit setTag:GREEN_LABEL];
	[blueNumberDigit setTag:BLUE_LABEL];
	
	[alphaNumberDigit setFont:font];
	[redNumberDigit setFont:font];
	[greenNumberDigit setFont:font];
	[blueNumberDigit setFont:font];
	
	[alphaNumberDigit setText:[NSString stringWithFormat:@"%d", [self percentTORGBValue:alphaValue]]];
	[redNumberDigit setText:[NSString stringWithFormat:@"%d", [self percentTORGBValue:redValue]]];
	[greenNumberDigit setText:[NSString stringWithFormat:@"%d", [self percentTORGBValue:greenValue]]];
	[blueNumberDigit setText:[NSString stringWithFormat:@"%d", [self percentTORGBValue:blueValue]]];
	
	[alphaNumberDigit setBackgroundColor:[UIColor clearColor]];
	[redNumberDigit setBackgroundColor:[UIColor clearColor]];
	[greenNumberDigit setBackgroundColor:[UIColor clearColor]];
	[blueNumberDigit setBackgroundColor:[UIColor clearColor]];
	
	[alphaNumberDigit release];
	[redNumberDigit release];
	[greenNumberDigit release];
	[blueNumberDigit release];
}

// simple conversion
- (int) percentTORGBValue:(float)percent
{
	return percent * 255;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.delegate didUserCompletedSelectColor:YES withRGBAColor:aColor withBackGroundColor:bColor];
}

- (void)dealloc 
{
	[self.view release];
    [super dealloc];
}


@end
