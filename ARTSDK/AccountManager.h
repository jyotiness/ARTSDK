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
//#import "ACAPI.h"

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
-(void)bundlesSetSuccess;
-(void)bundlesSetFailed;
-(void)userGalleryLoadedSuccessfullyWithResponse:(id)jsonResponse withGalleryItems:(NSArray *)galleryItems withGalleryID:(NSString *)myPhotosDefaultGallery;
-(void)userGalleryLoadingFailedWithResponse:(id)jsonResponse;
@end

@interface AccountManager : NSObject
{
    
}

//Instance's
@property(nonatomic,strong) NSArray *purchasedBundles;
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

//Method's
+(AccountManager *) sharedInstance;
-(void)loadUserDefaultGallery:(id<AccountManagerDelegate>)delegate;
-(BOOL)isLoggedInForSwitchArt;
-(BOOL)retrieveBundlesArrayForLoggedInUser:(id<AccountManagerDelegate>)delegate;
-(BOOL)setBundlesForLoggedInUser:(id<AccountManagerDelegate>)delegate forOrderID:(NSString *)orderNumber;
-(void)setBundlesArrayForLoggedInUser:(NSArray *)bundlesArray;
-(void)addNewBundleToPurchasedBundles:(NSDictionary *)newBundle;
-(NSArray *)getBundlesArray;
-(NSDictionary *)getBundleForOrderNumber:(NSString*)orderNumber;
-(void)setBundlesArray:(NSArray *)bundleArray;

-(NSDictionary *)getAddressForAddressID:(NSString*)addressID;
-(NSString *)getNewPackName;

-(void)updateAccountLocationAddressWithParameters:(NSDictionary *)parameters delegate:(id<AccountManagerDelegate>)delegate;


@end