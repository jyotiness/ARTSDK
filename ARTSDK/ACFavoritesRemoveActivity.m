//
//  ACFavoritesRemoveActivity.m
//  ArtAPI
//
//  Created by Doug Diego on 2/13/14.
//  Copyright (c) 2014 Doug Diego. All rights reserved.
//



#import "ACFavoritesRemoveActivity.h"
#import "ACLoginViewController.h"
#import "ArtAPI.h"
#import "SVProgressHUD.h"

@interface ACFavoritesRemoveActivity () <ACLoginDelegate>

@property(nonatomic, copy) NSString *galleryItemId;

@end

@implementation ACFavoritesRemoveActivity


// Return the name that should be displayed below the icon in the sharing menu
- (NSString *)activityTitle {
    return ACLocalizedString(@"FAVORITES_REMOVE_ACTIVITY_TITLE", @"Remove from Gallery") ;
}

// Return the string that uniquely identifies this activity type
- (NSString *)activityType {
    return @"com.art.ios.FavoritesRemove";
}

// Return the image that will be displayed  as an icon in the sharing menu
- (UIImage *)activityImage {
    return [UIImage imageNamed: ARTImage(@"icon_save_unselected")];
}

// allow this activity to be performed with any activity items
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    //NSLog(@"prepareWithActivityItems: %@",activityItems);
    
    NSDictionary * dict = [activityItems objectAtIndex:0];
    //NSLog(@"dict: %@", dict);
    _galleryItemId = [dict objectForKey:@"galleryItemId"];
    
}

- (UIViewController *) activityViewController {
    //NSLog(@"activityViewController");
    //NSLog(@"Removing GalleryItemId: %@", _galleryItemId);
    
    [SVProgressHUD showWithStatus:ACLocalizedString(@"FAVORITES_REMOVE_ACTIVITY_SAVING_PROGRESS", @"Removing from Gallery") ];
    [ArtAPI removeFromMobileGalleryItemId:[NSNumber numberWithLongLong:_galleryItemId.longLongValue] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"SUCCESS url: %@ %@", request.HTTPMethod, request.URL);
        //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
        [SVProgressHUD showSuccessWithStatus:ACLocalizedString(@"FAVORITES_REMOVE_ACTIVITY_SAVED", @"Removed from Gallery") ];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        [SVProgressHUD showErrorWithStatus:ACLocalizedString(@"FAVORITES_REMOVE_ACTIVITY_ERROR", @"Error Removing") ];
    }];
    
    [self activityDidFinish:YES];
    
    return nil;
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