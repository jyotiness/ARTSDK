//
//  ACiPhoneLoginViewController.h
//  ArtAPI
//
//  Created by Jobin on 22/11/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "GAITrackedViewController.h"

typedef enum LoginMode {
    LoginModeLogin,
    LoginModeSignup
}LoginMode;

@protocol ACiPhoneLoginDelegate;

@interface ACiPhoneLoginViewController : GAITrackedViewController<FBLoginViewDelegate>

@property (nonatomic,assign) BOOL onlyFacebook;
@property (nonatomic,assign) LoginMode loginMode;

@property (nonatomic,strong) IBOutlet UISegmentedControl *segmentedButton;
@property (nonatomic,strong) IBOutlet UIButton *facebookLoginButton;
@property (nonatomic,strong) IBOutlet UITableView *tableview;
@property (nonatomic,strong) IBOutlet UIView *loginFooterView;
@property (nonatomic,strong) IBOutlet UIView *signupFooterView;
@property (nonatomic,strong) IBOutlet UIView *facebookLoginHolderView;
@property (nonatomic,strong) IBOutlet UIScrollView *loginHolderScrollView;

@property (nonatomic,strong) IBOutlet UIButton *emailLoginButton;
@property (nonatomic,strong) IBOutlet UIButton *emailSignupButton;
@property (nonatomic,strong) IBOutlet UIButton *forgotPasswordButton;
@property (nonatomic, assign) id <ACiPhoneLoginDelegate> delegate;

- (IBAction)toggleSegmentedAction:(id)sender;

- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)loginWithEmail:(id)sender;
- (IBAction)signupWithEmail:(id)sender;
- (IBAction)forgotPassword:(id)sender;

@end

@protocol ACiPhoneLoginDelegate<NSObject>
@optional
- (void)loginSuccess;
- (void)loginFailure;
@end
