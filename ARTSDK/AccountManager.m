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
@synthesize orderHistory;
@synthesize orderHistoryByOrderID;;
@synthesize userName;
@synthesize accountID;
@synthesize unpurchasedWorkingPack;
@synthesize purchasedWorkingPack;
@synthesize addressesByAddressID;
@synthesize addressArray;
@synthesize unpurchasedPackName;
@synthesize packPurchaseMode;
@synthesize shippingAddressUsedInCheckout;
@synthesize lastPrintCountPurchased;
@synthesize defaultP2AGallery;

+ (AccountManager*) sharedInstance {
    static AccountManager* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) {
            _one = [[ AccountManager alloc ] init ];
        }
    }
    
    return _one;
}

-(void)cancelOperations
{
    self.delegate = nil;
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
    
//    if([ArtAPI authenticationToken])
//        return YES;
    
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

-(BOOL)getIsCartEmpty{
    
    NSDictionary *theCart = [ArtAPI cart];
    
    NSArray *shipmentArray = [theCart objectForKeyNotNull:@"Shipments"];
    NSDictionary *shipmentsDict = [shipmentArray objectAtIndex:0];
    
    if(!shipmentArray) return YES;
    if([shipmentArray count] == 0) return YES;
    
    NSArray *cartItemsArray = [shipmentsDict objectForKey:@"CartItems"];
    
    if(!cartItemsArray) return YES;
    if([cartItemsArray count] == 0) return YES;
    
    int itemCount = (int)cartItemsArray.count;
    
    if(itemCount==0){
        
        return YES;
    }else{
        return NO;
    }
    
}

-(void)setBundlesArray:(NSArray *)bundleArray{
    
    self.purchasedBundles = bundleArray;
    
}

-(NSArray *)getBundlesArray
{
    return self.purchasedBundles;
}

-(NSMutableDictionary *)getBundleForOrderNumber:(NSString*)orderNumber
{
    NSMutableDictionary *bundleDict = nil;
    for(NSMutableDictionary *dict in self.purchasedBundles)
    {
        @try{
            
            //order dict might be nil
            NSString *oNumber = [[dict objectForKey:@"orderInfo"] objectForKey:@"orderNumber"];
            if([orderNumber isEqualToString:oNumber])
            {
                bundleDict = dict;
                break;
            }
        }@catch(id exception){
            continue;
        }
    }
    
    return bundleDict;
}

-(NSMutableDictionary *)getBundleForBundleID:(NSString*)bundleID
{
    NSMutableDictionary *bundleDict = nil;
    for(NSMutableDictionary *dict in self.purchasedBundles)
    {
        @try{
            
            //order dict might be nil
            NSString *tempBundleID = [dict objectForKey:@"bundleId"];
            if([bundleID isEqualToString:tempBundleID])
            {
                bundleDict = dict;
                break;
            }
        }@catch(id exception){
            continue;
        }
    }
    
    return bundleDict;
}


-(NSMutableDictionary *)getOrderDictForOID:(NSString*)OID
{
    NSMutableDictionary *orderDict = nil;

    orderDict = [self.orderHistoryByOrderID objectForKey:OID];
    
    return orderDict;
}

-(NSDictionary *)getAddressForAddressID:(NSString*)addressID
{
    NSDictionary *addressDict = nil;
    
    if(self.addressesByAddressID){
        addressDict = [self.addressesByAddressID objectForKey:addressID];
    }
    
    return addressDict;
}

-(NSString *)getNewPackName{
    
    NSString *rootPackName = @"Untitled Pack";
    int maxPackIndex = 1000;
    
    NSString *packName;
    
    for(int i=1;i<maxPackIndex;i++){
        packName = [NSString stringWithFormat:@"%@ %i", rootPackName, i, nil];
        
        if(![self packNameExistsInPurchasedBundles:packName]){
            return packName;
        }
        
    }
    
    //if you get through 100, then just return the rootName - this should never happen
    return rootPackName;
}

-(BOOL)packNameExistsInPurchasedBundles:(NSString *)packName{
    
    BOOL retBool = NO;
    
    NSString *tempPackName = @"";
    
    for(NSDictionary *tempPack in self.purchasedBundles){
        
        tempPackName = [tempPack objectForKeyNotNull:@"name"];
        
        if([[packName uppercaseString] isEqualToString:[tempPackName uppercaseString]]){
            
            return YES;
            
        }
        
    }
    
    return retBool;
    
}

-(BOOL)updateBundlesForLoggedInUser:(id<AccountManagerDelegate>)delegate
{
    self.delegate = delegate;
    __block BOOL status = NO;
    
    NSString *propertyKey = @"Bundles";
    
    //assume bundles are already compressed
    NSMutableArray *packArray = [NSMutableArray arrayWithArray:[AccountManager sharedInstance].purchasedBundles];
    
    
    //need to make it into a Dictionary with one key
    NSMutableDictionary *bundlesDictionary = [[NSMutableDictionary alloc] init];
    [bundlesDictionary setObject:packArray forKey:@"Bundles"];
    
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bundlesDictionary options:0 error:&writeError];
    NSString *propertyValue = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", propertyValue);
    
    [ArtAPI requestForAccountUpdateProperty:propertyKey withValue:propertyValue success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         
         NSLog(@" requestForAccountUpdateProperty success \n JSON Account Update Property response %@ ", JSON);
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
         
         NSLog(@" requestForAccountUpdateProperty failed \n JSON Account Update Property response %@ ", JSON);
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(bundlesSetFailed)])
         {
             [self.delegate bundlesSetFailed];
         }
         
     }];
    
    return status;
}

