//
//  Analytics.h
//  ArtAPI
//
//  Created by Mike Larson
//  Copyright 2013 Art.com, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark Event Names

//only general tracking strings - App specific ones are in teh AppAnalytics in the
//specific project which is referencing the ArtAPI

#define ANALYTICS_CATEGORY_UI_ACTION                    @"UI ACTION"
#define ANALYTICS_CATEGORY_ERROR_EVENT                  @"Error Event"

#define ANALYTICS_EVENT_NAME_LOGIN                      @"Log in"
#define ANALYTICS_EVENT_NAME_LOGIN_EMAIL                @"Log in Email"
#define ANALYTICS_EVENT_NAME_LOGIN_FACEBOOK             @"Log in Facebook"
#define ANALYTICS_EVENT_NAME_CREATE_ACCOUNT             @"Create Account"
#define ANALYTICS_EVENT_NAME_FORGOT_PASSWORD            @"Forgot Password"
#define ANALYTICS_EVENT_NAME_INFO_BUTTON_PRESSED        @"Info button pressed"
#define ANALYTICS_EVENT_NAME_LOGIN_FAILED               @"Log in Failed"

#define ANALYTICS_EVENT_NAME_PLACE_ORDER                @"Place order pressed"
#define ANALYTICS_EVENT_NAME_ORDER_CONFIRM_SHOWN        @"Order confirmation shown"

#define ANALYTICS_EVENT_NAME_BUY_BUTTON_PRESSED         @"Buy button pressed"
#define ANALYTICS_EVENT_NAME_SHIPPING_ADDRESS_CONTINUE  @"Shipping address continue button pressed"
#define ANALYTICS_EVENT_NAME_SHIPPING_METHOD_CONTINUE   @"Shipping method continue button pressed"

#define ANALYTICS_EVENT_NAME_APPLY_COUPON               @"Apply coupon pressed"
#define ANALYTICS_EVENT_NAME_REMOVE_COUPON              @"Remove coupon pressed"

#define ANALYTICS_EVENT_NAME_SCAN_CARD_PRESS            @"Scan card - scan pressed"
#define ANALYTICS_EVENT_NAME_SCAN_CARD_DONE             @"Scan card - done pressed"
#define ANALYTICS_EVENT_NAME_SCAN_CARD_CANCEL           @"Scan card - cancel pressed"

#define ANALYTICS_EVENT_NAME_LILITAB_SWIPE              @"LiliTab - card swiped"
#define ANALYTICS_EVENT_NAME_LILITAB_CARD_INVALID       @"LiliTab - card not supported"


#define ANALYTICS_EVENT_NAME_GALAXY_BUTTON_CLICKED      @"Galaxy button clicked"
#define ANALYTICS_EVENT_NAME_SETUP_BUTTON_CLICKED       @"Setup button clicked"
#define ANALYTICS_EVENT_NAME_GALLERY_VIEWED             @"Gallery viewed"
#define ANALYTICS_EVENT_NAME_FAVORITE_GALLERY_VIEWED    @"Favorite gallery viewed"
#define ANALYTICS_EVENT_NAME_OWN_PROFILE_VIEWED         @"Own Profile viewed"
#define ANALYTICS_EVENT_NAME_EXTERNAL_LINK_CLICKED      @"External link clicked"
#define ANALYTICS_EVENT_NAME_ITEM_ADDED_TO_FAVORITES    @"Item added to favorites"
#define ANALYTICS_EVENT_NAME_GALLERY_ADDED_TO_BOOKMARKS @"Gallery added to bookmarks"
#define ANALYTICS_EVENT_NAME_GALLERY_SHARED             @"Gallery shared"
#define ANALYTICS_EVENT_NAME_AUDIO_PLAYED               @"Audio played"
#define ANALYTICS_EVENT_NAME_VISUALIZER                 @"Visualizer"
#define ANALYTICS_EVENT_NAME_FAVORITE_GALLERY_CREATED   @"Favorite gallery created"
#define ANALYTICS_EVENT_NAME_WHEEL_VIEWED               @"Wheel viewed"
#define ANALYTICS_EVENT_NAME_INFO_AUTHOR_VIEWED         @"Info author viewed"
#define ANALYTICS_EVENT_NAME_INFO_PRODUCT_VIEWED        @"Info product viewed"
#define ANALYTICS_EVENT_NAME_WHEEL_CLICKED              @"Wheel clicked"
#define ANALYTICS_EVENT_NAME_ITEM_FRAME                 @"Item frame"
#define ANALYTICS_EVENT_NAME_ITEM_ADDED_TO_CART         @"Item add to cart"
#define ANALYTICS_EVENT_NAME_INITIATE_CHECKOUT          @"Initiated checkout"
#define ANALYTICS_EVENT_NAME_ORDER_CONFIRM              @"Order confirmed"
#define ANALYTICS_EVENT_NAME_APP_LAUNCHED               @"App launched"
#define ANALYTICS_EVENT_NAME_APP_RETURN_FROM_BKGND      @"App return from background"
#define ANALYTICS_EVENT_NAME_CACHE_REFRESH              @"Cache refreshed"

