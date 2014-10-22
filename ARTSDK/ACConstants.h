//
//  ACConstants.h
//  ArtAPI
//
//  Created by Doug Diego on 4/19/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
// //

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//#ifdef COCOAPODS_POD_AVAILABLE_ARTSDK
#define ACBundle [NSBundle bundleWithPath:[[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:@"ArtAPI.bundle"]]
#define ARTImage(name) [NSString stringWithFormat:@"ArtAPI.bundle/%@",(name)]
#define ACLocalizedString(key, comment) \
    [[NSBundle bundleWithPath:[[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:@"ArtAPI.bundle"]] localizedStringForKey:(key) value:@"" table:nil]
/*#else
    #define ACBundle [NSBundle mainBundle]
    #define ARTImage(name) (name)
    #define ACLocalizedString(key, comment) NSLocalizedString((key), (comment))
#endif*/


#define ABOUT_URL @"http://cache1.artprintimages.com/images/photostoart/mobile/index.html"
#define ABOUT_URL_IPAD @"http://www.art.com/asp/aboutus/default-asp/_/posters.htm"
#define SHIPPING_DETAILS_URL @"http://www.art.com/asp/customerservice/shipping-asp/_/posters.htm"
#define URL_TERMS_OF_SERVICE @"http://www.art.com/help/terms-of-use.html"
#define Localized_Bundles [NSArray arrayWithObjects:@"com.art.photostoart",@"com.art.myphotos",@"com.art.mesphotos",nil]
#define IS_IOS_7_ABOVE ([[UIDevice currentDevice].systemVersion floatValue] >=7.0f)?YES:NO

#define FACEBOOK_SHARE_CUSTOM_PARAMS @"?utm_medium=social&utm_source=facebook&utm_campaign=ACapp&rfid=220421"
#define FACEBOOK_SHARE_CUSTOM_ADD_PARAMS @"&utm_medium=social&utm_source=facebook&utm_campaign=ACapp&rfid=220421"
#define TWITTER_SHARE_CUSTOM_PARAMS @"?utm_medium=social&utm_source=twitter&utm_campaign=ACapp&rfid=054994"
#define TWITTER_SHARE_CUSTOM_ADD_PARAMS @"&utm_medium=social&utm_source=twitter&utm_campaign=ACapp&rfid=054994"
#define PINTEREST_SHARE_CUSTOM_PARAMS @"?utm_medium=social&utm_source=pinterest&utm_campaign=ACapp&rfid=097383"
#define PINTEREST_SHARE_CUSTOM_ADD_PARAMS @"&utm_medium=social&utm_source=pinterest&utm_campaign=ACapp&rfid=097383"

#define CC_TYPE_AMEX @"0"
#define CC_TYPE_VISA @"5"
#define CC_TYPE_MASTERCARD @"3"
#define CC_TYPE_DISCOVER @"1"

#define NOTIFICATION_CART_UPDATED @"NOTIFICATION_CART_UPDATED"
#define NOTIFICATION_ORDER_COMPLETED @"ORDERCOMPLETED"
#define NOTIFICATION_LOGGEDOUT @"LOGOUT_DONE"


//#define SUPPORT_LILITAB_CARD_READER

// TODO: this is specific to photos to art.  Need to 
typedef enum
{
    AppLocationDefault,
    AppLocationFrench,
    AppLocationGerman,
    AppLocationNone
}AppLocation;

typedef enum
{
    ACCustomSharingTypeFacebook,
    ACCustomSharingTypeTwitter,
    ACCustomSharingTypePinterest
}ACCustomSharingType;

typedef NS_ENUM(NSInteger, ACCheckoutType) {
    ACCheckoutTypeInApp,
    ACCheckoutTypePrintReciept
};

extern NSString *kACStandardFont;
extern NSString *kACNotificationDismissModal;

#define NAV_BAR_HEIGHT 44

#define BUTTON_CLOSE_WIDTH 80
#define BUTTON_CLOSE_HEIGHT 39
#define BUTTON_CLOSE_PADDING 2

#define RATE_APP_DELAY 3.0

#define APP_TINT_COLOR [UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0]

// RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@interface ACConstants : NSObject

+(AppLocation)getCurrentAppLocation;

+(NSString *)getLocalizedStringForKey:(NSString *)key withDefaultValue:(NSString *)defaultValue;
+(UIFont *)getStandardMediumFontWithSize:(CGFloat)size;
+(UIFont *)getStandardBoldFontWithSize:(CGFloat)size;
+(UIButton *)getBackButtonForTitle:(NSString *)backTitle;
+(UIButton *)getGreyBackButtonForTitle:(NSString *)backTitle;
+(UIButton *)getNextButtonForTitle:(NSString *)nextTitle;
+(UIView *)getNavBarLogo;
+(BOOL)isArtCircles;
+(UIImage *)getMiniCartImage;
+(UIColor *)getPrimaryButtonColor;
+(UIColor *)getHomeScreenHoverColor;
+(UIColor *)getSecondaryButtonColor;
+(UIColor *)getPrimaryLinkColor;
+(NSString *)getGATrackingID;
+(UIColor *)getDisabledPrimaryLinkColor;
+(UIColor *)getHighlightedPrimaryLinkColor;
+(NSDictionary *)getHelpShiftTokens;
+(NSString *)getCardIOToken;
+(NSString *)getUpperCaseStringIfNeededForString:(NSString *)normalString;
+(NSString *)getCutomizedUrlForUrl:(NSString *)urlString forType:(ACCustomSharingType)type;

@end

