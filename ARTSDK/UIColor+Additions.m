//
//  UIColor+Additions.m
//  Judy
//
//  Created by Doug Diego on 1/22/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "UIColor+Additions.h"

#define COLOR_COMPONENT_RED_INDEX 0
#define COLOR_COMPONENT_GREEN_INDEX 1
#define COLOR_COMPONENT_BLUE_INDEX 2
#define COLOR_COMPONENT_SCALE_FACTOR 255.0f
#define COMPONENT_DOMAIN_DEGREES 60.0f
#define COMPONENT_MAXIMUM_DEGREES 360.0f
#define COMPONENT_OFFSET_DEGREES_GREEN 120.0f
#define COMPONENT_OFFSET_DEGREES_BLUE 240.0f
#define COMPONENT_PERCENTAGE 100.0f

#define INTEGER_FORMAT_STRING @"%i"
#define HEXADECIMAL_FORMAT_STRING @"%02X%02X%02X"
#define HEXADECIMAL_LENGTH 6
#define INTEGER_LENGTH 3

#define ANIMATION_DURATION 0.5f

#define HEXADECIMAL_CHARACTERS @"0123456789ABCDEF"
#define DECIMAL_CHARACTERS @"0123456789"

#define HEXADECIMAL_RED_LOCATION 0
#define HEXADECIMAL_GREEN_LOCATION 2
#define HEXADECIMAL_BLUE_LOCATION 4
#define HEXADECIMAL_COMPONENT_LENGTH 2

@implementation UIColor (Additions)

