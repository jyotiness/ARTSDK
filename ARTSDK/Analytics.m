//
//  AnalyticsWrapper.m
//  artCircles
//
//  Created by Eric Hackman on 11/28/11.
//  Copyright 2011 Hot Studio. All rights reserved.
//

#import "Analytics.h"
#import "GAIFields.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@implementation Analytics

+ (void)startSession:(NSString *)apiKey withSecret:(NSString *)secret {

    //NSLog(@"Starting tracking session");
    //[Apsalar startSession:apiKey withKey:secret];
}

+ (void)startSession:(NSString *)apiKey withSecret:(NSString *)secret withLaunchOptions:(NSDictionary *)launchOptions {

    //NSLog(@"Starting tracking session with lanuch options");
    //[Apsalar startSession:apiKey withKey:secret andLaunchOptions:launchOptions];
}

+ (void)endSession {

    //NSLog(@"Ending tracking session");
    //[Apsalar endSession];
}

+ (void)restartSession:(NSString *)apiKey withSecret:(NSString *)secret {

    //NSLog(@"Restarting tracking session");
    //[Apsalar reStartSession:apiKey withKey:secret];
}

+ (void)logEvent:(NSString *)eventName {

    //NSLog(@"Tracking event: %@", eventName);
    //[Apsalar event:eventName];
    
    //if([[GAI sharedInstance] defaultTracker]){
    //    [Analytics logGAEvent:eventName];
    //}
}

+ (void)logEvent:(NSString *)eventName withParams:(NSDictionary *)params {

    //NSLog(@"Tracking event with param: %@", eventName);
    //[Apsalar event:eventName withArgs:params];
    
    //if([[GAI sharedInstance] defaultTracker]){
    //    [Analytics logGAEvent:eventName];
    //}
}


+ (void)startGASession:(NSString *)trackingID {
    
    @try{
            
        // Optional: automatically send uncaught exceptions to Google Analytics.
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        [GAI sharedInstance].dispatchInterval = 20;
        
        // Optional: set Logger to VERBOSE for debug information.
        //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
        
        // Initialize tracker.
        // id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:trackingID];
        [[GAI sharedInstance] trackerWithTrackingId:trackingID];
        
        [[GAI sharedInstance] defaultTracker].allowIDFACollection = NO;
        
    }@catch(id exception){
        NSLog(@"GA Exception");
    }
}

+ (void)logGAEvent:(NSString *)categoryName withAction:(NSString *)actionString {
    
    @try{
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:categoryName      // Event category (required)
                                                              action:actionString          // Event action (required)
                                                               label:@""          // Event label
                                                               value:nil] build]];      // Event value
    }@catch(id exception){
        NSLog(@"GA Exception");
    }
}

+ (void)logGAEvent:(NSString *)categoryName withAction:(NSString *)actionString withLabel:(NSString *)labelString {
    
    @try{
            
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:categoryName       // Event category (required)
                                                              action:actionString         // Event action (required)
                                                               label:labelString          // Event label
                                                               value:nil] build]];      // Event value
    }@catch(id exception){
        NSLog(@"GA Exception");
    }
}

+ (void)logGAEvent:(NSString *)categoryName withAction:(NSString *)actionString withParams:(id)params
{
    @try{
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                    
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:categoryName       // Event category (required)
                                                                  action:actionString         // Event action (required)
                                                                   label:jsonString          // Event label
                                                                   value:nil] build]];
        }// Event value
    }@catch(id exception){
        NSLog(@"GA Exception");
    }
}

+ (void)logGAEvent:(NSString *)categoryName withAction:(NSString *)actionString withLabel:(NSString *)labelString withValue:(NSNumber *)numberValue {
    
    @try{
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:categoryName       // Event category (required)
                                                              action:actionString         // Event action (required)
                                                               label:labelString          // Event label
                                                               value:numberValue] build]];      // Event value
    }@catch(id exception){
        NSLog(@"GA Exception");
    }
}

+ (void)logScreenView:(NSString *)screenName{
    
    @try{
            
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:screenName];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    }@catch(id exception){
        NSLog(@"GA Exception");
    }
    
}

+ (void)logGARevenueEvent:(NSString *)oid withRevenue:(NSNumber *)revenue withTax:(NSNumber *)tax withShipping:(NSNumber *)shipping withCurrencyCode:(NSString *)currencyCode {
    
    @try{
            
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createTransactionWithId:oid
                                                        affiliation:@"Checkout Purchase"         // (NSString) Affiliation
                                                        revenue:revenue    // (int64_t) Order revenue (including tax and shipping)
                                                        tax:tax         // (int64_t) Tax
                                                        shipping:shipping             // (int64_t) Shipping
                                                        currencyCode:currencyCode] build]];          // (NSString) Currency code
    }@catch(id exception){
        NSLog(@"GA Exception");
    }
}

+ (void)logGACartItemEventWithTransactionID:(NSString *)oid forName:(NSString *)name withSku:(NSString *)sku forCategory:(NSString *)category atPrice:(NSNumber *)price forQuantity:(NSInteger)quantity havingCurrencyCode:(NSString *)currencyCode
{
    @try{
            
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createItemWithTransactionId:oid
                                                                    name:name
                                                                     sku:sku
                                                                category:category
                                                                   price:price
                                                                quantity:[NSNumber numberWithInt:quantity]
                                                            currencyCode:currencyCode] build]];
    }@catch(id exception){
        NSLog(@"GA Exception");
    }
}



@end