//SA
#define ANALYTICS_EVENT_NAME_CAMERA_ROLL_BUTTON_PRESSED @"CameraRoll button pressed"
#define ANALYTICS_EVENT_NAME_TAKE_PHOTO_BUTTON_PRESSED  @"TakePhoto button pressed"
#define ANALYTICS_EVENT_NAME_INSTAGRAM_BUTTON_PRESSED   @"Instagram button pressed"
#define ANALYTICS_EVENT_NAME_FACEBOOK_BUTTON_PRESSED    @"Facebook button pressed"
#define ANALYTICS_EVENT_NAME_CART_BUTTON_PRESSED        @"Cart button pressed"
#define ANALYTICS_EVENT_NAME_LOGIN_BUTTON_PRESSED       @"Login button pressed"
#define ANALYTICS_EVENT_NAME_SIGNUP_BUTTON_PRESSED      @"SignUp button pressed"
#define ANALYTICS_EVENT_NAME_PACKS_BUTTON_PRESSED       @"Packs button pressed"

#define ANALYTICS_EVENT_NAME_HELP_SCREEN_1              @"Viewed Help Screen 1"
#define ANALYTICS_EVENT_NAME_HELP_SCREEN_2              @"Viewed Help Screen 2"
#define ANALYTICS_EVENT_NAME_HELP_SCREEN_3              @"Viewed Help Screen 3"
#define ANALYTICS_EVENT_NAME_HELP_SCREEN_4              @"Viewed Help Screen 4"
#define ANALYTICS_EVENT_NAME_SKIP_BUTTON_PRESSED        @"Skip button pressed"
#define ANALYTICS_EVENT_NAME_GOTIT_BUTTON_PRESSED       @"GotIt button pressed"

#define ANALYTICS_EVENT_NAME_TABBAR_HOME                @"Tapped Home Tab"
#define ANALYTICS_EVENT_NAME_TABBAR_PACKS               @"Tapped Packs Tab"
#define ANALYTICS_EVENT_NAME_TABBAR_HELP                @"Tapped Help Tab"
#define ANALYTICS_EVENT_NAME_TABBAR_ACCOUNT             @"Tapped Account Tab"

#define ANALYTICS_EVENT_NAME_LANDSCAPE_BUTTON_PRESSED    @"Landscape button pressed"
#define ANALYTICS_EVENT_NAME_PORTRAIT_BUTTON_PRESSED     @"Portrait button pressed"
#define ANALYTICS_EVENT_NAME_SQUARE_BUTTON_PRESSED       @"Square button pressed"

#define ANALYTICS_EVENT_NAME_EDIT_IMAGE_BUTTON_PRESSED   @"Edit image button pressed"
#define ANALYTICS_EVENT_NAME_REVERT_IMAGE_BUTTON_PRESSED @"Revert image button pressed"

#define ANALYTICS_EVENT_NAME_VIEW_TERMS_FROM_PACK             @"Viewed terms and conditions (pack)"
#define ANALYTICS_EVENT_NAME_VIEW_TERMS_FROM_ACCOUNT             @"Viewed terms and conditions (account)"

#define ANALYTICS_EVENT_NAME_BUNDLE_DRAWER_OPEN             @"Open Bundle Config Drawer"
#define ANALYTICS_EVENT_NAME_BUNDLE_DRAWER_CLOSE             @"Close Bundle Config Drawer"

#define ANALYTICS_EVENT_NAME_BUNDLE_HELP_BUTTON_PRESSED    @"Bundle Help Button Pressed"

#define ANALYTICS_EVENT_NAME_ADD_BUNDLE_TO_CART_PRESSED    @"Add Bundle To Cart Pressed"
#define ANALYTICS_EVENT_NAME_ADD_PRINT_ONLY_EXISTING_TO_CART_PRESSED    @"Add Print Only To Existing Pack To Cart Pressed"
#define ANALYTICS_EVENT_NAME_ADD_PRINT_ONLY_NEW_TO_CART_PRESSED    @"Add Print Only To New Pack To Cart Pressed"

