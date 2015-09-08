//
//  PAAUtilities.h
//  PhotosArt
//
//  Created by BLR-MobilityMac1 on 07/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "ACConstants.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_4 (IS_IPHONE &&[[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_IPHONE_6P (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

#define GET_BANNERS_SUCCEEDED @"GET_BANNERS_SUCCEEDED"
#define GET_BANNERS_FAILED @"GET_BANNERS_FAILED"
#define AVIARY_PROCESS_HIRES_SUCCEEDED @"AVIARY_PROCESS_HIRES_SUCCEEDED"

#define USE_AVIARY YES

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define DO_LOG NO
#define USE_AVIARY YES
#define THUMBNAIL_MIN_DIMENSION 130
#define INSTAGRAM_MAX_MEDIA 32
#define INSTAGRAM_MIN_TIMESTAMP 1104537600
#define OVERRIDE_MAX_WIDTH 750
#define OVERRIDE_MAX_HEIGHT 750
#define MAX_AVIARY_PIXEL_DIM 5500
#define IS_LOGIN_ENABLED NO
#define JPG_COMPRESSION 1.0

typedef enum {
    ButtonColorGrey,
    ButtonColorBlue,
    ButtonColorGreen
} ACButtonColor;

typedef enum {
    CartItemTypeBundle,
    CartItemTypeFrame,
    CartItemTypePrint,
    CartItemTypeOther
} SACartItemType;

typedef enum {
    OrientationLandscape = 0,
    OrientationPortrait = 1,
    OrientationSquare = 2
} SAImageOrientation;


@interface SAUtilities : NSObject

@property(nonatomic,copy) NSArray *dataArray;
@property(nonatomic,copy) NSDictionary *responseDictionary;
@property(nonatomic,copy) NSDictionary *galleryAddDictionary;
@property(nonatomic,retain) NSString *errorMessageSent;
@property(nonatomic,assign) int currentGalleryItemIndex;
@property(nonatomic,copy) NSMutableArray *mouldingIDArray;
@property(nonatomic,copy) NSMutableArray *frameNamesArray;
@property(nonatomic,retain) NSNumber *frameID;
@property(nonatomic, retain) NSDictionary *currentItemDictionary;



+ (id)sharedUtilities;

+(NSString *) getEncodedURLForString:(NSString *)thisURL;
+(NSString *)networkAvailabilityFailedErrorMessage;

+(void)showComingSoonDialog;

+ (NSString *) formatedPriceFor: (NSNumber *)inPriceValue;

+(UIImage*)imageWithShadowForImageView:(UIImageView *)initialImageView;
+(void)imageWithShadowForCanvasImageView:(UIImageView *)initialImageView;
+ (UIImage *)scaleAndRotateImage:(UIImage *)image withMaxRes:(CGFloat ) kMaxResolution;
+(NSString *)overrideFrameImageSize:(NSString *)frameURL withMaxW:(int)maxWidth withMaxHeight:(int)maxHeight;
+(AppLocation)getCurrentAppLocation;

+(UIFont *)getStandardMediumFontWithSize:(CGFloat)size;
+(UIFont *)getStandardBoldFontWithSize:(CGFloat)size;

+(NSString *)getAppleSoftwareID;
+(NSString *)getWebsiteDisplayName;

+(NSString*)getShareMessageUsesURL:(BOOL)withURL usesHtml:(BOOL)withHtml usesTwitter:(BOOL)usesTwitter;

+(UIImage *)getButtonImageForSize:(int) size withColor:(ACButtonColor) buttonColor isSelected:(BOOL) isSelected;

+(NSString *)getKeyChainServiceName;
+(UIButton *)getNextButtonForTitle:(NSString *)nextTitle;
+(UIButton *)getBackButtonForTitle:(NSString *)backTitle;
+(UIButton *)getBuyButtonForTitle:(NSString *)buyTitle;
+(UIColor *)getPrimaryButtonColor;
+(UIColor *)getHighlightedButtonColor;
+(UIColor *)getDisabledButtonColor;
+(UIImage *)cropImage:(UIImage *)image ToAspectRatio:(SAImageOrientation)imageOrientation withAspectDecimal:(float)aspectDecimal;

//CS;== SwitchArt TabBar related Method's
+(BOOL)isTabBarShowing;
+(SAImageOrientation)getDefaultOrientationForWorkingPack:(NSDictionary *)packDict;
+(float)getAspectRatioForWorkingPack:(NSDictionary *)packDict;
+(NSString *)getPODConfigForWorkingPack:(NSDictionary *)packDict;
+(NSString *)getNameOfWorkingPack:(NSDictionary *)packDict;
+(NSString *)getAPNumForWorkingPack:(NSDictionary *)packDict;
+(NSString *)getUUID;

@end
