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
@end

@interface AccountManager : NSObject

//Instance's
@property(nonatomic,strong) NSArray *purchasedBundles;

@property(nonatomic, unsafe_unretained) id<AccountManagerDelegate> delegate;

@property(nonatomic,copy) NSString *activeOrderNumber;

//Method's
+(AccountManager *) sharedInstance;
-(void)loadUserDefaultGallery;
-(BOOL)isLoggedInForSwitchArt;
-(BOOL)retrieveBundlesArrayForLoggedInUser:(id<AccountManagerDelegate>)delegate;
-(void)setBundlesArrayForLoggedInUser:(NSArray *)bundlesArray;
-(void)addNewBundleToPurchasedBundles:(NSDictionary *)newBundle;
-(NSArray *)getBundlesArray;
-(NSDictionary *)getBundleForOrderNumber:(NSString*)orderNumber;
-(void)setBundlesArray:(NSArray *)bundleArray;

@end
