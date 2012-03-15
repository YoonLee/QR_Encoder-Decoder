

#import "QREncoder.h"


@interface QREncoder(PrivateMethod)

+ (unsigned int) colorToHexadecimalWithColor:(int)color;

@end

@implementation QREncoder
unsigned char* rawData;


+ (DataMatrix*)encodeWithECLevel:(int)ecLevel version:(int)version string:(NSString*)_string
{
    const char* cstring = [_string cStringUsingEncoding:NSUTF8StringEncoding];
	
    CQR_Encode* encoder = new CQR_Encode;
    encoder->EncodeData(ecLevel, version, true, -1, cstring);
    int dimension = encoder->m_nSymbleSize;
    DataMatrix* matrix = [[[DataMatrix alloc] initWith:dimension] autorelease];
    for (int y=0; y<dimension; y++) {
        for (int x=0; x<dimension; x++) {
            int v = encoder->m_byModuleData[y][x];
            bool bk = v==1;
            [matrix set:bk x:y y:x];
        }
    }
    
    delete encoder;
    
    return matrix;
}

+ (void)drawDotAt:(int)x y:(int)y offset:(int)offset baseColor:(unsigned char*)baseColor pixelPerDot:(int)pixelPerDot imageDimension:(int)imageDimension
{
    const int bytesPerPixel = 4;
    const int bytesPerLine = bytesPerPixel * imageDimension;
	
    int startX = pixelPerDot * x * bytesPerPixel + bytesPerPixel * offset;
    int startY = pixelPerDot * y + offset;
    int endX = startX + pixelPerDot * bytesPerPixel;
    int endY = startY + pixelPerDot;
    printf("%X\n", baseColor[3]);
    for (int my = startY; my < endY; my++) 
	{
        for (int mx = startX; mx < endX; mx+=bytesPerPixel) 
		{
            rawData[bytesPerLine * my + mx    ] = baseColor[0];    //red
            rawData[bytesPerLine * my + mx + 1] = baseColor[1];    //green
            rawData[bytesPerLine * my + mx + 2] = baseColor[2];    //blue
            //rawData[bytesPerLine * my + mx + 3] = baseColor[3];    //alpha
        }
    }
}

+ (UIImage*)renderDataMatrix:(DataMatrix*)matrix imageDimension:(int)imageDimension red:(int)red green:(int)green blue:(int)blue backRed:(int)backRed backGreen:(int)backGreen backBlue:(int)backBlue alpha:(int)alpha backAlpha:(int)backAlpha
{    
    const int bitsPerPixel = BITS_PER_BYTE * BYTES_PER_PIXEL;
    const int bytesPerLine = BYTES_PER_PIXEL * imageDimension;
    const int rawDataSize = imageDimension * imageDimension * BYTES_PER_PIXEL;
    rawData = (unsigned char*)malloc(rawDataSize);
	unsigned char* baseColor = (unsigned char*)malloc(BYTES_PER_PIXEL);
	
	// baseColor = { R, P, G, A };
	baseColor[0] = [QREncoder colorToHexadecimalWithColor:red];
	baseColor[1] = [QREncoder colorToHexadecimalWithColor:green];
	baseColor[2] = [QREncoder colorToHexadecimalWithColor:blue];
	baseColor[3] = 0x4B;//[QREncoder colorToHexadecimalWithColor:alpha];
	printf("%X\n", baseColor[3]);
	// backgroundColor = {R, P, G, A};
	unsigned char* backColor = (unsigned char*)malloc(BYTES_PER_PIXEL);
	backColor[0] = [QREncoder colorToHexadecimalWithColor:backRed];
	backColor[1] = [QREncoder colorToHexadecimalWithColor:backGreen];
	backColor[2] = [QREncoder colorToHexadecimalWithColor:backBlue];
    backColor[3] = [QREncoder colorToHexadecimalWithColor:backAlpha];
	
    int matrixDimension = [matrix dimension];
    int pixelPerDot = imageDimension / matrixDimension;
    int offset = (int)((imageDimension - pixelPerDot * matrixDimension) / 2);
	
    for (int y=0; y<matrixDimension; y+=1) 
	{
        for (int x=0; x<matrixDimension; x+=1) 
		{
            bool isDark = [matrix valueAt:x y:y];
            if (isDark) 
                [QREncoder drawDotAt:x y:y offset:offset baseColor:baseColor pixelPerDot:pixelPerDot imageDimension:imageDimension ];
			else
				[QREncoder drawDotAt:x y:y offset:offset baseColor:backColor pixelPerDot:pixelPerDot imageDimension:imageDimension ];
        }
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, 
                                                              rawData, 
                                                              rawDataSize, 
                                                              NULL);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(imageDimension,
                                        imageDimension,
                                        BITS_PER_BYTE,
                                        bitsPerPixel,
                                        bytesPerLine,
                                        colorSpaceRef,
                                        bitmapInfo,
                                        provider,
                                        NULL,NO,renderingIntent);
    
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
	
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
	
	free(baseColor);
	
    return newImage;
}

+ (unsigned int) colorToHexadecimalWithColor:(int)color
{
	unsigned int hexValue;
	NSScanner *scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"%X", color]];
	[scanner scanHexInt:&hexValue];
	
	return hexValue;
}

- (void) dealloc
{
	[super dealloc];
}


@end