-(NSInteger)getIndexOfPack:(NSMutableDictionary *)packDict{
    
    NSInteger index = -1;
    
    
    NSDictionary *oDict = [packDict objectForKeyNotNull:@"orderInfo"];
    
    if(!oDict) return -1;
    
    NSString *orderId = [oDict objectForKeyNotNull:@"orderNumber"];
    
    if(!orderId) return -1;
    
    NSString *bundleId = [packDict objectForKeyNotNull:@"bundleId"];
    
    if(!bundleId) return -1;
    
    NSDictionary *oInfoDict;
    NSString *oId;
    NSString *bName;
    NSString *bId;
    
    for(NSMutableDictionary *dict in [AccountManager sharedInstance].purchasedBundles)
    {
        bName = [dict objectForKeyNotNull:@"name"];
        oInfoDict = [dict objectForKeyNotNull:@"orderInfo"];
        oId = [oInfoDict objectForKeyNotNull:@"orderNumber"];
        bId = [dict objectForKeyNotNull:@"bundleId"];
        
        if([oId isEqualToString:orderId] && [bId isEqualToString:bundleId])
        {
            index = [[AccountManager sharedInstance].purchasedBundles indexOfObject:dict];
            break;
        }
    }

    return index;
    
}

-(void)subtractPrintCountOnPurchasedWorkingPack:(NSInteger)printCount{
    
    NSMutableArray *purchasedBundlesArray = [NSMutableArray arrayWithArray:[AccountManager sharedInstance].purchasedBundles];
    
    //just decrement the balance number on the bundle
    NSMutableDictionary *packDict = [NSMutableDictionary dictionaryWithDictionary:[AccountManager sharedInstance].purchasedWorkingPack];
    
    //find the index of the dict
    NSInteger index = [self getIndexOfPack:packDict];
    
    if(index < 0) return;
    
    NSInteger currentBalance = 0;
    NSDictionary *orderInfoDict = [packDict objectForKey:@"orderInfo"];
    NSDictionary *balanceDict;
    NSMutableDictionary *newBalanceDict;
    NSMutableDictionary *newOrderInfoDict;
    
    if(orderInfoDict){
        newOrderInfoDict = [NSMutableDictionary dictionaryWithDictionary:orderInfoDict];
        balanceDict = [orderInfoDict objectForKey:@"balance"];
        
        if(balanceDict){
            newBalanceDict = [NSMutableDictionary dictionaryWithDictionary:balanceDict];
            NSString *countString = [balanceDict objectForKey:@"count"];
            
            if(!countString)countString = @"0";
            
            currentBalance = [countString integerValue];
        }
    }
    
    NSInteger newBalance = currentBalance - printCount;
    
    if(newBalance < 0) newBalance = 0;
    NSString *newBalanceString = [NSString stringWithFormat:@"%i", (int)newBalance];
    
    //need to do the whole dictionary replacement process ensuring you have mutable dictionaries
    [newBalanceDict setObject:newBalanceString forKey:@"count"];
    [newOrderInfoDict setObject:newBalanceDict forKey:@"balance"];
    [packDict setObject:newOrderInfoDict forKey:@"orderInfo"];
    
    [purchasedBundlesArray replaceObjectAtIndex:index withObject:packDict];
    [AccountManager sharedInstance].purchasedBundles = purchasedBundlesArray;
    [AccountManager sharedInstance].purchasedWorkingPack = packDict;
}

