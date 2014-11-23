//
//  ArtAPI.h
//  ArtAPI
//
//  Created by Doug Diego on 3/7/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACSDKAvailability.h"
#import "ACNonEmptyCollectionTesting.h"
#import "NSDictionary+Additions.h"
#import "ACConstants.h"

//Gallery Visibility Enum from http://dev-api.art.com/docs/html/ed1e8418-f199-e9bf-0a0a-79f719ca47e6.htm
typedef const NSString* ACCGalleryVisibility;
static ACCGalleryVisibility ACCGalleryVisibilityPublic __attribute__((unused))  =  @"Public";
static ACCGalleryVisibility ACCGalleryVisibilityPrivate __attribute__((unused)) = @"Private";
static ACCGalleryVisibility ACCGalleryVisibilityRestricted __attribute__((unused)) = @"Restricted";

//Shipping Priority Enumeration from http://dev-api.art.com/docs/html/ed1e8418-f199-e9bf-0a0a-79f719ca47e6.htm
typedef const NSString* ACCShippingPriority;
static ACCGalleryVisibility ACCShippingPriorityStandard __attribute__((unused)) = @"Standard";
static ACCGalleryVisibility ACCShippingPriorityExpedited __attribute__((unused)) = @"Expedited";
static ACCGalleryVisibility ACCShippingPriorityOvernight __attribute__((unused)) = @"Overnight";


//Card Type Enumeration from
typedef const NSString* ACCCardType;
static ACCCardType ACCCardTypeAMERICAN_EXPRESS __attribute__((unused)) = @"AMERICAN_EXPRESS";
static ACCCardType ACCCardTypeDISCOVER __attribute__((unused)) = @"DISCOVER";
static ACCCardType ACCCardTypeJCB __attribute__((unused)) = @"CardTypeJCB";
static ACCCardType ACCCardTypeMASTERCARD __attribute__((unused)) = @"MASTERCARD";
static ACCCardType ACCCardTypeSWITCH_SOLO __attribute__((unused)) = @"SWITCH_SOLO";
static ACCCardType ACCCardTypeVISA __attribute__((unused)) = @"VISA";

@interface ArtAPI : NSObject

@property (readwrite, nonatomic, copy) NSString *apiKey;
@property (readwrite, nonatomic, copy) NSString *applicationId;
@property (readwrite, nonatomic, copy) NSString *twoDigitISOLanguageCode;
@property (readwrite, nonatomic, copy) NSString *twoDigitISOCountryCode;
@property (nonatomic, strong) NSString *authenticationToken;
@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic,retain) NSString *persistentID;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSDictionary *cart;
@property (nonatomic, copy) NSString *currentYear;
@property (nonatomic, copy) NSString *currentMonth;
@property (nonatomic, assign) CGFloat smallSidePixelMin;
@property (nonatomic, assign) CGFloat largeSidePixelMin;
@property (nonatomic, assign) CGFloat currentAspectRatio;
@property (nonatomic, retain) NSNumber *uploadJPGQuality;
@property (nonatomic, retain) NSString *galleryItemsCount;

@property (nonatomic, assign) BOOL isDeviceConfigForUS;

@property(nonatomic,strong) NSString *aboutURL;
@property(nonatomic,strong) NSString *termsURL;
@property(nonatomic,strong) NSString *shippingURL;
@property(nonatomic,strong) NSString *shareURL;

@property (nonatomic, assign) BOOL isLoginEnabled;
@property(nonatomic,assign) BOOL isInitFinished;
@property(nonatomic,assign) BOOL isInitAborted;
@property(nonatomic,assign) BOOL isRestartInProgress;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init
+ (void) initilizeApp;
+ (void) initilizeAppWithAPIKey:(NSString *)apiKey applicationId: (NSString *) applicationId;
+ (void) initilizeAppWithAPIKey:(NSString *)apiKey
                  applicationId:(NSString *)applicationId
        twoDigitISOLanguageCode:(NSString *)twoDigitISOLanguageCode
         twoDigitISOCountryCode:(NSString *)twoDigitISOCountryCode
                        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
