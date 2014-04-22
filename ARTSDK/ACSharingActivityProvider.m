//
//  SharingActivityProvider.m
//  JudyTouch
//
//  Created by Doug Diego on 10/17/13.
//  Copyright (c) 2013 Art.com, Inc. All rights reserved.
//

#import "ACSharingActivityProvider.h"
// https://github.com/rdougan/RDActivityViewController

@implementation ACSharingActivityProvider

- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(NSString *)activityType {
    
    //NIDINFO("activityType: %@", activityType);
    
    // customize the sharing string for facebook, twitter, weibo, and google+
    if ([activityType isEqualToString:@"com.art.ios.PinterestSharing"] ||
        [activityType isEqualToString:@"com.art.ios.Mail"] ||
        [activityType isEqualToString:@"com.art.ios.Favorites"] ||
        [activityType isEqualToString:@"com.art.ios.Facebook"] ||
        [activityType isEqualToString:@"com.art.ios.Twitter"] ||
        [activityType isEqualToString:@"com.art.ios.FavoritesRemove"]  ) {
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        [dict setObjectNotNull:_title forKey:@"title"];
        [dict setObjectNotNull:_imageURL forKey:@"imageURL"];
        [dict setObjectNotNull:_sourceURL forKey:@"sourceURL"];
        [dict setObjectNotNull:_iTunesURL forKey:@"iTunesURL"];
        [dict setObjectNotNull:_appName forKey:@"appName"];
        [dict setObjectNotNull:_itemId forKey:@"itemId"];
        if(_shareItemId){
            [dict setObjectNotNull:_shareItemId forKey:@"shareItemId"];
        }
        if(_galleryItemId){
            [dict setObjectNotNull:_galleryItemId forKey:@"galleryItemId"];
        }
        return dict;
        
    } else {
        
        //return _title;
        return [super activityViewController:activityViewController itemForActivityType:activityType];
    }
}

//- Returns the placeholder object for the data. (required)
//- The class of this object must match the class of the object you return from the above method
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    
    //NIDINFO("activityViewControllerPlaceholderItem: %@", activityViewController);
    
    //return @"";
    return [super activityViewControllerPlaceholderItem:activityViewController];
}

@end
