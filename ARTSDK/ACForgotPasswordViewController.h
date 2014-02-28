//
//  ACForgotPasswordViewController.h
//  ArtAPI
//
//  Created by Doug Diego on 5/7/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ACForgotPasswordDelegate;

@interface ACForgotPasswordViewController : UITableViewController

// If set to true, the standard back button will be used
@property (nonatomic, assign) BOOL  showStandardBackButton;

// Delegate
@property (assign, nonatomic) id <ACForgotPasswordDelegate> delegate;

@end

@protocol ACForgotPasswordDelegate<NSObject>
@optional
- (void)forgotPasswordDidPressCloseButton: (ACForgotPasswordViewController*) forgotPasswordViewController;
@end
