//
//  ArtAPI.m
//  ArtAPI
//
//  Created by Doug Diego on 3/7/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ArtAPI.h"
#import "AFNetworking.h"
#import "NSDictionary+Additions.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NSMutableDictionary+SetNull.h"
#import "SVProgressHUD.h"
#import "XMLDictionary.h"
#import "BundleManager.h"
#include <netdb.h>
#include <arpa/inet.h>
#import "SFHFKeychainUtils.h"
#import "ACMasterVariations.h"
#import "XMLDictionary.h"
#import "NSArray+Addition.h"
#import "NSMutableArray+Addition.h"
#import "NSMutableDictionary+SetNull.h"

////////////////////////////////////////////////////////////////////////////////
// URLs


// Art.com API
//NSString* const kArtAPIUrl = @"api.art.com";
NSString* const kProtocolSecure = @"https://";
NSString* const kProtocolDefault = @"http://";


  NSString *apiKey = @"519BAAC8E607413CA1FC043C92D08AAD";
NSString *applicationID = @"EE363FE53CAD46249C724FB2680F799F";

// Judy
NSString* const kArtcomJudyServerAPIUrl = @"http://ws-decor.art.com";

// Edge Search
NSString* const kArtcomEdgeSearch = @"http://edge-ws.search.art.com";


////////////////////////////////////////////////////////////////////////////////
// Judy Resources
NSString* const kResourcePalettesForMood = @"/api/getPalettesForMood";
NSString* const kResourceProductsForMoodAndColor = @"/api/getProductsForMoodAndColor";
NSString* const kResourceProductsForMoodAndColorWithPaging = @"/api/decorProductSearch";

////////////////////////////////////////////////////////////////////////////////
// Edge Search Resources
NSString* const kResourceSearchResultInSimpleFormat = @"/wcf/SearchService.svc/ajax/GetSearchResultInSimpleFormat";

////////////////////////////////////////////////////////////////////////////////
// Art.com API Resources


NSString* const kResourceAccountAuthenticate = @"AccountAuthenticate";
NSString* const kResourceAccountCreateAnonymous = @"AccountCreateAnonymous";
NSString* const kResourceAccountChangePassword = @"AccountChangePassword";
NSString* const kResourceAccountCreate = @"AccountCreate";
NSString* const kResourceAccountCreateExtented = @"AccountCreateExtented";
NSString* const kResourceAccountMerge = @"AccountMerge";
NSString* const kResourceAccountGet = @"AccountGet";
NSString* const kResourceAccountUpdateProfile = @"AccountUpdateProfile";
NSString* const kResourceAccountUpdateProperty = @"AccountUpdateProperty";
NSString* const kResourceAccountSubscribe = @"AccountSubscribe";
NSString* const kResourceAccountUpdateLocationByType = @"AccountUpdateLocationByType";
NSString* const kResourceAccountRetrievePassword = @"AccountRetrievePassword";
NSString* const kResourceAccountAuthenticateWithFacebookUID = @"AccountAuthenticateWithFacebookUID";
NSString* const kResourceAccountAuthenticateWithSocial = @"AccountAuthenticateWithSocial";

NSString* const kResourceInitializeAPI= @"InitializeAPI";
NSString* const kResourceCatalogGetSession = @"CatalogGetSession";
NSString* const kResourceApplicationGetForSession = @"ApplicationGetForSession";
NSString* const kResourceGalleryGetUserDefaultMobileGallery = @"GalleryGetUserDefaultMobileGallery";
NSString* const kResourceGalleryAddItem = @"GalleryAddItem";
NSString* const kResourceBookmarkAddGallery = @"ProfileAddGalleryBookmark";
NSString* const kResourceBookmarkRemoveGallery = @"ProfileRemoveGalleryBookmark";
NSString* const kResourceGalleryDelete = @"GalleryDelete";
NSString* const kResourceGalleryRemoveItem = @"GalleryRemoveItem";
NSString* const kResourceGalleryGetUserDefaultGallery = @"GalleryGetUserDefaultGallery";
NSString* const kResourceCatalogItemGetFrameRecommendations = @"CatalogItemGetFrameRecommendations";
NSString* const kResourceCatalogItemGet = @"CatalogItemGet";
NSString* const kResourceImageGetMasterVariations = @"ImageGetMasterVariations";

NSString* const kCatalogItemGetVariations = @"CatalogItemGetVariations";

NSString* const kResourceCatalogGetContentBlock = @"CatalogGetContentBlock";
NSString* const kResourceCatalogGetFeaturedCategories = @"CatalogGetFeaturedCategories";
NSString* const kResourceCatalogItemSearch = @"CatalogItemSearch";
NSString* const kResourceCatalogItemGetVariations= @"CatalogItemGetVariations";
NSString* const kResourceCartAddItem = @"CartAddItem";
NSString* const kResourceCartUpdateCartItemQuantity = @"CartUpdateCartItemQuantity";
NSString* const kResourceCartGetActiveCountryList = @"CartGetActiveCountryList";
NSString* const kResourceCartGetActiveStateListByCountryCode = @"CartGetActiveStateListByCountryCode";
NSString* const kResourceCartGetCityStateSuggestions = @"CartGetCityStateSuggestions";
NSString* const kResourceCartUpdateShippingAddress = @"CartUpdateShippingAddress";
NSString* const kResourceCartGetShippingOptions = @"CartGetShippingOptions";
NSString* const kResourceCartUpdateShipmentPriority = @"CartUpdateShipmentPriority";
NSString* const kResourceCartAddCoupon = @"CartAddCoupon";
NSString* const kResourceCartRemoveCoupon = @"CartRemoveCoupon";
NSString* const kResourceCartAddCreditCard = @"CartAddCreditCard";
NSString* const kResourceCartAddPayment = @"CartAddPayment";
NSString* const kResourceCartSubmitForOrder = @"CartSubmitForOrder";
NSString* const kResourceCartGet = @"CartGet";
NSString* const kResourceCartClear = @"CartClear";
NSString* const kResourceCartTrackOrderHistory = @"CartTrackOrderHistory";
NSString* const kResourceCartAddGiftCertificatePayment = @"CartAddGiftCertificatePayment";
NSString* const kResourceCartSubmitForPayPalRestOrder = @"CartSubmitForPayPalRestOrder";


////////////////////////////////////////////////////////////////////////////////
// Art.com API Endpoints
NSString* const kEndpointAccountAuthorizationAPI = @"AccountAuthorizationAPI";
NSString* const kEndpointECommerceAPI = @"ECommerceAPI";
NSString* const kEndpointPaymentAPI = @"PaymentAPI";
NSString* const kEndpointIPaymentAPI = @"IPaymentAPI";


@interface ArtAPI ()
{
    NSString *_savedMyPhotosGalleryID;
    NSMutableDictionary *mMasterVariationsDict;
    NSMutableDictionary *mCurrentVariationsDict;
    NSMutableArray *mFilteredMouldingArray;
    NSMutableArray *mFilteredConfigArray;
}

@property (nonatomic, retain) NSArray *countries;
@property (nonatomic, retain) NSArray *states;
@property (nonatomic, retain) NSString *shippingCountryCode;
@property (nonatomic, strong) NSMutableDictionary  *mobileGalleryMap;
@end

@implementation ArtAPI

@synthesize apiKey = _apiKey;
@synthesize applicationId = _applicationId;
@synthesize twoDigitISOLanguageCode = _twoDigitISOLanguageCode;
@synthesize twoDigitISOCountryCode = _twoDigitISOCountryCode;
@synthesize sessionID = _sessionID;
@synthesize persistentID = _persistentID;
@synthesize authenticationToken = _authenticationToken;
@synthesize email = _email;
@synthesize password = _password;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize cart = _cart;
@synthesize isDeviceConfigForUS;
@synthesize countries = _countries;
@synthesize states = _states;
@synthesize shippingCountryCode = _shippingCountryCode;
@synthesize currentYear = _currentYear;
@synthesize currentMonth = _currentMonth;
@synthesize CustomerAssetPaperID = _CustomerAssetPaperID;
@synthesize CustomerAssetCanvasID = _CustomerAssetCanvasID;

@synthesize aboutURL = _aboutURL;
@synthesize termsURL = _termsURL;
@synthesize shippingURL = _shippingURL;
@synthesize shareURL = _shareURL;
@synthesize isLoginEnabled;

//FrmaeyourArt variable

@synthesize ApplicationVariale = _ApplicationVariale;

// @synthesize mobileGalleryItems = _mobileGalleryItems;

// Key Chain Contants
#define SERVICE_LOGGING NO
static NSString *SESSION_ID_KEY = @"SESSION_ID_KEY";
static NSString *AUTH_TOKEN_KEY = @"AUTH_TOKEN_KEY";
static NSString *PERSISTENT_ID_KEY = @"PERSISTENT_ID_KEY";
static NSString *EMAIL_KEY = @"EMAIL_KEY";
static NSString * PASSWORD_KEY = @"PASSWORD_KEY";
static NSString *FIRST_NAME_KEY = @"FIRST_NAME_KEY";
static NSString *LAST_NAME_KEY = @"LAST_NAME_KEY";
//static NSString *PASSWORD_KEY = @"PASSWORD_KEY";
//static NSString *ART_SERICE_KEY = @"ART_SERICE_KEY";
static NSString *SESSION_EXPIRATION_KEY = @"SESSION_EXPIRATION_KEY";
#define ANONYMOUS_AUTH_TOKEN @"ANONYMOUS_AUTH_TOKEN"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init

-(id) init {
    if ((self = [super init])) {
        
        self.usePersistentIDForAuth = NO;
        self.keyChainService = [ACConstants getKeyChainServiceName];
        
        mMasterVariationsDict = [[ NSMutableDictionary alloc] init];
        mCurrentVariationsDict = [[ NSMutableDictionary alloc] init];
        mFilteredMouldingArray = [[NSMutableArray alloc] init];
        mFilteredConfigArray = [[NSMutableArray alloc] init];

    }
    return self;

}


+ (ArtAPI*) sharedInstance {
    static ArtAPI* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) {
            _one = [[ ArtAPI alloc ] init ];
        }
    }
    
    return _one;
}

+ (void) startAppWithAPIKey:(NSString *)apiKey
                  applicationId:(NSString *)applicationId {
    [[ArtAPI sharedInstance] startAppWithAPIKey:apiKey applicationId:applicationId];
}

+ (void) startAPI {
    
   // NSString *apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"APIKey"];
   // NSString *apiKey = @"519BAAC8E607413CA1FC043C92D08AAD";
    //NSString *applicationID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ApplicationID"];
    //NSString *applicationID = @"EE363FE53CAD46249C724FB2680F799F";
    
    [[ArtAPI sharedInstance] startAppWithAPIKey:apiKey applicationId:applicationID];
}

+(NSDictionary *)GetDictApplicationVarriable
{
    return [[ArtAPI sharedInstance] getDictApplicationVarriable];
}

-(NSDictionary *)getDictApplicationVarriable
{
    return self.ApplicationVariale ;
}

- (void) startAppWithAPIKey:(NSString *)apiKey
              applicationId:(NSString *)applicationId {
    //NSLog(@"startAppWithAPIKey: %@ applicationId: %@", apiKey, applicationId );
    
    self.apiKey = apiKey;
    self.applicationId = applicationId;
    self.twoDigitISOLanguageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    self.twoDigitISOCountryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    //NSLog(@"ArtAPI.start() sessionID: %@ sessionIDExpired: %d", self.sessionID, [self sessionIDExpired] );
    self.isInitFinished = NO;
    
    NSError *error = nil;
    
    NSString *savedPersistentID = [SFHFKeychainUtils getPasswordForUsername:PERSISTENT_ID_KEY andServiceName:self.keyChainService error:&error];
    
    if(savedPersistentID&&![savedPersistentID isKindOfClass:[NSNull class]]){
        
        NSError *error;
        
        [SFHFKeychainUtils deleteItemForUsername:EMAIL_KEY andServiceName:self.keyChainService error:&error];
        [SFHFKeychainUtils deleteItemForUsername:PASSWORD_KEY andServiceName:self.keyChainService error:&error];
        
        [ArtAPI setPersistentID:savedPersistentID];
        self.usePersistentIDForAuth = YES;
        
        [SFHFKeychainUtils deleteItemForUsername:EMAIL_KEY andServiceName:self.keyChainService error:&error];
        [SFHFKeychainUtils deleteItemForUsername:PASSWORD_KEY andServiceName:self.keyChainService error:&error];
        
        NSString *savedSessionID = [SFHFKeychainUtils getPasswordForUsername:SESSION_ID_KEY andServiceName:self.keyChainService error:&error];
        NSString *savedAuthToken = [SFHFKeychainUtils getPasswordForUsername:AUTH_TOKEN_KEY andServiceName:self.keyChainService error:&error];
        if(![ArtAPI sessionID]){
            [ArtAPI setSessionID:savedSessionID];
        }
        if(![ArtAPI authenticationToken]){
            [ArtAPI setAuthenticationToken:savedAuthToken];
        }
        [[NSUserDefaults standardUserDefaults] setObject:savedAuthToken forKey:ANONYMOUS_AUTH_TOKEN];
    }else{
        self.usePersistentIDForAuth = NO;
        NSError *error;
        NSString *emailAddress = [SFHFKeychainUtils getPasswordForUsername:EMAIL_KEY andServiceName:self.keyChainService error:&error];
        NSString *passwordForAuth = [SFHFKeychainUtils getPasswordForUsername:PASSWORD_KEY andServiceName:self.keyChainService error:&error];
        if(emailAddress&&passwordForAuth&&(![emailAddress isKindOfClass:[NSNull class]])&&(![passwordForAuth isKindOfClass:[NSNull class]])){
            //it's not an anonymous account
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANONYMOUS_AUTH_TOKEN];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    if (self.sessionID == nil || [self sessionIDExpired]) {
        
        Reachability *internetReachabilityTest = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [internetReachabilityTest currentReachabilityStatus];
        if (networkStatus == NotReachable) // NETWORK Reachability
        {
            //[ AppDel setApiInitFailed:YES];
            //[ AppDel showReachabilityAlert];
            return;
        }

        NSLog(@"start() sessionID == nil or is expired, get new sessionID");
        // Initialize a new session
        
        BOOL isSitwchArt = (AppLocationSwitchArt == [ACConstants getCurrentAppLocation]);
        
        //Jobin :  SWIT-235
        NSString *languageCode = isSitwchArt ? @"EN": [self getISOLanguageCode];
        NSString *countryCode = isSitwchArt ? @"US": [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        
        [self initilizeApplicationId:self.applicationId apiKey:self.apiKey twoDigitISOLanguageCode:languageCode twoDigitISOCountryCode:countryCode success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
            
            [self getContentBlockSetup];

            //NSLog(@"start() Check Session ID");
            
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
                                 NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
                             }];
    }
    else
    {
        NSLog(@"start() Check Session ID");
        [self catalogGetSessionWithSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            [self getContentBlockSetup];

            // Refresh Mobile Gallery
            if( [self isLoggedIn] ){
                [self requestForGalleryGetUserDefaultMobileGallerySuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    
                    NSLog(@"Success");

                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                }];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"Session Invalid - Initilize Session ");
            // Initialize a new session
            [self initilizeApplicationId:self.applicationId apiKey:self.apiKey twoDigitISOLanguageCode:self.twoDigitISOLanguageCode twoDigitISOCountryCode:self.twoDigitISOCountryCode success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
                //NSLog(@"start() Check Session ID");
            }
                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
                                     NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
                                 }];
        }];
    }
}

