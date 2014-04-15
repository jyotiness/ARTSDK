//
//  ACFacebookActivity.m
//  Pods
//
//  Created by Jobin on 14/04/14.
//
//

#import "ACFacebookActivity.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "ACConstants.h"

@interface ACFacebookActivity ()

@property(nonatomic, strong) NSString *imageURL;
@property(nonatomic, strong) NSString *sourceURL;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *iTunesURL;
@property(nonatomic, strong) NSString *appName;
@end


@implementation ACFacebookActivity


// Return the name that should be displayed below the icon in the sharing menu
- (NSString *)activityTitle {
    return @"Facebook";
}

// Return the string that uniquely identifies this activity type
- (NSString *)activityType {
    return @"com.art.ios.Facebook";
}

// Return the image that will be displayed  as an icon in the sharing menu
- (UIImage *)activityImage {
    return [UIImage imageNamed: ARTImage(@"icon_facebook")];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    //Determine whether this service should be displayed by the UIActivityController
    //(This mostly depends if this service can do something with the objects/ data provided via the activityItems
    
    //NIDINFO("canPerformWithActivityItems");
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        //NIDINFO("canPerformWithActivityItems - YES - [MFMailComposeViewController canSendMail]");
        return YES;
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    //This gets call when the user select this custom service
    //Then, the controller will either call :
    //(a) the activityViewController, or
    //(b) performActivity.
    
    NSDictionary * dict = [activityItems objectAtIndex:0];
    _title = [dict objectForKey:@"title"];
    _imageURL = [dict objectForKey:@"imageURL"];
    _sourceURL = [dict objectForKey:@"sourceURL"];
    _iTunesURL = [dict objectForKey:@"iTunesURL"];
    _appName = [dict objectForKey:@"appName"];
}

- (UIViewController *) activityViewController
{
    SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [mySLComposerSheet setInitialText:_title];
    
    //[mySLComposerSheet addImage:[UIImage imageNamed:@"myImage.png"]];
    
    NSString *customUrl = [ACConstants getCutomizedUrlForUrl:_imageURL forType:ACCustomSharingTypeFacebook];
    [mySLComposerSheet addURL:[NSURL URLWithString:customUrl]];
    
    [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                NSLog(@"Post Canceled");
                break;
            case SLComposeViewControllerResultDone:
                NSLog(@"Post Sucessful");
                break;
                
            default:
                break;
        }
    }];
    
    return mySLComposerSheet;
}
@end
