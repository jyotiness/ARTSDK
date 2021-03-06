//
//  AccountManager.h
//  SwitchArt
//
//  Created by Mike Larson on 11/3/14.
//  Copyright (c) 2014 Art.com, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ACJSONAPIRequest.h"
#import "ArtAPI.h"

typedef enum {
    PurchaseModeNewPack = 0,
    PurchaseModeExistingPack = 1
} SAPackPurchaseMode;

@protocol AccountManagerDelegate<NSObject>;
@optional
-(void)addressUpdatedSuccessfully:(id)jsonResponse;
-(void)addressUpdationFailed:(id)jsonResponse;
-(void)bundlesLoadedSuccessfully:(NSArray *)purchasedBundles;
-(void)bundlesLoadingFailed;
-(void)orderHistoryLoadedSuccessfully;
-(void)orderHistoryLoadingFailed;
-(void)bundlesSetSuccess;
-(void)bundlesSetFailed;
-(void)addGiftCertificateSuccess;
-(void)addGiftCertificateFailed;
-(void)shippingAddressSetSuccess:(NSString *)theOrderNumber withAddressID:(NSString *)addressID;
-(void)shippingAddressSetFailed:(NSString *)theOrderNumber;
-(void)billingAddressSetSuccess:(NSString *)theOrderNumber withAddressID:(NSString *)addressID;
-(void)billingAddressSetFailed:(NSString *)theOrderNumber;
-(void)userGalleryLoadedSuccessfullyWithResponse:(id)jsonResponse withGalleryItems:(NSArray *)galleryItems withGalleryID:(NSString *)myPhotosDefaultGallery;
-(void)userGalleryLoadingFailedWithResponse:(id)jsonResponse;
@end

@interface AccountManager : NSObject
{
    
}

//Instance's
@property(nonatomic,strong) NSArray *purchasedBundles;
@property(nonatomic,strong) NSArray *orderHistory;
@property(nonatomic,strong) NSMutableDictionary *orderHistoryByOrderID;
@property(nonatomic,unsafe_unretained) id<AccountManagerDelegate> delegate;
@property(nonatomic,strong) NSString *activeOrderNumber;
@property(nonatomic,strong) NSString *userName;
@property(nonatomic,strong) NSString *accountID;
@property(nonatomic,strong) NSString *unpurchasedPackName;
@property(nonatomic,assign) SAPackPurchaseMode packPurchaseMode;
@property(nonatomic,strong) NSMutableDictionary *unpurchasedWorkingPack;
@property(nonatomic,strong) NSMutableDictionary *purchasedWorkingPack;
@property(nonatomic,strong) NSMutableDictionary *addressesByAddressID;
@property(nonatomic,strong) NSMutableArray *addressArray;
@property(nonatomic,strong) NSMutableArray *shippingAddressArray;
@property(nonatomic,strong) NSString *firstName;
@property(nonatomic,strong) NSString *lastName;
@property(nonatomic,strong) NSString *shippingAddressIdentifier;
@property(nonatomic,strong) NSString *billingAddressIdentifier;
@property(nonatomic,strong) NSString *userEmailAddress;
@property(nonatomic,strong) NSMutableDictionary *shippingAddressUsedInCheckout;
@property(nonatomic,strong) NSMutableDictionary *billingAddressUsedInCheckout;
@property(nonatomic,assign) NSInteger lastPrintCountPurchased;
@property(nonatomic,strong) NSString *defaultP2AGallery;
@property(nonatomic,strong) NSMutableDictionary *requestsByDelegate;
@property(nonatomic,strong) NSString *editingAddressIdentifier;


@property(nonatomic,strong) NSString *profileImageUrl;

//isJustFrameSelected related instance's
@property(nonatomic,strong) NSMutableDictionary *justFrameSelectedDetailsDictionary;
@property(nonatomic,assign) BOOL isJustFrameSelected;

//Method's
+(AccountManager *) sharedInstance;
-(void)cancelOperations;
-(void)loadUserDefaultGallery:(id<AccountManagerDelegate>)delegate;
-(BOOL)isLoggedInForSwitchArt;
-(BOOL)retrieveBundlesArrayForLoggedInUser:(id<AccountManagerDelegate>)delegate;
-(BOOL)retrieveOrderHistoryArrayForLoggedInUser:(id<AccountManagerDelegate>)delegate;
-(BOOL)setBundlesForLoggedInUser:(id<AccountManagerDelegate>)delegate forOrderID:(NSString *)orderNumber withAddressID:(NSString *)addressID subtractingPrintCount:(NSInteger)printCount;
-(void)setBundlesArrayForLoggedInUser:(NSArray *)bundlesArray;
-(void)addNewBundleToPurchasedBundles:(NSDictionary *)newBundle;
-(BOOL)updateBundlesForLoggedInUser:(id<AccountManagerDelegate>)delegate;
-(NSArray *)getBundlesArray;
-(NSMutableDictionary *)getBundleForOrderNumber:(NSString*)orderNumber;
-(NSMutableDictionary *)getBundleForBundleID:(NSString*)bundleID;
-(void)setBundlesArray:(NSArray *)bundleArray;
-(BOOL)setShippingAddressForLastPurchase:(id<AccountManagerDelegate>)delegate forOrderID:(NSString *)orderNumber;
-(BOOL)setBillingAddressForLastPurchase:(id<AccountManagerDelegate>)delegate forOrderID:(NSString *)orderNumber;
-(NSDictionary *)getAddressForAddressID:(NSString*)addressID;
-(NSString *)getNewPackName;
-(NSString *)getGiftCertificateForWorkingPack;
-(BOOL)applyGiftCertificateToCart:(id<AccountManagerDelegate>)delegate usingGiftCertificate:(NSString *)giftCertificate;
-(BOOL)needsToLoadOrderHistory;
-(void)updateFirstNameLastName:(NSString *)firstName lastName:(NSString *)lastName;
-(void)updateAccountLocationAddressWithParameters:(NSDictionary *)parameters delegate:(id<AccountManagerDelegate>)delegate;
-(BOOL)getIsCartEmpty;
-(void)reIndexAddressesAfterAddressUpdate:(NSArray *)addressArrayFromUpdate;
-(void)updatePurchasedPack:(NSString *)bundleId withAddressId:(NSString *)newAddressId;

//isJustFrameSelected related method's
-(void)setJustFrameSelectedDetailsWithFrameName:(NSString *)frameName frameSize:(NSString *)frameSize selectedFrameUrl:(NSString *)selectedFrameImageUrl;
-(NSDictionary *)getJustFrameSelectedDetails;

@end