- (void)getContentBlockSetup
{
    //if(![ArtAPI sharedInstance].gigyaApiKey) // If Gigya token is available already
    {
        [[ArtAPI sharedInstance] catalogGetContentBlockForBlockName:@"_config" success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            NSLog(@"contentBlock = %@",JSON);
            
            NSDictionary *contentBlock  = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"ContentBlock"];
            
            NSString *contentBlockString = [contentBlock objectForKey:@"LargeTextBlock"];
            NSDictionary *contentBlockDict = [[XMLDictionaryParser sharedInstance] dictionaryWithString:contentBlockString];
            NSDictionary *configDict = [[contentBlockDict objectForKeyNotNull:@"APPLICATION"] objectForKeyNotNull:@"CONFIGURATION"];
            NSString *gigyaKeyString = [configDict objectForKeyNotNull:@"GIGYAAPIKEY"];
            [ArtAPI sharedInstance].gigyaApiKey = [gigyaKeyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [[BundleManager sharedInstance] setBundleConfigurations:contentBlock];
            
            if(AppLocationDefault == [ACConstants getCurrentAppLocation]) /*Top Banner images only for P2A */
            {
                NSArray *banners = [contentBlock objectForKeyNotNull:@"Banners"];
                self.bannersArray = banners;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:GET_BANNERS_SUCCEEDED object:nil];
                
                self.smallSidePixelMin = [DEFAULT_SMALL_SIDE_PIXEL_MIN integerValue];
                self.largeSidePixelMin = [DEFAULT_LARGE_SIDE_PIXEL_MIN integerValue];
                
                if(contentBlock){
                    if(contentBlockString.length>0){
                        
                        NSArray *mouldingArray = [[[[contentBlockDict objectForKeyNotNull:@"mP2A"] objectForKeyNotNull:@"PRODUCTS"] objectForKeyNotNull:@"MOULDINGS"] objectForKeyNotNull:@"MOULDING"];
                        NSMutableArray *apNumArray = [[NSMutableArray alloc] init];
                        NSMutableArray *sortOrderArray = [[NSMutableArray alloc] init];
                        for(int i=0;i<mouldingArray.count;i++){
                            NSDictionary *molding = [mouldingArray objectAtValidIndex:i];
                            NSString *apNum = [[molding valueForKeyPath:@"APNUM.text"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                            NSString *sortOrder = [[molding valueForKeyPath:@"SORTORDER.text"]stringByReplacingOccurrencesOfString:@" " withString:@""];
                            [apNumArray addObject:apNum];
                            [sortOrderArray addObject:[NSNumber numberWithInt:[sortOrder intValue]]];
                            //NSLog(@"apNum=%@ sortOrder=%@\n",apNum,sortOrder);
                        }
                        for(int i=sortOrderArray.count-2;i>=0;i--){
                            for(int j=0;j<=i;j++){
                                if([[sortOrderArray objectAtValidIndex:j] intValue] > [[sortOrderArray objectAtValidIndex:(j+1)] intValue]){
                                    NSNumber *tempNumber = [sortOrderArray objectAtValidIndex:j];
                                    NSString *tempApNum = [apNumArray objectAtValidIndex:j];
                                    [sortOrderArray replaceObjectAtIndex:j withObject:[sortOrderArray objectAtValidIndex:(j+1)]];
                                    [apNumArray replaceObjectAtIndex:j withObject:[apNumArray objectAtValidIndex:(j+1)]];
                                    [sortOrderArray replaceObjectAtIndex:(j+1) withObject:tempNumber];
                                    [apNumArray replaceObjectAtIndex:j withObject:tempApNum];
                                }
                            }
                        }
                        mFilteredMouldingArray = apNumArray;
                        
                        NSArray *configArray = [[[[contentBlockDict objectForKeyNotNull:@"mP2A"] objectForKeyNotNull:@"PRODUCTS"] objectForKeyNotNull:@"CONFIGS"] objectForKeyNotNull:@"CONFIG"];
                        
                        NSMutableArray *configOrderedArray = [[NSMutableArray alloc] init];
                        
                        for(int i=0;i<configArray.count;i++){
                            NSString *configID = [[configArray objectAtValidIndex:i] valueForKeyPath:@"text"];
                            [configOrderedArray addObject:configID];
                        }
                        
                        mFilteredConfigArray = configOrderedArray;
                        
                        //get small and large pixel size limit
                        NSDictionary *configurationDict = [[[contentBlockDict objectForKeyNotNull:@"mP2A"] objectForKeyNotNull:@"APPLICATION"] objectForKeyNotNull:@"CONFIGURATION"];
                        
                        NSString *smallThreshold = [[configurationDict valueForKeyPath:@"SMALLPIXELMIN.text"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSString *largeThreshold = [[configurationDict valueForKeyPath:@"LARGEPIXELMIN.text"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                        
                        NSString *useAccounts = [[configurationDict valueForKeyPath:@"USEACCOUNTS.text"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                        
                        if(useAccounts && ![useAccounts isKindOfClass:[NSNull class]] && (useAccounts.length > 0)){
                            [ArtAPI sharedInstance].isLoginEnabled = [useAccounts intValue];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kgalleryQuantNotification object:nil];
                            [[NSUserDefaults standardUserDefaults] setObject:useAccounts forKey:@"USE_ACCOUNTS"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        
                        if(DO_LOG) NSLog(@"Got string values for pixel lower limits: LRG: %@, SML: %@", largeThreshold, smallThreshold);
                        
                        @try{
                            CGFloat tempSmall = [smallThreshold floatValue];
                            CGFloat tempLarge = [largeThreshold floatValue];
                            
                            if(tempSmall > 0){
                                self.smallSidePixelMin = tempSmall;
                            }
                            if(tempLarge > 0){
                                self.largeSidePixelMin = tempLarge;
                            }
                            
                        }@catch(id exc){
                            //leave as is
                        }
                        
                        if(DO_LOG) NSLog(@"Pixel lower limits: LRG: %f, SML: %f", self.largeSidePixelMin, self.smallSidePixelMin);
                        
                        //get values for JPG Compression and Upload Server
                        NSString *jpgCompressionString = [[configurationDict valueForKeyPath:@"JPGCOMPRESSION.text"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                        //            NSString *uploadServerUrlString = [[configurationDict valueForKeyPath:@"UPLOADURL.text"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                        
                        //new URL strings
                        NSString *aboutUrlString = [[configurationDict valueForKeyPath:@"ABOUTURL.text"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSString *termsUrlString = [[configurationDict valueForKeyPath:@"TERMSURL.text"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSString *shareUrlString = [[configurationDict valueForKeyPath:@"SHAREURL.text"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSString *shipUrlString = [[configurationDict valueForKeyPath:@"SHIPURL.text"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSString *gigyaToken = [[configurationDict valueForKeyPath:@"GIGYAAPIKEY.text"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                        [ArtAPI sharedInstance].gigyaApiKey = gigyaToken;
                        
                        
                        if(!jpgCompressionString) jpgCompressionString=@"";
                        //            if(!uploadServerUrlString) uploadServerUrlString=@"";
                        
                        CGFloat jpgCompressionFloat = 1.0;
                        
                        @try{
                            jpgCompressionFloat = [jpgCompressionString floatValue];
                            
                            if(jpgCompressionFloat > 1.0){
                                jpgCompressionFloat = 1.0;
                            }
                            if(jpgCompressionFloat < 0.5){
                                jpgCompressionFloat = 1.0;
                            }
                            
                        }@catch(id exc){
                            //leave as is
                        }
                    }
                }
            }

        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            
            NSLog(@"Content block call Failed");
        }];
    }
    
    [ArtAPI requestForImageGetMasterVariationsWithLookupType:@"Sku" success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
    }];
}

-(void)processMasterVariations:(NSArray*)masterVariationsArray forService:(NSString*)serviceName
{
    NSString *filePath = [[ NSBundle mainBundle] pathForResource:@"SupportedDims" ofType:@"plist"];
    NSArray *paramArray = [[ NSArray alloc] initWithContentsOfFile:filePath];
    
    NSMutableArray *array = [[ NSMutableArray alloc] init];
    for(NSDictionary *dict in masterVariationsArray)
    {
        ACMasterVariations *masterVariation = [[ ACMasterVariations alloc] init];
        masterVariation.podConfigId = [ dict objectForKeyNotNull:@"PodConfigId"];
        masterVariation.timeToShipText = [ dict objectForKeyNotNull:@"TimeToShipText"];
        float large = [[dict objectForKeyNotNull:@"Large"] integerValue];
        float small = [[dict objectForKeyNotNull:@"Small"] integerValue];
        int unitOfMeasure = [[dict objectForKeyNotNull:@"UnitOfMeasure"] intValue];
        //        if(small==8){
        //            if([serviceName isEqualToString:@"CanvasMuseum"]){
        //                [self.minPODArray replaceobjectAtValidIndex:0 withObject:masterVariation.podConfigId];
        //            }else if([serviceName isEqualToString:@"Mounting"]){
        //                [self.minPODArray replaceobjectAtValidIndex:1 withObject:masterVariation.podConfigId];
        //            }else if([serviceName isEqualToString:@"PrintOnly"]){
        //                [self.minPODArray replaceobjectAtValidIndex:2 withObject:masterVariation.podConfigId];
        //            }else{
        //                [self.minPODArray replaceobjectAtValidIndex:3 withObject:masterVariation.podConfigId];
        //            }
        //        }
        
        //        float aspectRatio = [[dict objectForKeyNotNull:@"AspectRatioTarget"] floatValue];
        
        if(unitOfMeasure==2){ // UnitOfMeasure=2 means that the dimensions are coming in cm
            large = large/2.54;
            small = small/2.54;
            int largeRounded = large;
            int smallRounded = small;
            if((large-(CGFloat)largeRounded)>=0.50f){
                largeRounded++;
            }
            if((small-(CGFloat)smallRounded)>=0.50f){
                smallRounded++;
            }
            large = largeRounded;
            small = smallRounded;
        }
        int largeDimension = large;
        int smallDimension = small;
        
        if(smallDimension>largeDimension){
            int tempDimension = smallDimension;
            smallDimension = largeDimension;
            largeDimension = tempDimension;
        }
        
        //        if(aspectRatio>1.0f){
        //            masterVariation.dimensions = [NSString stringWithFormat:@"%dx%d",largeDimension,smallDimension];
        //        }else{
        masterVariation.dimensions = [NSString stringWithFormat:@"%dx%d",smallDimension,largeDimension];
        masterVariation.small = smallDimension;
        //        }
        masterVariation.size = large*small;
        if(mFilteredConfigArray.count>0){
            if([mFilteredConfigArray containsObject:masterVariation.podConfigId]){
                [array addObject: masterVariation];
            }
        }else{
            if([paramArray containsObject:masterVariation.dimensions]){
                [array addObject: masterVariation];
            }
        }
        
        masterVariation = nil;
    }
    
    
    /*    for(int j=0;j<array.count;j++){
     PAAMasterVariations *vaaar = [array objectAtValidIndex:j];
     NSLog(@"%d . Size=%f  ID=%@  Dimen=%@\n",j,vaaar.size,vaaar.podConfigId,vaaar.dimensions);
     }
     
     NSLog(@"\n\n"); */
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"size" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"small" ascending:YES];
    
    [array sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];
    
    /*    for(int j=0;j<array.count;j++){
     PAAMasterVariations *vaaar = [array objectAtValidIndex:j];
     NSLog(@"%d . Size=%f  ID=%@  Dimen=%@\n",j,vaaar.size,vaaar.podConfigId,vaaar.dimensions);
     } */
    
    [ mMasterVariationsDict setObject:array forKey:[serviceName isEqualToString:@"CanvasMuseum"]?@"canvasmw":serviceName];
}

+ (void) initilizeApp {
    //NSLog(@"+initilizeApp() apiKey: %@ applicationId: %@", [[ArtAPI sharedInstance] apiKey],[[ArtAPI sharedInstance] applicationId] );
    //NIDASSERT([[ArtAPI sharedInstance] applicationId]);
    //NIDASSERT([[ArtAPI sharedInstance] apiKey]);
    
    [[ArtAPI sharedInstance]
     initilizeApplicationId:[[ArtAPI sharedInstance] applicationId] apiKey:[[ArtAPI sharedInstance] apiKey] twoDigitISOLanguageCode:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] twoDigitISOCountryCode:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
     }];
}

+ (void) initilizeAppWithAPIKey:(NSString *)apiKey
                  applicationId:(NSString *)applicationId {
    //NSLog(@"+initilizeAppWithAPIKey() apiKey: %@ applicationId: %@", apiKey,applicationId);
    
    [[ArtAPI sharedInstance]
     initilizeApplicationId:applicationId apiKey:apiKey twoDigitISOLanguageCode:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] twoDigitISOCountryCode:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
     }];
}

+ (void) initilizeAppWithAPIKey:(NSString *)apiKey
                  applicationId:(NSString *)applicationId
        twoDigitISOLanguageCode:(NSString *)twoDigitISOLanguageCode
         twoDigitISOCountryCode:(NSString *)twoDigitISOCountryCode
                        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
 
{
    //NSLog(@"+initilizeAppWithAPIKey() apiKey: %@ applicationId: %@ twoDigitISOLanguageCode: %@ twoDigitISOCountryCode: %@",
    //      apiKey,applicationId, twoDigitISOLanguageCode, twoDigitISOCountryCode);
    
    [[ArtAPI sharedInstance] initilizeApplicationId:applicationId apiKey:apiKey twoDigitISOLanguageCode:twoDigitISOLanguageCode twoDigitISOCountryCode:twoDigitISOCountryCode success:success failure:failure];
}


- (void) initilizeApplicationId:applicationId
                         apiKey:(NSString*)apiKey
        twoDigitISOLanguageCode:(NSString *) twoDigitISOLanguageCode
         twoDigitISOCountryCode:(NSString * ) twoDigitISOCountryCode
                        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    self.isDeviceConfigForUS = NO;
    self.apiKey = apiKey;
    self.applicationId = applicationId;
    self.twoDigitISOCountryCode = twoDigitISOCountryCode;
    self.twoDigitISOLanguageCode = twoDigitISOLanguageCode;
    _cart = nil;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                applicationId, @"applicationId",
                                twoDigitISOLanguageCode, @"twoDigitISOLanguageCode",
                                twoDigitISOCountryCode, @"twoDigitISOCountryCode",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceInitializeAPI
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:NO
                                            requiresAuthKey:NO];
    NSLog(@"request: %@", request);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"JSON: %@", JSON);
        
        
        // Geo Code
        NSString *geoIPCountryCode = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"GeoIPCountryCode"];
        //NSLog(@"geoIPCountryCode: %@", geoIPCountryCode );
        if([[geoIPCountryCode uppercaseString] isEqualToString:@"US"]){
            self.isDeviceConfigForUS = YES;
        }else{
            self.isDeviceConfigForUS = NO;
        }
        
        // Save SessionID and Expiration Date
        self.sessionID = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"SessionId"];
        NSString *dateExpires = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"DateExpires"];
        NSDate *sessionExpirationDate = [ArtAPI extractDataFromAPIString:dateExpires];
        [self setSessionExpirationDate:sessionExpirationDate];
        //apl=[[NSDictionary alloc]init];
        self.ApplicationVariale = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"Application"];

        // Process Request
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
        
        NSString * isoCurrencyCode = [[JSON objectForKeyNotNull:@"d"] objectForKeyNotNull:@"IsoCurrencyCode"];
        if(!isoCurrencyCode){
            isoCurrencyCode = @"USD";
        }
        //NSLog(@"isoCurrencyCode: %@", isoCurrencyCode);
        [self setIsoCountryCode:isoCurrencyCode];
        
        // Save SessionID and Expiration Date
        self.sessionID = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"SessionId"];
        
        if((AppLocationSwitchArt == [ACConstants getCurrentAppLocation]) || (AppLocationDefault == [ACConstants getCurrentAppLocation])) /* SA or P2A */
        {
            [ArtAPI
             catalogGetSessionWithSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
             }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
                 NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
             }];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}


+ (void) initilizeACAPIApplicationId:applicationId
                              apiKey:(NSString*)apiKey
             twoDigitISOLanguageCode:(NSString *)twoDigitISOLanguageCode
              twoDigitISOCountryCode:(NSString * )twoDigitISOCountryCode {
    //NSLog(@"+initilizeACAPIApplicationId() apiKey: %@ applicationId: %@ twoDigitISOLanguageCode: %@ twoDigitISOCountryCode: %@",
    //      apiKey,applicationId, twoDigitISOLanguageCode, twoDigitISOCountryCode);
    [[ArtAPI sharedInstance] initilizeACAPIApplicationId: applicationId
                                                  apiKey:apiKey
                                 twoDigitISOLanguageCode:twoDigitISOLanguageCode
                                  twoDigitISOCountryCode:twoDigitISOCountryCode];
}

- (void) initilizeACAPIApplicationId:applicationId
                              apiKey:(NSString*)apiKey
             twoDigitISOLanguageCode:(NSString *)twoDigitISOLanguageCode
              twoDigitISOCountryCode:(NSString * )twoDigitISOCountryCode {
    self.isDeviceConfigForUS = NO;
    self.apiKey = apiKey;
    self.applicationId = applicationId;
    self.twoDigitISOCountryCode = twoDigitISOCountryCode;
    self.twoDigitISOLanguageCode = twoDigitISOLanguageCode;
    _cart = nil;
    
    [ArtAPI
     catalogGetSessionWithSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
     }];
}

-(NSDictionary*)getMasterVariationsDict
{
    return (NSDictionary*)mMasterVariationsDict;
}
-(NSDictionary *)getCurrentVariationsDict{
    return (NSDictionary*)mCurrentVariationsDict;
}
- (void)setCurrentVariationsDict:(NSMutableDictionary *)dictt
{
    mCurrentVariationsDict = dictt;
}

-(NSArray *)getFilteredMouldArray
{
    return (NSArray *)mFilteredMouldingArray;
}


+ (void) applicationGetForSessionWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    [[ArtAPI sharedInstance] applicationGetForSessionWithSuccess:success failure:failure];
}

- (void) applicationGetForSessionWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceApplicationGetForSession
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:nil
                                            requiresSession:NO
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"JSON: %@", JSON);
        
        Reachability *internetReachabilityTest = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [internetReachabilityTest currentReachabilityStatus];
        if (networkStatus == NotReachable) /* NETWORK Reachability*/
        {
//            [ AppDel setApiInitFailed:YES];
//            [ AppDel showReachabilityAlert];
            return;
        }
        if(DO_LOG) NSLog(@"Application retrieval succeeded");
        [self checkForAuthentication];
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

- (void) checkForAuthentication
{
    Reachability *internetReachabilityTest = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachabilityTest currentReachabilityStatus];
    if (networkStatus == NotReachable) /* NETWORK Reachability*/
    {
//        [ AppDel setApiInitFailed:YES];
//        [ AppDel showReachabilityAlert];
        return;
    }
    if(![ArtAPI authenticationToken])
    {
        if(self.isInitAborted){
            self.isInitAborted = NO;
            return;
        }else
        {
            
            NSLog(@"Reached");
            NSString *emailAddress = nil;
            if(self.usePersistentIDForAuth){
                emailAddress = [[ArtAPI persistentID] stringByAppendingString:@"@art.com"];
                [ArtAPI requestForAccountAuthenticateWithEmailAddress:emailAddress password:[ArtAPI persistentID] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    NSDictionary *apiRespons = JSON;
                    [ArtAPI setAuthenticationToken: [apiRespons objectForKeyNotNull:@"AuthenticationToken"]];
                    NSDictionary *accountDetails = [apiRespons objectForKeyNotNull:@"Account"];
                    NSDictionary *profileInfo = [accountDetails objectForKeyNotNull:@"ProfileInfo"];
                    int accountType = [[profileInfo objectForKeyNotNull:@"AccountType"] intValue];
                    
                    if((accountType==1)||self.usePersistentIDForAuth){
                        [[NSUserDefaults standardUserDefaults] setObject:[apiRespons objectForKeyNotNull:@"AuthenticationToken"] forKey:ANONYMOUS_AUTH_TOKEN];
                    }else{
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANONYMOUS_AUTH_TOKEN];
                    }
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self defaultInitiationMethods];

                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    
                }];
            }else{
                NSError *error;
                emailAddress = [SFHFKeychainUtils getPasswordForUsername:EMAIL_KEY andServiceName:self.keyChainService error:&error];
                NSString *passwordForAuth = [SFHFKeychainUtils getPasswordForUsername:PASSWORD_KEY andServiceName:self.keyChainService error:&error];
                if(emailAddress&&passwordForAuth&&(![emailAddress isKindOfClass:[NSNull class]])&&(![passwordForAuth isKindOfClass:[NSNull class]])){
                    [ArtAPI requestForAccountAuthenticateWithEmailAddress:emailAddress password:passwordForAuth success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        NSDictionary *apiRespons = JSON;
                        [ArtAPI setAuthenticationToken: [apiRespons objectForKeyNotNull:@"AuthenticationToken"]];
                        NSDictionary *accountDetails = [apiRespons objectForKeyNotNull:@"Account"];
                        NSDictionary *profileInfo = [accountDetails objectForKeyNotNull:@"ProfileInfo"];
                        int accountType = [[profileInfo objectForKeyNotNull:@"AccountType"] intValue];
                        
                        if((accountType==1)||self.usePersistentIDForAuth){
                            [[NSUserDefaults standardUserDefaults] setObject:[apiRespons objectForKeyNotNull:@"AuthenticationToken"] forKey:ANONYMOUS_AUTH_TOKEN];
                        }else{
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANONYMOUS_AUTH_TOKEN];
                        }
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [self defaultInitiationMethods];
                        
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                        
                    }];
                }else
                {
                    [ArtAPI requestForAccountCreateAnonymousSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                        
                    }];
                }
            }
        }
    }else {
        if(self.isInitAborted){
            self.isInitAborted = NO;
            return;
        }else{
                        
            [ArtAPI requestForAccountGet:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                
                NSDictionary *apiRespons = [JSON objectForKeyNotNull:@"d"];
                [ArtAPI setAuthenticationToken: [apiRespons objectForKeyNotNull:@"AuthenticationToken"]];
                NSDictionary *accountDetails = [apiRespons objectForKeyNotNull:@"Account"];
                NSDictionary *profileInfo = [accountDetails objectForKeyNotNull:@"ProfileInfo"];
                int accountType = [[profileInfo objectForKeyNotNull:@"AccountType"] intValue];
                
                if((accountType==1)||self.usePersistentIDForAuth){
                    [[NSUserDefaults standardUserDefaults] setObject:[apiRespons objectForKeyNotNull:@"AuthenticationToken"] forKey:ANONYMOUS_AUTH_TOKEN];
                }else{
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANONYMOUS_AUTH_TOKEN];
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self defaultInitiationMethods];

            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                
            }];

           /* ACJSONAPIRequest *accountGetRequest = [self requestForAccountGetWithDelegate:self];
            if(!accountGetRequest){
                self.isInitFinished = NO;
                self.isInitAborted = YES;
                [self.initialRequestArray removeAllObjects];
                if(![ArtAPI authenticationToken]){
                    [self checkForAuthentication];
                    return;
                }else{
                    //                    NSLog(@"??");
                    [self start];
                    return;
                }
            }
            [accountGetRequest setDidFinishSelector:@selector(accountAuthenticateSucceeded:)];
            [accountGetRequest setDidFailSelector:@selector(accountGetFailed:)];
            if(accountGetRequest && ![accountGetRequest isKindOfClass:[NSNull class]]){
                [self.initialRequestArray addObject:accountGetRequest];
                [accountGetRequest startAsynchronous];
            }else{
                self.isInitFinished = NO;
                self.isInitAborted = YES;
                [self.initialRequestArray removeAllObjects];
                //                NSLog(@"??");
                return;
            } */
        }
    }
}

