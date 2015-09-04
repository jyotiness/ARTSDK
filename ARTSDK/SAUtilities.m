//
//  PAAUtilities.m
//  PhotosArt
//
//  Created by BLR-MobilityMac1 on 07/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SAUtilities.h"
#import <QuartzCore/QuartzCore.h>
#import "AccountManager.h"

NSString *kVersion = @"photosToArtCurrentVersion";
NSString *kgalleryQuantNotification = @"GALLERY_QUANTITY_NOTIFICATION";

@implementation SAUtilities
@synthesize dataArray,responseDictionary,galleryAddDictionary,errorMessageSent,currentGalleryItemIndex,mouldingIDArray,frameNamesArray,frameID,currentItemDictionary;

+ (id)sharedUtilities
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


+(NSString *) getEncodedURLForString:(NSString *)thisURL{
    thisURL = [thisURL stringByReplacingOccurrencesOfString:@"://qa-" withString:@"://"];
    
    thisURL = [thisURL stringByReplacingOccurrencesOfString:@"%5c" withString:@"\\"];
    thisURL = [thisURL stringByReplacingOccurrencesOfString:@"%5C" withString:@"\\"];
    thisURL = [thisURL stringByReplacingOccurrencesOfString:@"%5B" withString:@"["];
    thisURL = [thisURL stringByReplacingOccurrencesOfString:@"%5D" withString:@"]"];
    thisURL = [thisURL stringByReplacingOccurrencesOfString:@"%7C" withString:@"|"];
    
    //MKL - replacing GREY corners - HACK
//    thisURL = [thisURL stringByReplacingOccurrencesOfString:@"BKC=FFFFFF" withString:@"BKC=b4b4b4"];
    //thisURL = [thisURL stringByReplacingOccurrencesOfString:@"BKC=FFFFFF" withString:@"BKC=b4b4b4"];
    
    thisURL = [thisURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return thisURL;
}
+(NSString *)networkAvailabilityFailedErrorMessage{
    Reachability *internetReachabilityTest = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachabilityTest currentReachabilityStatus];
    NSString *errorMessage = @"";
    if (networkStatus == NotReachable){
        //MKL added to .strings
        errorMessage = @"Could not connect to the Internet.  Please try again.";
    }else{
        //MKL added to .strings
        errorMessage = @"Request timed out.  Please try again";
    }
    return errorMessage;
   

}

+(void)showComingSoonDialog{
    //MKL added to .strings
    UIAlertView *nextReleaseAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Coming soon in next release" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
    [nextReleaseAlert show];
}


+ (NSString *) formatedPriceFor: (NSNumber *)inPriceValue; {
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey: @"Currency_Code_to_use"])
        [currencyFormatter setCurrencyCode: [[NSUserDefaults standardUserDefaults] objectForKey: @"Currency_Code_to_use"]];
    else [currencyFormatter setCurrencyCode: @"USD"];   
    
    NSString * formatedPrice = [currencyFormatter stringFromNumber: inPriceValue];
//    NSLog(@"The formatted price is %@",formatedPrice);
//    if([formatedPrice hasPrefix:@"$"]){
        formatedPrice = [formatedPrice stringByReplacingOccurrencesOfString:@" " withString:@""];
        formatedPrice = [formatedPrice stringByReplacingOccurrencesOfString:@" " withString:@""];
//    }
    
    return formatedPrice;     
}

+(NSString *)overrideFrameImageSize:(NSString *)frameURL withMaxW:(int)maxWidth withMaxHeight:(int)maxHeight{
    
    NSString *retString = frameURL;
    NSString *overrideString = [NSString stringWithFormat:@"+MXW:%i+MXH:%i", maxWidth, maxHeight, nil];
    
    retString = [retString stringByReplacingOccurrencesOfString:@"+MXW:400+MXH:350" withString:overrideString];
    retString = [retString stringByReplacingOccurrencesOfString:@"+MXW:0+MXH:0" withString:overrideString];
    
    return retString;
    
}

