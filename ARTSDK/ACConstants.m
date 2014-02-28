//
//  ACConstants.m
//  ArtAPI
//
//  Created by Doug Diego on 4/19/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ACConstants.h"

NSString *kACStandardFont = @"GiorgioSans-Bold";

NSString *kACNotificationDismissModal = @"NOTIFICATION_DISMISS_MODAL";

@implementation ACConstants

+(AppLocation)getCurrentAppLocation
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if([bundleIdentifier hasSuffix:@"myphotos"])
        return AppLocationGerman;
    else if([bundleIdentifier hasSuffix:@"mesphotos"])
        return AppLocationFrench;
    else if([bundleIdentifier hasSuffix:@"photostoart"])
        return AppLocationDefault;

    return AppLocationNone;
}

+(NSString *)getGATrackingID
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if([bundleIdentifier hasSuffix:@"myphotos"])
    {
        return @"UA-45173617-3";
    }else if([bundleIdentifier hasSuffix:@"mesphotos"])
    {
        return @"UA-45173617-2";
    }
    else if([bundleIdentifier hasSuffix:@"photostoart"])
    {
        return @"UA-45173617-1";
    }
    else if([bundleIdentifier hasSuffix:@"artCircles"])
    {
        return @"UA-45173617-4";
    }
    else if([bundleIdentifier hasSuffix:@"artDials"])
    {
        return @"UA-45173617-5";
    }else{
        return @"";
    }
}

+(NSString *)getCardIOToken{
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    if([bundleIdentifier hasSuffix:@"myphotos"])
    {
        return @"9dc3e9e8cb7f4011830d23918206ce53";
    }else if([bundleIdentifier hasSuffix:@"mesphotos"])
    {
        return @"8dac6f74c6ef43af82c482f176e4c351";
    }
    else if([bundleIdentifier hasSuffix:@"photostoart"])
    {
        return @"84ad0c3a417b46edb2619b056bbac1a8";
    }
    else if([bundleIdentifier hasSuffix:@"artCircles"])
    {
        return @"a280bdc32372411c94fd3bea59fab781";
    }
    else if([bundleIdentifier hasSuffix:@"artDials"])
    {
        return @"d4f404eb4fca4e828a4571451b069365";
    }else
    {
        return @"";
    }
}

+(NSDictionary *)getHelpShiftTokens
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if([bundleIdentifier hasSuffix:@"myphotos"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"c01355239a779a3180a5db2f778e4c4e", @"API_KEY",
                @"artdotcom.helpshift.com", @"DOMAIN",
                @"artdotcom_platform_20131028140949766-d3d69d607c9e6c1", @"APP_ID",nil];
    }else if([bundleIdentifier hasSuffix:@"mesphotos"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"95810e5fdbe00d7a8a43a54eb43b5589", @"API_KEY",
                @"artdotcom.helpshift.com", @"DOMAIN",
                @"artdotcom_platform_20131028140804002-2aec1b4cf324899", @"APP_ID",nil];    }
    else if([bundleIdentifier hasSuffix:@"photostoart"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"b9cd3b851b8203d2657ba8b2b810fa52", @"API_KEY",
                @"artdotcom.helpshift.com", @"DOMAIN",
                @"artdotcom_platform_20130603221642857-441499586f82fcb", @"APP_ID",nil];    }
    else if([bundleIdentifier hasSuffix:@"artcircles"])
    {
        return [NSDictionary dictionary];
    }else
    {
        return nil;
    }
}

+(NSString *)getLocalizedStringForKey:(NSString *)key withDefaultValue:(NSString *)defaultValue
{
    
    NSString *msg = defaultValue;
    NSArray *appsLocationArray = [NSArray arrayWithObjects:@"PHOTOSTOART",@"MESPHOTOS",@"MYPHOTOS",@"", nil];
    
    AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
    NSString *keyy = [key stringByReplacingOccurrencesOfString:@"&&" withString:[appsLocationArray objectAtIndex:currAppLoc]];
    
    if(currAppLoc!=AppLocationNone){
        msg = ACLocalizedString(keyy, defaultValue);
    }
    return msg;
    
}

+(UIFont *)getStandardMediumFontWithSize:(CGFloat)size
{
    AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
    return (currAppLoc == AppLocationGerman || currAppLoc == AppLocationFrench)?[UIFont fontWithName:@"FetteEngschrift" size:size]:[UIFont fontWithName:@"GiorgioSans-Medium" size:size];
}

+(UIFont *)getStandardBoldFontWithSize:(CGFloat)size
{
    AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
    return (currAppLoc == AppLocationGerman || currAppLoc == AppLocationFrench)?[UIFont fontWithName:@"FetteEngschrift" size:size]:[UIFont fontWithName:@"GiorgioSans-Bold" size:size];
}