- (UIColor*) colorWithDesaturationAmount: (int) amount {
    //NSLog(@"desaturateColor: %@", self );
    if (self){
        CGFloat hue, saturation, brightness, alpha;
        BOOL success = [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        NSLog(@"BEFORE success: %i hue: %0.2f, saturation: %0.2f, brightness: %0.2f, alpha: %0.2f", success, hue, saturation, brightness, alpha);
        //CGFloat newSaturation = fmodf(saturation - ((CGFloat)amount/100), 1);//(20/100);
        CGFloat newSaturation = fmodf(saturation - amount, 1);//(20/100);
        float newHue = hue;
        NSLog(@"newSaturation: %f hue: %f", newSaturation, newHue );
        //return [UIColor colorWithHue:hue saturation:newSaturation brightness:brightness alpha:alpha];
        
        CGFloat hue2, saturation2, brightness2, alpha2;
        UIColor * newColor = [UIColor colorWithHue:newHue saturation:newSaturation brightness:brightness alpha:alpha];
        success = [newColor getHue:&hue2 saturation:&saturation2 brightness:&brightness2 alpha:&alpha2];
        NSLog(@"AFTER: %i hue: %0.2f, saturation: %0.2f, brightness: %0.2f, alpha: %0.2f", success, hue2, saturation2, brightness2, alpha2);
        return newColor;
    }
    return self;
}

- (UIColor *)lighterColor
{
    float h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.3, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColor
{
    float h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    return nil;
}

//http://www.cocoanetics.com/2009/10/manipulating-uicolors/
- (UIColor *)colorByDarkeningColor
{
	// oldComponents is the array INSIDE the original color
	// changing these changes the original, so we copy it
	CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([self CGColor]);
	CGFloat newComponents[4];
    
	int numComponents = CGColorGetNumberOfComponents([self CGColor]);
    
	switch (numComponents)
	{
		case 2:
		{
			//grayscale
			newComponents[0] = oldComponents[0]*0.7;
			newComponents[1] = oldComponents[0]*0.7;
			newComponents[2] = oldComponents[0]*0.7;
			newComponents[3] = oldComponents[1];
			break;
		}
		case 4:
		{
			//RGBA
			newComponents[0] = oldComponents[0]*0.7;
			newComponents[1] = oldComponents[1]*0.7;
			newComponents[2] = oldComponents[2]*0.7;
			newComponents[3] = oldComponents[3];
			break;
		}
	}
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
	return retColor;
}

- (UIColor *)colorByDarkeningColorAmount: (float) amount
{
	// oldComponents is the array INSIDE the original color
	// changing these changes the original, so we copy it
	CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([self CGColor]);
	CGFloat newComponents[4];
    
	int numComponents = CGColorGetNumberOfComponents([self CGColor]);
    
	switch (numComponents)
	{
		case 2:
		{
			//grayscale
			newComponents[0] = oldComponents[0]*amount;
			newComponents[1] = oldComponents[0]*amount;
			newComponents[2] = oldComponents[0]*amount;
			newComponents[3] = oldComponents[1];
			break;
		}
		case 4:
		{
			//RGBA
			newComponents[0] = oldComponents[0]*amount;
			newComponents[1] = oldComponents[1]*amount;
			newComponents[2] = oldComponents[2]*amount;
			newComponents[3] = oldComponents[3];
			break;
		}
	}
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
	return retColor;
}

/*
- (UInt32)rgbHex {
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use rgbHex");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return 0;
	
	r = MIN(MAX(r, 0.0f), 1.0f);
	g = MIN(MAX(g, 0.0f), 1.0f);
	b = MIN(MAX(b, 0.0f), 1.0f);
	
	return (((int)roundf(r * 255)) << 16)
    | (((int)roundf(g * 255)) << 8)
    | (((int)roundf(b * 255)));
}*/

+ (UIColor*)colorWithHexValue:(NSString*)hexValue
{
    //Default
    UIColor *defaultResult = [UIColor blackColor];
    
    //Strip prefixed # hash
    if ([hexValue hasPrefix:@"#"] && [hexValue length] > 1) {
        hexValue = [hexValue substringFromIndex:1];
    }
    
    //Determine if 3 or 6 digits
    NSUInteger componentLength = 0;
    if ([hexValue length] == 3)
    {
        componentLength = 1;
    }
    else if ([hexValue length] == 6)
    {
        componentLength = 2;
    }
    else
    {
        return defaultResult;
    }
    
    BOOL isValid = YES;
    CGFloat components[3];
    
    //Seperate the R,G,B values
    for (NSUInteger i = 0; i < 3; i++) {
        NSString *component = [hexValue substringWithRange:NSMakeRange(componentLength * i, componentLength)];
        if (componentLength == 1) {
            component = [component stringByAppendingString:component];
        }
        NSScanner *scanner = [NSScanner scannerWithString:component];
        unsigned int value;
        isValid &= [scanner scanHexInt:&value];
        components[i] = (CGFloat)value / 255.0f;
    }
    
    if (!isValid) {
        return defaultResult;
    }
    
    return [UIColor colorWithRed:components[0]
                           green:components[1]
                            blue:components[2]
                           alpha:1.0];
}

// Grays

+ (UIColor *)artDotComDarkGrayTextColor_iPad {
    return [UIColor colorWithRed:61.0 / 255 green:61.0 / 255 blue:61.0 / 255 alpha:1.0];
}

+ (UIColor *)artDotComDarkGrayColor_iPad {
    return [UIColor colorWithRed:61.0 / 255 green:61.0 / 255 blue:61.0 / 255 alpha:1.0];
}

+ (UIColor *)artDotComLightGray_Light_Color_iPad {
    return [UIColor colorWithRed:231.0 / 255 green:231.0 / 255 blue:231.0 / 255 alpha:1.0];
}

+ (UIColor *)artDotComLightGray_MediumLight_Color_iPad {
    return [UIColor colorWithRed:221.0 / 255 green:221.0 / 255 blue:221.0 / 255 alpha:1.0];
}

+ (UIColor *)artDotComGray_TableRowSelected_Color_iPad {
    return [UIColor colorWithRed:104.0 / 255 green:104.0 / 255 blue:104.0 / 255 alpha:1.0];
}

+ (UIColor *)artDotComDarkGray_Header_Color_iPad {
    return [UIColor colorWithRed:50.0 / 255 green:50.0 / 255 blue:50.0 / 255 alpha:1.0];
}


// Blues

+ (UIColor *)artDotComBlueTextColor_iPad {
    return [UIColor colorWithRed:50.0 / 255 green:116.0 / 255 blue:126.0 / 255 alpha:1.0];
}

+ (UIColor *)artDotComBlueHeaderColor_iPad {
    return [UIColor colorWithRed:215.0 / 255 green:228.0 / 255 blue:230.0 / 255 alpha:1.0];
}
//Added to provide a blue color to the audio state label inside the audio switch
+ (UIColor *)artDotComAudioBlueColor_iPad {
    return [UIColor colorWithRed:48.0 / 255 green:158.0 / 255 blue:183.0 / 255 alpha:1.0];
}

+ (UIColor *) artPhotosSectionTextColor {
    return [UIColor colorWithRed:99.0/255 green:99.0/255 blue:99.0/255 alpha:1.0];
}

+ (UIColor *) artDotComTextCyan {
    return [UIColor colorWithRed:15.0/255 green:154.0/255 blue:196.0/255 alpha:1.0];
}


#pragma mark -
#pragma mark Class Methods
/*
+ (HsvColor)hsvColorFromColor:(UIColor *)color {
    RgbColor rgbColor = [UIColor rgbColorFromColor:color];
    return [UIColor hsvColorFromRgbColor:rgbColor];
}*/
/*
- (RgbColor)rgbColor {
    RgbColor rgbColor;
    
    CGColorRef cgColor = [self CGColor];
    const CGFloat *colorComponents = CGColorGetComponents(cgColor);
    rgbColor.red = colorComponents[COLOR_COMPONENT_RED_INDEX];
    rgbColor.green = colorComponents[COLOR_COMPONENT_GREEN_INDEX];
    rgbColor.blue = colorComponents[COLOR_COMPONENT_BLUE_INDEX];
    
    rgbColor.redValue = (int)(rgbColor.red * COLOR_COMPONENT_SCALE_FACTOR);
    rgbColor.greenValue = (int)(rgbColor.green * COLOR_COMPONENT_SCALE_FACTOR);
    rgbColor.blueValue = (int)(rgbColor.blue * COLOR_COMPONENT_SCALE_FACTOR);
    
    return rgbColor;

}

+ (NSString *)hexValue {
    RgbColor rgbColor = rgbColor;
    return [UIColor hexValueFromRgbColor:rgbColor];
}
*/
+ (RGBColor)rgbColorFromColor:(UIColor *)color {
    RGBColor rgbColor;
    
    CGColorRef cgColor = [color CGColor];
    const CGFloat *colorComponents = CGColorGetComponents(cgColor);
    rgbColor.red = colorComponents[COLOR_COMPONENT_RED_INDEX];
    rgbColor.green = colorComponents[COLOR_COMPONENT_GREEN_INDEX];
    rgbColor.blue = colorComponents[COLOR_COMPONENT_BLUE_INDEX];
    
    rgbColor.redValue = (int)(rgbColor.red * COLOR_COMPONENT_SCALE_FACTOR);
    rgbColor.greenValue = (int)(rgbColor.green * COLOR_COMPONENT_SCALE_FACTOR);
    rgbColor.blueValue = (int)(rgbColor.blue * COLOR_COMPONENT_SCALE_FACTOR);
    
    return rgbColor;
}

+ (NSString *)hexValueFromColor:(UIColor *)color {
    RGBColor rgbColor = [UIColor rgbColorFromColor:color];
    return [UIColor hexValueFromRgbColor:rgbColor];
}

+ (UIColor *)colorFromHexValue:(NSString *)hexValue {
    //NSLog(@"colorFromHexValue: %@", hexValue);
    UIColor *blackColor = [UIColor blackColor];
    
    if(!hexValue){
        return blackColor;
    }
    if([hexValue length] < 6){
        return blackColor;
    }
    
    NSRange componentRange = NSMakeRange(HEXADECIMAL_RED_LOCATION,
                                         HEXADECIMAL_COMPONENT_LENGTH);
    NSString *redComponent = [hexValue substringWithRange:componentRange];
    
    componentRange.location = HEXADECIMAL_GREEN_LOCATION;
    NSString *greenComponent = [hexValue substringWithRange:componentRange];
    
    componentRange.location = HEXADECIMAL_BLUE_LOCATION;
    NSString *blueComponent = [hexValue substringWithRange:componentRange];
    
    uint red = 0;
    uint green = 0;
    uint blue = 0;
    [[NSScanner scannerWithString:redComponent] scanHexInt:&red];
    [[NSScanner scannerWithString:greenComponent] scanHexInt:&green];
    [[NSScanner scannerWithString:blueComponent] scanHexInt:&blue];
    
    UIColor * color = [UIColor colorWithRed:red / COLOR_COMPONENT_SCALE_FACTOR
                            green:green / COLOR_COMPONENT_SCALE_FACTOR
                             blue:blue / COLOR_COMPONENT_SCALE_FACTOR
                            alpha:1.0f];
    
    return color;
}

+ (BOOL)isValidHexValue:(NSString *)hexValue {
    BOOL isValid = NO;
    
    NSString *trimmedString =
    [hexValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length == HEXADECIMAL_LENGTH) {
        NSCharacterSet *hexadecimalCharacters =
        [NSCharacterSet characterSetWithCharactersInString:HEXADECIMAL_CHARACTERS];
        if ([UIColor stringIsValid:trimmedString
                                 forCharacterSet:hexadecimalCharacters]) {
            isValid = YES;
        }
    }
    
    return isValid;
}

+ (NSString *)hexValueFromRgbColor:(RGBColor)color {
    return [NSString stringWithFormat:HEXADECIMAL_FORMAT_STRING,
            color.redValue,
            color.greenValue,
            color.blueValue];
}
/*
+ (HsvColor)hsvColorFromRgbColor:(RgbColor)color {
    HsvColor hsvColor;
    
    CGFloat maximumValue = MAX(color.red, color.green);
    maximumValue = MAX(maximumValue, color.blue);
    CGFloat minimumValue = MIN(color.red, color.green);
    minimumValue = MIN(minimumValue, color.blue);
    CGFloat range = maximumValue - minimumValue;
    
    hsvColor.hueValue = 0;
    if (maximumValue == minimumValue) {
        // continue
    }
    else if (maximumValue == color.red) {
        hsvColor.hueValue =
        (int)roundf(COMPONENT_DOMAIN_D+ (HsvColor)hsvColorFromColor:(UIColor *)color;
                    + (RgbColor)rgbColorFromColor:(UIColor *)color;
                    + (NSString *)hexValueFromColor:(UIColor *)color;
                    + (UIColor *)colorFromHexValue:(NSString *)hexValue;
                    + (BOOL)isValidHexValue:(NSString *)hexValue;EGREES * (color.green - color.blue) / range);
        if (hsvColor.hueValue < 0) {
            hsvColor.hueValue += COMPONENT_MAXIMUM_DEGREES;
        }
    }
    else if (maximumValue == color.green) {
        hsvColor.hueValue =
        (int)roundf(((COMPONENT_DOMAIN_DEGREES * (color.blue - color.red) / range) +
                     COMPONENT_OFFSET_DEGREES_GREEN));
    }
    else if (maximumValue == color.blue) {
        hsvColor.hueValue =
        (int)roundf(((COMPONENT_DOMAIN_DEGREES * (color.red - color.green) / range) +
                     COMPONENT_OFFSET_DEGREES_BLUE));
    }
    
    hsvColor.saturationValue = 0;
    if (maximumValue == 0.0f) {
        // continue
    }
    else {
        hsvColor.saturationValue =
        (int)roundf(((1.0f - (minimumValue / maximumValue)) * COMPONENT_PERCENTAGE));
    }
    
    hsvColor.brightnessValue = (int)roundf((maximumValue * COMPONENT_PERCENTAGE));
    
    hsvColor.hue = (float)hsvColor.hueValue / COMPONENT_MAXIMUM_DEGREES;
    hsvColor.saturation = (float)hsvColor.saturationValue / COMPONENT_PERCENTAGE;
    hsvColor.brightness = (float)hsvColor.brightnessValue / COMPONENT_PERCENTAGE;
    
    return hsvColor;
}*/

+ (BOOL)stringIsValid:(NSString *)string
      forCharacterSet:(NSCharacterSet *)characters {
    BOOL isValid = YES;
    
    for (int counter = 0; counter < string.length; counter++) {
        unichar currentCharacter = [string characterAtIndex:counter];
        if ([characters characterIsMember:currentCharacter]) {
            // continue
        }
        else {
            isValid = NO;
            break;
        }
    }
    
    return isValid;
}

// http://stackoverflow.com/questions/1855884/determine-font-color-based-on-background-color
+ (UIColor*) contrastOfUIColor:(UIColor*) color {

    int d = 0;
    const CGFloat* components = CGColorGetComponents([color CGColor]);
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    CGFloat alpha = CGColorGetAlpha([[UIColor greenColor] CGColor]);
    double a = 1 - ( 0.299 * red + 0.587 * green+ 0.114 * blue)/255;
    
    if (a < 0.5) {
        d = 0; // bright colors - black font
    }else{
        d = 255; // dark colors - white font
    }
    
    return [UIColor colorWithRed:d
                           green:d
                            blue:d
                           alpha:alpha];
}

+(UIColor*) randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}


@end
