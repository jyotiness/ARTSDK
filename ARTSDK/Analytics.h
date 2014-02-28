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

#define ANALYTICS_EVENT_NAME_LOGIN                      @"Log in"
#define ANALYTICS_EVENT_NAME_LOGIN_EMAIL                @"Log in Email"
#define ANALYTICS_EVENT_NAME_LOGIN_FACEBOOK             @"Log in Facebook"
#define ANALYTICS_EVENT_NAME_CREATE_ACCOUNT             @"Create Account"
#define ANALYTICS_EVENT_NAME_FORGOT_PASSWORD            @"Forgot Password"
#define ANALYTICS_EVENT_NAME_INFO_BUTTON_PRESSED        @"Info button pressed"

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
#define ANALYTICS_EVENT_NAME_EXTERNAL_LINK_CLICKED      @"External link clicked"
#define ANALYTICS_EVENT_NAME_ITEM_ADDED_TO_FAVORITES    @"Item added to favorites"
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

#define ANALYTICS_EVENT_NAME_NOTIFICATION_RECIEVED      @"Notification recieved"
#define ANALYTICS_EVENT_NAME_SIMPLE_NOTIFICATION             @"Simple Notification"
#define ANALYTICS_EVENT_NAME_URLLINK_NOTIFICATION_RECIEVED     @"Link Notification"
#define ANALYTICS_EVENT_NAME_CIRCLE_LANDING_NOTIFICATION       @"Circle Landing Notification"
#define ANALYTICS_EVENT_NAME_GALLERY_LANDING_NOTIFICATION      @"Gallery Landing Notification"

#define ANALYTICS_EVENT_NAME_ITEM_SHARE_CANCELED @"Item Share Canceled"


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