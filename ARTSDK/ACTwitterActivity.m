//
//  ACTwitterActivity.m
//  Pods
//
//  Created by Jobin on 14/04/14.
//
//

#import "ACTwitterActivity.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "ACConstants.h"


@interface ACTwitterActivity ()

@property(nonatomic, strong) NSString *imageURL;
@property(nonatomic, strong) NSString *sourceURL;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *iTunesURL;
@property(nonatomic, strong) NSString *appName;
@end

@implementation ACTwitterActivity


// Return the name that should be displayed below the icon in the sharing menu
- (NSString *)activityTitle {
    return @"Twitter";
}

// Return the string that uniquely identifies this activity type
- (NSString *)activityType {
    return @"com.art.ios.Twitter";
}

// Return the image that will be displayed  as an icon in the sharing menu
- (UIImage *)activityImage {
    return [UIImage imageNamed: ARTImage(@"icon_twitter")];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    //Determine whether this service should be displayed by the UIActivityController
    //(This mostly depends if this service can do something with the objects/ data provided via the activityItems
    
    //NIDINFO("canPerformWithActivityItems");
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
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
    NSString *customUrl = [ACConstants getCutomizedUrlForUrl:[dict objectForKey:@"sourceURL"] forType:ACCustomSharingTypeTwitter];
    NSError *error;
    NSString *tinyURL =  [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@", customUrl]]
                                                  encoding:NSASCIIStringEncoding error:&error];
    _sourceURL = tinyURL;
    _iTunesURL = [dict objectForKey:@"iTunesURL"];
    _appName = [dict objectForKey:@"appName"];
}

- (UIViewController *) activityViewController
{
    SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    [mySLComposerSheet setInitialText:_title];
    
    @try{
        //try to add the image
        NSURL *url = [NSURL URLWithString:_imageURL];
        if(url){
            [mySLComposerSheet addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]];
        }
    }@catch(id exception){
        //do nothing - just dont add the image
    }
    
    [mySLComposerSheet addURL:[NSURL URLWithString:_sourceURL]];
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

/*
 - (void)performActivity {
 NIDINFO("performActivity");
 
 [self activityDidFinish:YES];
 }
 */

@end
