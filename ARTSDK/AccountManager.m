//
//  AccountManager.m
//  SwitchArt
//
//  Created by Mike Larson on 11/3/14.
//  Copyright (c) 2014 Art.com, Inc. All rights reserved.
//

#import "AccountManager.h"
//#import "Reachability.h"
//#import "AppDelegate.h"
//#import "ACJSONAPIRequest.h"
#import "ArtAPI.h"
#import "SVProgressHUD.h"

@implementation AccountManager

@synthesize purchasedBundles;

+ (AccountManager*) sharedInstance {
    static AccountManager* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) {
            _one = [[ AccountManager alloc ] init ];
        }
    }
    
    return _one;
}

-(void)loadUserDefaultGallery:(id<AccountManagerDelegate>)delegate
{

    self.delegate = delegate;
/*    Reachability *internetReachabilityTest = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachabilityTest currentReachabilityStatus];
    if (networkStatus == NotReachable) // NETWORK Reachability
    {
        NSString *errorMessage = NSLocalizedString(@"COULD_NOT_CONNECT_TO_INTERNET_TRY_AGAIN", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:errorMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    } */

    [SVProgressHUD showWithStatus:@"Fetching Photos" maskType:SVProgressHUDMaskTypeClear];
    [ArtAPI requestForGalleryGetUserDefaultGallery:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         [SVProgressHUD dismiss];
         NSDictionary *aDict = [JSON objectForKeyNotNull:@"d"];
         NSDictionary *responseGallery = [aDict objectForKeyNotNull:@"Gallery"];
         NSString *myPhotosDefaultGallery = [[responseGallery objectForKeyNotNull:@"GalleryAttributes"] objectForKeyNotNull:@"GalleryId"];
         
         NSLog(@"P2A Gallery recieved: %@", myPhotosDefaultGallery);
      
         NSArray *responseGalleryItems = [responseGallery objectForKeyNotNull:@"GalleryItems"];
         
         [[ArtAPI sharedInstance] setMyPhotosGalleryID:myPhotosDefaultGallery];

         if(self.delegate && [self.delegate respondsToSelector:@selector(userGalleryLoadedSuccessfullyWithResponse:withGalleryItems:)])
             [self.delegate userGalleryLoadedSuccessfullyWithResponse:JSON withGalleryItems:responseGalleryItems];
         
         //NSLog(@" requestForAccountGet success \n JSON Account Get response %@ ", JSON);
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         [SVProgressHUD dismiss];
         if(self.delegate && [self.delegate respondsToSelector:@selector(userGalleryLoadingFailedWithResponse:)])
             [self.delegate userGalleryLoadingFailedWithResponse:JSON];

         NSLog(@"GalleryRetrievalFailed");
     }];
    
/*    ACJSONAPIRequest *requestDefaultGalleries=[[ACAPI sharedAPI] requestForGalleryGetUserDefaultGalleryWithDelegate:self withDefaultGalleryType:@"DefaultMyPhotosGallery"];
    if(!requestDefaultGalleries){
        if(![ArtAPI authenticationToken]){
            UIAlertView *authAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"AUTHENTICATION_TOKEN_IS_NULL", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [authAlertView show];
            return;
        }
    }
    [requestDefaultGalleries setDidFinishSelector:@selector(defaultGalleriesSucceeded:)];
    [requestDefaultGalleries setDidFailSelector:@selector(defaultGalleriesFailed:)];
    [requestDefaultGalleries startAsynchronous]; */
    
}

/*
-(void)defaultGalleriesFailed:(ACJSONAPIRequest *)request{

    NSLog(@"GalleryRetrievalFailed");
    if(request.isCancelled){
        return;
    }
}


-(void) defaultGalleriesSucceeded:(ACJSONAPIRequest *)request{
 
    NSDictionary *responseGallery = [[request APIResponse] objectForKeyNotNull:@"Gallery"];
    NSString *myPhotosDefaultGallery = [[responseGallery objectForKeyNotNull:@"GalleryAttributes"] objectForKeyNotNull:@"GalleryId"];

    NSLog(@"P2A Gallery recieved: %@", myPhotosDefaultGallery);
    
    [[ACAPI sharedAPI] setMyPhotosGalleryID:myPhotosDefaultGallery];
    
} */

