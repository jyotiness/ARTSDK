//
//  ACLoginViewController.h
//  artAPI
//
//  Created by Doug Diego on 04/01/13.
//  Copyright (c) 2013 Art.com. All rights reserved.
//
#import <FacebookSDK/FacebookSDK.h>

/**
 * A view controller that allows a user to login to Art.com
 * with either a username and paassword or through Facebook.
 *
 * <h2>NSNotificationCenter</h2>
 *
 * Responds notification: NOTIFICATION_DISMISS_MODAL  This will close the modal
 *
 */

typedef NS_OPTIONS(NSInteger, ACLoginOptions) {
    ACLoginOptionsArtcom        = 1 << 0,
    ACLoginOptionsFacebook      = 1 << 1,
    ACLoginOptionsCreateAccount = 1 << 2,
    ACLoginOptionsAll           =   ACLoginOptionsArtcom        |
                                    ACLoginOptionsFacebook      |
                                    ACLoginOptionsCreateAccount,
};

@protocol ACLoginDelegate;

@interface ACLoginViewController : UITableViewController <FBLoginViewDelegate>
@property (nonatomic, assign) id <ACLoginDelegate> delegate;
@property (nonatomic, assign) ACLoginOptions  loginOptions;

// When set, this will display a message at the top of the screen.
@property (nonatomic, copy) NSString *loginMessage;

// When set to YES, a button will be show shown that says: "Not Now, Next Time".
@property (nonatomic, assign) BOOL  showNotNowButton;

// If set to true, the standard back button will be used
@property (nonatomic, assign) BOOL  showStandardBackButton;

// If set to true, the SVProgressHUD won't be dismissed after login, and it will be handled by the delegate
@property (nonatomic, assign) BOOL  shouldRetainHudOnLogin;

@end

@protocol ACLoginDelegate<NSObject>
@optional
- (void)loginDidPressCloseButton: (ACLoginViewController*) loginViewController;
- (void)loginSuccess;
- (void)loginSuccess: (ACLoginViewController*) loginViewController;
- (void)loginFailure;
- (void)loginLater;
@end