+(void)imageWithShadowForCanvasImageView:(UIImageView *)initialImageView{
    
    //do nothing - per Roberto to not have a shadow on Canvas
    
    /*
    UIImage *initialImage = initialImageView.image;
    CGFloat imageAspectRatio = initialImage.size.width/initialImage.size.height;
    CGFloat imageViewAspectRatio = initialImageView.frame.size.width/initialImageView.frame.size.height;
    bool isAspectGreater = (imageAspectRatio>imageViewAspectRatio)?YES:NO;
    CGFloat incrementFactor = 0.0f;
    bool isWidthGreater = (initialImage.size.width<initialImage.size.height)?NO:YES;
    if(isAspectGreater){
        incrementFactor = 2*(initialImage.size.width/initialImageView.frame.size.width);
    }else{
        incrementFactor = 2*(initialImage.size.height/initialImageView.frame.size.height);
    }
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    if(DO_LOG) NSLog(@"Size is (%f,%f)",initialImage.size.width,initialImage.size.height);
    if(DO_LOG) NSLog(@"Size of the frame is (%f,%f)",initialImageView.frame.size.width,initialImageView.frame.size.height);
    CGContextRef shadowContext = CGBitmapContextCreate(NULL, initialImage.size.width + incrementFactor, initialImage.size.height + incrementFactor, CGImageGetBitsPerComponent(initialImage.CGImage), 0, colourSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    CGContextDrawImage(shadowContext, CGRectMake(0,incrementFactor, initialImage.size.width, initialImage.size.height), initialImage.CGImage);
    
    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
    CGContextRelease(shadowContext);
    
    UIImage * shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
    CGImageRelease(shadowedCGImage);
    initialImageView.image = shadowedImage;
    initialImageView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    initialImageView.layer.shadowOpacity = 0.6f;
//    initialImageView.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    initialImageView.layer.shadowRadius = 1.0f;
    initialImageView.layer.masksToBounds = NO;
    
    CGFloat imageHeight = 0.0f;
    CGFloat imageWidth = 0.0f;
    if(DO_LOG) NSLog(@"Image size is (%f,%f)\n",initialImage.size.width,initialImage.size.height);
    if(DO_LOG) NSLog(@"ImageView size is (%f,%f)\n",initialImageView.frame.size.width,initialImageView.frame.size.height);
    if(isAspectGreater){
        imageWidth = initialImageView.frame.size.width;
        imageHeight = initialImage.size.height*(initialImageView.frame.size.width/initialImage.size.width);
    }else{
        imageWidth = initialImage.size.width*(initialImageView.frame.size.height/initialImage.size.height);
        imageHeight = initialImageView.frame.size.height;
    }
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat triangleDimen = 0;
    if(isWidthGreater){
        triangleDimen = 5;
    }else{
        triangleDimen = 0.05*imageWidth;
    }
    
    if((imageAspectRatio>0.99f)&&(imageAspectRatio<1.01f)){
        triangleDimen = 0.04*imageWidth;
    }
    
    if(isAspectGreater){
        [path moveToPoint:CGPointMake(initialImageView.frame.size.width - 2, initialImageView.center.y - imageHeight/2 + triangleDimen + 2)];
        [path addLineToPoint:CGPointMake(initialImageView.frame.size.width,initialImageView.center.y - imageHeight/2 + triangleDimen + 2 + 2)];
        [path addLineToPoint:CGPointMake(initialImageView.frame.size.width, initialImageView.center.y + imageHeight/2 + 3)];
        [path addLineToPoint:CGPointMake(triangleDimen + 2, initialImageView.center.y + imageHeight/2 + 3)];
        [path addLineToPoint:CGPointMake(initialImageView.center.x - imageWidth/2 + triangleDimen, initialImageView.center.y + imageHeight/2 - triangleDimen)];
        [path addLineToPoint:CGPointMake(initialImageView.frame.size.width - 2, initialImageView.center.y - imageHeight/2 + triangleDimen + 2)];
    }else{
        [path moveToPoint:CGPointMake(initialImageView.center.x + imageWidth/2 - 2, triangleDimen)];
        [path addLineToPoint:CGPointMake(initialImageView.center.x + imageWidth/2, triangleDimen + 2)];
        [path addLineToPoint:CGPointMake(initialImageView.center.x + imageWidth/2, initialImageView.frame.size.height + 2)];
        [path addLineToPoint:CGPointMake(initialImageView.center.x - imageWidth/2 + triangleDimen, initialImageView.frame.size.height + 2)];
        [path addLineToPoint:CGPointMake(initialImageView.center.x - imageWidth/2 + triangleDimen - 2, initialImageView.frame.size.height - 2)];
        [path addLineToPoint:CGPointMake(initialImageView.center.x + imageWidth/2 - 2, triangleDimen)];
    }
    
    initialImageView.layer.shadowPath = path.CGPath;
     
     */
}

