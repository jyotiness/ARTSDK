//
//  PinterestActivity.m
//  JudyTouch
//
//  Created by Doug Diego on 10/17/13.
//  Copyright (c) 2013 Art.com, Inc. All rights reserved.
//

#import "ACMailActivity.h"
#import "Pinterest.h"
#import <MessageUI/MessageUI.h>
#import "ACConstants.h"

@interface ACMailActivity () <MFMailComposeViewControllerDelegate>

@property(nonatomic, strong) NSString *imageURL;
@property(nonatomic, strong) NSString *sourceURL;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *iTunesURL;
@property(nonatomic, strong) NSString *appName;
@end

@implementation ACMailActivity



// Return the name that should be displayed below the icon in the sharing menu
- (NSString *)activityTitle {
    return @"Mail";
}

// Return the string that uniquely identifies this activity type
- (NSString *)activityType {
    return @"com.art.ios.Mail";
}

// Return the image that will be displayed  as an icon in the sharing menu
- (UIImage *)activityImage {
    return [UIImage imageNamed: ARTImage(@"icon_mail")];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    //Determine whether this service should be displayed by the UIActivityController
    //(This mostly depends if this service can do something with the objects/ data provided via the activityItems
    
    //NIDINFO("canPerformWithActivityItems");
    
    if(  [MFMailComposeViewController canSendMail] ){
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

- (UIViewController *) activityViewController {
    //NIDINFO("activityViewController");

    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
    mail.modalPresentationStyle = UIModalPresentationFormSheet;
    mail.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    mail.mailComposeDelegate = self;
    
    [mail setSubject:ACLocalizedString(@"SHARE_MAIL_SUBJECT", @"Check out what I found on Art.com")];
    
    
    NSString *artLogoURL = @"http://cache1.artprintimages.com/images/iPad/artCircles/ArtLogo.png";
    NSString *artDotComURL = @"http://www.art.com";
    
    // Fill out the email body text
    
    NSString *emailBody = [NSString stringWithFormat:
                           ACLocalizedString(@"SHARE_MAIL_BODY", @""),
                           _sourceURL,
                           _title,
                           artDotComURL,
                           _sourceURL,
                           _imageURL,
                           _sourceURL,
                           _sourceURL,
                           _iTunesURL,
                           _appName,
                           artDotComURL,
                           artDotComURL,
                           artLogoURL];
    
    [mail setMessageBody:emailBody isHTML:YES];
    
    return mail;
}
/*
- (void)performActivity {
    NIDINFO("performActivity");
    
    [self activityDidFinish:YES];
}
*/

#pragma martk - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent) {
        //This notifies the system that your activity object has completed its work.
        //This will dismiss the view controller provided via activityViewController method and the sharing interface provided by the UIActivityViewController
        [self activityDidFinish:YES];
    } else
    {
        [self activityDidFinish:NO];
    }
}
@end