+ (void) catalogGetSessionWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    [[ArtAPI sharedInstance] catalogGetSessionWithSuccess:success failure:failure];
    
}

- (void) catalogGetSessionWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCatalogGetSession
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:nil
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"JSON: %@", JSON);
        
        // Geo IP Country Code
        NSString *geoIPCountryCode = [[JSON objectForKeyNotNull:@"d"] objectForKeyNotNull:@"GeoIPCountryCode"];
        //NSLog(@"geoIPCountryCode: %@", geoIPCountryCode );
        if([[geoIPCountryCode uppercaseString] isEqualToString:@"US"]){
            self.isDeviceConfigForUS = YES;
        }else{
            self.isDeviceConfigForUS = NO;
        }
        //NSLog(@"isDeviceConfigForUS: %d", isDeviceConfigForUS);
        
        // Iso Currency Code
        NSString * isoCurrencyCode = [[JSON objectForKeyNotNull:@"d"] objectForKeyNotNull:@"IsoCurrencyCode"];
        if(!isoCurrencyCode){
            isoCurrencyCode = @"USD";
        }
        //NSLog(@"isoCurrencyCode: %@", isoCurrencyCode);
        [self setIsoCountryCode:isoCurrencyCode];
        
        // Save SessionID and Expiration Date
        self.sessionID = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"SessionId"];
//        NSString *dateExpires = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"DateExpires"];
//        NSDate *sessionExpirationDate = [ArtAPI extractDataFromAPIString:dateExpires];
//        [self setSessionExpirationDate:sessionExpirationDate];
        
//        NSString *authenticationToken = [[JSON objectForKey:@"d"] objectForKey:@"AuthenticationToken"];
        NSDate *authenticationTokenExpires = [ArtAPI extractDataFromAPIString: [[JSON objectForKey:@"d"] objectForKeyNotNull:@"DateExpires"]];
        [self setAuthenticationTokenExpirationDate:authenticationTokenExpires];

        
        self.persistentID = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"PersistentId"];
        
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
        
        if([[geoIPCountryCode uppercaseString] isEqualToString:@"US"]){
            [ArtAPI sharedInstance].isDeviceConfigForUS = YES;
        }else{
            [ArtAPI sharedInstance].isDeviceConfigForUS = NO;
        }
        if(self.isInitAborted){
            self.isInitAborted = NO;
            return;
        }else
        {
            if((AppLocationSwitchArt == [ACConstants getCurrentAppLocation]) || (AppLocationDefault == [ACConstants getCurrentAppLocation])) /* SA or P2A */
            {
                [ArtAPI applicationGetForSessionWithSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    NSLog(@"YES");
                    [self checkForAuthentication];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    NSLog(@"NO");
                }];
            }
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}


+ (void) requestForGalleryGetUserDefaultGallery:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForGalleryGetUserDefaultGallery:success failure:failure];
}

-(void) requestForGalleryGetUserDefaultGallery:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = nil;
    AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
    if((currAppLoc == AppLocationDefault) || (currAppLoc == AppLocationNone)) // ArtCircles or ArtDials
    {
        parameters = [NSDictionary dictionaryWithObject:@"DefaultMobileGallery" forKey:@"defaultGalleryType"];
    }
    else
    {
        parameters = [NSDictionary dictionaryWithObject:@"DefaultMyPhotosGallery" forKey:@"defaultGalleryType"];
    }
       
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceGalleryGetUserDefaultGallery
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             NSLog(@"request.URL %@",request.URL);
                                             [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
                                             
                                         }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             failure(request, response, error, JSON);
                                         }];
    
    [operation start];
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Authenticaion


+ (void) requestForAccountUpdateProfileWithFirstName:(NSString *) firstName lastName:(NSString *)lastName
                                 success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                 failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForAccountUpdateProfileWithFirstName:firstName lastName:lastName success:success failure:failure];
}

- (void) requestForAccountUpdateProfileWithFirstName:(NSString *) firstName lastName:(NSString *)lastName
                                             success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                             failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:firstName, @"firstName", lastName, @"lastName",nil];
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceAccountUpdateProfile
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    
    NSLog(@"request.URL %@",request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             
                                             [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
                                             
                                         }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             failure(request, response, error, JSON);
                                         }];
    
    
    [operation start];
    
}



+ (void) requestForAccountUpdateProperty:(NSString *) propertyKey
                                withValue:(NSString *) propertyValue
                                 success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForAccountUpdateProperty:propertyKey withValue:propertyValue success:success failure:failure];
}

-(void) requestForAccountUpdateProperty:(NSString *) propertyKey
                               withValue:(NSString *) propertyValue
                                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:propertyKey, @"propertyKey", propertyValue, @"propertyValue",nil];
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"POST"
                                                   resource:kResourceAccountUpdateProperty
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    
    NSLog(@"request.URL %@",request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             
                                             [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
                                             
                                         }
                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             failure(request, response, error, JSON);
                                         }];
    
    
    [operation start];
    
}


+ (void) requestForAccountUpdateLocationWithParameters:(NSDictionary *)parameters
                                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForAccountUpdateLocationWithParameters:parameters success:success failure:failure];
}

- (void) requestForAccountUpdateLocationWithParameters:(NSDictionary *)parameters
                                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    
    /* 
        http://developer-api.art.com/AccountAuthorizationAPI.svc/jsonp/AccountUpdateLocationByType?
        apiKey=A555B7EF46B941C3A13B21537E03427D&
        sessionId=0D3B5AD8CDC9440882A8F3998B1952C7&
        authToken=98772724fd3e412aab1767cecbdf69e3&
        addressType=3&
        addressLine1=41%20Ord%20Street&
        addressLine2=upstairs&
        companyName=myself&
        city=San%20Francisco&
        state=CA&
        twoDigitIsoCountryCode=US&
        zipCode=94114&
        primaryPhone=510-879-4748
     */
    
   // NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:addresstype,@"addressType",addressLine1,@"addressLine1",addressLine2,@"addressLine2",companyName,@"companyName",city,@"city",state,@"state",countryCode,@"twoDigitIsoCountryCode",zipCode,@"zipCode",primaryPhone,@"primaryPhone",nil];
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceAccountUpdateLocationByType
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    
    NSLog(@"request.URL %@",request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             
                                             [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
                                             
                                         }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             failure(request, response, error, JSON);
                                         }];
    
    [operation start];

}

+ (void) requestForAccountGet:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForAccountGet:success failure:failure];
}

-(void) requestForAccountGet:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"Bundles",@"propertiesToReturn",nil];

    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceAccountGet
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        NSLog(@"request.URL %@",request.URL);
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
        
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        failure(request, response, error, JSON);
    }];
    
    [operation start];

}

+ (void) requestForAccountChangePasswordWithOldPassword:(NSString *)oldPassword
                                              newPassword:(NSString *)newPassword
                                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForAccountChangePasswordWithOldPassword:oldPassword newPassword:newPassword success:success failure:failure];
}

- (void) requestForAccountChangePasswordWithOldPassword:(NSString *) oldPassword
                                              newPassword:(NSString *)newPassword
                                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                oldPassword, @"currentPassword",
                                newPassword, @"newPassword",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"POST"
                                                   resource:kResourceAccountChangePassword
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];// CS -- Requires Autotoken as per the SWIT-208
    //NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}



+ (void) requestForAccountCreateAnonymousSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForAccountCreateAnonymousSuccess:success failure:failure];
}

- (void) requestForAccountCreateAnonymousSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceAccountCreateAnonymous
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:nil
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    //NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
        NSDictionary *responseDict = [ JSON objectForKeyNotNull:@"d"];
        [ArtAPI setAuthenticationToken: [responseDict objectForKeyNotNull:@"AuthenticationToken"]];
        NSDictionary *accountDetails = [responseDict objectForKeyNotNull:@"Account"];
        NSDictionary *profileInfo = [accountDetails objectForKeyNotNull:@"ProfileInfo"];
        int accountType = [[profileInfo objectForKeyNotNull:@"AccountType"] intValue];
        
        if((accountType==1)||self.usePersistentIDForAuth){
            [[NSUserDefaults standardUserDefaults] setObject:[JSON objectForKeyNotNull:@"AuthenticationToken"] forKey:ANONYMOUS_AUTH_TOKEN];
        }else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANONYMOUS_AUTH_TOKEN];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self defaultInitiationMethods];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

-(void)defaultInitiationMethods
{
    [ArtAPI requestForGalleryGetUserDefaultGallery:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [SVProgressHUD dismiss];

        NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
        
        // Save Gallery Response
        NSDictionary *defaultGalleryResponse = [JSON objectForKeyNotNull:@"d"];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:defaultGalleryResponse];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"USER_DEFAULT_GALLERY_RESPONSE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSDictionary *responseGallery = [defaultGalleryResponse objectForKeyNotNull:@"Gallery"];
        //        NSArray *responseGalleryItems = [responseGallery objectForKeyNotNull:@"GalleryItems"];
        //        self.data = responseGalleryItems;
        
        NSArray * galleryItems = [responseGallery objectForKeyNotNull:@"GalleryItems"];
        if([galleryItems count]){
            //NSLog(@"setMobileGalleryItems: %@", galleryItems);
            [[ArtAPI sharedInstance] setMobileGalleryItems: galleryItems];
        }
        
        NSDictionary *galleryAttributes = [responseGallery objectForKeyNotNull:@"GalleryAttributes"];
        NSString *defaultGalleryID = [galleryAttributes objectForKeyNotNull:@"GalleryId"];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *myNumber = [f numberFromString:defaultGalleryID];
        [ArtAPI sharedInstance].mobileGalleryID = myNumber;
        
    }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        [SVProgressHUD dismiss];
    }];
}

