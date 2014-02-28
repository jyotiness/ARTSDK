//
//  ACCreateAccountViewController.h
//  ArtAPI
//
//  Created by Doug Diego on 3/7/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

/**
 * A view controller that allows a user to create an account on Art.com
 * with either a username and paassword or through Facebook.
 *
 * <h2>NSNotificationCenter</h2>
 *
 * Responds notification: NOTIFICATION_DISMISS_MODAL  This will close the modal
 *
 */

@protocol ACCreateAccountDelegate;

@interface ACCreateAccountViewController : UITableViewController <FBLoginViewDelegate>
@property (assign, nonatomic) id <ACCreateAccountDelegate> delegate;

// If set to true, the standard back button will be used
@property (nonatomic, assign) BOOL  showStandardBackButton;

@end

@protocol ACCreateAccountDelegate<NSObject>
@optional
- (void)createAccountDidPressCloseButton: (ACCreateAccountViewController*) createAccountViewController;
- (void)createAccountSuccess;
- (void)createAccountFailure;
@end