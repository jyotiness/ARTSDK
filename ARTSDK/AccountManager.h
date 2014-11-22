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
-(void)addressSetSuccess:(NSString *)orderNumber withAddressID:(NSString *)addressID;
-(void)addressSetFailed:(NSString *)orderNumber;
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
@property(nonatomic,strong) NSString *firstName;
@property(nonatomic,strong) NSString *lastName;
@property(nonatomic,strong) NSString *shippingAddressIdentifier;
@property(nonatomic,strong) NSString *userEmailAddress;
@property(nonatomic,strong) NSMutableDictionary *shippingAddressUsedInCheckout;

//Method's
+(AccountManager *) sharedInstance;
-(void)loadUserDefaultGallery:(id<AccountManagerDelegate>)delegate;
-(BOOL)isLoggedInForSwitchArt;
-(BOOL)retrieveBundlesArrayForLoggedInUser:(id<AccountManagerDelegate>)delegate;
-(BOOL)retrieveOrderHistoryArrayForLoggedInUser:(id<AccountManagerDelegate>)delegate;
-(BOOL)setBundlesForLoggedInUser:(id<AccountManagerDelegate>)delegate forOrderID:(NSString *)orderNumber  withAddressID:(NSString *)addressID;
-(void)setBundlesArrayForLoggedInUser:(NSArray *)bundlesArray;
-(void)addNewBundleToPurchasedBundles:(NSDictionary *)newBundle;
-(BOOL)updateBundlesForLoggedInUser:(id<AccountManagerDelegate>)delegate;
-(NSArray *)getBundlesArray;
-(NSDictionary *)getBundleForOrderNumber:(NSString*)orderNumber;
-(NSDictionary *)getBundleForBundleID:(NSString*)bundleID;
-(void)setBundlesArray:(NSArray *)bundleArray;
-(BOOL)setShippingAddressForLastPurchase:(id<AccountManagerDelegate>)delegate forOrderID:(NSString *)orderNumber;
-(NSDictionary *)getAddressForAddressID:(NSString*)addressID;
-(NSString *)getNewPackName;
-(NSString *)getGiftCertificateForWorkingPack;
-(BOOL)applyGiftCertificateToCart:(id<AccountManagerDelegate>)delegate usingGiftCertificate:(NSString *)giftCertificate;

-(void)updateAccountLocationAddressWithParameters:(NSDictionary *)parameters delegate:(id<AccountManagerDelegate>)delegate;

@end