+(UIImage*)imageWithShadowForImageView:(UIImageView *)initialImageView {
    UIImage *initialImage = initialImageView.image;
    CGFloat incrementFactor = 0.6*(initialImage.size.width/100);
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef shadowContext = CGBitmapContextCreate(NULL, initialImage.size.width + incrementFactor, initialImage.size.height + incrementFactor, CGImageGetBitsPerComponent(initialImage.CGImage), 0, colourSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    CGContextSetShadowWithColor(shadowContext, CGSizeMake(incrementFactor,-incrementFactor), 6, [UIColor colorWithWhite:0.2 alpha:0.4].CGColor);
    CGContextDrawImage(shadowContext, CGRectMake(0, incrementFactor, initialImage.size.width, initialImage.size.height), initialImage.CGImage);
    
    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
    CGContextRelease(shadowContext);
    
    UIImage * shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
    CGImageRelease(shadowedCGImage);
    
    return shadowedImage;
}

+ (UIImage *)scaleAndRotateImage:(UIImage *)image withMaxRes:(CGFloat) kMaxResolution
{
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution)
    {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            //MKL added to .strings
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

+(AppLocation)getCurrentAppLocation{
    
#ifdef MYPHOTOS
    return AppLocationGerman;
#elif MESPHOTOS
    return AppLocationFrench;
#else
    return AppLocationDefault;
#endif
    
}

+(UIFont *)getStandardMediumFontWithSize:(CGFloat)size{
    
#ifdef PHOTOSTOART
    return [UIFont fontWithName:@"GiorgioSans-Medium" size:size];
#else
    return [UIFont fontWithName:@"FetteEngschrift" size:size];
#endif

}

+(UIFont *)getStandardBoldFontWithSize:(CGFloat)size{
    
#ifdef PHOTOSTOART
    return [UIFont fontWithName:@"GiorgioSans-Bold" size:size];
#else
    return [UIFont fontWithName:@"FetteEngschrift" size:size];
#endif
    
}

+(NSString *)getAppleSoftwareID{
#ifdef MYPHOTOS
    return @"680293532";
#elif MESPHOTOS
    return @"680292917";
#elif PHOTOSTOART
    return @"576093128";
#elif SWITCHART
    return @"920984366";
#else
    return @"576093128";
#endif
}

+(NSString *)getWebsiteDisplayName{
#ifdef MYPHOTOS
    return @"Allposters.de";
#elif MESPHOTOS
    return @"Allposters.fr";
#elif PHOTOSTOART
    return @"Art.com";
#else
    return @"Art.com";
#endif
}

+(NSString*)getShareMessageUsesURL:(BOOL)withURL usesHtml:(BOOL)withHtml usesTwitter:(BOOL)usesTwitter
{
    /*
    NSString *iTunesURL = nil;
    NSString *appName = nil;
    
#ifdef MYPHOTOS
    iTunesURL = ITUNES_URL_MYPHOTOS;
    appName = @"MyPhotos";
#elif MESPHOTOS
    iTunesURL = ITUNES_URL_MESPHOTOS;
    appName = @"MesPhotos";
#else
    iTunesURL = ITUNES_URL_PHOTOSTOART;
    appName = @"PhotosToArt";
#endif
    
    NSString *shareText = [NSString stringWithFormat:NSLocalizedString(@"DEFAULT_SHARE_TEXT_NO_URL", nil),appName];
    
    if(usesTwitter){
        shareText = [NSString stringWithFormat:NSLocalizedString(@"TWITTER_SHARE_TEXT1", nil),appName,iTunesURL];
    }else{
        if(withURL){
            if(withHtml){
                shareText = [NSString stringWithFormat:@"<p>%@ <a href='%@'>iTunes Store</a>",shareText,iTunesURL];
            }else{
                shareText = [shareText stringByAppendingString:iTunesURL];
            }
        }
    }
    
    return shareText; */ //Jobin : TBR
    
    return nil;
    
}

+(UIImage *)getButtonImageForSize:(int) size withColor:(ACButtonColor) buttonColor isSelected:(BOOL) isSelected{
    
    //this returns the right button based on size, color and whether it is selected
    UIImage *retImage = nil;
    
    switch(buttonColor){
        case ButtonColorGrey:
            if (size > 0 && size < 80){
                //use the 75
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_75.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_SELECTED_75.png"];
                }
            }else if (size >= 80 && size < 110){
                //use the 90
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_90.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_SELECTED_90.png"];
                }
            }else if (size >= 120 && size < 140){
                //use the 120
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_120.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_SELECTED_120.png"];
                }
            }else if (size > 140){
                //use the 150
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_150.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_SELECTED_150.png"];
                }
            }else{
                //use the 90
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_90.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_SELECTED_90.png"];
                }
            }
            break;
        case ButtonColorBlue:
            if (size > 0 && size < 80){
                //use the 75
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_BLUE_75.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_BLUE_SELECTED_75.png"];
                }
            }else if (size >= 80 && size < 110){
                //use the 90
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_BLUE_90.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_BLUE_SELECTED_90.png"];
                }
            }else if (size >= 120 && size < 140){
                //use the 120
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_BLUE_120.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_BLUE_SELECTED_120.png"];
                }
            }else if (size > 140){
                //use the 150
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_BLUE_150.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_BLUE_SELECTED_150.png"];
                }
            }else{
                //use the 90
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_BLUE_90.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_BLUE_SELECTED_90.png"];
                }
            }
            break;
        case ButtonColorGreen:
            if (size > 0 && size < 80){
                //use the 75
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREEN_75.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREEN_SELECTED_75.png"];
                }
            }else if (size >= 80 && size < 110){
                //use the 90
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREEN_90.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREEN_SELECTED_90.png"];
                }
            }else if (size >= 120 && size < 140){
                //use the 120
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREEN_120.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREEN_SELECTED_120.png"];
                }
            }else if (size > 140){
                //use the 150
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREEN_150.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREEN_SELECTED_150.png"];
                }
            }else{
                //use the 90
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREEN_90.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREEN_SELECTED_90.png"];
                }
            }
            break;
        default:
            if (size > 0 && size < 80){
                //use the 75
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_75.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_SELECTED_75.png"];
                }
            }else if (size >= 80 && size < 110){
                //use the 90
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_90.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_SELECTED_90.png"];
                }
            }else if (size >= 120 && size < 140){
                //use the 120
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_120.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_SELECTED_120.png"];
                }
            }else if (size > 140){
                //use the 150
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_150.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_SELECTED_150.png"];
                }
            }else{
                //use the 90
                if(!isSelected){
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_90.png"];
                }else{
                    retImage = [UIImage imageNamed:@"TOP_NAV_BUTTONS_GREY_SELECTED_90.png"];
                }
            }
            break;
    }
    
    return retImage;
}