+ (void) requestForAccountAuthenticateWithEmailAddress:(NSString *) emailAddress
                                              password:(NSString *)password
                                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForAccountAuthenticateWithEmailAddress:emailAddress password:password success:success failure:failure];
}

- (void) requestForAccountAuthenticateWithEmailAddress:(NSString *) emailAddress
                                              password:(NSString *)password
                                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                emailAddress, @"emailAddress",
                                password, @"password",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"POST"
                                                   resource:kResourceAccountAuthenticate
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    //NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];

        NSDictionary *responseDictionary = [JSON objectForKey:@"d"];
        NSString *authenticationToken = [responseDictionary objectForKey:@"AuthenticationToken"];
        if(!authenticationToken || [authenticationToken isKindOfClass:[NSNull class]])
        {
            NSDictionary *operationResponseDict = [responseDictionary objectForKey:@"OperationResponse"];
            NSArray *errosArray = [ operationResponseDict objectForKeyNotNull:@"Errors"];
            if([errosArray count])
            {
                NSDictionary *errorDict = [errosArray objectAtIndex:0];
                NSString *msg = [errorDict objectForKeyNotNull:@"ErrorMessage"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        else
        {
            NSDate *authenticationTokenExpires = [ArtAPI extractDataFromAPIString: [responseDictionary objectForKeyNotNull:@"DateExpires"]];
            [self setAuthenticationTokenExpirationDate:authenticationTokenExpires];
            [self persistAuthenticationToken:authenticationToken];
            // Save Email Address
            self.email = emailAddress;
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) requestForAccountAuthenticateWithSocialUID:(NSString *)gigyaUID
                                       emailAddress:(NSString *)emailAddress
                                          firstName:(NSString *)firstName
                                           lastName:(NSString *)lastName
                                           regToken:(NSString*)regToken
                                            uidSignature:(NSString *)uidSignature signatureTimestamp:(NSString *)signatureTimestamp
                                            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForAccountAuthenticateWithSocialUID:gigyaUID emailAddress:emailAddress firstName:firstName lastName:lastName regToken:regToken uidSignature:uidSignature signatureTimestamp:signatureTimestamp success:success failure:failure];
}

- (void) requestForAccountAuthenticateWithSocialUID:(NSString *)gigyaUID
                                       emailAddress:(NSString *)emailAddress
                                          firstName:(NSString *)firstName
                                           lastName:(NSString *)lastName
                                           regToken:(NSString*)regToken
                                            uidSignature:(NSString *)uidSignature signatureTimestamp:(NSString *)signatureTimestamp
                                            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    //NSLog(@"requestForAccountAuthenticateWithFacebookUID: %@ emailAddress: %@ firstName: %@ lastName: %@ facebookToken: %@",
    //      facebookUID, emailAddress, firstName, lastName,facebookToken);
    // Required
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       gigyaUID, @"socialToken",uidSignature,@"uidsignature",signatureTimestamp,@"signaturetimestamp",
                                       nil];
    // Optional
    if( regToken ){
        [parameters setObject:regToken forKey:@"regToken"];
    }
    if( emailAddress ){
        [parameters setObject:emailAddress forKey:@"emailAddress"];
    }
    //NSLog(@"requestForAccountAuthenticateWithFacebookUID parameters: %@",parameters);
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceAccountAuthenticateWithSocial
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    NSLog(@"AccountAuthenticateWithSocial URL is  %@",[request.URL description]);
    // No SessionId, send to failure
    if( !request){
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"SessionID required but not found" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"local" code:100 userInfo:errorDetail];
        failure(request, nil, error, nil);
    }
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *responseDictionary = [JSON objectForKey:@"d"];
        NSString *authenticationToken = [responseDictionary objectForKey:@"AuthenticationToken"];
        NSDate *authenticationTokenExpires = [ArtAPI extractDataFromAPIString: [responseDictionary objectForKeyNotNull:@"DateExpires"]];
        [self setAuthenticationTokenExpirationDate:authenticationTokenExpires];
        [self persistAuthenticationToken:authenticationToken];

        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
        
        // Save Email Address, firstName, lastName
        self.email = emailAddress;
        self.firstName = firstName;
        self.lastName = lastName;
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}


+ (void) requestForAccountAuthenticateWithFacebookUID:(NSString *)facebookUID
                                         emailAddress:(NSString *)emailAddress
                                            firstName:(NSString *)firstName
                                             lastName:(NSString *)lastName
                                        facebookToken:(NSString*)facebookToken
                                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForAccountAuthenticateWithFacebookUID:facebookUID emailAddress:emailAddress firstName:firstName lastName:lastName facebookToken:facebookToken success:success failure:failure];
}

- (void) requestForAccountAuthenticateWithFacebookUID:(NSString *)facebookUID
                                         emailAddress:(NSString *)emailAddress
                                            firstName:(NSString *)firstName
                                             lastName:(NSString *)lastName
                                        facebookToken:(NSString*)facebookToken
                                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    //NSLog(@"requestForAccountAuthenticateWithFacebookUID: %@ emailAddress: %@ firstName: %@ lastName: %@ facebookToken: %@",
    //      facebookUID, emailAddress, firstName, lastName,facebookToken);
    // Required
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                facebookToken, @"facebookToken",
                                nil];
    // Optional
    if( facebookUID ){
        [parameters setObjectNotNull:facebookUID forKey:@"facebookUID"];
    }
    if( facebookToken ){
        [parameters setObjectNotNull:facebookToken forKey:@"facebookToken"];
    }
    if( lastName ){
        [parameters setObjectNotNull:lastName forKey:@"lastName"];
    }
    if( emailAddress ){
        [parameters setObjectNotNull:emailAddress forKey:@"emailAddress"];
    }
    if( firstName ){
        [parameters setObjectNotNull:firstName forKey:@"firstName"];
    }
    //NSLog(@"requestForAccountAuthenticateWithFacebookUID parameters: %@",parameters);
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceAccountAuthenticateWithFacebookUID
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // No SessionId, send to failure
    if( !request){
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"SessionID required but not found" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"local" code:100 userInfo:errorDetail];
        failure(request, nil, error, nil);
    }
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *responseDictionary = [JSON objectForKey:@"d"];
        NSString *authenticationToken = [responseDictionary objectForKey:@"AuthenticationToken"];
        NSDate *authenticationTokenExpires = [ArtAPI extractDataFromAPIString: [responseDictionary objectForKeyNotNull:@"DateExpires"]];
        [self setAuthenticationTokenExpirationDate:authenticationTokenExpires];
        [self persistAuthenticationToken:authenticationToken];

        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
        
        // Save Email Address, firstName, lastName
        self.email = emailAddress;
        self.firstName = firstName;
        self.lastName = lastName;

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) requestForAccountCreateWithEmailAddress: (NSString *) emailAddress
                                        password:(NSString *)password
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    [[ArtAPI sharedInstance] requestForAccountCreateWithEmailAddress:emailAddress
                                                            password:password
                                                             success:success
                                                             failure:failure];
}

- (void) requestForAccountCreateWithEmailAddress: (NSString *) emailAddress
                                        password:(NSString *)password
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                emailAddress, @"emailAddress",
                                password, @"password",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceAccountCreateExtented
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *responseDictionary = [JSON objectForKey:@"d"];
        NSString *authenticationToken = [responseDictionary objectForKey:@"AuthenticationToken"];
        NSDate *authenticationTokenExpires = [ArtAPI extractDataFromAPIString: [responseDictionary objectForKeyNotNull:@"DateExpires"]];
        [self setAuthenticationTokenExpirationDate:authenticationTokenExpires];
        [self persistAuthenticationToken:authenticationToken];

        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
        
        // Save email addresss
        self.email = emailAddress;
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) requestForAccountCreateWithEmailAddress:(NSString *) emailAddress
                                        password:(NSString *)password
                                       firstName:(NSString *)firstName
                                        lastName:(NSString *)lastName
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForAccountCreateWithEmailAddress:emailAddress
                                                            password:password
                                                            firstName:firstName
                                                            lastName:lastName
                                                             success:success
                                                             failure:failure];
}

- (void) requestForAccountCreateWithEmailAddress: (NSString *) emailAddress
                                        password:(NSString *)password
                                       firstName:firstName
                                        lastName:lastName
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                emailAddress, @"emailAddress",
                                password, @"password",
                                firstName, @"firstname",
                                lastName, @"lastname",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"POST"
                                                   resource:kResourceAccountCreate
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *responseDictionary = [JSON objectForKey:@"d"];
        NSString *authenticationToken = [responseDictionary objectForKey:@"AuthenticationToken"];
        NSDate *authenticationTokenExpires = [ArtAPI extractDataFromAPIString: [responseDictionary objectForKeyNotNull:@"DateExpires"]];
        [self setAuthenticationTokenExpirationDate:authenticationTokenExpires];
        [self persistAuthenticationToken:authenticationToken];

        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
        
        // Save email addresss
        self.email = emailAddress;
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) requestForAccountCreateExtentedEmailAddress:(NSString *) emailAddress
                                        password:(NSString *)password
                                       firstName:(NSString *)firstName
                                        lastName:(NSString *)lastName
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForAccountCreateExtentedEmailAddress:emailAddress
                                                            password:password
                                                           firstName:firstName
                                                            lastName:lastName
                                                             success:success
                                                             failure:failure];
}

- (void) requestForAccountCreateExtentedEmailAddress: (NSString *) emailAddress
                                        password:(NSString *)password
                                       firstName:firstName
                                        lastName:lastName
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                emailAddress, @"emailAddress",
                                password, @"password",
                                firstName, @"firstname",
                                lastName, @"lastname",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceAccountCreateExtented
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];

        NSDictionary *responseDictionary = [JSON objectForKey:@"d"];
        NSString *authenticationToken = [responseDictionary objectForKey:@"AuthenticationToken"];
        if(!authenticationToken || [authenticationToken isKindOfClass:[NSNull class]])
        {
            NSDictionary *operationResponse = [responseDictionary objectForKey:@"OperationResponse"];
            NSArray *errosArray = [ operationResponse objectForKeyNotNull:@"Errors"];
            if([errosArray count])
            {
                NSDictionary *errorDict = [errosArray objectAtIndex:0];
                NSString *msg = [errorDict objectForKeyNotNull:@"ErrorMessage"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        else
        {
            NSDate *authenticationTokenExpires = [ArtAPI extractDataFromAPIString: [responseDictionary objectForKeyNotNull:@"DateExpires"]];
            [self setAuthenticationTokenExpirationDate:authenticationTokenExpires];
            [self persistAuthenticationToken:authenticationToken];
            // Save email addresss
            self.email = emailAddress;
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) requestForAccountMergeFromAuthToken:(NSString *) fromAuthToken
                                            toAuthToken:(NSString *)toAuthToken
                                             success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                             failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForAccountMergeFromAuthToken:fromAuthToken toAuthToken:toAuthToken success:success
                                                         failure:failure];
}

- (void) requestForAccountMergeFromAuthToken:(NSString *) fromAuthToken
                                 toAuthToken:(NSString *)toAuthToken
                                     success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                fromAuthToken, @"fromAuthToken",
                                toAuthToken, @"toAuthToken",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceAccountMerge
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
        
        NSString *authTok = [JSON objectForKeyNotNull:@"AuthenticationToken"];
        NSLog(@"authTok = %@",authTok);
        NSLog(@"JSON = %@",JSON);
        
//        [ArtAPI setAuthenticationToken:authTok];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ANONYMOUS_AUTH_TOKEN"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
      /*  NSError *error;
        [SFHFKeychainUtils deleteItemForUsername:@"PERSISTENT_ID_KEY" andServiceName:[ACAPI sharedAPI].keyChainService error:&error];
        [ACAPI sharedAPI].usePersistentIDForAuth = NO;
        [self getDefaultGallery]; */
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}


+ (void) accountRetrievePasswordWithEmailAddress:(NSString *) emailAddress
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] accountRetrievePasswordWithEmailAddress:emailAddress success:success failure:failure];
}

- (void) accountRetrievePasswordWithEmailAddress:(NSString *) emailAddress
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                emailAddress, @"emailAddress",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceAccountRetrievePassword
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    //NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) requestForAccountSubscribe:(NSDictionary *) subscriptionInfo
                            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure{
    
    [[ArtAPI sharedInstance] requestForAccountSubscribe:subscriptionInfo success:success failure:failure];
    
}

- (void) requestForAccountSubscribe:(NSDictionary *) subscriptionInfo
                            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure{
    
    //NSString *hardCodedString = @"{\"apiKey\":\"A555B7EF46B941C3A13B21537E03427D\",\"sessionId\":\"D7B62F5E9891452B894B7172C6A58512\",\"subscriptionType\":\"PushNotification\",\"subscriptionData\":\"{\"eMailAddress\":\"\",\"phoneNo\":\"\",\"pushNotification\":{\"deviceType\":\"iPhone7,2\",\"deviceToken\":\"f4c82bd1dad5618893d7ea77abeda2e282f7bde43626834bb26ac52505cfe5a5\"}}\"}";
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"POST"
                                                   resource:kResourceAccountSubscribe
                                              usingEndpoint:kEndpointAccountAuthorizationAPI
                                                 withParams:subscriptionInfo
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    NSLog(@"request.URL %@",request.URL);
    NSLog(@"subscriptionInfo %@",subscriptionInfo);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             
                                             [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
                                             
                                         }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             failure(request, response, error, JSON);
                                         }];
    
    
    [operation start];
    
}


+ (void) cartClear:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartClear:success failure:failure];
}

- (void) cartClear:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartClear
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:nil
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    //NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (BOOL)isLoggedIn {
    return [[ArtAPI sharedInstance] isLoggedIn];
    
}

- (BOOL)isLoggedIn {
    if (self.authenticationToken && ([self authTokenExpired] == NO) ) { //&& (nil != self.mobileGalleryID)) {
        return YES;
    }
    return NO;
}

-(void) setAuthenticationTokenExpirationDate:(NSDate *)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"AUTH_TOKEN_EXPIRATION_KEY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setGigyaApiKey:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"GIGYAAPIKEY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)gigyaApiKey
{
    NSString *gigyaKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"GIGYAAPIKEY"];
    return gigyaKey;
}

- (BOOL) authTokenExpired {
    NSDate *authtokenExpirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"AUTH_TOKEN_EXPIRATION_KEY"];
    NSDate *now = [NSDate date];
    
    if (!authtokenExpirationDate) {
        return YES;
    }
    
    if ([authtokenExpirationDate timeIntervalSince1970] > [now timeIntervalSince1970]) {
        return NO;
    } else {
        return YES;
    }
}


// Check is the session is expired and clear the cart if it is
+ (BOOL)sessionIDExpired {
    return [[ArtAPI sharedInstance] sessionIDExpired];
}

- (BOOL)sessionIDExpired {
    NSDate *sessionExpirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:SESSION_EXPIRATION_KEY];
    NSDate *now = [NSDate date];
    
    if ([sessionExpirationDate timeIntervalSince1970] > [now timeIntervalSince1970]) {
        return NO;
    } else {
        self.cart = nil;
        return YES;
    }
}

