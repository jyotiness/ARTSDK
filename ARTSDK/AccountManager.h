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

@protocol AccountManagerDelegate<NSObject>;
@optional
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
@property(nonatomic, unsafe_unretained) id<AccountManagerDelegate> delegate;
@property(nonatomic,copy) NSString *activeOrderNumber;
@property(nonatomic,strong) NSDictionary *lastPurchasedBundle;

//Method's
+(AccountManager *) sharedInstance;
-(void)loadUserDefaultGallery:(id<AccountManagerDelegate>)delegate;
-(BOOL)isLoggedInForSwitchArt;
-(BOOL)retrieveBundlesArrayForLoggedInUser:(id<AccountManagerDelegate>)delegate;
-(BOOL)setBundlesForLoggedInUser:(id<AccountManagerDelegate>)delegate;
-(void)setBundlesArrayForLoggedInUser:(NSArray *)bundlesArray;
-(void)addNewBundleToPurchasedBundles:(NSDictionary *)newBundle;
-(NSArray *)getBundlesArray;
-(NSDictionary *)getBundleForOrderNumber:(NSString*)orderNumber;
-(void)setBundlesArray:(NSArray *)bundleArray;

@end