+(NSString *)getKeyChainServiceName
{
    AppLocation currAppLoc = [self getCurrentAppLocation];
    NSString *serviceName = nil;
    switch (currAppLoc) {
        case AppLocationDefault:{
            serviceName = @"ART_SERICE_KEY";
            break;
        }
        case AppLocationFrench:{
            serviceName = @"MESPHOTOS_SERVICE_KEY";
            break;
        }
        case AppLocationGerman:{
            serviceName = @"MYPHOTOS_SERVICE_KEY";
            break;
        }
        default:{
            serviceName = @"ART_SERICE_KEY";
            break;
        }
    }
    return serviceName;
}

+(NSString *)getAPNumForWorkingPack:(NSDictionary *)packDict{
    
    if(!packDict) return @"";
    
    NSString *apnum = [packDict objectForKey:@"APNUM"];
    
    if(!apnum)apnum = @"";
    
    return apnum;
    
}

+(NSString *)getUUID
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    
    return uuidString;
}

+(NSString *)getPODConfigForWorkingPack:(NSDictionary *)packDict{
    
    if(!packDict) return @"";
    
    NSString *podConfigID = @"";
    
    NSDictionary *termsDict = [packDict objectForKey:@"terms"];
    
    if(termsDict){
        NSDictionary *sizeDict = [termsDict objectForKey:@"size"];
        if(sizeDict){
            podConfigID = [sizeDict objectForKey:@"configId"];
        }
    }
    
    return podConfigID;
    
}