-(void)setAddressIDOnPurchasedWorkingPack:(NSString *)addressID{
    
    NSMutableArray *purchasedBundlesArray = [NSMutableArray arrayWithArray:[AccountManager sharedInstance].purchasedBundles];
    
    //just decrement the balance number on the bundle
    NSMutableDictionary *packDict = [NSMutableDictionary dictionaryWithDictionary:[AccountManager sharedInstance].purchasedWorkingPack];
    
    //find the index of the dict
    NSInteger index = [self getIndexOfPack:packDict];
    
    if(index < 0) return;
    
    [packDict setObject:addressID forKey:@"shippingAddressId"];
    
    [purchasedBundlesArray replaceObjectAtIndex:index withObject:packDict];
    [AccountManager sharedInstance].purchasedBundles = purchasedBundlesArray;
    [AccountManager sharedInstance].purchasedWorkingPack = packDict;
}

-(NSInteger)getBundleCountStringFromDict:(NSDictionary *)bundleDict{
    
    NSString *countString = @"";
    NSInteger retInt = 0;
    
    if(!bundleDict) return 0;
    
    NSDictionary *termsDict = [bundleDict objectForKey:@"terms"];
    
    if(termsDict){
        
        countString = [termsDict objectForKey:@"count"];
        if(!countString){
            countString = @"";
        }
        
        if([countString isEqualToString:@""]){
            countString = @"0";
        }
        
    }
    
    @try{
        retInt = [countString integerValue];
    }@catch(id exception){
        retInt = 0;
    }
    
    return retInt;
}

-(BOOL)setBundlesForLoggedInUser:(id<AccountManagerDelegate>)delegate forOrderID:(NSString *)orderNumber withAddressID:(NSString *)addressID subtractingPrintCount:(NSInteger)printCount
{
    self.delegate = delegate;
    __block BOOL status = NO;
    
    NSString *propertyKey = @"Bundles";
    
    //assume bundles are already compressed
    NSMutableArray *packArray = [NSMutableArray arrayWithArray:[AccountManager sharedInstance].purchasedBundles];


    if([AccountManager sharedInstance].purchasedWorkingPack){
    
        [self subtractPrintCountOnPurchasedWorkingPack:printCount];
        [self setAddressIDOnPurchasedWorkingPack:addressID];
        
        packArray = [NSMutableArray arrayWithArray:[AccountManager sharedInstance].purchasedBundles];
        
    }else{
        
        //it is new
        NSMutableDictionary *newUnpurchasedBundle = [NSMutableDictionary dictionaryWithDictionary:[AccountManager sharedInstance].unpurchasedWorkingPack];
        
        //get bundle size
        NSInteger bundleSize = [self getBundleCountStringFromDict:newUnpurchasedBundle];
        
        //try to set last bundle worked with
        NSString *bundleID = [newUnpurchasedBundle objectForKey:@"bundleId"];
        if(bundleID){
            if([bundleID length] > 0){
                
                [[NSUserDefaults standardUserDefaults] setObject:bundleID forKey:@"LAST_SELECTED_PACK"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
        }
        
        //set order id
        NSMutableDictionary *orderDict = [newUnpurchasedBundle objectForKey:@"orderInfo"];
        if(orderDict){
            [orderDict setObject:orderNumber forKey:@"orderNumber"];
            
            //make a balance dict
            NSMutableDictionary *balanceDict = [[NSMutableDictionary alloc] init];
            [balanceDict setObject:@"" forKey:@"amount"];
            
            NSInteger balance = bundleSize - printCount;
            if(balance < 0) balance = 0;
            
            NSString *balanceString = [NSString stringWithFormat:@"%i", (int)balance, nil];
            [balanceDict setObject:balanceString forKey:@"count"];
            [orderDict setObject:balanceDict forKey:@"balance"];
        }
        
        if(addressID){
            if(![addressID isEqual:@""]){
                [newUnpurchasedBundle setObject:addressID forKey:@"shippingAddressId"];
            }
            
        }else{
            //leave address as is, because it is probably setting teh BILLING
        }
        
        packArray = [NSMutableArray arrayWithArray:[AccountManager sharedInstance].purchasedBundles];
        
        [packArray addObject:newUnpurchasedBundle];
    
        //set it with the new count, just for the Order Confirmation Screen
        [AccountManager sharedInstance].unpurchasedWorkingPack = newUnpurchasedBundle;
    }
    
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
         
         NSLog(@" requestForAccountUpdateProperty success \n JSON Account Update Property response %@ ", JSON);
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
         
         NSLog(@" requestForAccountUpdateProperty failed \n JSON Account Update Property response %@ ", JSON);
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(bundlesSetFailed)])
         {
             [self.delegate bundlesSetFailed];
         }
         
     }];
    
    return status;
}