+ (void) initilizeACAPIApplicationId:applicationId
                              apiKey:(NSString*)apiKey
             twoDigitISOLanguageCode:(NSString *)twoDigitISOLanguageCode
              twoDigitISOCountryCode:(NSString * )twoDigitISOCountryCode;
+ (void) catalogGetSessionWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
+ (void)start;

+ (void) cancelRequest;

// Use this method when starting your application all by itself (Not in conjunction with ACAPI)
+ (void) startAppWithAPIKey:(NSString *)apiKey
              applicationId:(NSString *)applicationId ;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Authenticaion

+ (void) requestForAccountCreateExtentedEmailAddress:(NSString *) emailAddress
                                            password:(NSString *)password
                                           firstName:(NSString *)firstName
                                            lastName:(NSString *)lastName
                                             success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                             failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) requestForAccountAuthenticateWithEmailAddress:(NSString *) emailAddress
                                              password:(NSString *)password
                                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) requestForAccountAuthenticateWithFacebookUID:(NSString *)facebookUID
                                         emailAddress:(NSString *)emailAddress
                                            firstName:(NSString *)firstName
                                             lastName:(NSString *)lastName
                                        facebookToken:(NSString*)facebookToken
                                              success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) requestForAccountCreateWithEmailAddress:(NSString *) emailAddress
                                        password:(NSString *)password
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
+ (void) requestForAccountCreateWithEmailAddress:(NSString *) emailAddress
                                        password:(NSString *)password
                                        firstName:(NSString *)firstName
                                        lastName:(NSString *)lastName
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) accountRetrievePasswordWithEmailAddress:(NSString *) emailAddress
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
+ (void) requestForAccountMergeFromAuthToken:(NSString *) fromAuthToken
                                 toAuthToken:(NSString *)toAuthToken
                                     success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
+ (void) requestForAccountGet:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;


+ (void) requestForAccountUpdateProperty:(NSString *) propertyKey
                               withValue:(NSString *) propertyValue
                                 success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                 failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;


+ (void) requestForAccountUpdateLocationWithParameters:(NSDictionary *)parameters
                                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) requestForAccountUpdateLocationByType:(NSString *)addresstype addressLine1:(NSString *)addressLine1 addressLine2:(NSString *)addressLine2 companyName:(NSString *)companyName city:(NSString *)city state:(NSString *)state countryCode:(NSString *)countryCode zipCode:(NSString *)zipCode primaryPhone:(NSString *)primaryPhone
                                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
+ (void)logoutAndReset;
+ (void)logoutArtCircles;
+ (void)logoutAndRestart;
+ (BOOL)isLoggedIn;
+ (BOOL)sessionIDExpired;
- (BOOL) authTokenExpired;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Judy
+(void) decorProductSearchKeyword:(NSString*) keyword
                      refinements:(NSString*) refinements
                       paletteHex:(NSString*) paletteHex
                       pageNumber:(NSString*) pageNumber
                      numProducts:(NSString*) numProducts
                         minWidth:(NSString*) minWidth
                         maxWidth:(NSString*) maxWidth
                        minHeight:(NSString*) minHeight
                        maxHeight:(NSString*) maxHeight
                         minPrice:(NSString*) minPrice
                         maxPrice:(NSString*) maxPrice
                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) palettesForMoodId:(NSNumber*) moodId
                 wallColor:(NSString *) wallColor
                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) productsForMoodId:(NSNumber*) moodId
                    colors:(NSString *) colors
               numProducts:(NSNumber*) numProducts
                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) productsForMoodId:(NSNumber*) moodId
                    colors:(NSString *) colors
                   keyword:(NSString *) keyword
               numProducts:(NSNumber*) numProducts
                      page:(NSNumber *) page
                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ECommerceAPI