+(NSString *)getNameOfWorkingPack:(NSDictionary *)packDict{
    
    if(!packDict) return @"";
    
    NSString *packName = [packDict objectForKey:@"name"];
    
    if(packName){
        return packName;
    }else{
        return @"";
    }
    
}

+(float)getAspectRatioForWorkingPack:(NSDictionary *)packDict{
    
    if(!packDict) return 1.0f;
    
    NSDictionary *termsDict = [packDict objectForKey:@"terms"];
    NSDictionary *sizeDict;
    
    if(termsDict){
        
        sizeDict = [termsDict objectForKey:@"size"];
        
        if(sizeDict){
            NSString *heightString = [sizeDict objectForKeyNotNull:@"height"];
            NSString *widthString = [sizeDict objectForKeyNotNull:@"width"];
            
            
            if(heightString && widthString){
                float height = [heightString floatValue];
                float width = [widthString floatValue];
                
                if(height == 0.0f || width == 0.0f) return 1.0f;
                
                if(height > width){
                    return width / height;
                }else{
                    return height / width;
                }
            }
        }
        
    }
    
    return 1.0f;
    
}

+(SAImageOrientation)getDefaultOrientationForWorkingPack:(NSDictionary *)packDict{
    
    if(!packDict) return OrientationLandscape;
    
    NSDictionary *termsDict = [packDict objectForKey:@"terms"];
    NSDictionary *sizeDict;
    
    if(termsDict){
        
        sizeDict = [termsDict objectForKey:@"size"];
        
        NSString *heightString = [sizeDict objectForKeyNotNull:@"height"];
        NSString *widthString = [sizeDict objectForKeyNotNull:@"width"];
        
        
        if(heightString && widthString){
            int height = [heightString intValue];
            int width = [widthString intValue];
            
            if(height == width){
                return OrientationSquare;
            }else{
                return OrientationLandscape;
            }
        }
        
    }
    
    return OrientationLandscape;
    
}


+(UIButton *)getBuyButtonForTitle:(NSString *)buyTitle
{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    float buttonW = 48.0f;
    float buttonH = 29.0f;
    
    button.frame = CGRectMake(0, 0, buttonW, buttonH);
    [button.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitleColor:[SAUtilities getPrimaryButtonColor] forState:UIControlStateNormal];
    [button setTitleColor:[SAUtilities getDisabledButtonColor] forState:UIControlStateDisabled];
    [button setTitleColor:[SAUtilities getHighlightedButtonColor] forState:UIControlStateHighlighted];
    
    [button setTitle:buyTitle forState:UIControlStateNormal];

    CALayer *layer = button.layer;
    layer.backgroundColor = [[UIColor clearColor] CGColor];
    layer.borderColor = [button.titleLabel.textColor CGColor];
    layer.cornerRadius = 5.0f;
    layer.borderWidth = 1.0f;
    
    return button;
}