-(NSString *)getGiftCertificateForWorkingPack{
    
    NSString *giftCertificate = @"";
    
    NSDictionary *packDict = self.purchasedWorkingPack;
    
    if(!packDict)return @"";
    
    NSDictionary *orderInfoDict = [packDict objectForKey:@"orderInfo"];
    
    if(orderInfoDict){
        NSString *orderNumber = [orderInfoDict objectForKey:@"orderNumber"];
        
        NSLog(@"OrderNumber: %@", orderNumber);
        
        NSDictionary *orderDict = [self getOrderDictForOID:orderNumber];
        
        if(orderDict){
            giftCertificate = [orderDict objectForKey:@"CreditCode"];
            
            if(!giftCertificate) giftCertificate = @"";
        }
        
    }
    
    return giftCertificate;

}

-(NSInteger)getCreditBalanceForWorkingPack{
    
    NSString *creditBalanceString = @"0";
    NSInteger creditBalance = 0;
    
    NSDictionary *packDict = self.purchasedWorkingPack;
    
    if(!packDict)return 0;
    
    NSDictionary *orderInfoDict = [packDict objectForKey:@"orderInfo"];
    
    if(orderInfoDict){
        NSString *orderNumber = [orderInfoDict objectForKey:@"orderNumber"];
        
        NSDictionary *orderDict = [self getOrderDictForOID:orderNumber];
        
        if(orderDict){
            creditBalanceString = [orderDict objectForKey:@"CreditBalanceCount"];
            
            if(!creditBalanceString) creditBalanceString = @"0";
            
            @try{
                creditBalance = [creditBalanceString integerValue];
            }@catch(id exception){
                creditBalance = 0;
            }
        }
    }
    
    return creditBalance;
    
}