+(UIButton *)getBackButtonForTitle:(NSString *)backTitle
{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *normalBackground;
    
    AppLocation currAppLoc = [self getCurrentAppLocation];
    
    switch (currAppLoc) {
        case AppLocationDefault:{
            normalBackground = [[UIImage imageNamed:ARTImage(@"chevronBlue40")] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
            break;
        }
        case AppLocationFrench:{
            normalBackground = [[UIImage imageNamed:ARTImage(@"chevronBlue40")] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
            break;
        }
        case AppLocationGerman:{
            normalBackground = [[UIImage imageNamed:ARTImage(@"chevronBlue40")] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
            break;
        }
        default:
            normalBackground = [[UIImage imageNamed:ARTImage(@"chevronBlue40")] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
            break;
    }
    
    
    [button setBackgroundImage:normalBackground forState:UIControlStateNormal];
//    [button setBackgroundImage:normalBackground forState:UIControlStateHighlighted];
    CGSize size = CGSizeZero;
    if(IS_IOS_7_ABOVE){
        size = [backTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
    }else{
        size = [backTitle sizeWithFont:[UIFont systemFontOfSize:17.0f]];
    }
    //NSLog(@"Frame Size is %@",NSStringFromCGSize(size));
    button.frame = CGRectMake(0, 0, size.width + 20, 20);
    [button.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    //[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[ACConstants getPrimaryLinkColor] forState:UIControlStateNormal];
    [button setTitleColor:[ACConstants getDisabledPrimaryLinkColor] forState:UIControlStateDisabled];
    [button setTitleColor:[ACConstants getHighlightedPrimaryLinkColor] forState:UIControlStateHighlighted];
    
    [button setTitle:backTitle forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(1, 18, 0, 0);
    return button;
}

+(UIButton *)getNextButtonForTitle:(NSString *)nextTitle
{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *normalBackground;
    
    AppLocation currAppLoc = [self getCurrentAppLocation];
    
    switch (currAppLoc) {
        case AppLocationDefault:{
            normalBackground = [[UIImage imageNamed:ARTImage(@"chevronBlueRight40")] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
            break;
        }
        case AppLocationFrench:{
            normalBackground = [[UIImage imageNamed:ARTImage(@"chevronBlueRight40")] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
            break;
        }
        case AppLocationGerman:{
            normalBackground = [[UIImage imageNamed:ARTImage(@"chevronBlueRight40")] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
            break;
        }
        default:
            normalBackground = [[UIImage imageNamed:ARTImage(@"chevronBlueRight40")] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
            break;
    }
    
    
    
    [button setBackgroundImage:normalBackground forState:UIControlStateNormal];
//    [button setBackgroundImage:normalBackground forState:UIControlStateHighlighted];
    CGSize size = CGSizeZero;
    if(IS_IOS_7_ABOVE){
        size = [nextTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
    }else{
        size = [nextTitle sizeWithFont:[UIFont systemFontOfSize:17.0f]];
    }
    //NSLog(@"Frame Size is %@",NSStringFromCGSize(size));
    button.frame = CGRectMake(0, 0, size.width + 20, 20);
    [button.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    button.titleLabel.textAlignment = NSTextAlignmentRight;
    //[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[ACConstants getPrimaryLinkColor] forState:UIControlStateNormal];
    [button setTitleColor:[ACConstants getDisabledPrimaryLinkColor] forState:UIControlStateDisabled];
    [button setTitleColor:[ACConstants getHighlightedPrimaryLinkColor] forState:UIControlStateHighlighted];

    [button setTitle:nextTitle forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(1, 0, 0, 18);
    return button;
}

+(UIImage *)getMiniCartImage
{
    //color for solid buttons
    AppLocation currAppLoc = [self getCurrentAppLocation];
    
    switch (currAppLoc) {
        case AppLocationDefault:{
            return [UIImage imageNamed:ARTImage(@"CartSmallBlue.png")];
        }
        case AppLocationFrench:{
            return [UIImage imageNamed:ARTImage(@"CartSmallBlue.png")];
        }
        case AppLocationGerman:{
            return [UIImage imageNamed:ARTImage(@"CartSmallBlue.png")];
        }
        default:
            return [UIImage imageNamed:ARTImage(@"CartSmallBlue.png")];
    }
    
}



+(UIColor *)getHomeScreenHoverColor
{
    //color for solid buttons
    AppLocation currAppLoc = [self getCurrentAppLocation];
    
    switch (currAppLoc) {
        case AppLocationDefault:{
            return [UIColor colorWithRed:52.0/255 green:55.0/255 blue:61.0/255 alpha:1.0];
        }
        case AppLocationFrench:{
            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
        }
        case AppLocationGerman:{
            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
        }
        default:
            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
    }
    
}

+(UIColor *)getPrimaryButtonColor
{
    //color for solid buttons
    AppLocation currAppLoc = [self getCurrentAppLocation];

    switch (currAppLoc) {
        case AppLocationDefault:{
            //return [UIColor colorWithRed:239.0/255 green:146.0/255 blue:35.0/255 alpha:1.0];
            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
        }
        case AppLocationFrench:{
            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
        }
        case AppLocationGerman:{
            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
        }
        default:
            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
    }
    
}

+(UIColor *)getSecondaryButtonColor
{
    //color for solid secondary buttons
    AppLocation currAppLoc = [self getCurrentAppLocation];
    
    switch (currAppLoc) {
        case AppLocationDefault:{
            return [UIColor colorWithRed:0.200 green:0.478 blue:0.576 alpha:1.000];
        }
        case AppLocationFrench:{
            return [UIColor colorWithRed:0.200 green:0.478 blue:0.576 alpha:1.000];
        }
        case AppLocationGerman:{
            return [UIColor colorWithRed:0.200 green:0.478 blue:0.576 alpha:1.000];
        }
        default:
            return [UIColor colorWithRed:0.200 green:0.478 blue:0.576 alpha:1.000];
    }
    
}

+(UIColor *)getPrimaryLinkColor
{
    //color for navigation links
    AppLocation currAppLoc = [self getCurrentAppLocation];
    
    switch (currAppLoc) {
        case AppLocationDefault:{
            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
        }
        case AppLocationFrench:{
            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
        }
        case AppLocationGerman:{
            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
        }
        default:
            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
    }
    
}

+(UIColor *)getDisabledPrimaryLinkColor
{
    //color for navigation links
    AppLocation currAppLoc = [self getCurrentAppLocation];
    
    switch (currAppLoc) {
        case AppLocationDefault:{
            return [UIColor colorWithRed:146.0/255 green:212.0/255 blue:234.0/255 alpha:1.0];
        }
        case AppLocationFrench:{
//            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
            return [UIColor colorWithRed:146.0/255 green:212.0/255 blue:234.0/255 alpha:1.0];
        }
        case AppLocationGerman:{
//            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
            return [UIColor colorWithRed:146.0/255 green:212.0/255 blue:234.0/255 alpha:1.0];
        }
        default:{
//            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
            return [UIColor colorWithRed:146.0/255 green:212.0/255 blue:234.0/255 alpha:1.0];
        }
    }
    
}

+(UIColor *)getHighlightedPrimaryLinkColor
{
    //color for navigation links
    AppLocation currAppLoc = [self getCurrentAppLocation];
    
    switch (currAppLoc) {
        case AppLocationDefault:{
            return [UIColor colorWithRed:0.196 green:0.475 blue:0.573 alpha:1.000];
        }
        case AppLocationFrench:{
            //            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
            return [UIColor colorWithRed:0.196 green:0.475 blue:0.573 alpha:1.000];
        }
        case AppLocationGerman:{
            //            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
            return [UIColor colorWithRed:0.196 green:0.475 blue:0.573 alpha:1.000];
        }
        default:{
            //            return [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0];
            return [UIColor colorWithRed:0.196 green:0.475 blue:0.573 alpha:1.000];
        }
    }
}



+(UIView *)getNavBarLogo
{
    AppLocation currAppLoc = [self getCurrentAppLocation];
    UIImage *appLogoImage = nil;
    switch (currAppLoc) {
        case AppLocationDefault:{
            appLogoImage = [UIImage imageNamed:ARTImage(@"P2AHorizontalLogo")]; //PhotosToArt Logo
            break;
        }
        case AppLocationFrench:{
            appLogoImage = [UIImage imageNamed:ARTImage(@"MesPhotosHorizontalLogo")]; //MesPhotos Logo
            break;
        }
        case AppLocationGerman:{
            appLogoImage = [UIImage imageNamed:ARTImage(@"MyPhotosHorizontalLogo")]; //MyPhotos Logo
            break;
        }
        //Add more cases if needed in future
        default:
            break;
    }
    if(appLogoImage&&[appLogoImage isKindOfClass:[UIImage class]])
    {
        UIImageView *appLogoImageView = [[UIImageView alloc] initWithImage:appLogoImage];
        appLogoImageView.frame = CGRectMake(0, 0, 100, 44);
        [appLogoImageView setContentMode:UIViewContentModeScaleAspectFit];
        appLogoImageView.tag = 'n';
        UIView *appLogoView = [[UIView alloc] initWithFrame:appLogoImageView.frame];
        [appLogoView addSubview:appLogoImageView];
        return appLogoView;
    }
    return nil;
}

+(BOOL)isArtCircles
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if([bundleIdentifier hasSuffix:@"artCircles"]){
        return YES;
    }
    return NO;
}

+(NSString *)getUpperCaseStringIfNeededForString:(NSString *)normalString
{
    AppLocation currAppLoc = [self getCurrentAppLocation];
    if(currAppLoc == AppLocationDefault){
        return [normalString uppercaseString];
    }else{
        return normalString;
    }
}

@end
