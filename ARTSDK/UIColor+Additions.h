//
//  UIColor+Additions.h
//  Judy
//
//  Created by Doug Diego on 1/22/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
    int hueValue;
    int saturationValue;
    int brightnessValue;
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
} HSVColor;

typedef struct {
    int redValue;
    int greenValue;
    int blueValue;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
} RGBColor;


@interface UIColor (Additions)

- (UIColor*) colorWithDesaturationAmount: (int) amount;
- (UIColor *)lighterColor;
- (UIColor *)darkerColor;
- (UIColor *)colorByDarkeningColor;
- (UIColor *)colorByDarkeningColorAmount: (float) amount;
+ (UIColor*)colorWithHexValue:(NSString*)hexValue;

//+ (HSVColor)hsvColorFromColor:(UIColor *)color;
+ (RGBColor)rgbColorFromColor:(UIColor *)color;
+ (NSString *)hexValueFromColor:(UIColor *)color;
+ (UIColor *)colorFromHexValue:(NSString *)hexValue;
+ (BOOL)isValidHexValue:(NSString *)hexValue;

+ (UIColor*) contrastOfUIColor: (UIColor*) color;

// Grays
+ (UIColor *)artDotComDarkGrayTextColor_iPad;

+ (UIColor *)artDotComDarkGrayColor_iPad;

+ (UIColor *)artDotComLightGray_Light_Color_iPad;

+ (UIColor *)artDotComLightGray_MediumLight_Color_iPad;

+ (UIColor *)artDotComGray_TableRowSelected_Color_iPad;

+ (UIColor *)artDotComDarkGray_Header_Color_iPad;

// Blues
+ (UIColor *)artDotComBlueTextColor_iPad;

+ (UIColor *)artDotComBlueHeaderColor_iPad;

+ (UIColor *)artDotComAudioBlueColor_iPad;

+ (UIColor *) artPhotosSectionTextColor;

+ (UIColor *) artDotComTextCyan;

+(UIColor*) randomColor;
@end