-(BOOL)isLoggedInForSwitchArt{
    
    //not sure if we need any special conditions for
    //being logged in for SwitchArt and displaying the tab bar
    
    //for now just return logged in state
    
    return [ArtAPI isLoggedIn];
}

-(void)setBundlesArray:(NSArray *)bundleArray{
    
    self.purchasedBundles = bundleArray;
    
}

-(NSArray *)getBundlesArray
{
    return self.purchasedBundles;
}

-(NSDictionary *)getBundleForOrderNumber:(NSString*)orderNumber
{
    NSDictionary *bundleDict = nil;
    for(NSDictionary *dict in self.purchasedBundles)
    {
        NSString *oNumber = [[dict objectForKey:@"orderInfo"] objectForKey:@"orderNumber"];
        if([orderNumber isEqualToString:oNumber])
        {
            bundleDict = dict;
            break;
        }
    }
    
    return bundleDict;
}

-(BOOL)retrieveBundlesArrayForLoggedInUser:(id<AccountManagerDelegate>)delegate
{
    self.delegate = delegate;
    //need to get this from AccountGet
    __block BOOL status = NO;
/*    Reachability *internetReachabilityTest = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachabilityTest currentReachabilityStatus];
    if (networkStatus == NotReachable) // NETWORK Reachability
    {
        NSString *errorMessage = NSLocalizedString(@"COULD_NOT_CONNECT_TO_INTERNET_TRY_AGAIN", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:errorMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    } */
    
    [ArtAPI requestForAccountGet:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         NSLog(@" requestForAccountGet success \n JSON Account Get response %@ ", JSON);
         status = YES;
         NSArray *bundlesArray = [[NSMutableArray alloc] init];
         
         if(JSON){
             
             NSDictionary *dDict = [JSON objectForKeyNotNull:@"d"];
             
             if(dDict){
             
                 NSDictionary *accountDict = [dDict objectForKeyNotNull:@"Account"];
                 if(accountDict){
                     NSDictionary *profileInfoDict = [accountDict objectForKeyNotNull:@"ProfileInfo"];
                     
                     if(profileInfoDict){
                         NSArray *userPropertiesArray = [profileInfoDict objectForKeyNotNull:@"UserProperties"];
                         
                         if(userPropertiesArray){
                             
                             NSString *propertyName;
                             NSString *propertyValue;
                             
                             for(NSDictionary *userProperty in userPropertiesArray){
                                 
                                 propertyName = [userProperty objectForKey:@"PropertyName"];
                                 if([propertyName isEqualToString:@"Bundles"]){
                                     propertyValue = [userProperty objectForKeyNotNull:@"PropertyValue"];
                                     
                                     NSData *propertyData = [propertyValue dataUsingEncoding:NSUTF8StringEncoding];
                                     
                                     NSError *error;
                                     NSDictionary *propertyDict = [NSJSONSerialization JSONObjectWithData:propertyData options:0 error:&error];
                                     
                                     if(!error){
                                         bundlesArray = [propertyDict objectForKey:@"Bundles"];
                                         
                                         [[AccountManager sharedInstance] setPurchasedBundles:bundlesArray];
                                         

                                     }
                                     
                                 }
                                 
                             }
                             
                         }
                         
                     }
                 }
             }
         }
         
         //need to call this no matter what
         //to make spinner go away
         //i noticed that if UserProperties is nil, this would never be called
         //when it was inside all the if blocks above...
         //-MKL
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(bundlesLoadedSuccessfully:)])
         {
             [self.delegate bundlesLoadedSuccessfully:self.purchasedBundles];
         }
         
         
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         status = NO;
         NSLog(@" requestForAccountGet failed ");
         if(self.delegate && [self.delegate respondsToSelector:@selector(bundlesLoadedSuccessfully:)])
         {
             [self.delegate bundlesLoadingFailed];
         }

     }];
    
    return status;
}


-(void)setBundlesArrayForLoggedInUser:(NSArray *)bundlesArray{
    
    //need to set the property on the logged in account
    
}

-(void)addNewBundleToPurchasedBundles:(NSDictionary *)newBundle{
    
    //need to add a bundle to the array
    //this will be done prior to setting it through the API call
}

@end
