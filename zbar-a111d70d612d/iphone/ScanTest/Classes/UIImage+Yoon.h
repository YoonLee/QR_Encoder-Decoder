//
//  UIImage+Yoon+Alex.h
//  Untitled
//
//  Created by Yoon Lee on 8/20/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (UIImage_Yoon_Alex)

- (UIImage *) paintColorOnQR:(UIImage *)originalImg withColor:(UIColor *) color;

// this method will split the image into top, bottom with updated origin x, y and will store into array
// index 0 has top and index 1 has bottom portion will be stored
- (NSArray *) spliteQRImageWithPosition:(CGSize)_size;

- (UIImage *) imageWithSprite:(NSString *)spriteName;

- (UIImage *) imageWithOverlayColor:(UIColor *)color;

- (void) setSpriteSheetPlist:(NSString *)plistName;

@end
