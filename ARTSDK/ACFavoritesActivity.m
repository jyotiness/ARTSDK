//
//  ACFavoritesActivity.m
//  ArtAPI
//
//  Created by Doug Diego on 2/10/14.
//  Copyright (c) 2014 Doug Diego. All rights reserved.
//

#import "ACFavoritesActivity.h"
#import "ACLoginViewController.h"
#import "ArtAPI.h"
#import "SVProgressHUD.h"

@interface ACFavoritesActivity () <ACLoginDelegate>

@property(nonatomic, copy) NSString *itemId;
@property(readwrite,nonatomic) BOOL failOnNoAuthSession;

@end

@implementation ACFavoritesActivity

- (instancetype)initWithType:(FavoritesType)type
{
    self = [super init];
    if (self) {
        
        self.type = type;
        self.failOnNoAuthSession = YES;
    }
    return self;
}

// Return the name that should be displayed below the icon in the sharing menu
- (NSString *)activityTitle
{
    NSString *title = nil;
    
    switch (self.type) {
        case FavoritesTypeGallery:
            title = ACLocalizedString(@"FAVORITES_GALLERY_ACTIVITY_TITLE", @"Save Gallery") ;
            break;
        case FavoritesTypeItem:
            title = ACLocalizedString(@"FAVORITES_ITEM_ACTIVITY_TITLE", @"Save Item") ;
            break;
        case FavoritesTypeOther:
            title = ACLocalizedString(@"FAVORITES_ACTIVITY_TITLE", @"Save to Gallery") ;
            break;
        default:
            title = ACLocalizedString(@"FAVORITES_ACTIVITY_TITLE", @"Save to Gallery") ;
            break;
    }
    return title;
}

// Return the string that uniquely identifies this activity type
- (NSString *)activityType {
    return @"com.art.ios.Favorites";
}

// Return the image that will be displayed  as an icon in the sharing menu
- (UIImage *)activityImage {
    return [UIImage imageNamed: ARTImage(@"icon_save_selected")];
}

// allow this activity to be performed with any activity items
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    //NSLog(@"prepareWithActivityItems: %@",activityItems);
    
    NSDictionary * dict = [activityItems objectAtIndex:0];
    _itemId = [dict objectForKey:@"shareItemId"];
    
    //NSLog(@"itemId: %@", _itemId);
    
}

-(void)favoritesAction
{
    if(self.type == FavoritesTypeGallery)
    {
        [SVProgressHUD showWithStatus:ACLocalizedString(@"FAVORITES_ACTIVITY_BOOKMARK_PROGRESS", @"Saving to Bookmarks") ];
        [ArtAPI addGalleryToBookmark:_itemId success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            //NSLog(@"SUCCESS url: %@ %@", request.HTTPMethod, request.URL);
            //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
            
            [SVProgressHUD showSuccessWithStatus:ACLocalizedString(@"FAVORITES_ACTIVITY_BOOKMARKED", @"Saved to Bookmarks") ];
            
        }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
            NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
            [SVProgressHUD showErrorWithStatus:ACLocalizedString(@"FAVORITES_ACTIVITY_ERROR", @"Error Saving") ];
            
        }];
    }
    else
    {
        [SVProgressHUD showWithStatus:ACLocalizedString(@"FAVORITES_ACTIVITY_SAVING_PROGRESS", @"Saving to Gallery") ];
        [ArtAPI addToMobileGalleryItemId:_itemId success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            //NSLog(@"SUCCESS url: %@ %@", request.HTTPMethod, request.URL);
            //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
            
            [SVProgressHUD showSuccessWithStatus:ACLocalizedString(@"FAVORITES_ACTIVITY_SAVED", @"Saved to Gallery") ];
            
        }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
            NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
            [SVProgressHUD showErrorWithStatus:ACLocalizedString(@"FAVORITES_ACTIVITY_ERROR", @"Error Saving") ];
            
        }];
    }
}

- (UIViewController *) activityViewController {
    //NSLog(@"activityViewController itemId: %@", _itemId);
    
    
    if( [ArtAPI isLoggedIn])
    {
        //NSLog(@"LoggedIn");
        //NSLog(@"Adding Gallery ItemId: %@", _itemId);
        [self favoritesAction];
        [self activityDidFinish:YES];
        
    } else {
        //NSLog(@"!LoggedIn");
        
        if( _failOnNoAuthSession ){
            [self activityDidFinish:NO];
        } else {
            ACLoginViewController *loginViewController = [[ACLoginViewController alloc] init];
            loginViewController.delegate = self;
            loginViewController.loginMessage = ACLocalizedString(@"FAVORITES_ACTIVITY_LOGIN_MESSAGE", @"Please login to save to your Gallery");
            
            [[UINavigationBar appearance] setTintColor:UIColorFromRGB(0x32ccff)];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
            navigationController.modalInPopover = YES;
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            return navigationController;
        }
    }
    
    //[self activityDidFinish:YES];
    
    return nil;
}


// handles results from sharing activity.
- (void)finishedSharing: (BOOL)shared {
    
    if (shared) {
        NSLog(@"User successfully shared!");
    } else {
        NSLog(@"User didn't share.");
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ACLoginDelegate

-(void) loginDidPressCloseButton:(ACLoginViewController *)loginViewController {
    //NSLog(@"loginDidPressCloseButton");
    [self activityDidFinish:YES];
}


- (void)loginSuccess:(ACLoginViewController *)loginViewController {
    //_itemId = loginViewController.tag;
    //NSLog(@"loginSuccess itemId: %@", _itemId );
    [self favoritesAction];
}

@end