+ (void) frameRecomendationsForItemId:(NSString *) itemId
           maxNumberOfRecommendations:(NSNumber *) maxNumberOfRecommendations
                    maxJpegImageWidth:(int)maxJpegImageWidth
                   maxJpegImageHeight:(int)maxJpegImageHeight
                              success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) searchResultInSimpleFormatForProductIds: (NSArray *) productIds
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) variationsForItemId:(NSString *) itemId
                     success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) requestForCatalogItemGetForItemId:(NSString *) itemId
                                lookupType:(NSString*) lookupType
                                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;


// Note: The max numberOfRecords is 48.  The API does not return an error. It only caps the request at 48.
+ (void) catalogItemSearchForCategoryIdList:(NSString *)categoryIdList
                            numberOfRecords:(NSNumber *)numberOfRecords
                                 pageNumber:(NSNumber *)pageNumber
                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) catalogGetContentBlockForBlockName:(NSString *)contentBlockName
                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) catalogetFeaturedCategorieWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) requestForCartAddItemForItemId:(NSString *)itemId
                             lookupType:(NSString *)lookupType
                              quantitiy:(int)quantity
                                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) requestForCartUpdateCartItemQuantityForCartItemId:(NSString *)cartItemId
                                                  quantity:(int)quantity
                                                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) requestForCartGetActiveCountryListWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) requestForCartGetActiveStateListByTwoDigitIsoCountryCode:(NSString *)twoDigitIsoCountryCode
                                                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) cartGetCityStateSuggestionsCountryCode:(NSString *)countryCode
                                        zipCode:(NSString *)zipCode
                                        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) cartUpdateShippingAddressFirstName:(NSString *)firstName
                                   lastName:(NSString *)lastName
                               addressLine1:(NSString *)addressLine1
                               addressLine2:(NSString *)addressLine2
                                companyName:(NSString *)companyName
                                       city:(NSString *)city
                                      state:(NSString *)state
                     twoDigitIsoCountryCode:(NSString *)twoDigitIsoCountryCode
                                        zip:(NSString *)zip
                               primaryPhone:(NSString *)primaryPhone
                             secondaryPhone:(NSString *)secondaryPhone
                               emailAddress:(NSString *)emailAddress
                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) cartGetShippingOptionsWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) cartUpdateShipmentPriority:(int)shipmentPriority
                            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) cartRemoveCoupon:(NSString *)couponCode
                  success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                  failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) cartAddCouponCode:(NSString *)couponCode
                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) cartGetPaypalToken:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) cartGetPaymentOptionsWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) cartSubmitForOrderWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) requestForCartGetWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PaymentAPI

+ (void) cartAddCreditCardNumber:(NSString *)cardNumber
                        cardType:(ACCCardType)cardType
                            cvv2:(NSString *)cvv2
                 expiryDateMonth:(int)expiryDateMonth
                  expiryDateYear:(int)expiryDateYear
                 soloIssueNumber:(NSString *)soloIssueNumber
                       firstName:(NSString *)firstName
                        lastName:(NSString *)lastName
                    addressLine1:(NSString *)addressLine1
                    addressLine2:(NSString *)addressLine2
                     companyName:(NSString *)companyName
                            city:(NSString *)city
                           state:(NSString *)state
          twoDigitIsoCountryCode:(NSString *)twoDigitIsoCountryCode
                             zip:(NSString *)zip
                    primaryPhone:(NSString *)primaryPhone
                  secondaryPhone:(NSString *)secondaryPhone
                    emailAddress:(NSString *)emailAddress
                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) requestForCartTrackOrderHistory:(NSString *) customerNumber
                        withEmailAddress:(NSString *) emailAddress
                                 success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                 failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

-(void) requestForCartTrackOrderHistory:(NSString *) customerNumber
                       withEmailAddress:(NSString *) emailAddress
                                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+(void) requestForCartAddGiftCertificatePayment:(NSString *) giftCertificateCode
                                 success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                 failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