- (NSDictionary *)getSubscriptionInfo:(NSString *)subscriptionType
                             forEmail:(NSString *)emailAddress
                             forPhone:(NSString *)phoneNumber
                        forDeviceType:(NSString *)deviceType
                       forDeviceToken:(NSString *)deviceToken
                             forAppId:(NSString *)appId{
    
    NSMutableDictionary *retDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    if(subscriptionType==nil) subscriptionType = @"PushNotification";
    if(emailAddress==nil) emailAddress = @"";
    if(phoneNumber==nil) phoneNumber = @"";
    if(deviceType==nil) deviceType = @"";
    if(deviceToken==nil) deviceToken = @"";
    if(appId==nil) appId = @"";
    
    NSString *apiKeyToPass = _apiKey;
    if(apiKeyToPass==nil) apiKeyToPass = @"";
    
    NSString *sessionIDToPass = _sessionID;
    if(sessionIDToPass==nil) sessionIDToPass = @"";
    
    
    NSString *subscriptionDataString = @"{\"eMailAddress\":\"";
    subscriptionDataString = [subscriptionDataString stringByAppendingString:emailAddress];
    subscriptionDataString = [subscriptionDataString stringByAppendingString:@"\",\"phoneNo\":\""];
    subscriptionDataString = [subscriptionDataString stringByAppendingString:phoneNumber];
    subscriptionDataString = [subscriptionDataString stringByAppendingString:@"\",\"pushNotification\":{\"deviceType\":\""];
    subscriptionDataString = [subscriptionDataString stringByAppendingString:deviceType];
    subscriptionDataString = [subscriptionDataString stringByAppendingString:@"\",\"deviceToken\":\""];
    subscriptionDataString = [subscriptionDataString stringByAppendingString:deviceToken];
    subscriptionDataString = [subscriptionDataString stringByAppendingString:@"\",\"appId\":\""];
    subscriptionDataString = [subscriptionDataString stringByAppendingString:appId];
    subscriptionDataString = [subscriptionDataString stringByAppendingString:@"\"}}"];
        
    
    [retDict setObject:apiKeyToPass forKey:@"apiKey"];
    [retDict setObject:sessionIDToPass forKey:@"sessionId"];
    [retDict setObject:subscriptionType forKey:@"subscriptionType"];
    [retDict setObject:subscriptionDataString forKey:@"subscriptionData"];
    
    return retDict;
}

+ (BOOL)isInternalArtNetwork{
    
    //DNS RESOLUTION CHECK - THIS SHOULD STAY DEV-API.ART.COM
    struct hostent *host_entry = gethostbyname("dev-api.art.com");
    //char *buff;
    //buff = inet_ntoa(*((struct in_addr *)host_entry->h_addr_list[0]));
    
    if(host_entry == nil){
        return NO;
    }else{
        return YES;
    }
}

+ (void)start {
    return [[ArtAPI sharedInstance] start];
}

- (void)start {
    self.sessionID = [[NSUserDefaults standardUserDefaults] objectForKey:SESSION_ID_KEY];
    //NSLog(@"ArtAPI.start() sessionID: %@", self.sessionID);
    
    if (self.sessionID == nil || [self sessionIDExpired]) {
        //NSLog(@"start() sessionID == nil or is expired, get new sessionID");
        // Initialize a new session
        [self initilizeApplicationId:self.applicationId apiKey:self.apiKey twoDigitISOLanguageCode:self.twoDigitISOLanguageCode twoDigitISOCountryCode:self.twoDigitISOCountryCode success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            //NIDINFO("SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
        }
                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
                                 NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
                             }];
    }
}

+ (void)logoutArtCircles {
    [[ArtAPI sharedInstance] logoutArtCircles];
}

- (void)logoutArtCircles {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.email = nil;
    self.firstName = nil;
    self.lastName = nil;
    self.authenticationToken = nil;
    
    [defaults removeObjectForKey:AUTH_TOKEN_KEY];
    
    [defaults setObject:nil forKey:@"LOGGED_OUT_GALLERY_PERSISTANCE_KEY"];
    [defaults setObject:nil forKey:@"MOBILE_GALLERY_ID_PERSISTANCE_KEY"];
    [defaults setObject:nil forKey:@"WALL_GALLERY_ID_PERSISTANCE_KEY"];
    [defaults setObject:nil forKey:@"FB_ACCESS_TOKEN_KEY"];
    [defaults setObject:nil forKey:@"FB_EXPIRATION_DATE_KEY"];
    [defaults setObject:nil forKey:@"USER_ACCOUNT_ID"];
    
    /* Clears the hash map used for tracking User's favorite galleries */
    [self clearMobileGalleryMap];

    //[_facebook logout:nil];
    
    //[[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [defaults synchronize];
    
    if ([FBSession activeSession].isOpen) {
        //NSLog(@"logoutAndReset() Has FBSession.  Closing...");
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // Do I really need to listen for the session?
        // https://developers.facebook.com/docs/howtos/login-with-facebook-using-ios-sdk/#step5
    } else {
        //NSLog(@"logoutAndReset() Does not have an active FBSession");
    }
    
    [self start];
}

+ (void)logoutAndRestart {
    [[ArtAPI sharedInstance]  logoutAndRestart];
}

- (void)logoutAndRestart {
    [self logoutAndReset];
    [self start];
}


+ (void)logoutAndReset {
    [[ArtAPI sharedInstance] logoutAndReset];
}


- (void)logoutAndReset {
    //NSLog(@"ArtAPI.logoutAndReset");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.email = nil;
    self.firstName = nil;
    self.lastName = nil;
    self.cart = nil;
    self.authenticationToken = nil;
    self.sessionID = nil;
    self.persistentID = nil;
    
    [defaults removeObjectForKey:AUTH_TOKEN_KEY];
    [defaults removeObjectForKey:SESSION_ID_KEY];

    [defaults setObject:nil forKey:@"LOGGED_OUT_GALLERY_PERSISTANCE_KEY"];
    [defaults setObject:nil forKey:@"CART_PERSISTANCE_KEY"];
    [defaults setObject:nil forKey:@"MOBILE_GALLERY_ID_PERSISTANCE_KEY"];
    [defaults setObject:nil forKey:@"WALL_GALLERY_ID_PERSISTANCE_KEY"];
    [defaults setObject:nil forKey:@"FB_ACCESS_TOKEN_KEY"];
    [defaults setObject:nil forKey:@"FB_EXPIRATION_DATE_KEY"];
    [defaults setObject:nil forKey:@"GIGYAAPIKEY"];
    
    //[_facebook logout:nil];
    
    //[[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [defaults synchronize];
    
     if ([FBSession activeSession].isOpen) {
         //NSLog(@"logoutAndReset() Has FBSession.  Closing...");
         [FBSession.activeSession closeAndClearTokenInformation];
         
         // Do I really need to listen for the session?
         // https://developers.facebook.com/docs/howtos/login-with-facebook-using-ios-sdk/#step5
     } else {
         //NSLog(@"logoutAndReset() Does not have an active FBSession");
     }
}


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
                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    
    [[ArtAPI sharedInstance] decorProductSearchKeyword:keyword refinements:refinements paletteHex:paletteHex pageNumber:pageNumber numProducts:numProducts minWidth:minWidth maxWidth:maxWidth minHeight:minHeight maxHeight:maxHeight minPrice:minPrice maxPrice:maxPrice success:success failure:failure];
}

-(void) decorProductSearchKeyword:(NSString*) keyword
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
                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if( keyword){ [parameters setObject:keyword forKey:@"keyword"]; }
    if( refinements){ [parameters setObject:refinements forKey:@"refinements"]; }
    if( paletteHex){ [parameters setObject:paletteHex forKey:@"paletteHex"]; }
    if( pageNumber){ [parameters setObject:pageNumber forKey:@"pageNumber"]; }
    if( numProducts){ [parameters setObject:numProducts forKey:@"numProducts"]; }
    if( minWidth){ [parameters setObject:keyword forKey:@"minWidth"]; }
    if( maxWidth){ [parameters setObject:keyword forKey:@"maxWidth"]; }
    if( minHeight){ [parameters setObject:minHeight forKey:@"minHeight"]; }
    if( maxHeight){ [parameters setObject:maxHeight forKey:@"maxHeight"]; }
    if( minPrice){ [parameters setObject:keyword forKey:@"minPrice"]; }
    if( maxPrice){ [parameters setObject:maxPrice forKey:@"maxPrice"]; }
    //NSLog(@"parameters: %@", parameters );
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET" path:kResourceProductsForMoodAndColorWithPaging  parameters:parameters server:kArtcomJudyServerAPIUrl];
    
    //NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
        success(request, response, JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (void) palettesForMoodId:(NSNumber*) moodId
                 wallColor:(NSString *) wallColor
                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] palettesForMoodId:moodId wallColor:wallColor success:success failure:failure];
}
- (void) palettesForMoodId:(NSNumber*) moodId
                 wallColor:(NSString *) wallColor
                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       moodId.stringValue, @"moodId",
                                       wallColor, @"wallColor",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET" path:kResourcePalettesForMood  parameters:parameters server:kArtcomJudyServerAPIUrl];
    
    //NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
        // [self processResponse:response];
        success(request, response, JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) productsForMoodId:(NSNumber*) moodId
                    colors:(NSString *) colors
               numProducts:(NSNumber*) numProducts
                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] productsForMoodId:moodId colors:colors numProducts:numProducts success:success failure:failure];
}

- (void) productsForMoodId:(NSNumber*) moodId
                    colors:(NSString *) colors
               numProducts:(NSNumber*) numProducts
                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       moodId.stringValue, @"moodId",
                                       colors, @"paletteHex",
                                       numProducts.stringValue, @"numProducts",
                                       nil];
    //NIDINFO("parameters: %@", parameters );
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET" path:kResourceProductsForMoodAndColor  parameters:parameters server:kArtcomJudyServerAPIUrl];
    
    NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
        // [self processResponse:response];
        success(request, response, JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) productsForMoodId:(NSNumber*) moodId
                    colors:(NSString *) colors
                   keyword:(NSString *) keyword
               numProducts:(NSNumber*) numProducts
                      page:(NSNumber *) page
                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    
    [[ArtAPI sharedInstance] productsForMoodId:moodId colors:colors keyword:keyword numProducts:numProducts page:page success:success failure:failure];
}

+ (void) cancelRequest {
    [[ArtAPI sharedInstance]    cancelRequest];
}

- (void) cancelRequest {
    NSLog(@"cancelRequest");
    //[[NSOperationQueue mainQueue] cancelAllOperations];
    [[[[NSOperationQueue mainQueue] operations] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) { return [evaluatedObject isKindOfClass:[AFHTTPRequestOperation class]]; }]] makeObjectsPerformSelector:@selector(cancel)];
    NSLog(@"canceled");
}

- (void) productsForMoodId:(NSNumber*) moodId
                    colors:(NSString *) colors
                   keyword:(NSString *) keyword
               numProducts:(NSNumber*) numProducts
                      page:(NSNumber *) page
                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       colors, @"paletteHex",
                                       numProducts.stringValue, @"numProducts",
                                       page.stringValue, @"pageNumber",
                                       keyword, @"keyword",
                                       nil];
    if( moodId){
        [parameters setObjectNotNull:moodId.stringValue forKey:@"moodId"];
    }
    //NIDINFO("parameters: %@", parameters );
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET" path:kResourceProductsForMoodAndColorWithPaging  parameters:parameters server:kArtcomJudyServerAPIUrl];
    
    NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
        // [self processResponse:response];
        success(request, response, JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    //[operation start];
    [[NSOperationQueue mainQueue] addOperation:operation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ECommerceAPI

+ (void) frameRecomendationsForItemId:(NSString *) itemId
           maxNumberOfRecommendations:(NSNumber *) maxNumberOfRecommendations
                    maxJpegImageWidth:(int)maxJpegImageWidth
                   maxJpegImageHeight:(int)maxJpegImageHeight
                              success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] frameRecomendationsForItemId:itemId maxNumberOfRecommendations:maxNumberOfRecommendations maxJpegImageWidth:maxJpegImageWidth maxJpegImageHeight:maxJpegImageHeight success:success failure: failure];
}


- (void) frameRecomendationsForItemId:(NSString *) itemId
           maxNumberOfRecommendations:(NSNumber *) maxNumberOfRecommendations
                    maxJpegImageWidth:(int)maxJpegImageWidth
                   maxJpegImageHeight:(int)maxJpegImageHeight
                              success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    //NSLog(@"creating parameters with itemId: %@ class: %@", itemId, NSStringFromClass([itemId class]));
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       itemId, @"itemId",
                                       @"ItemNumber", @"lookupType",
                                       maxNumberOfRecommendations.stringValue, @"maxNumberOfRecommendations",
                                       [NSString stringWithFormat:@"%d", maxJpegImageWidth], @"maxJpegImageWidth",
                                       [NSString stringWithFormat:@"%d", maxJpegImageHeight], @"maxJpegImageHeight",
                                       nil];
    
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCatalogItemGetFrameRecommendations
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    //NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}


+ (void) requestForImageGetMasterVariationsWithLookupType:(NSString *)lookupType
                                                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForImageGetMasterVariationsWithLookupType:lookupType success:success failure:failure];
}

- (void) requestForImageGetMasterVariationsWithLookupType:(NSString *)lookupType
                                                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:
                          lookupType,@"lookupType",
                          nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceImageGetMasterVariations
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:params
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary *responseDict = [[ JSON objectForKey:@"d"] objectForKeyNotNull:@"AvailableSizes" ];
        NSArray *keyArray = [ responseDict allKeys];
        
        NSArray *supportedServicesArray = [ NSArray arrayWithObjects:@"PrintOnly",@"Framing",@"Mounting",@"CanvasMuseum", nil];
        for(NSString *keyName in keyArray)
        {
            if([ supportedServicesArray containsObject: keyName])
            {
                NSArray *servicesArray = [ responseDict objectForKeyNotNull:keyName ];
                [ self processMasterVariations:servicesArray forService:keyName];
            }
        }
        self.isInitFinished = YES;
        self.isInitAborted = NO;
        self.isRestartInProgress = NO;

        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) searchResultInSimpleFormatForProductIds: (NSArray *) productIds
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] searchResultInSimpleFormatForProductIds:productIds success:success failure:failure];
}

- (void) searchResultInSimpleFormatForProductIds: (NSArray *) productIds
                                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    
    NSString * productIdList = [productIds componentsJoinedByString:@","];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"1", @"PageNumber",
                                       @"200", @"RecordsPerPage",
                                       @"3", @"CustomerZoneId",
                                       @"USD", @"CurrencyCode",
                                       @"1", @"LanguageId",
                                       @"false", @"FilterSpecialItems",
                                       productIdList, @"APNumList",
                                       nil];
    NSLog(@"searchResultInSimpleFormatForProductIds: %@",parameters );
    // Create Request
    NSMutableURLRequest *request  = [[ArtAPI sharedInstance] requestWithMethod:@"GET"
                                                                          path:kResourceSearchResultInSimpleFormat
                                                                    parameters:parameters
                                                                        server:kArtcomEdgeSearch];
    
    //NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"searchResultInSimpleFormatForProductIds() url: %@ %@ json: %@ ", request.HTTPMethod, request.URL, JSON);
        //[self processResultsForRequest: request response:response results:JSON success:success failure:failure];
        success(request, response, JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) variationsForItemId:(NSString *) itemId
                     success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] variationsForItemId:itemId success:success failure:failure];
}
- (void) variationsForItemId:(NSString *) itemId
                     success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       itemId, @"itemId",
                                       @"ItemNumber", @"lookupType",
                                       nil];
    
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCatalogItemGetVariations
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}



+ (void) requestForCatalogItemGetForItemId: (NSString *) itemId
                                lookupType:(NSString *)lookupType
                                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForCatalogItemGetForItemId:itemId lookupType:lookupType success:success failure:failure];
}

- (void) requestForCatalogItemGetForItemId:(NSString *)itemId
                                lookupType:(NSString *)lookupType
                                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       itemId, @"itemId",
                                       lookupType, @"lookupType",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCatalogItemGet
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}


+ (void) requestForCatalogItemGetVariations: (NSString *) itemId
                                lookupType:(NSString *)lookupType
                                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForCatalogItemGetVariations:itemId lookupType:lookupType success:success failure:failure];
}

