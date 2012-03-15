//
//  UIImage+Yoon+Alex.m
//  Untitled
//
//  Created by Yoon Lee on 8/20/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//

#import "UIImage+Yoon.h"


@implementation UIImage (UIImage_Yoon)


NSDictionary *root = nil;

- (UIImage *) paintColorOnQR:(UIImage *)originalImg withColor:(UIColor *) color
{
	// begin a new image context, to draw our colored image onto
	UIGraphicsBeginImageContext(originalImg.size);
	
	// get a reference to that context we created
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// set the fill color
	[color setFill];
	
	// translate/flip the graphics context (for transforming from CG* coords to UI* coords
	CGContextTranslateCTM(context, 0, originalImg.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// set the blend mode to color burn, and the original image
	CGContextSetBlendMode(context, kCGBlendModeMultiply);
	CGRect rect = CGRectMake(0, 0, originalImg.size.width, originalImg.size.height);
	CGContextDrawImage(context, rect, originalImg.CGImage);
	
	// set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
	CGContextClipToMask(context, rect, originalImg.CGImage);
	CGContextAddRect(context, rect);
	CGContextDrawPath(context,kCGPathFillStroke);
	
	// generate a new UIImage from the graphics context we drew onto
	UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//return the color-burned image
	return coloredImg;
}

- (NSArray *) spliteQRImageWithPosition:(CGSize)_size
{
	NSArray *images = nil;
	CGRect targetedImagePositionTop = CGRectMake(0.0f, 0.0f, _size.width, _size.height / 2);
	
	CGRect targetedImagePositionBottom = CGRectMake(0.0f, _size.height / 2, _size.width, _size.height / 2);
	
	CGImageRef imgRefsTop    = CGImageCreateWithImageInRect([self CGImage], targetedImagePositionTop);
	CGImageRef imgRefsBottom = CGImageCreateWithImageInRect([self CGImage], targetedImagePositionBottom); 
	images = [NSArray arrayWithObjects:[UIImage imageWithCGImage:imgRefsTop], [UIImage imageWithCGImage:imgRefsBottom], nil];
	
	CGImageRelease(imgRefsTop);
	CGImageRelease(imgRefsBottom);
	
	return images;
}

- (void) setSpriteSheetPlist:(NSString *)plistName
{
	NSString *paths = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
	
	root = [NSDictionary dictionaryWithContentsOfFile:paths];
}

- (UIImage *) imageWithSprite:(NSString *)spriteName
{
	NSDictionary *frames = [root objectForKey:@"frames"];
	
	// retina display detect
	NSString *cpsprite = @"";
	CGFloat scales = 1.0f;
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
	{
		cpsprite = spriteName;
		// removal of .png
		spriteName = [spriteName substringToIndex:spriteName.length - 4];
		spriteName = [NSString stringWithFormat:@"%@@2x.png", spriteName];
		scales = 2.0f;
	}
	
	NSDictionary *image = [frames objectForKey:spriteName];
	
	// if retina image not found from the spritesheet then use regular image
	if (!image) 
	{
		image = [frames objectForKey:cpsprite];
		scales = 1.0f;
	}
	
	NSNumber *x      = [image objectForKey:@"x"];
	NSNumber *y      = [image objectForKey:@"y"];
	NSNumber *width  = [image objectForKey:@"width"];
	NSNumber *height = [image objectForKey:@"height"];
	
	CGRect imagePosition = CGRectMake([x floatValue], [y floatValue], [width floatValue], [height floatValue]);
	
	CGImageRef imgRefs = CGImageCreateWithImageInRect([self CGImage], imagePosition);
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	
	UIImage *retImage = nil;
	
	// retina image support
	if (version >= 4.0)
		retImage = [UIImage imageWithCGImage:imgRefs scale:scales orientation:UIImageOrientationUp];
	// below version
	else
		retImage = [UIImage imageWithCGImage:imgRefs];
	
	CGImageRelease(imgRefs);
	
	return retImage;
}

- (UIImage *) imageWithOverlayColor:(UIColor *)color
{        
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
	
	CGFloat imageScale = 1.0f;
	if ([self respondsToSelector:@selector(scale)])
	{
		// The scale property is new with iOS4.
		imageScale = self.scale;
		UIGraphicsBeginImageContextWithOptions(self.size, NO, imageScale);
	}
    else 
        UIGraphicsBeginImageContext(self.size);
    
	
    [self drawInRect:rect];
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
	
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return image;
}

- (void)dealloc 
{
    [super dealloc];
}


@end
