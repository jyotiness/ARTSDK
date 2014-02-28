//
//  PinterestActivity.m
//  JudyTouch
//
//  Created by Doug Diego on 10/17/13.
//  Copyright (c) 2013 Art.com, Inc. All rights reserved.
//

#import "ACPinterestActivity.h"
#import "Pinterest.h"

@interface ACPinterestActivity ()

@property(nonatomic, strong) NSString *imageURL;
@property(nonatomic, strong) NSString *sourceURL;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) Pinterest *pinterest;
@end

@implementation ACPinterestActivity

- (id)initWithClientId: (NSString*) clientId
       urlSchemeSuffix: (NSString*) urlSchemeSuffix {
    
    self = [super init];
    if (self) {
        _pinterest = [[Pinterest alloc] initWithClientId:clientId urlSchemeSuffix:urlSchemeSuffix];
    }
    return self;
    
}

// Return the name that should be displayed below the icon in the sharing menu
- (NSString *)activityTitle {
    return @"Pinterest";
}

// Return the string that uniquely identifies this activity type
- (NSString *)activityType {
    return @"com.art.ios.PinterestSharing";
}

// Return the image that will be displayed  as an icon in the sharing menu
- (UIImage *)activityImage {
    return [UIImage imageNamed: @"ArtAPI.bundle/icon_pinterest"];
}

// allow this activity to be performed with any activity items
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    //return YES;
    //NIDINFO("canPinWithSDK: %d" , [_pinterest canPinWithSDK] );
    
    return [_pinterest canPinWithSDK];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    //NIDINFO("prepareWithActivityItems: %@",activityItems);
    
    NSDictionary * dict = [activityItems objectAtIndex:0];
    _title = [dict objectForKey:@"title"];
    _imageURL = [dict objectForKey:@"imageURL"];
    _sourceURL = [dict objectForKey:@"sourceURL"];
    
}

// initiate the sharing process. First we will need to login
- (void)performActivity {
    //NIDINFO("performActivity");
    [_pinterest createPinWithImageURL:[NSURL URLWithString:_imageURL]
                            sourceURL:[NSURL URLWithString:_sourceURL]
                          description:_title];
    
    [self activityDidFinish:YES];
}


// handles results from sharing activity.
- (void)finishedSharing: (BOOL)shared {
    if (shared) {
        //NIDINFO("User successfully shared!");
    } else {
        //NIDINFO("User didn't share.");
    }
}

@end
