//
//  UIImage+Colors.m
//  Judy
//
//  Created by Doug Diego on 1/24/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "UIImage+Colors.h"

@implementation UIImage (Colors)

- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
	UIColor* color = nil;
	CGImageRef inImage = self.CGImage;
	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
	CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
	if (cgctx == NULL) { return nil; /* error */ }
	
    size_t w = CGImageGetWidth(inImage);
	size_t h = CGImageGetHeight(inImage);
	CGRect rect = {{0,0},{w,h}};
    //CGRect rect = {{-point.x, point.y - h +1}, {w, h}};
    //NSLog(@"w: %lu h: %lu point x: %f y: %f", w,h,point.x, point.y);
    
	
	// Draw the image to the bitmap context. Once we draw, the memory
	// allocated for the context for rendering will then contain the
	// raw image data in the specified color space.
	CGContextDrawImage(cgctx, rect, inImage);
	
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
	unsigned char* data = CGBitmapContextGetData (cgctx);
    //NSLog(@"data size %lu", sizeof(data) );
	if (data != NULL || sizeof(data) < 4) {
		//offset locates the pixel in the data from x,y.
		//4 for 4 bytes of data per pixel, w is width of one row of data.
		int offset = 4*((w*round(point.y))+round(point.x));
        //int offset = 4*((w*round(point.y*2))+round(point.x*2));
        //int offset = 0;
		int alpha =  data[offset];
		int red = data[offset+1];
		int green = data[offset+2];
		int blue = data[offset+3];
		//NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
		color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
	} else {
        color = [UIColor blackColor];
    }
	
	// When finished, release the context
	CGContextRelease(cgctx);
	// Free image data memory for the context
	if (data) { free(data); }
    
    // Return black if point is not in image.
    if( point.x > w){
        return [UIColor blackColor];
    }
    if( point.x < 0){
        return [UIColor blackColor];
    }
    if( point.y > h){
        return [UIColor blackColor];
    }
    if( point.y < 0){
        return [UIColor blackColor];
    }
	
	return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
    //size_t pixelsWide = 1;
	//size_t pixelsHigh = 1;
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
    
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	#ifndef __clang_analyzer__
    context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 2);//kCGImageAlphaPremultipliedFirst);
    //NSLog(@"kCGImageAlphaPremultipliedFirst: %d",kCGImageAlphaPremultipliedFirst);
    //NSLog(@"kCGBitmapAlphaInfoMask: %d",kCGBitmapAlphaInfoMask);
    //NSLog(@"kCGBitmapFloatComponents: %d",kCGBitmapFloatComponents);
	#endif
    if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
    
    
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
   
    #ifndef __clang_analyzer__
	return context;
    #endif
}


@end