- (void) requestForCatalogItemGetVariations:(NSString *)itemId
                                lookupType:(NSString *)lookupType
                                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       itemId, @"itemId",
                                       lookupType, @"lookupType",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kCatalogItemGetVariations
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) catalogItemSearchForCategoryIdList:(NSString *)categoryIdList
                            numberOfRecords:(NSNumber *)numberOfRecords
                                 pageNumber:(NSNumber *)pageNumber
                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] catalogItemSearchForCategoryIdList:categoryIdList numberOfRecords:numberOfRecords pageNumber:pageNumber success:success failure:failure];
}

- (void) catalogItemSearchForCategoryIdList:(NSString *)categoryIdList
                            numberOfRecords:(NSNumber *)numberOfRecords
                                 pageNumber:(NSNumber *)pageNumber
                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       categoryIdList, @"categoryIdList",
                                       numberOfRecords.stringValue, @"numberOfRecords",
                                       pageNumber.stringValue, @"pageNumber",
                                       @"popularity", @"sortBy",
                                       //@"d", @"sortDirection",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCatalogItemSearch
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    //NSLog(@"request: %@", request);
    if( request == nil){
        return;
    }
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    //[operation start];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (void) catalogGetContentBlockForBlockName:(NSString *)contentBlockName
                                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] catalogGetContentBlockForBlockName:contentBlockName success:success failure:failure];
}

- (void) catalogGetContentBlockForBlockName:(NSString *)contentBlockName
                                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       contentBlockName, @"contentBlockName",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCatalogGetContentBlock
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) catalogetFeaturedCategorieWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] catalogetFeaturedCategorieWithSuccess:success failure:failure];
}

- (void) catalogetFeaturedCategorieWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCatalogGetFeaturedCategories
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:nil
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) requestForCartGetWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForCartGetWithSuccess:success failure:failure];
    //[self requestForCartGetWithSuccess:success failure:failure];
}

- (void) requestForCartGetWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartGet
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:nil
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
                                         }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             failure(request, response, error, JSON);
                                         }];
    [operation start];
}


+ (void) requestForCartAddItemForItemId:(NSString *)itemId
                             lookupType:(NSString *)lookupType
                              quantitiy:(int)quantity
                                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForCartAddItemForItemId:itemId lookupType:lookupType quantitiy:quantity success:success failure:failure];
}

- (void) requestForCartAddItemForItemId:(NSString *)itemId
                             lookupType:(NSString *)lookupType
                              quantitiy:(int)quantity
                                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       itemId, @"itemId",
                                       lookupType, @"lookupType",
                                       [NSString stringWithFormat:@"%d", quantity], @"quantity",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartAddItem
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    NSLog(@"%@", request.URL.absoluteString);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) requestForCartUpdateCartItemQuantityForCartItemId:(NSString *)cartItemId
                                                  quantity:(int)quantity
                                                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForCartUpdateCartItemQuantityForCartItemId:cartItemId quantity:quantity success:success failure:failure];
}

- (void) requestForCartUpdateCartItemQuantityForCartItemId:(NSString *)cartItemId
                             quantity:(int)quantity
                                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       cartItemId, @"cartItemId",
                                       [NSString stringWithFormat:@"%d", quantity], @"quantity",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartUpdateCartItemQuantity
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}


+ (void) requestForCartGetActiveCountryListWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForCartGetActiveCountryListWithSuccess:success failure:failure];
}

- (void) requestForCartGetActiveCountryListWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartGetActiveCountryList
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:nil
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) requestForCartGetActiveStateListByTwoDigitIsoCountryCode:(NSString *)twoDigitIsoCountryCode
                                                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForCartGetActiveStateListByTwoDigitIsoCountryCode:twoDigitIsoCountryCode success:success failure:failure];
}

- (void) requestForCartGetActiveStateListByTwoDigitIsoCountryCode:(NSString *)twoDigitIsoCountryCode
                                                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       twoDigitIsoCountryCode, @"twoDigitIsoCountryCode",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartGetActiveStateListByCountryCode
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) cartGetCityStateSuggestionsCountryCode:(NSString *)countryCode
                                        zipCode:(NSString *)zipCode
                                        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartGetCityStateSuggestionsCountryCode:countryCode
                                                            zipCode:zipCode
                                                            success:success
                                                            failure:failure];
}

- (void) cartGetCityStateSuggestionsCountryCode:(NSString *)countryCode
                                        zipCode:(NSString *)zipCode
                                        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       countryCode, @"twoDigitIsoCountryCode",
                                       zipCode, @"zipCode",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartGetCityStateSuggestions
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}


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
                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartUpdateShippingAddressFirstName:firstName
                                                       lastName:lastName
                                                   addressLine1:addressLine1
                                                   addressLine2:addressLine2
                                                    companyName:companyName
                                                           city:city
                                                          state:state
                                         twoDigitIsoCountryCode:twoDigitIsoCountryCode
                                                            zip:zip
                                                   primaryPhone:primaryPhone
                                                 secondaryPhone:secondaryPhone
                                                   emailAddress:emailAddress
                                                        success:success
                                                        failure:failure];
}

- (void) cartUpdateShippingAddressFirstName:(NSString *)firstName
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
                                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       firstName, @"firstName",
                                       lastName, @"lastName",
                                       addressLine1, @"addressLine1",
                                       addressLine2?addressLine2:@"", @"addressLine2",
                                       companyName?companyName:@"", @"companyName",
                                       city, @"city",
                                       state, @"state",
                                       twoDigitIsoCountryCode, @"twoDigitIsoCountryCode",
                                       zip, @"zipCode",
                                       primaryPhone?primaryPhone:@"", @"primaryPhone",
                                       secondaryPhone?secondaryPhone:@"", @"secondaryPhone",
                                       emailAddress, @"emailAddress",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartUpdateShippingAddress
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) cartGetShippingOptionsWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartGetShippingOptionsWithSuccess:success
                                                       failure:failure];
}

- (void) cartGetShippingOptionsWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{

    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartGetShippingOptions
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:nil
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}


+ (void) cartUpdateShipmentPriority:(int)shipmentPriority
                            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartUpdateShipmentPriority:shipmentPriority
                                                success:success
                                                failure:failure];
}

- (void) cartUpdateShipmentPriority:(int)shipmentPriority
                            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%d",shipmentPriority], @"shipmentPriority",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartUpdateShipmentPriority
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}


+ (void) cartAddCouponCode:(NSString *)couponCode
                            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartAddCouponCode:couponCode
                                       success:success
                                       failure:failure];
}

- (void) cartAddCouponCode:(NSString *)couponCode
                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       couponCode, @"couponCode",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartAddCoupon
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) cartRemoveCoupon:(NSString *)couponCode
                  success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                  failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartRemoveCoupon:couponCode
                                       success:success
                                       failure:failure];
}

- (void) cartRemoveCoupon:(NSString *)couponCode
                  success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                  failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       couponCode, @"couponCode",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartRemoveCoupon
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}

#pragma mark PayPal API methods -----
+ (void) cartGetPaypalToken:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartGetPaypalToken:success failure:failure];
}

- (void) cartGetPaypalToken:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:@"CartGetPayPalToken"
                                              usingEndpoint:kEndpointIPaymentAPI
                                                 withParams:nil
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) cartGetPaymentOptionsWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartGetPaymentOptionsWithSuccess:success
                                                       failure:failure];
}

- (void) cartGetPaymentOptionsWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:@"CartGetPaymentOptions"
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:nil
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}


+ (void) cartSubmitForOrderWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                  failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartSubmitForOrderWithSuccess:success
                                      failure:failure];
}

- (void) cartSubmitForOrderWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                  failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartSubmitForOrder
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:nil
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) cartSubmitForPayPalRestOrderWithPaymentId:(NSString *)paymentId withOrderId:(NSString *) orderId success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartSubmitForPayPalRestOrderWithPaymentId:paymentId withOrderId:orderId success:success
                                                   failure:failure];
}

- (void) cartSubmitForPayPalRestOrderWithPaymentId:(NSString *)paymentId withOrderId:(NSString *) orderId success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       paymentId, @"paymentId",
                                       orderId, @"orderId",
                                       nil];
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartSubmitForPayPalRestOrder
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    NSLog(@"%@", request.URL.absoluteString);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PaymentAPI

+ (void) cartAddPayment:(NSString *)paymentString
                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartAddPayment: paymentString
                                            success:success failure:failure];
}

- (void) cartAddPayment:(NSString *)paymentString
                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       paymentString, @"paymentString",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartAddPayment
                                              usingEndpoint:kEndpointPaymentAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}

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
                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] cartAddCreditCardNumber: cardNumber
                                            cardType:cardType cvv2:cvv2 expiryDateMonth:expiryDateMonth expiryDateYear:expiryDateYear soloIssueNumber:soloIssueNumber firstName:firstName lastName:lastName addressLine1:addressLine1 addressLine2:addressLine2 companyName:companyName city:city state:state twoDigitIsoCountryCode:twoDigitIsoCountryCode zip:zip primaryPhone:primaryPhone secondaryPhone:secondaryPhone emailAddress:emailAddress success:success failure:failure];
}

- (void) cartAddCreditCardNumber:(NSString *)cardNumber
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
                  failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       cardNumber, @"cardNumber",
                                       cardType, @"cardType",
                                       cvv2, @"cvv2",
                                       [NSString stringWithFormat:@"%d", expiryDateMonth], @"expiryDateMonth",
                                       [NSString stringWithFormat:@"%d", expiryDateYear], @"expiryDateYear",
                                       soloIssueNumber,  @"soloIssueNumber",
                                       firstName, @"firstName",
                                       lastName, @"lastName",
                                       addressLine1, @"addressLine1",
                                       addressLine2, @"addressLine2",
                                       companyName, @"companyName",
                                       city, @"city",
                                       state, @"state",
                                       twoDigitIsoCountryCode, @"twoDigitIsoCountryCode",
                                       zip, @"zipCode",
                                       primaryPhone, @"primaryPhone",
                                       secondaryPhone, @"secondaryPhone",
                                       emailAddress, @"emailAddress",
                                       nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartAddCreditCard
                                              usingEndpoint:kEndpointPaymentAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) requestForCartTrackOrderHistory:(NSString *) customerNumber
                        withEmailAddress:(NSString *) emailAddress
                                 success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                 failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForCartTrackOrderHistory:customerNumber withEmailAddress:emailAddress success:success failure:failure];
}

-(void) requestForCartTrackOrderHistory:(NSString *) customerNumber
                              withEmailAddress:(NSString *) emailAddress
                                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:customerNumber, @"customerNumber", emailAddress, @"emailAddress",nil];
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceCartTrackOrderHistory
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    
    NSLog(@"request.URL %@",request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             
                                             [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
                                             
                                         }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             failure(request, response, error, JSON);
                                         }];
    
    [operation start];
    
}

+ (void) requestForCartAddGiftCertificatePayment:(NSString *) giftCertificateCode
                                 success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                 failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForCartAddGiftCertificatePayment:giftCertificateCode success:success failure:failure];
}

-(void) requestForCartAddGiftCertificatePayment:(NSString *) giftCertificateCode
                                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:giftCertificateCode, @"giftCertificateCode",nil];
    
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"POST"
                                                   resource:kResourceCartAddGiftCertificatePayment
                                              usingEndpoint:kEndpointPaymentAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    NSLog(@"request.URL %@",request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             
                                             [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
                                             
                                         }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             failure(request, response, error, JSON);
                                         }];
    
    [operation start];
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Gallery

+ (void) requestForGalleryGetUserDefaultMobileGallerySuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] requestForGalleryGetUserDefaultMobileGallerySuccess:success failure:failure];
}

- (void) requestForGalleryGetUserDefaultMobileGallerySuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceGalleryGetUserDefaultMobileGallery
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:nil
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"SUCCESS url: %@ %@ json: %@ ", request.HTTPMethod, request.URL, JSON);
        
        // Process Mobile Gallery
        [self processMobileGalleryResponse:JSON];
        
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

+ (void) removeGalleryId: (NSNumber *) galleryId
                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] removeGalleryId:galleryId success:success failure:failure];
}

+ (void) removeMobileGallerySuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                 failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSNumber * galleryId = [[ArtAPI sharedInstance] mobileGalleryID];
    [[ArtAPI sharedInstance] removeGalleryId:galleryId success:success failure:failure];
}

- (void) removeGalleryId: (NSNumber *) galleryId
                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                //galleryItemId.stringValue, @"galleryItemId",
                                //galleryId, @"galleryId",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceGalleryDelete
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

/**/
+ (void) removeFromMobileGalleryItemId: (NSNumber *) galleryItemId
                         success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                         failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] removeFromMobileGalleryItemId:galleryItemId success:success failure:failure];
}

- (void) removeFromMobileGalleryItemId: (NSNumber *) galleryItemId
                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSNumber * galleryId = [self mobileGalleryID];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                galleryItemId.stringValue, @"galleryItemId",
                                galleryId, @"galleryId",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceGalleryRemoveItem
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processMobileGalleryResponse:JSON];
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}

/**/

+(void) processMobileGalleryResponse: (NSDictionary*) mobileGalleryResponse {
    [[ArtAPI sharedInstance] processMobileGalleryResponse:mobileGalleryResponse];
}

-(void) processMobileGalleryResponse: (NSDictionary*) mobileGalleryResponse {
    // Save mobile galleryID
    NSDictionary * gallery = [[mobileGalleryResponse objectForKeyNotNull:@"d"] objectForKeyNotNull:@"Gallery"];
    NSLog(@"mobileGalleryResponse %@ gallery: %@", mobileGalleryResponse,gallery);
    
    NSDictionary *userInfoDict = nil;
    
    if(gallery){
        userInfoDict = [NSDictionary dictionaryWithObject:gallery forKey:@"gallery"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MOBILE_GALLERY_UPDATED" object:nil userInfo:userInfoDict];
    
    if(gallery){
        NSDictionary * galleryAttributes = [gallery objectForKeyNotNull:@"GalleryAttributes"];
        if(galleryAttributes){
            NSNumber * galleryId = [galleryAttributes objectForKeyNotNull:@"GalleryId"];
            if(galleryId){
                //NSLog(@"setMobileGalleryID: %@", galleryId);
                [self setMobileGalleryID:galleryId];
            }
            // Save mobile gallery Items
            NSArray * galleryItems = [gallery objectForKeyNotNull:@"GalleryItems"];
            if(galleryItems){
                //NSLog(@"setMobileGalleryItems: %@", galleryItems);
                [self setMobileGalleryItems: galleryItems];
                //NSLog(@"MobileGalleryItems: %@", [ArtAPI mobileGalleryItems]);
            }
        }
    }
}

+ (void) addGalleryToBookmark: (NSString *) galleryId
                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] addGalleryToBookmarks:galleryId success:success failure:failure] ;
}

- (void) addGalleryToBookmarks: (NSString *) galleryId
                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
//    NSNumber * galleryId = [self mobileGalleryID];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                galleryId, @"galleryId",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceBookmarkAddGallery
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    //NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [self updateBookmarksDictionary:JSON];
        
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
    
    // Analytics
    //NSDictionary *analyticsParams = [[NSMutableDictionary alloc] initWithCapacity:1];
    //[analyticsParams setValue:galleryItem.itemID forKey:@"ItemID"];
    //[Analytics logEvent:ANALYTICS_EVENT_NAME_ITEM_ADDED_TO_FAVORITES withParams:analyticsParams];
}

+ (void) removeGalleryToBookmark: (NSString *) galleryId
                      success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] removeGalleryToBookmark:galleryId success:success failure:failure] ;
}

- (void) removeGalleryToBookmark: (NSString *) galleryId
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    //    NSNumber * galleryId = [self mobileGalleryID];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                galleryId, @"galleryId",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceBookmarkRemoveGallery
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    //NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [self updateBookmarksDictionary:JSON];
        
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
    
    // Analytics
    //NSDictionary *analyticsParams = [[NSMutableDictionary alloc] initWithCapacity:1];
    //[analyticsParams setValue:galleryItem.itemID forKey:@"ItemID"];
    //[Analytics logEvent:ANALYTICS_EVENT_NAME_ITEM_ADDED_TO_FAVORITES withParams:analyticsParams];
}



+ (void) addToMobileGalleryItemId: (NSString *) itemId
                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] addToMobileGalleryItemId:itemId success:success failure:failure] ;
}

