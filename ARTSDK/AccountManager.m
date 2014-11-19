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
@synthesize userName;
@synthesize lastPurchasedBundle;
@synthesize currentWorkingBundle;


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

    //[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    [ArtAPI requestForGalleryGetUserDefaultGallery:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         //[SVProgressHUD dismiss];
         NSDictionary *aDict = [JSON objectForKeyNotNull:@"d"];
         NSDictionary *responseGallery = [aDict objectForKeyNotNull:@"Gallery"];
         NSString *myPhotosDefaultGallery = [[responseGallery objectForKeyNotNull:@"GalleryAttributes"] objectForKeyNotNull:@"GalleryId"];
         
         NSDictionary *galleryOwnerDict = [[responseGallery objectForKeyNotNull:@"GalleryAttributes"] objectForKeyNotNull:@"GalleryOwner"];
         if(galleryOwnerDict)
         {
             if(galleryOwnerDict)
             {
                 self.accountID = [ galleryOwnerDict objectForKey:@"AccountId"];
             }
         }
         
         NSLog(@"P2A Gallery recieved: %@", myPhotosDefaultGallery);
      
         NSArray *responseGalleryItems = [responseGallery objectForKeyNotNull:@"GalleryItems"];
         
         [[ArtAPI sharedInstance] setMyPhotosGalleryID:myPhotosDefaultGallery];
         NSLog(@"Persisted P2A Gallery: %@", myPhotosDefaultGallery);
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(userGalleryLoadedSuccessfullyWithResponse:withGalleryItems:withGalleryID:)])
             [self.delegate userGalleryLoadedSuccessfullyWithResponse:JSON withGalleryItems:responseGalleryItems withGalleryID:myPhotosDefaultGallery];
         
         //NSLog(@" requestForAccountGet success \n JSON Account Get response %@ ", JSON);
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         //[SVProgressHUD dismiss];
         if(self.delegate && [self.delegate respondsToSelector:@selector(userGalleryLoadingFailedWithResponse:)])
             [self.delegate userGalleryLoadingFailedWithResponse:JSON];

         NSLog(@"GalleryRetrievalFailed");
     }];
    
}