+(UIButton *)getNextButtonForTitle:(NSString *)nextTitle
{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *normalBackground = [[UIImage imageNamed:ARTImage(@"chevronBlueRight40")] stretchableImageWithLeftCapWidth:20 topCapHeight:0];

    [button setBackgroundImage:normalBackground forState:UIControlStateNormal];

    CGSize size = [nextTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];

    button.frame = CGRectMake(0, 0, size.width + 20, 20);
    [button.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    button.titleLabel.textAlignment = NSTextAlignmentRight;
    [button setTitleColor:[SAUtilities getPrimaryButtonColor] forState:UIControlStateNormal];
    [button setTitleColor:[SAUtilities getDisabledButtonColor] forState:UIControlStateDisabled];
    [button setTitleColor:[SAUtilities getHighlightedButtonColor] forState:UIControlStateHighlighted];
    
    [button setTitle:nextTitle forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(1, 0, 0, 18);
    return button;
}


+(UIButton *)getBackButtonForTitle:(NSString *)backTitle
{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *normalBackground = [[UIImage imageNamed:ARTImage(@"chevronBlue40")] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    UIImage *selectedBackground = [[UIImage imageNamed:ARTImage(@"chevronBlue40")] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    
    [button setBackgroundImage:normalBackground forState:UIControlStateNormal];
    [button setBackgroundImage:selectedBackground forState:UIControlStateHighlighted];
    
    CGSize size = [backTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];

    button.frame = CGRectMake(0, 0, size.width + 20, 20);
    [button.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];

    [button setTitleColor:[SAUtilities getPrimaryButtonColor] forState:UIControlStateNormal];
    [button setTitleColor:[SAUtilities getDisabledButtonColor] forState:UIControlStateDisabled];
    [button setTitleColor:[SAUtilities getHighlightedButtonColor] forState:UIControlStateHighlighted];
    
    [button setTitle:backTitle forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(1, 18, 0, 0);
    return button;
}

+(UIColor *)getPrimaryButtonColor
{
    return [UIColor colorWithRed:57.0/255 green:182.0/255 blue:229.0/255 alpha:1.0];
}

+(UIColor *)getHighlightedButtonColor
{
    return [UIColor colorWithRed:0.196 green:0.475 blue:0.573 alpha:1.000];
}

+(UIColor *)getDisabledButtonColor
{
    return [UIColor colorWithRed:146.0/255 green:212.0/255 blue:234.0/255 alpha:1.0];
}

+(UIImage *)cropImage:(UIImage *)image ToAspectRatio:(SAImageOrientation)imageOrientation withAspectDecimal:(float)aspectDecimal{
    
    CGRect cropRect;
    float origW = image.size.width;
    float origH = image.size.height;
    
    switch(imageOrientation){
        case OrientationSquare:
            
            if(origW == origH){
                //original is square
                cropRect = CGRectMake(0, 0, round(origW), round(origH));
            }else if(origW > origH){
                //original is landscape
                float cropAmount = round((origW - origH) / 2);
                cropRect = CGRectMake(cropAmount, 0, origH, origH);
            }else{
                //original is portrait
                float cropAmount = round((origH - origW) / 2);
                cropRect = CGRectMake(0, cropAmount, origW, origW);
            }
            
            break;
        case OrientationLandscape:
            
            if(origW == origH){
                //original is square
                float newH = (origW * aspectDecimal);
                float cropAmount = round((origH - newH) / 2);
                cropRect = CGRectMake(0, cropAmount, origW, round(newH));
            }else if(origW > origH){
                //original is landscape
                
                float origAspect = origH / origW;
                
                if(origAspect > aspectDecimal){
                    //image is too square - crop off top and bottom
                    float newH = (origW * aspectDecimal);
                    float cropAmount = round((origH - newH) / 2);
                    cropRect = CGRectMake(0, cropAmount, origW, round(newH));
                    
                }else{
                    //image is too panoramic - crop off left and right
                    float newW = (origH / aspectDecimal);
                    float cropAmount = round((origW - newW) / 2);
                    cropRect = CGRectMake(cropAmount, 0, round(newW), origH);
                }
                
            }else{
                //original is portrait - always crop top and bottom
                
                float newH = (origW * aspectDecimal);
                float cropAmount = round((origH - newH) / 2);
                cropRect = CGRectMake(0, cropAmount, origW, round(newH));

            }
            
            break;
        case OrientationPortrait:
            
            if(origW == origH){
                //original is square
                float newW = (origH * aspectDecimal);
                float cropAmount = round((origW - newW) / 2);
                cropRect = CGRectMake(cropAmount, 0, round(newW), origH);
            }else if(origW > origH){
                //original is landscape - always crop left and right
                
                float newW = (origH * aspectDecimal);
                float cropAmount = round((origW - newW) / 2);
                cropRect = CGRectMake(cropAmount, 0, round(newW), origH);
                
            }else{
                //original is portrait
                
                float origAspect = origW / origH;
                
                if(origAspect > aspectDecimal){
                    //image is too square - crop off left and right
                    float newW = (origH * aspectDecimal);
                    float cropAmount = round((origW - newW) / 2);
                    cropRect = CGRectMake(cropAmount, 0, round(newW), origH);
                    
                }else{
                    //image is too panoramic - crop off left and right

                    float newH = (origW / aspectDecimal);
                    float cropAmount = round((origH - newH) / 2);
                    cropRect = CGRectMake(0, cropAmount, origW, round(newH));
                }
                
            }
            
            break;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

+(BOOL)isTabBarShowing
{
    return [[AccountManager sharedInstance] isLoggedInForSwitchArt];
}


@end