#define ANALYTICS_EVENT_NAME_RENAME_PACK_ON_ORDER_CONFIRM    @"Rename Pack on Order Confirmation Pressed"
#define ANALYTICS_EVENT_NAME_RENAME_PACK_ON_PACK_EDIT    @"Rename Pack on Order Confirmation Pressed"

#define ANALYTICS_EVENT_NAME_CHANGE_ACCOUNT_NAME    @"Edit account name"
#define ANALYTICS_EVENT_NAME_CHANGE_PACK_NAME    @"Edit pack name"
#define ANALYTICS_EVENT_NAME_CHANGE_PACK_ADDRESS    @"Edit pack shipping address"

#define ANALYTICS_EVENT_NAME_BUNDLE_SELECT_FRAME    @"Frame Selection Button Pressed"
#define ANALYTICS_EVENT_NAME_BUNDLE_SELECT_SIZE    @"Pack Size Selection Button Pressed"
#define ANALYTICS_EVENT_NAME_BUNDLE_SELECT_COUNT    @"Pack Count Selection Button Pressed"


#define ANALYTICS_EVENT_NAME_NOTIFICATION_RECIEVED      @"Notification recieved"
#define ANALYTICS_EVENT_NAME_SIMPLE_NOTIFICATION               @"Simple Notification"
#define ANALYTICS_EVENT_NAME_URLLINK_NOTIFICATION_RECIEVED     @"Link Notification"
#define ANALYTICS_EVENT_NAME_CIRCLE_LANDING_NOTIFICATION       @"Circle Landing Notification"
#define ANALYTICS_EVENT_NAME_GALLERY_LANDING_NOTIFICATION      @"Gallery Landing Notification"

#define ANALYTICS_EVENT_NAME_ITEM_SHARE_CANCELED          @"Item Share Canceled"
#define ANALYTICS_EVENT_NAME_MOST_LOVED_VIEWED            @"Most Loved Circle viewed"
#define ANALYTICS_EVENT_NAME_FEATURED_FEED_VIEWED         @"Featured Feed viewed"
#define ANALYTICS_EVENT_NAME_EVERYONE_FEED_VIEWED         @"Everyone Feed viewed"

#define ANALYTICS_EVENT_NAME_FOLLOW_CLICKED               @"Follow Clicked"
#define ANALYTICS_EVENT_NAME_UNFOLLOW_CLICKED             @"Unfollow Clicked"
#define ANALYTICS_EVENT_NAME_ADD_FOLLOW                   @"Add Follow"
#define ANALYTICS_EVENT_NAME_REMOVE_FOLLOW                @"Remove Follow"
#define ANALYTICS_EVENT_NAME_PROFILE_VIEW                 @"Profile Viewed"

//error related
#define ANALYTICS_APIERRORCODE                               @"ErrorCode"
#define ANALYTICS_APIURL                                     @"APIURL"
#define ANALYTICS_APIERRORMESSAGE                            @"ErrorMessage"
#define ANALYTICS_APIRESPONSETYPE                            @"APIResponseType"


@interface Analytics : NSObject {

}

+ (void)startSession:(NSString *)apiKey withSecret:(NSString *)secret;
+ (void)startSession:(NSString *)apiKey withSecret:(NSString *)secret withLaunchOptions:(NSDictionary *)launchOptions;
+ (void)endSession;
+ (void)restartSession:(NSString *)apiKey withSecret:(NSString *)secret;
+ (void)logEvent:(NSString *)eventName;
+ (void)logEvent:(NSString *)eventName withParams:(NSDictionary *)params;

+ (void)startGASession:(NSString *)trackingID;
+ (void)logGAEvent:(NSString *)categoryName withAction:(NSString *)actionString;
+ (void)logGAEvent:(NSString *)categoryName withAction:(NSString *)actionString withLabel:(NSString *)labelString;
+ (void)logGAEvent:(NSString *)categoryName withAction:(NSString *)actionString withParams:(id)params;
+ (void)logGAEvent:(NSString *)categoryName withAction:(NSString *)actionString withLabel:(NSString *)labelString withValue:(NSNumber *)numberValue;
+ (void)logGARevenueEvent:(NSString *)oid withRevenue:(NSNumber *)revenue withTax:(NSNumber *)tax withShipping:(NSNumber *)shipping withCurrencyCode:(NSString *)currencyCode;
+ (void)logGACartItemEventWithTransactionID:(NSString *)oid forName:(NSString *)name withSku:(NSString *)sku forCategory:(NSString *)category atPrice:(NSNumber *)price forQuantity:(NSInteger)quantity havingCurrencyCode:(NSString *)currencyCode;

@end