-(BOOL)isLoggedInForSwitchArt{
    
    //not sure if we need any special conditions for
    //being logged in for SwitchArt and displaying the tab bar
    
    //for now just return logged in state
    
    BOOL isLoggedIn = [ArtAPI isLoggedIn];
    
    bool isAnonymousLogin = YES;
    static NSString * ANONYMOUS_AUTH_TOKEN = @"ANONYMOUS_AUTH_TOKEN";
    
    NSString *anonymousAuthToken = [[NSUserDefaults standardUserDefaults] objectForKey:ANONYMOUS_AUTH_TOKEN];
    
    if(anonymousAuthToken){
        isAnonymousLogin = YES;
    }else{
        isAnonymousLogin = NO;
    }
    
    return (isLoggedIn && !isAnonymousLogin);
    
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


-(BOOL)setBundlesForLoggedInUser:(id<AccountManagerDelegate>)delegate forOrderID:(NSString *)orderNumber
{
    self.delegate = delegate;
    __block BOOL status = NO;

    NSString *propertyKey = @"Bundles";
    
    //assume bundles are already compressed
    NSMutableArray *packArray = [NSMutableArray arrayWithArray:[AccountManager sharedInstance].purchasedBundles];
    //NSMutableArray *packArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *newBundleUncompressed = [NSMutableDictionary dictionaryWithDictionary:[AccountManager sharedInstance].lastPurchasedBundle];
    
    //set order id
    NSMutableDictionary *orderDict = [newBundleUncompressed objectForKey:@"orderInfo"];
    if(orderDict){
        [orderDict setObject:orderNumber forKey:@"orderNumber"];
    }
    
    [packArray addObject:newBundleUncompressed];
    
    //need to make it into a Dictionary with one key
    NSMutableDictionary *bundlesDictionary = [[NSMutableDictionary alloc] init];
    [bundlesDictionary setObject:packArray forKey:@"Bundles"];
    
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bundlesDictionary options:0 error:&writeError];
    NSString *propertyValue = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", propertyValue);
    
    /*
    NSString *propertyValue2 = @"{\"Bundles\" :[{\"bundleId\":\"MIKE TEST BUNDLE UPDATE\", \"name\":\"My Updated House\", \"description\":\"\", \"APNUM\":\"12259962\", \"terms\":{\"size\":{\"configId\":\"12260010\", \"width\":\"10\", \"height\":\"8\"}, \"frame\":{\"frameAPNUM\":\"\", \"frameText\":\"\"}, \"count\":\"1\"}, \"shippingAddressId\":\"A1\", \"retailPrice\":\"10\", \"invoicePrice\":\"\", \"orderInfo\":{\"orderNumber\":\"3452363772784\", \"creditCode\":\"\", \"balance\":{\"count\":\"1\", \"amount\":\"\"}}} , {\"bundleId\":\"94C02DF0772C4054A3BA8044C575E36C-2\", \"name\":\"My Mom's House\", \"description\":\"\", \"APNUM\":\"12259984\", \"terms\":{\"size\":{\"configId\":\"11969361\", \"width\":\"32\", \"height\":\"24\"}, \"frame\":{\"frameAPNUM\":\"12260003\", \"frameText\":\"Pecan\"}, \"count\":\"12\"}, \"shippingAddressId\":\"A2\", \"retailPrice\":\"460\", \"invoicePrice\":\"\", \"orderInfo\":{\"orderNumber\":\"4545467845635\", \"creditCode\":\"\", \"balance\":{\"count\":\"6\", \"amount\":\"\"}}}]}";
    
    NSLog(@"%@", propertyValue2);
    */
    
    [ArtAPI requestForAccountUpdateProperty:propertyKey withValue:propertyValue success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         
         NSLog(@" requestForAccountUpdateProperty success \n JSON Account Get response %@ ", JSON);
         status = YES;
         //NSArray *bundlesArray = [[NSMutableArray alloc] init];
         
         if(JSON){
             
             NSDictionary *dDict = [JSON objectForKeyNotNull:@"d"];
             
             if(dDict){
                 
             }
         }
         
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(bundlesSetSuccess)])
         {
             [self.delegate bundlesSetSuccess];
         }
         
         
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         status = NO;
         NSLog(@" requestForAccountUpdateProperty failed ");
         if(self.delegate && [self.delegate respondsToSelector:@selector(bundlesSetFailed)])
         {
             [self.delegate bundlesSetFailed];
         }
         
     }];
    
    return status;
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
    
    [[AccountManager sharedInstance] setPurchasedBundles:nil];
    
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
                     
                     NSString *accountUserName = @"";
                     
                     NSDictionary *profileInfoDict = [accountDict objectForKeyNotNull:@"ProfileInfo"];
                     if(profileInfoDict){
                         accountUserName = [profileInfoDict objectForKeyNotNull:@"UserName"];
                         
                         if(!accountUserName) accountUserName = @"";
                         
                     }
                     
                     
                     NSDictionary *curatorInfoDict = [accountDict objectForKeyNotNull:@"CuratorInfo"];
                     if(curatorInfoDict)
                     {
                         NSString *firstName = [ curatorInfoDict objectForKey:@"FirstName"];
                         if(firstName && ![firstName isKindOfClass:[NSNull class]])
                         {
                             firstName = (firstName.length > 0)?firstName:@"";
                         }
                         else
                         {
                             firstName = @"";
                         }
                         NSString *lastName = [ curatorInfoDict objectForKey:@"LastName"];
                         if(lastName && ![lastName isKindOfClass:[NSNull class]])
                         {
                             lastName = (lastName.length > 0)?lastName:@"";
                         }
                         else
                         {
                             lastName = @"";
                         }
                         
                         NSString *nameToUse = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
                         nameToUse = [nameToUse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                         
                         if([nameToUse length] == 0){
                             nameToUse = accountUserName;
                         }
                         
                         self.userName = nameToUse;
                         NSLog(@"Set acccount name to %@", self.userName);
                         
                         self.accountID = [ curatorInfoDict objectForKey:@"AccountId"];
                     }

                     
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
                                         @try{
                                             bundlesArray = [propertyDict objectForKey:@"Bundles"];
                                             [[AccountManager sharedInstance] setPurchasedBundles:bundlesArray];
                                         }@catch(id exception){
                                             NSLog(@"There was a bundles array but it was not parseable into a dictionary");
                                         }

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
         
         //default to working with the first bundle
         self.currentWorkingBundle = nil;
         if(self.purchasedBundles){
             if([self.purchasedBundles count] > 0){
                 self.currentWorkingBundle = [NSMutableDictionary dictionaryWithDictionary:[self.purchasedBundles objectAtIndex:0]];
                 NSLog(@"Set the working bundle to be the first one in the array");
             }else{
                 NSLog(@"Set the working bundle to nil");
             }
         }else{
             NSLog(@"Set the working bundle to nil");
         }
         
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(bundlesLoadedSuccessfully:)])
         {
             [self.delegate bundlesLoadedSuccessfully:self.purchasedBundles];
         }
         
         
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         self.currentWorkingBundle = nil;
         NSLog(@"Set the working bundle to nil");
         
         status = NO;
         NSLog(@" requestForAccountGet failed ");
         if(self.delegate && [self.delegate respondsToSelector:@selector(bundlesLoadingFailed)])
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