-(BOOL)setBillingAddressForLastPurchase:(id<AccountManagerDelegate>)delegate forOrderID:(NSString *)orderNumber
{
    self.delegate = delegate;
    __block BOOL status = NO;
    
    //need to make it into a Dictionary with one key
    NSDictionary *addressDict = self.billingAddressUsedInCheckout;
    
    NSString *addresstype = [addressDict objectForKeyNotNull:@"AddressType"];
    NSString *addressLine1 = [addressDict objectForKeyNotNull:@"Address1"];
    NSString *addressLine2 = [addressDict objectForKeyNotNull:@"Address2"];
    NSString *companyName = [addressDict objectForKeyNotNull:@"CompanyName"];
    NSString *city = [addressDict objectForKeyNotNull:@"City"];
    NSString *state = [addressDict objectForKeyNotNull:@"State"];
    NSString *countryCode = [addressDict objectForKeyNotNull:@"CountryIsoA2"];
    NSString *zipCode = [addressDict objectForKeyNotNull:@"ZipCode"];
    NSString *primaryPhone = [[addressDict objectForKeyNotNull:@"Phone"] objectForKeyNotNull:@"Primary"];
    NSString *firstName = [[addressDict objectForKeyNotNull:@"Name"] objectForKeyNotNull:@"FirstName"];
    NSString *lastName = [[addressDict objectForKeyNotNull:@"Name"] objectForKeyNotNull:@"LastName"];
    
    NSString *isDefault = @"true";
    
    NSDictionary *addressParameters = [NSDictionary dictionaryWithObjectsAndKeys:addresstype,@"addressType",firstName,@"firstName",lastName,@"lastName",addressLine1,@"addressLine1",addressLine2,@"addressLine2",companyName,@"companyName",city,@"city",state,@"state",countryCode,@"twoDigitIsoCountryCode",zipCode,@"zipCode",primaryPhone,@"primaryPhone",isDefault,@"isDefault", nil];
    
    
    [ArtAPI requestForAccountUpdateLocationWithParameters:addressParameters success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         
         NSLog(@" requestForAccountUpdateProperty success \n JSON Account Update Property response %@ ", JSON);
         status = YES;
         
         NSString *addressID = @"";
         
         if(JSON){
             
             NSDictionary *dDict = [JSON objectForKey:@"d"];
             
             if(dDict){
                 
                 NSDictionary *accountDict = [dDict objectForKey:@"Account"];
                 
                 if(accountDict){
                     
                     NSDictionary *profileInfoDict = [accountDict objectForKey:@"ProfileInfo"];
                     
                     if(profileInfoDict){
                         NSArray *addresses = [profileInfoDict objectForKey:@"Addresses"];
                         
                         if(addresses){
                             int lastIndex = (int)[addresses count];
                             lastIndex = lastIndex - 1;
                             if(lastIndex >= 0){
                                 NSDictionary *theAddressWeJustSet = [addresses objectAtIndex:lastIndex];
                                 addressID = [theAddressWeJustSet objectForKeyNotNull:@"AddressIdentifier"];
                             }
                         }
                     }
                 }
             }
         }
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(billingAddressSetSuccess:withAddressID:)])
         {
             [self.delegate billingAddressSetSuccess:orderNumber withAddressID:addressID];
         }
         
         
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         status = NO;
         
         NSLog(@" requestForAccountUpdateLocation failed \n JSON Account Update Location response %@ ", JSON);
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(billingAddressSetFailed:)])
         {
             [self.delegate billingAddressSetFailed:orderNumber];
         }
         
     }];
    
    return status;
}

-(BOOL)setShippingAddressForLastPurchase:(id<AccountManagerDelegate>)delegate forOrderID:(NSString *)orderNumber
{
    self.delegate = delegate;
    __block BOOL status = NO;

    //need to make it into a Dictionary with one key
    NSDictionary *addressDict = self.shippingAddressUsedInCheckout;
    
    NSString *addresstype = [addressDict objectForKeyNotNull:@"AddressType"];
    NSString *addressLine1 = [addressDict objectForKeyNotNull:@"Address1"];
    NSString *addressLine2 = [addressDict objectForKeyNotNull:@"Address2"];
    NSString *companyName = [addressDict objectForKeyNotNull:@"CompanyName"];
    NSString *city = [addressDict objectForKeyNotNull:@"City"];
    NSString *state = [addressDict objectForKeyNotNull:@"State"];
    NSString *countryCode = [addressDict objectForKeyNotNull:@"CountryIsoA2"];
    NSString *zipCode = [addressDict objectForKeyNotNull:@"ZipCode"];
    NSString *primaryPhone = [[addressDict objectForKeyNotNull:@"Phone"] objectForKeyNotNull:@"Primary"];
    NSString *firstName = [[addressDict objectForKeyNotNull:@"Name"] objectForKeyNotNull:@"FirstName"];
    NSString *lastName = [[addressDict objectForKeyNotNull:@"Name"] objectForKeyNotNull:@"LastName"];
    
    NSString *isDefault = @"true";
    
    NSDictionary *addressParameters = [NSDictionary dictionaryWithObjectsAndKeys:addresstype,@"addressType",firstName,@"firstName",lastName,@"lastName",addressLine1,@"addressLine1",addressLine2,@"addressLine2",companyName,@"companyName",city,@"city",state,@"state",countryCode,@"twoDigitIsoCountryCode",zipCode,@"zipCode",primaryPhone,@"primaryPhone",isDefault,@"isDefault", nil];
    
    
    [ArtAPI requestForAccountUpdateLocationWithParameters:addressParameters success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         
         NSLog(@" requestForAccountUpdateProperty success \n JSON Account Update Property response %@ ", JSON);
         status = YES;
         
         NSString *addressID = @"";
         
         if(JSON){
             
             NSDictionary *dDict = [JSON objectForKey:@"d"];
             
             if(dDict){
                 
                 NSDictionary *accountDict = [dDict objectForKey:@"Account"];
                 
                 if(accountDict){
                     
                     NSDictionary *profileInfoDict = [accountDict objectForKey:@"ProfileInfo"];
                     
                     if(profileInfoDict){
                         NSArray *addresses = [profileInfoDict objectForKey:@"Addresses"];
                         
                         if(addresses){
                             int lastIndex = (int)[addresses count];
                             lastIndex = lastIndex - 1;
                             if(lastIndex >= 0){
                                 NSDictionary *theAddressWeJustSet = [addresses objectAtIndex:lastIndex];
                                 addressID = [theAddressWeJustSet objectForKeyNotNull:@"AddressIdentifier"];
                             }
                         }
                     }
                 }
                 
                 
             }
         }
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(shippingAddressSetSuccess:withAddressID:)])
         {
             [self.delegate shippingAddressSetSuccess:orderNumber withAddressID:addressID];
         }
         
         
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         status = NO;
         
         NSLog(@" requestForAccountUpdateLocation failed \n JSON Account Update Location response %@ ", JSON);
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(shippingAddressSetFailed:)])
         {
             [self.delegate shippingAddressSetFailed:orderNumber];
         }
         
     }];
    
    return status;
}