- (void) addToMobileGalleryItemId: (NSString *) itemId
                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSNumber * galleryId = [self mobileGalleryID];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                itemId, @"itemId",
                                galleryId, @"galleryId",
                                @"ItemNumber", @"lookupType",
                                nil];
    // Create Request
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:kResourceGalleryAddItem
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    //NSLog(@"starting request url: %@ %@", request.HTTPMethod, request.URL);
    
    // Execute Request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [self processMobileGalleryResponse:JSON];
        
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
    
    // Analytics
    //NSDictionary *analyticsParams = [[NSMutableDictionary alloc] initWithCapacity:1];
    //[analyticsParams setValue:galleryItem.itemID forKey:@"ItemID"];
    //[Analytics logEvent:ANALYTICS_EVENT_NAME_ITEM_ADDED_TO_FAVORITES withParams:analyticsParams];
}

-(void) clearMobileGalleryMap
{
    [_mobileGalleryMap removeAllObjects];
}

+(NSString*) galleryItemIdForItemId: (NSString *) itemId {
    return [[ArtAPI sharedInstance] galleryItemIdForItemId:itemId];
}

-(NSString *) galleryItemIdForItemId: (NSString *) itemId {
    return [_mobileGalleryMap objectForKey:itemId];
}

-(void) refreshMobileGalleryMapWithGalleryItem: (NSArray *)mobileGalleryItems   {
    if( !_mobileGalleryMap ){
        _mobileGalleryMap = [NSMutableDictionary dictionary];
    }
    [_mobileGalleryMap removeAllObjects];

    if( mobileGalleryItems && mobileGalleryItems.count > 0){
        for( NSDictionary * galleryItem in mobileGalleryItems){
            //NSLog(@"galleryItem: %@", galleryItem );
            NSString * galleryItemId = [galleryItem objectForKey:@"GalleryItemId"];
            NSString * itemId = [[galleryItem objectForKey:@"Item"] objectForKey:@"ItemNumber"];
            
            [_mobileGalleryMap setObjectNotNull:galleryItemId forKey:itemId];
        }
    }
    
    //NSLog(@"refreshMobileGallery() _mobileGalleryMap: %@", _mobileGalleryMap );
}

- (NSString *) myPhotosGalleryID {
    if (!_savedMyPhotosGalleryID) {
        _savedMyPhotosGalleryID = [[NSUserDefaults standardUserDefaults] stringForKey:@"MY_PHOTOS_GALLERY_ID_PERSISTANCE_KEY"];
    }
    return _savedMyPhotosGalleryID;
}

- (void) setMyPhotosGalleryID:(NSString *)galleryID {
    _savedMyPhotosGalleryID = galleryID;
    [[NSUserDefaults standardUserDefaults] setObject:galleryID forKey:@"MY_PHOTOS_GALLERY_ID_PERSISTANCE_KEY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


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
                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure{
    
    [[ArtAPI sharedInstance] feedGetForAccountID:accountID feedScope:feedScope recordCount:recordCount timeStamp:timeStamp timeStampType:timeStampType includeFeedItems:includeFeedItems noCachedCopy:noCachedCopy success:success failure:failure];
    
}

- (void) feedGetForAccountID:(NSString *)accountID
                   feedScope:(NSString *)feedScope
                 recordCount:(int)recordCount
                   timeStamp:(NSString *)timeStamp
               timeStampType:(NSString *)timeStampType
            includeFeedItems:(BOOL)includeFeedItems
                noCachedCopy:(BOOL)noCachedCopy
                     success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       accountID, @"accountID",
                                       feedScope, @"feedScope",
                                       [NSString stringWithFormat:@"%d",recordCount], @"recordCount",
                                       timeStamp, @"timeStamp",
                                       timeStampType, @"timeStampType",
                                       includeFeedItems?@"true":@"false",@"includeFeedItems",
                                       noCachedCopy?@"true":@"false",@"noCachedCopy",
                                       nil];
    if(self.authenticationToken){
        [parameters setObjectNotNull:self.authenticationToken forKey:@"authToken"];
    }
    
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:@"FeedGet"
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:NO];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
    
}


+ (void) profileAddFollowForLookupType:(NSString *)profileLookupType
                     accountIdentifier:(NSString *)accountIdentifier
                    returnBareResponse:(BOOL)returnBareResponse
                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] profileAddFollowForLookupType:profileLookupType accountIdentifier:accountIdentifier returnBareResponse:returnBareResponse success:success failure:failure];
}

- (void) profileAddFollowForLookupType:(NSString *)profileLookupType
                     accountIdentifier:(NSString *)accountIdentifier
                    returnBareResponse:(BOOL)returnBareResponse
                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       profileLookupType, @"LookupType",
                                       accountIdentifier, @"accountIdentifier",
                                       returnBareResponse?@"true":@"false",@"returnBareResponse",
                                       nil];
    
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:@"ProfileAddFollow"
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}


+ (void) profileRemoveFollowForLookupType:(NSString *)profileLookupType
                     accountIdentifier:(NSString *)accountIdentifier
                    returnBareResponse:(BOOL)returnBareResponse
                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    [[ArtAPI sharedInstance] profileRemoveFollowForLookupType:profileLookupType accountIdentifier:accountIdentifier returnBareResponse:returnBareResponse success:success failure:failure];
}

- (void) profileRemoveFollowForLookupType:(NSString *)profileLookupType
                     accountIdentifier:(NSString *)accountIdentifier
                    returnBareResponse:(BOOL)returnBareResponse
                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       profileLookupType, @"LookupType",
                                       accountIdentifier, @"accountIdentifier",
                                       returnBareResponse?@"true":@"false",@"returnBareResponse",
                                       nil];
    
    NSMutableURLRequest *request  = [self requestWithMethod:@"GET"
                                                   resource:@"ProfileRemoveFollow"
                                              usingEndpoint:kEndpointECommerceAPI
                                                 withParams:parameters
                                            requiresSession:YES
                                            requiresAuthKey:YES];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self processResultsForRequest: request response:response results:JSON success:success failure:failure];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        failure(request, response, error, JSON);
    }];
    [operation start];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Getters & Setters

+ (NSString *) authenticationToken {
    return [[ArtAPI sharedInstance] authenticationToken];
}

- (NSString *)authenticationToken {
    if (!_authenticationToken) {
         _authenticationToken = [[NSUserDefaults standardUserDefaults] objectForKey:AUTH_TOKEN_KEY];
    }
    //NSLog(@"authenticationToken: %@", _authenticationToken);
    return _authenticationToken;
}

+ (void)setAuthenticationToken:(NSString *)authenticationToken {
    [[ArtAPI sharedInstance] setAuthenticationToken:authenticationToken];
}

- (void)setAuthenticationToken:(NSString *)authenticationToken {
    //NSLog(@"saving to keychain authenticationToken: %@", authenticationToken );
    _authenticationToken = authenticationToken;
    if (authenticationToken) {
        [[NSUserDefaults standardUserDefaults] setObject:authenticationToken forKey:AUTH_TOKEN_KEY];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:AUTH_TOKEN_KEY];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)sessionID {
    return [[ArtAPI sharedInstance] sessionID];
}

- (NSString *)sessionID {
    if (!_sessionID) {
        _sessionID = [[NSUserDefaults standardUserDefaults] objectForKey:SESSION_ID_KEY ];
    }
    //NSLog(@"sessionID: %@", _sessionID);
    return _sessionID;
}

//FrameyouArt


+ (void)setSessionID:(NSString *)sessionID {
    [[ArtAPI sharedInstance] setSessionID:sessionID];
}

- (void)setSessionID:(NSString *)sessionID {
    //NSLog(@"ArtAPI.saving to keychain sessionID: %@", sessionID );
    _sessionID = sessionID;
    if (sessionID) {
        //NSLog(@"store sessionId: %@", sessionID);
        [[NSUserDefaults standardUserDefaults] setObject:sessionID forKey:SESSION_ID_KEY];
    }
    else {
        //NSLog(@"delete");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SESSION_ID_KEY];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//
+ (NSString *)persistentID {
    return [[ArtAPI sharedInstance] persistentID];
}

- (NSString *)persistentID {
    if (!_persistentID) {
        _persistentID = [[NSUserDefaults standardUserDefaults] objectForKey:PERSISTENT_ID_KEY ];
    }
    //NSLog(@"persistentID: %@", _persistentID);
    return _persistentID;
}

+ (void)setPersistentID:(NSString *)persistentID {
    [[ArtAPI sharedInstance] setPersistentID:persistentID];
}

- (void)setPersistentID:(NSString *)persistentID {
    //NSLog(@"ArtAPI.saving to keychain persistentID: %@", persistentID );
    _persistentID = persistentID;
    if (persistentID) {
        //NSLog(@"store persistentID: %@", persistentID);
        [[NSUserDefaults standardUserDefaults] setObject:persistentID forKey:PERSISTENT_ID_KEY];
    }
    else {
        //NSLog(@"delete");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PERSISTENT_ID_KEY];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//

- (void)persistSessionID:(NSString *)sessionID {
    self.sessionID = sessionID;
}

- (void)persistAuthenticationToken:(NSString *)authToken {
    self.authenticationToken = authToken;
}

+ (NSDate *) sessionExpirationDate {
    return [[ArtAPI sharedInstance] sessionExpirationDate];
}

- (NSDate *)sessionExpirationDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SESSION_EXPIRATION_KEY];
}


+ (void) setSessionExpirationDate: (NSDate*) sessionExpirationDate {
    [[ArtAPI sharedInstance] setSessionExpirationDate:sessionExpirationDate];
}

- (void) setSessionExpirationDate: (NSDate*) sessionExpirationDate {
    [[NSUserDefaults standardUserDefaults] setObject:sessionExpirationDate
                                              forKey:SESSION_EXPIRATION_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setCart:(NSDictionary *)cartDictionary {
    
    [[ArtAPI sharedInstance] setCart:cartDictionary];
}

- (void)setCart:(NSDictionary *)cartDictionary
{
    _cart = cartDictionary;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cartDictionary];
    
    if(data){
        NSLog(@"Cart Data is not nil");
    }else{
        NSLog(@"Cart Data is nil");
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"CART_PERSISTANCE_KEY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CART_UPDATED" object:nil];
}

+ (NSDictionary *)cart {
    
   // NSLog(@"Cart dictionary contains %i nodes", [[[ArtAPI sharedInstance] cart] count]);
    
    return [[ArtAPI sharedInstance] cart];
}

- (NSDictionary *)cart {
    if (!_cart) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"CART_PERSISTANCE_KEY"];
        _cart = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _cart;
}

- (NSNumber *)wallGalleryID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"WALL_GALLERY_ID_PERSISTANCE_KEY"];
}

- (void)setWallGalleryID:(NSNumber *)galleryID {
    [[NSUserDefaults standardUserDefaults] setObject:galleryID forKey:@"WALL_GALLERY_ID_PERSISTANCE_KEY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber *)mobileGalleryID {
    //return [[NSUserDefaults standardUserDefaults] objectForKey:@"MOBILE_GALLERY_ID_PERSISTANCE_KEY"];
    NSNumber * galleryID = [[NSUserDefaults standardUserDefaults] objectForKey:@"MOBILE_GALLERY_ID_PERSISTANCE_KEY"];
    //NSLog(@"mobileGalleryID =  %@", galleryID);
    return galleryID;
}

- (void)setMobileGalleryID:(NSNumber *)galleryID {
    //NSLog(@"setMobileGalleryID: %@", galleryID);
    [[NSUserDefaults standardUserDefaults] setObject:galleryID forKey:@"MOBILE_GALLERY_ID_PERSISTANCE_KEY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



+ (NSArray *)mobileGalleryItems {
    //NSArray * mobileGalleryItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"MOBILE_GALLERY_ITEMS_PERSISTANCE_KEY"];
    //NSLog(@"mobileGalleryItems =  %@", mobileGalleryItems);
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"MOBILE_GALLERY_ITEMS_PERSISTANCE_KEY"];
    NSArray *mobileGalleryItems = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return mobileGalleryItems;
}
/*
 - (NSArray *)mobileGalleryItems {
 NSArray * mobileGalleryItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"MOBILE_GALLERY_ITEMS_PERSISTANCE_KEY"];
 NSLog(@"mobileGalleryItems =  %@", mobileGalleryItems);
 return mobileGalleryItems;
 }*/

- (void)setMobileGalleryItems:(NSArray *)mobileGalleryItems {
    //NSLog(@"setMobileGalleryItems: %@", mobileGalleryItems);
    //[[NSUserDefaults standardUserDefaults] setObject:mobileGalleryItems forKey:@"MOBILE_GALLERY_ITEMS_PERSISTANCE_KEY"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mobileGalleryItems];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"MOBILE_GALLERY_ITEMS_PERSISTANCE_KEY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self refreshMobileGalleryMapWithGalleryItem: mobileGalleryItems];
}

+ (BOOL) isDeviceConfigForUS {
    return [[ArtAPI sharedInstance] isDeviceConfigForUS];
}

+ (NSArray *) getCountries {
    return [[ArtAPI sharedInstance] countries];
}

+ (void) setCountries:(NSArray*) countries {
    return [[ArtAPI sharedInstance] setCountries:countries];
}

+ (NSArray *) getStates {
    return [[ArtAPI sharedInstance] states];
}

+ (void) setStates:(NSArray*) states {
    return [[ArtAPI sharedInstance] setStates:states];
}

+ (NSString *) getShippingCountryCode {
    return [[ArtAPI sharedInstance] shippingCountryCode];
}

+ (void) setShippingCountryCode:(NSString*) shippingCountryCode {
    return [[ArtAPI sharedInstance] setShippingCountryCode:shippingCountryCode];
}

+ (NSString *) getCurrentYear {
    return [[ArtAPI sharedInstance] currentYear];
}

+ (void) setCurrentYear:(NSString*) currentYear {
    return [[ArtAPI sharedInstance] setCurrentYear:currentYear];
}

+ (NSString *) getCurrentMonth {
    return [[ArtAPI sharedInstance] currentMonth];
}

+ (void) setCurrentMonth:(NSString*) currentMonth {
    return [[ArtAPI sharedInstance] setCurrentMonth:currentMonth];
}

+ (NSString *) getEmail {
    return [[ArtAPI sharedInstance] email];
}

- (void)setEmail:(NSString *)email{
    _email = email;
    if (email) {
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:EMAIL_KEY];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:EMAIL_KEY];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)email {
    if (!_email) {
        _email = [[NSUserDefaults standardUserDefaults] objectForKey:EMAIL_KEY];
    }
    return _email;
}

+ (NSString *) getFirstName {
    return [[ArtAPI sharedInstance] firstName];
}


- (void)setFirstName:(NSString *)firstName{
    _firstName = firstName;
    if (firstName) {
        [[NSUserDefaults standardUserDefaults] setObject:firstName forKey:FIRST_NAME_KEY];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:FIRST_NAME_KEY];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)firstName {
    if (!_firstName) {
        _firstName = [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_NAME_KEY];
    }
    return _firstName;
}

+ (NSString *) getLastName {
    return [[ArtAPI sharedInstance] lastName];
}

- (void)setLastName:(NSString *)lastName{
    _lastName = lastName;
    if (lastName) {
        [[NSUserDefaults standardUserDefaults] setObject:lastName forKey:LAST_NAME_KEY];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:LAST_NAME_KEY];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)lastName {
    if (!_lastName) {
        _lastName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_NAME_KEY];
    }
    return _lastName;
}

