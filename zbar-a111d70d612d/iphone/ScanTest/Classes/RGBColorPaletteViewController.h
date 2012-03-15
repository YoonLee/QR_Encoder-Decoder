//
//  RGBColorPaletteViewController.h
//  QR
//
//  Created by Yoon Lee on 9/5/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRGlobal.h"


@protocol RGBColorPaletteDelegate;

@interface RGBColorPaletteViewController : UIViewController 
{
	id <RGBColorPaletteDelegate> delegate;
	int mode;
}

@property(nonatomic, assign) id delegate;

@end

@protocol RGBColorPaletteDelegate
@required

- (void) didUserCompletedSelectColor:(BOOL)completed withRGBAColor:(Color4f)aColor withBackGroundColor:(Color4f)bColor;

@end