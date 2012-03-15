/*
 *  QRGlobal.h
 *  QR
 *
 *  Created by Yoon Lee on 9/2/11.
 *  Copyright 2011 University of California, Irvine. All rights reserved.
 *
 */

// Structure that defines the elements which make up a color
// It represents the RGBA as percentage to RGBA as Actual Value
typedef struct 
{
	int red;
	int green;
	int blue;
	int alpha;
} Color4f;

// RGB easy access
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

// RGBA easy access
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

// ReversedRGB
static inline Color4f Color4fMake(float red, float green, float blue, float alpha)
{
	return (Color4f) {255 * red, 255 * green, 255 * blue, 255 * alpha};
}

static const Color4f Color4fZero = {1, 1, 1, 255};

static const Color4f Color4fWhite = {255, 255, 255, 255};