-(BOOL)applyGiftCertificateToCart:(id<AccountManagerDelegate>)delegate usingGiftCertificate:(NSString *)giftCertificate{
    
    self.delegate = delegate;
    __block BOOL status = NO;
    
    
    [ArtAPI requestForCartAddGiftCertificatePayment:giftCertificate success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         
         NSLog(@" requestForCartAddGiftCertificatePayment success \n JSON Account Update Property response %@ ", JSON);
         status = YES;
         
         if(JSON){
             
             NSDictionary *dDict = [JSON objectForKey:@"d"];
             
             if(dDict){
                 
                 
             }
         }
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(addGiftCertificateSuccess)])
         {
             [self.delegate addGiftCertificateSuccess];
         }
         
         
     }
          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         status = NO;
         
         NSLog(@" requestForCartAddGiftCertificatePayment failed \n JSON Account Update Location response %@ ", JSON);
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(addGiftCertificateFailed)])
         {
             [self.delegate addGiftCertificateFailed];
         }
         
     }];
    
    return status;

    
}

-(void)reIndexAddressesAfterAddressUpdate:(NSArray *)addressArrayFromUpdate
{

    if(addressArrayFromUpdate){
        
        //clear address cache
        self.addressesByAddressID = [[NSMutableDictionary alloc] init];
        self.addressArray = [[NSMutableArray alloc] init];
        
        
        
        //index all addresses
        NSString *tempAddressID;
        
        for(NSDictionary *tempAddress in addressArrayFromUpdate){
            
            NSLog(@"%@", tempAddress);
            tempAddressID = [tempAddress objectForKey:@"AddressIdentifier"];
            
            if(tempAddressID){
                if(![self.addressesByAddressID objectForKey:tempAddressID]){
                    //only index one per address id, just in case
                    [self.addressesByAddressID setObject:tempAddress forKey:tempAddressID];
                    [self.addressArray addObject:tempAddress];
                    
                    NSLog(@"Indexed address with AddressID: %@", tempAddressID);
                }
            }
            
        }
    }

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
    
    BOOL shouldDefaultBundle = NO;
    
    if(!self.purchasedBundles){
       shouldDefaultBundle = YES;
    }else{
        if([self.purchasedBundles count] == 0){
            shouldDefaultBundle = YES;
        }else{
            shouldDefaultBundle = NO;
        }
    }
    
    
    //clear the existing data.  this method will replace it
    [self setPurchasedBundles:nil];
    self.addressesByAddressID = [[NSMutableDictionary alloc] init];
    self.addressArray = [[NSMutableArray alloc] init];
    
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
                         
                         NSString *accountIDString = [profileInfoDict objectForKey:@"AccountId"];
                         self.accountID = accountIDString;
                         
                         accountUserName = [profileInfoDict objectForKeyNotNull:@"UserName"];
                         if(!accountUserName) accountUserName = @"";
                     }
                     
                     
                     NSDictionary *curatorInfoDict = [accountDict objectForKeyNotNull:@"CuratorInfo"];
                     if(curatorInfoDict)
                     {
                         NSString *accountIDString = [curatorInfoDict objectForKey:@"AccountId"];
                         if(!self.accountID){
                             self.accountID = accountIDString;
                         }
                         
                         NSString *firstName = [ curatorInfoDict objectForKey:@"FirstName"];
                         if(firstName && ![firstName isKindOfClass:[NSNull class]])
                         {
                             self.firstName = (firstName.length > 0)?firstName:@"";
                         }
                         else
                         {
                             self.firstName = @"";
                         }
                         NSString *lastName = [ curatorInfoDict objectForKey:@"LastName"];
                         if(lastName && ![lastName isKindOfClass:[NSNull class]])
                         {
                             self.lastName = (lastName.length > 0)?lastName:@"";
                         }
                         else
                         {
                             self.lastName = @"";
                         }
                         
                         NSString *nameToUse = [NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName];
                         nameToUse = [nameToUse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                         
                         if([nameToUse length] == 0){
                             nameToUse = accountUserName;
                         }
                         
                         self.userName = nameToUse;
                         NSLog(@"Set acccount name to %@", self.userName);
                         self.accountID = [ curatorInfoDict objectForKey:@"AccountId"];
                     }

                     
                     if(profileInfoDict){
                         
                         self.userEmailAddress = [ profileInfoDict objectForKeyNotNull:@"EmailAddress"];
                         NSArray *userDefaultArray = [profileInfoDict objectForKeyNotNull:@"UserDefaults"];
                         for(NSDictionary *dict in userDefaultArray)
                         {
                             if([@"DefaultShippingAddress" isEqualToString:[dict objectForKeyNotNull:@"PropertyName"]])
                             {
                                 self.shippingAddressIdentifier = [dict objectForKeyNotNull:@"PropertyValue"];
                                 break;
                             }
                             else if([@"DefaultBillingAddress" isEqualToString:[dict objectForKeyNotNull:@"PropertyName"]])
                             {
                                 self.billingAddressIdentifier = [dict objectForKeyNotNull:@"PropertyValue"];
                                 break;
                             }

                         }

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
                         
                         NSArray *addressesArray = [profileInfoDict objectForKeyNotNull:@"Addresses"];
                         
                         if(addressesArray){
                             //index all addresses
                             NSString *tempAddressID;
                             
                             for(NSDictionary *tempAddress in addressesArray){
                             
                                 NSLog(@"%@", tempAddress);
                                 tempAddressID = [tempAddress objectForKey:@"AddressIdentifier"];
                                 
                                 if(tempAddressID){
                                     if(![self.addressesByAddressID objectForKey:tempAddressID]){
                                         //only index one per address id, just in case
                                         [self.addressesByAddressID setObject:tempAddress forKey:tempAddressID];
                                         [self.addressArray addObject:tempAddress];
                                         
                                         NSLog(@"Indexed address with AddressID: %@", tempAddressID);
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
         
         if(self.purchasedBundles){
             if([self.purchasedBundles count] > 0){
                 
                 if(!self.purchasedWorkingPack){
                     if(self.packPurchaseMode == PurchaseModeNewPack){
                         //leave it as is - you are creating a new pack
                         if(shouldDefaultBundle){
                             self.purchasedWorkingPack = [NSMutableDictionary dictionaryWithDictionary:[self.purchasedBundles objectAtIndex:0]];
                             NSLog(@"Set the working bundle to be the first one in the array");
                         }
                     }else{
                         self.purchasedWorkingPack = [NSMutableDictionary dictionaryWithDictionary:[self.purchasedBundles objectAtIndex:0]];
                         NSLog(@"Set the working bundle to be the first one in the array");
                     }
                 }else{
                     //make sure the selected pack is in tehre and select it
                     
                     //rechecking the old pack to make sure it is in the newly loaded
                     //set of packs.  If not we need to select one that is
                     
                     NSString *bundleID = [self.purchasedWorkingPack objectForKey:@"bundleId"];
                     self.purchasedWorkingPack = [self getBundleForBundleID:bundleID];
                     
                     if(!self.purchasedWorkingPack){
                         //coundnt find the bundle anymore - need to set to the first one
                          self.purchasedWorkingPack = [NSMutableDictionary dictionaryWithDictionary:[self.purchasedBundles objectAtIndex:0]];
                     }
                     
                 }
             }else{
                 self.purchasedWorkingPack = nil;
                 NSLog(@"Set the working bundle to nil");
             }
         }else{
             self.purchasedWorkingPack = nil;
             NSLog(@"Set the working bundle to nil");
         }
         
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(bundlesLoadedSuccessfully:)])
         {
             [self.delegate bundlesLoadedSuccessfully:self.purchasedBundles];
         }
         
         
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         self.purchasedWorkingPack = nil;
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

-(BOOL)retrieveOrderHistoryArrayForLoggedInUser:(id<AccountManagerDelegate>)delegate
{
    self.delegate = delegate;

    __block BOOL status = NO;

   
    //clear the existing data.  this method will replace it
    [self setOrderHistory:nil];
    [self setOrderHistoryByOrderID:nil];
    
    NSString *customerNumber = self.accountID;
    NSString *emailAddress = @"USEACCOUNTID@ART.COM";
    
    [ArtAPI requestForCartTrackOrderHistory:customerNumber withEmailAddress:emailAddress success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         NSLog(@" requestForCartTrackOrderHistory success \n JSON Account Get response %@ ", JSON);
         status = YES;
         
         if(JSON){
             
             self.orderHistoryByOrderID = [[NSMutableDictionary alloc] init];
             
             NSDictionary *dDict = [JSON objectForKeyNotNull:@"d"];
             
             if(dDict){
                 
                 NSArray *orderHistoryArray = [dDict objectForKeyNotNull:@"OrderHistory"];
                 NSString *OID = @"";
                 
                 if(orderHistoryArray){
                     
                     self.orderHistory = orderHistoryArray;
                     
                     for(NSDictionary *orderDict in orderHistoryArray){
                         
                         OID = [orderDict objectForKeyNotNull:@"OrderNumber"];
                         if(OID){
                             [self.orderHistoryByOrderID setObject:orderDict forKey:OID];
                         }
                     }
                 }

             }
         }
         
         if(self.delegate && [self.delegate respondsToSelector:@selector(orderHistoryLoadedSuccessfully)])
         {
             [self.delegate orderHistoryLoadedSuccessfully];
         }
         
     }
      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         [self setOrderHistory:nil];
         [self setOrderHistoryByOrderID:nil];
         NSLog(@"Set the order history to nil");
         
         status = NO;
         NSLog(@" requestForCartTrackOrderHistory failed ");
         if(self.delegate && [self.delegate respondsToSelector:@selector(orderHistoryLoadingFailed)])
         {
             [self.delegate orderHistoryLoadingFailed];
         }
         
     }];
    
    return status;
}


-(void)updateAccountLocationAddressWithParameters:(NSDictionary *)parameters delegate:(id<AccountManagerDelegate>)delegate
{
    self.delegate = delegate;
    
    [ArtAPI requestForAccountUpdateLocationWithParameters:parameters success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(addressUpdatedSuccessfully:)])
        {
            [self.delegate addressUpdatedSuccessfully:JSON];
        }
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(addressUpdationFailed:)])
        {
            [self.delegate addressUpdationFailed:JSON];
        }

    }];
}

-(BOOL)needsToLoadOrderHistory{
    
    if(!self.purchasedWorkingPack)return NO;
    
    NSString *GC = [self getGiftCertificateForWorkingPack];
    
    if(!GC)GC = @"";
    if([GC isEqualToString:@""]) {
        return NO;
    }else{
        return YES;
    }
       
    
}

-(void)setBundlesArrayForLoggedInUser:(NSArray *)bundlesArray{
    
    //need to set the property on the logged in account
    
}

-(void)addNewBundleToPurchasedBundles:(NSDictionary *)newBundle{
    
    //need to add a bundle to the array
    //this will be done prior to setting it through the API call
}

-(void)updateFirstNameLastName:(NSString *)firstName lastName:(NSString *)lastName
{
    self.firstName = firstName;
    self.lastName = lastName;
    
    if(firstName && ![firstName isKindOfClass:[NSNull class]])
    {
        self.firstName = (firstName.length > 0)?firstName:@"";
    }
    else
    {
        self.firstName = @"";
    }
    if(lastName && ![lastName isKindOfClass:[NSNull class]])
    {
        self.lastName = (lastName.length > 0)?lastName:@"";
    }
    else
    {
        self.lastName = @"";
    }
    
    self.userName = [NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName];
}

@end