-(void) requestForCartAddGiftCertificatePayment:(NSString *) giftCertificateCode
                                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Gallery

+ (void) requestForGalleryGetUserDefaultGallery:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) removeGalleryId: (NSNumber *) galleryId
                 success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                 failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) removeMobileGallerySuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) addToMobileGalleryItemId: (NSString *) itemId
                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) removeFromMobileGalleryItemId: (NSNumber *) galleryItemId
                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;


+ (void) addGalleryToBookmark: (NSString *) galleryId
                      success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) removeGalleryToBookmark: (NSString *) galleryId
                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+(NSString*) galleryItemIdForItemId: (NSString *) itemId;

+ (NSArray *)mobileGalleryItems;

+ (void) processMobileGalleryResponse: (NSDictionary*) mobileGalleryResponse;

- (NSString *) myPhotosGalleryID;

- (void) setMyPhotosGalleryID:(NSString *)galleryID;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Feed

+ (void) feedGetForAccountID:(NSString *)accountID
                   feedScope:(NSString *)feedScope
                 recordCount:(int)recordCount
                   timeStamp:(NSString *)timeStamp
               timeStampType:(NSString *)timeStampType
            includeFeedItems:(BOOL)includeFeedItems
                noCachedCopy:(BOOL)noCachedCopy
                     success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) profileAddFollowForLookupType:(NSString *)profileLookupType
                     accountIdentifier:(NSString *)accountIdentifier
                    returnBareResponse:(BOOL)returnBareResponse
                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

+ (void) profileRemoveFollowForLookupType:(NSString *)profileLookupType
                        accountIdentifier:(NSString *)accountIdentifier
                       returnBareResponse:(BOOL)returnBareResponse
                                  success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                  failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Getters & Setters

+ (ArtAPI*) sharedInstance;

- (NSNumber *)wallGalleryID;
- (void)setWallGalleryID:(NSNumber *)galleryID;

- (NSNumber *)mobileGalleryID;
- (void)setMobileGalleryID:(NSNumber *)galleryID;

- (NSString *) getISOLanguageCode;

+ (void)setCart:(NSDictionary *)cartDictionary ;
+ (NSDictionary *)cart;

+ (BOOL) isDeviceConfigForUS;

+ (NSArray *) getCountries;
+ (void) setCountries:(NSArray*) countries;

+ (NSArray *) getStates;
+ (void) setStates:(NSArray*) states;

+ (NSString *) getShippingCountryCode;
+ (void) setShippingCountryCode:(NSString*) shippingCountryCode ;

+ (NSString *) getCurrentYear;
+ (void) setCurrentYear:(NSString*) currentYear;

+ (NSString *) getCurrentMonth;
+ (void) setCurrentMonth:(NSString*) currentMonth;

+ (NSString *) sessionID;
+ (void) setSessionID:(NSString *)sessionID;

+ (NSString *) persistentID;
+ (void) setPersistentID:(NSString *)persistentID;

+ (NSString *) authenticationToken;
+ (void) setAuthenticationToken:(NSString *)authenticationToken;

+ (NSDate *) sessionExpirationDate;
+ (void) setSessionExpirationDate: (NSDate*) sessionExpirationDate;

+ (NSString *) getEmail;

+ (NSString *) getFirstName;

+ (NSString *) getLastName;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utils

+ (NSString*) cleanImageUrl:(NSString *) imageURLString withSize: (int) size;
+ (NSDate *) extractDataFromAPIString:(NSString *)originalString;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 
#pragma mark Utils

- (NSString *)shippingURL;
- (NSString *)aboutURL;
- (NSString *)termsURL;
- (NSString *)shareURL;

-(NSURL *) URLWithRawFrameURLString:(NSString *)imageURLString maxWidth:(NSUInteger)maxWidth maxHeight:(NSUInteger)maxHeight;

@end