-(void) setIsoCountryCode:(NSString *) isoCountryCode {
    if(isoCountryCode){
        [[NSUserDefaults standardUserDefaults] setObject: isoCountryCode forKey:@"Currency_Code_to_use"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Currency_Code_to_use"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
- (void) refreshAuthenticationTokenUsingStoredCredentials {
    [ArtAPI setAuthenticationToken:nil];
    NSError *error;
    NSString *email = [SFHFKeychainUtils getPasswordForUsername:EMAIL_KEY andServiceName:self.keyChainService error:&error];
    NSString *password = [SFHFKeychainUtils getPasswordForUsername:PASSWORD_KEY andServiceName:self.keyChainService error:&error];
    
    NSString *facebookUID = [SFHFKeychainUtils getPasswordForUsername:FACEBOOK_UID_KEY andServiceName:self.keyChainService error:&error];
    NSString *firstName = [[NSUserDefaults standardUserDefaults] stringForKey:@"FIRST_NAME"];
    
    NSString *lastName = [[NSUserDefaults standardUserDefaults] stringForKey:@"LAST_NAME"];
    
    if (error) {
        if (SERVICE_LOGGING) NSLog(@"Error retrieving email and password from keychain");
        return;
    }
    if (email && password) {
        [[ASIHTTPRequest sharedQueue] cancelAllOperations];
        [[ASIHTTPRequest sharedQueue] setMaxConcurrentOperationCount:1];
        ACJSONAPIRequest *request = [[ACAPI sharedAPI] requestForAccountAuthenticateWithDelegate:self emailAddress:email password:self.password];
        [request setDidFinishSelector:@selector(refreshAuthenticationTokenUsingStoredCredentialsDidFinish:)];
        [request startAsynchronous];
    }
    else if (facebookUID) {
        [[ASIHTTPRequest sharedQueue] cancelAllOperations];
        [[ASIHTTPRequest sharedQueue] setMaxConcurrentOperationCount:1];
        ACJSONAPIRequest *request = [[ACAPI sharedAPI] requestForAccountAuthenticateWithFacebookUIDwithDelegate:self facebookUID:facebookUID emailAddress:email firstName:firstName lastName:lastName];
        [request setDidFinishSelector:@selector(refreshAuthenticationTokenUsingStoredCredentialsDidFinish:)];
        [request startAsynchronous];
        
    }
} */

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Request

- (NSMutableURLRequest *) requestWithMethod:(NSString * )method
                                   resource:(NSString *)resource
                              usingEndpoint:(NSString *)endpoint
                                 withParams:(NSDictionary *)parameters
                            requiresSession:(BOOL)requiresSession
                            requiresAuthKey:(BOOL)requiresAuthKey {
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    // Add API Key
    
    
    // Add Session if required
    if (requiresSession) {
        if (![self sessionID]){
            NSLog(@"SessionID required but not found");
            return nil;
        }
        //NSLog(@"setting sessionId: %@", [self sessionID] );
        [params setObject:[self sessionID] forKey:@"sessionId"];
    }
    
    if (requiresAuthKey) {
        if (![self authenticationToken]) {
            NSLog(@"authToken required but not found");
            return nil;
        }
        [params setObject:[self authenticationToken] forKey:@"authToken"];
    }
    
    // Add Auth Key
    //NSLog(@"setting apiKey: %@", [self apiKey] );
    [params setObjectNotNull:[self apiKey] forKey:@"apiKey"];
    
    NSString *protocol = kProtocolDefault;
    if ([endpoint isEqualToString:kEndpointAccountAuthorizationAPI]) {
        protocol = kProtocolSecure;
    }
    if ([endpoint isEqualToString:kEndpointPaymentAPI]) {
        protocol = kProtocolSecure;
    }
    
    NSString * host = [NSString stringWithFormat:@"%@%@", protocol,[ACConstants getEnvironment]/*kArtAPIUrl*/];
    
    NSString * path = [NSString stringWithFormat:@"/%@.svc/jsonp/%@",endpoint, resource ];
    
    if([resource isEqualToString:kResourceAccountSubscribe]){
        //host = [host stringByReplacingOccurrencesOfString:@"developer-api.art.com" withString:@"10.130.117.67"];
    }
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:host]];
    
    if([resource isEqualToString:kResourceAccountUpdateProperty] || [resource isEqualToString:kResourceAccountSubscribe] || /*[resource isEqualToString:kResourceAccountCreate] ||*/ [resource isEqualToString:kResourceAccountAuthenticate] /*|| [resource isEqualToString:kResourceAccountCreateExtented]*/){
        path = [NSString stringWithFormat:@"/%@.svc/V2/jsonp/%@",endpoint, resource ];
    }
    
    if([resource isEqualToString:kResourceAccountSubscribe]){
        httpClient.parameterEncoding = AFJSONParameterEncoding;
    }
    
    if([resource isEqualToString:kResourceCartAddGiftCertificatePayment]){
        httpClient.parameterEncoding = AFJSONParameterEncoding;
    }
    
    if([resource isEqualToString:kResourceAccountAuthenticate])
    {
        httpClient.parameterEncoding = AFJSONParameterEncoding;
    }
    
    [httpClient defaultValueForHeader:@"Accept"];
    //NSLog(@"httpClient: %@ method: %@ path: %@ params: %@", httpClient, method, path, params);
    NSMutableURLRequest *request = [httpClient requestWithMethod:method path:path parameters:params];
    NSLog(@"request: %@", request);
    return request;
}

/**
 * Making a requests on a non api-art.com server
 *
 **/
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSMutableDictionary *)parameters
                                    server: (NSString *) server {
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    [httpClient defaultValueForHeader:@"Accept"];
    NSMutableURLRequest *request = [httpClient requestWithMethod:method path:path parameters:parameters];
    return request;
}

-(NSDictionary *) processResponse: (NSHTTPURLResponse *) response responseObject: (id) JSON {
    NSMutableDictionary * json = [NSMutableDictionary dictionaryWithDictionary:JSON];
    //NSLog(@"processResponse() json: %@", JSON);
    
    NSDictionary *responseDictionary = nil;
    NSString *responseType = nil;
    NSDictionary *operationResponse = nil;
    NSNumber *responceCode = nil;
    NSString *responceMessage = nil;
    
    if ([JSON isKindOfClass:[NSDictionary class]]) {
        responseDictionary = [JSON objectForKey:@"d"];
        responseType = [responseDictionary objectForKey:@"__type"];
        
        
        operationResponse = [responseDictionary objectForKeyNotNull:@"OperationResponse"];
        if (operationResponse) {
            responceCode = [operationResponse objectForKey:@"ResponseCode"];
            responceMessage = [operationResponse objectForKey:@"ResponseMessage"];
        }
        else {
            responceCode = [responseDictionary objectForKey:@"ResponseCode"];
            responceMessage = [responseDictionary objectForKey:@"ResponseMessage"];
            if (!responceMessage) {
                responceMessage = [responseDictionary objectForKey:@"PaymentResponse"];
            }
        }
        
        if ([responceMessage rangeOfString:@"instance"].length > 1) {
            responceMessage = @"An unexpected error has occurred, please try again.";
        }
        
        if (responseDictionary && [responceCode isEqualToNumber:[NSNumber numberWithInt:200]]) {
            //self.APIResponseCode = 200;
            //self.APIResponse = responseDictionary;
            [json setObjectNotNull:responceCode forKey:@"APIResponseCode"];
            NSString *t = [[responseType componentsSeparatedByString:@":"] objectAtIndex:0];
            //self.APIResponseType = t;
            [json setObjectNotNull:t forKey:@"APIResponseType"];
            
            // Extract Session Token
         /*   if ([t isEqualToString:@"SessionResponse"]) {
                NSString *sessionID = [responseDictionary objectForKey:@"SessionId"];
                [self persistSessionID:sessionID];
            }
            
            // Extract Authentication Token
            if ([t isEqualToString:@"AuthorizationResponse"]) {
                NSString *authenticationToken = [responseDictionary objectForKey:@"AuthenticationToken"];
                NSDate *authenticationTokenExpires = [ArtAPI extractDataFromAPIString: [responseDictionary objectForKeyNotNull:@"DateExpires"]];
                [self setAuthenticationTokenExpirationDate:authenticationTokenExpires];
                [self persistAuthenticationToken:authenticationToken];
            } */ //Jobin: Supporting POST calls
            
        }
        else {
            //self.APIResponseCode = [responceCode intValue];
            [json setObjectNotNull:responceCode forKey:@"APIResponseCode"];
            //self.APIErrorMessage = responceMessage;
            [json setObjectNotNull:responceMessage forKey:@"APIErrorMessage"];
            if ([responceMessage length] < 1) {
                //self.APIErrorMessage = @"Empty Response";
                [json setObjectNotNull:@"Empty Response" forKey:@"APIErrorMessage"];
            }
        }
    }
    return json;
}

- (void) processResultsForRequest:(NSURLRequest *) request
                         response: (NSHTTPURLResponse *) response
                          results: (id) JSON
                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    JSON = [self processResponse:response responseObject: JSON];
    if( [[JSON objectForKey:@"APIResponseCode"] isEqualToNumber:[NSNumber numberWithInt:200]]){

        success(request, response, JSON);
    } else {
        
        /*
        if([[JSON objectForKey:@"APIErrorMessage"] isEqualToString:@"Invalid session identifier."]){
            NSLog(@"handle invalid session for url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
            [self logoutAndReset];
        }
         */
        failure(request, response, nil, JSON);
    }
}

- (void)updateBookmarksDictionary:(NSDictionary *)response
{
    NSDictionary *responseToUse = [response objectForKeyNotNull:@"d"];
    NSArray *profiles = [responseToUse objectForKeyNotNull:@"Profiles"];
    if(profiles.count>0){
        NSArray *bookmarks = [[profiles objectAtIndex:0] objectForKeyNotNull:@"Bookmarks"];
        
        if(bookmarks&&bookmarks.count>0){
            NSMutableDictionary *bookMarksDictionarySet = [[NSMutableDictionary alloc] init];
            for(NSDictionary *dict in bookmarks){
                NSDictionary *galleryAttributes = [dict objectForKeyNotNull:@"GalleryAttributes"];
                NSString *bookmarkId = [galleryAttributes objectForKeyNotNull:@"GalleryId"];
                if(bookmarkId){
                    [bookMarksDictionarySet setObjectNotNull:dict forKey:bookmarkId];
                }
                
            }
            if([[bookMarksDictionarySet allKeys] count]>0)
            {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bookMarksDictionarySet];
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"USER_BOOKMARKS_DICTIONARY"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"USER_BOOKMARKS_DICTIONARY"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"USER_BOOKMARKS_DICTIONARY"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utils

+ (NSString*) cleanImageUrl:(NSString *) imageURLString withSize: (int) size {
    NSString * sub1 = @"MXW:200+MXH:200";
    NSString * sub2 = @"MXW:640+MXH:640";
    
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"://qa-" withString:@"://"];
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"%5c" withString:@"\\"];
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"%5C" withString:@"\\"];
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"%5B" withString:@"["];
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"%5D" withString:@"]"];
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"%7C" withString:@"|"];
    NSString *sizeOverrideString = [NSString stringWithFormat:@"MXW:%d+MXH:%d", size, size]; // TODO: do better... what if it isn't 200
    
    if ([imageURLString rangeOfString:sub1].location != NSNotFound) {
        imageURLString = [imageURLString stringByReplacingOccurrencesOfString:sub1 withString:sizeOverrideString];
    }
    
    if ([imageURLString rangeOfString:sub2].location != NSNotFound) {
        imageURLString = [imageURLString stringByReplacingOccurrencesOfString:sub2 withString:sizeOverrideString];
    }
    
    NSString *imageURLStringEscaped = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) imageURLString, NULL, NULL, kCFStringEncodingUTF8));
    return imageURLStringEscaped;
}

/*
 The Art.com API returns dates formated like this:  /Date(1308646107731-0700)/
 Note: the slashes are included.
 The format is basically a unix time stamp (seconds seince 1970), with three digits concataneted (miliseconds), followed by a timezone.
 The whole thing is wrapped in the slashes and word date
 */

+ (NSDate *) extractDataFromAPIString:(NSString *)originalString {
    NSMutableString *strippedString = [[NSMutableString alloc] init];
    
    //String out everything but the digits and the dash
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789-+"];
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    
    NSString *miliSeconds = @"";
    NSString *timeZone = @"";
    //Presumable the string now looks like this: 1308646107731-0700
    if ([strippedString rangeOfString:@"-"].length > 0) {
        timeZone = [[strippedString componentsSeparatedByString:@"-"] objectAtIndex:1];
        timeZone = [NSString stringWithFormat:@"-%@",timeZone];
        miliSeconds = [[strippedString componentsSeparatedByString:@"-"] objectAtIndex:0];
    }
    if ([strippedString rangeOfString:@"+"].length > 0) {
        timeZone = [[strippedString componentsSeparatedByString:@"+"] objectAtIndex:1];
        timeZone = [NSString stringWithFormat:@"+%@",timeZone];
        miliSeconds = [[strippedString componentsSeparatedByString:@"+"] objectAtIndex:0];
    }
    
    // cast to into to Crop off the miliseconds
    NSTimeInterval seconds = [miliSeconds doubleValue] / 1000;
    
    NSString *string = [NSString stringWithFormat:@"%d %@",((int)seconds),timeZone];
    struct tm  sometime;
    const char *formatString = "%s %z";
    //strptime([string cString], formatString, &sometime);
    strptime([string UTF8String], formatString, &sometime);
    
    return  [NSDate dateWithTimeIntervalSince1970: mktime(&sometime)];
    
    
}

- (NSString *) getISOLanguageCode {
    
    NSString *languageString = @"en";
    
    NSArray *languageArray = [[NSBundle mainBundle] preferredLocalizations];
    
    if(languageArray){
        if([languageArray count] > 0){
            
            //only allow en, fr, de
            NSString *preferredLanguageString = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
            
            if([preferredLanguageString isEqualToString:@"en"]
               || [preferredLanguageString isEqualToString:@"de"]
               || [preferredLanguageString isEqualToString:@"fr"]){
                
                languageString = preferredLanguageString;
                
                //NSLog(@"Using preferred language: %@", preferredLanguageString);
                
            }else{
                //NSLog(@"Not using preferred language: %@", preferredLanguageString);
            }
        }
    }
    
    //NSLog(@"language %@", languageString);
    
    return languageString;
}

- (NSString *)shareURL{
    
    if (!_shareURL){
        NSString *savedShareURL = [ACConstants getLocalizedStringForKey:@"SHARE_LANDING_URL_&&" withDefaultValue:nil];
        return  savedShareURL;
    }
    
    return _shareURL;

}

- (NSString *)aboutURL{
    
    if(AppLocationSwitchArt == [ACConstants getCurrentAppLocation])
        return @"http://cache1.artprintimages.com/images/photostoart/mobile/index.html";
    
    if (!_aboutURL){
        NSString *savedAboutURL = [ACConstants getLocalizedStringForKey:@"ABOUT_URL_&&" withDefaultValue:ABOUT_URL];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            savedAboutURL = [ACConstants getLocalizedStringForKey:@"ABOUT_URL_&&" withDefaultValue:ABOUT_URL_IPAD];
        }
        return  savedAboutURL;
    }
    
    return _aboutURL;
    
}

- (NSString *)termsURL{
    
    if (!_termsURL){
        NSString *savedTermsURL = [ACConstants getLocalizedStringForKey:@"TERMS_OF_USE_URL_&&" withDefaultValue:nil];
        return  savedTermsURL;
    }
    
    return _termsURL;
    
}

- (NSString *)shippingURL{
    
    if(AppLocationSwitchArt == [ACConstants getCurrentAppLocation])
        return @"http://www.art.com/asp/customerservice/shipping-asp/_/posters.htm";

    if (!_shippingURL){
        NSString *savedShippingURL = [ACConstants getLocalizedStringForKey:@"SHIPPING_DETAILS_URL_&&" withDefaultValue:SHIPPING_DETAILS_URL];
        return  savedShippingURL;
    }
    
    return _shippingURL;
    
}

#pragma mark URL helpers

-(NSURL *) URLWithRawFrameURLString:(NSString *)imageURLString maxWidth:(NSUInteger)maxWidth maxHeight:(NSUInteger)maxHeight {
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"://qa-" withString:@"://"];
    
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"%5c" withString:@"\\"];
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"%5C" withString:@"\\"];
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"%5B" withString:@"["];
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"%5D" withString:@"]"];
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"%7C" withString:@"|"];
    NSString *sizeOverrideString = [NSString stringWithFormat:@"MXW:%d+MXH:%d",maxWidth,maxHeight];
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"MXW:2000+MXH:2000" withString:sizeOverrideString];
    
    imageURLString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)imageURLString, NULL, NULL, kCFStringEncodingUTF8));
    
    NSURL *url = [NSURL URLWithString:imageURLString];
    return url;
}


@end


