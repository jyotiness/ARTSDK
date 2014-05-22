//
//  ACLoginViewController.m
//  artAPI
//
//  Created by Doug Diego on 04/01/13.
//  Copyright (c) 2013 Art.com. All rights reserved.
//

// DOUG - NOTES
// 1. ArtCircles got the mobile default gallery after login and put it in the session.
//    I removed this because that logic is more specific to the app and not the view.
//    I'm not opposed to putting that back if you think all apps should be doing that.
// 2. I commented out the NSNotificationCenter stuff.  Not really sure what that is for
//    Again I think this is app logic that should be in the login view.
// 3. Need to add analytics back



#import "ACLoginViewController.h"
#import "ArtAPI.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Additions.h"
#import "ACCreateAccountViewController.h"
#import "ACLoginCustomCell.h"
#import "SVProgressHUD.h"
#import "NSString+Additions.h"
#import "UINavigationController+KeyboardDismiss.h"
#import "ACForgotPasswordViewController.h"
#import "Analytics.h"
#import "ACKeyboardToolbarView.h"

@interface ACLoginViewController () <ACCreateAccountDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ACKeyboardToolbarDelegate,ACForgotPasswordDelegate>
@property(nonatomic, copy) NSString *email;
@property(nonatomic, copy) NSString *password;
@property(nonatomic, strong) NSString * error;
@property(nonatomic, strong) NSMutableDictionary * fieldErrors;
@property(nonatomic, strong) UITextField * txtActiveField;
@property(nonatomic,retain) NSIndexPath *selectedIndexPath;
@end

@implementation ACLoginViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Life Cycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        [self setLoginOptions:ACLoginOptionsAll];
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    if((self.loginOptions & ACLoginOptionsAll) == ACLoginOptionsAll){
        //NSLog(@"ACLoginOptionsAll");
    }
    if((self.loginOptions & ACLoginOptionsFacebook) == ACLoginOptionsFacebook){
        //NSLog(@"ACLoginOptionsFacebook");
    }
    
    // Listen for notification kACNotificationDismissModal
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissModal)
                                                 name:kACNotificationDismissModal object:nil];
    
    
    // Create Close Button
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:ACLocalizedString(@"CLOSE", @"CLOSE")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(closeButtonAction:)];
    //closeButton.tintColor = UIColorFromRGB(0x32ccff);
    self.navigationItem.rightBarButtonItem = closeButton;
    
    
    // Initilize
    self.error = nil;
    self.fieldErrors = [NSMutableDictionary dictionary];
    self.password = @"";
    self.email = @"";
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, -20, 0);
    self.tableView.sectionHeaderHeight = 0.0;
    self.tableView.sectionFooterHeight = 0.0;
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
    
    // Table Header
    self.tableView.tableHeaderView = [self tableViewHeader];
    
    // Table Footer
    self.tableView.tableFooterView = [self tableViewFooter];

    if(
       (self.loginOptions & ACLoginOptionsFacebook) == ACLoginOptionsFacebook &&
       !((self.loginOptions & ACLoginOptionsAll) == ACLoginOptionsAll)
       ){
        //NSLog(@"Facebook auto login");
        [self facebookButtonTapped: nil];
    }
    
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    //NSLog(@"%s viewWillDisappear", __PRETTY_FUNCTION__);
    [super viewWillDisappear:YES];
}

- (void)viewDidUnload {
    //NSLog(@"%s viewDidUnload", __PRETTY_FUNCTION__);
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:nil name:kACNotificationDismissModal object:nil];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return NO;
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return YES;
    }
    return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Actions

- (void)dismissModal {
    [[NSNotificationCenter defaultCenter] removeObserver:nil name:kACNotificationDismissModal object:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginDidPressCloseButton:)]) {
        [self.delegate loginDidPressCloseButton:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) notNowButtonTapped: (id) sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginLater)]) {
        [self.delegate loginLater];
    }
}

- (void) closeButtonAction: (id) sender {
    //NSLog(@"closeButtonAction");
    
    if(self.fieldErrors){
        [self.fieldErrors removeAllObjects];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginDidPressCloseButton:)]) {
         //NSLog(@"calling delegate");
        [self.delegate loginDidPressCloseButton:self];
    } else {
        //NSLog(@"calling dismissViewControllerAnimated");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) forgotPassword {
    ACForgotPasswordViewController * controller = [[ACForgotPasswordViewController alloc] init];
    controller.showStandardBackButton = self.showStandardBackButton;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) facebookButtonTapped: (id) sender {
    //NSLog(@"facebookButtonTapped");
    [self openSessionWithAllowLoginUI: YES];
}

- (void) login {
    
    if([self.txtActiveField isFirstResponder])
    {
        [ self.txtActiveField resignFirstResponder];
    }
    
    self.error = nil;
    self.tableView.tableHeaderView = [self tableViewHeader];
    
    if ([self validateForm] ){
        
        [SVProgressHUD showWithStatus:ACLocalizedString(@"AUTHENTICATING",@"AUTHENTICATING") maskType:SVProgressHUDMaskTypeClear];
        
        [ArtAPI
         requestForAccountAuthenticateWithEmailAddress:self.email
         password:self.password
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
             //[SVProgressHUD dismiss];
             
             // ANALYTICS: log event - LOG IN (completed)
             [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_LOGIN];
             
             AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
             if(currAppLoc==AppLocationNone){
                 NSDictionary *accountDetails = [[JSON objectForKeyNotNull:@"d"] objectForKeyNotNull:@"Account"];
                 NSDictionary *profileInfo = [accountDetails objectForKeyNotNull:@"ProfileInfo"];
                 NSString *accountId = [[profileInfo objectForKeyNotNull:@"AccountId"] stringValue];
                 
                 [[NSUserDefaults standardUserDefaults] setObject:accountId forKey:@"USER_ACCOUNT_ID"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 [self getDefaultMobileGallery];
             }else{
                 NSDictionary *responseDict = [JSON objectForKeyNotNull:@"d"];
                 NSString *authTok = [responseDict objectForKeyNotNull:@"AuthenticationToken"];
                 [ArtAPI setAuthenticationToken:authTok];
                 
                 // Call Delegate (Deprecate)
                 if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess)]) {
                     [self.delegate loginSuccess];
                 }
                 
                 // Call Delegate
                 if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess:)]) {
                     [self.delegate loginSuccess:self];
                 }
             }
             
             
         }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
             NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
             // Failure
             [SVProgressHUD dismiss];
             
             [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_LOGIN_FAILED];
             
             self.error =  ACLocalizedString(@"Your email address or password is incorrect", @"Your email address or password is incorrect");
             self.tableView.tableHeaderView = [self tableViewHeader];
             [self.tableView reloadData];
             //
         }];
    } else {
        [self.tableView reloadData];
    }
}

- (void)createAccount {
    ACCreateAccountViewController *createAccount = [[ACCreateAccountViewController alloc] init];
    createAccount.showStandardBackButton = YES;
    createAccount.delegate = self;
    createAccount.showStandardBackButton = self.showStandardBackButton;
    
    [self.navigationController pushViewController:createAccount animated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Facebook
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    BOOL result = NO;
    FBSession *session = nil;
    
    BOOL isAC = [ACConstants isArtCircles];
    
    if(isAC){
        session =
        [[FBSession alloc] initWithAppID:nil
                             permissions:[NSArray arrayWithObjects:@"user_photos",@"email",nil]
                         urlSchemeSuffix:@"artcircles"
                      tokenCacheStrategy:nil];
    }else{
        session =
        [[FBSession alloc] initWithAppID:nil
                             permissions:[NSArray arrayWithObjects:@"user_photos",@"email",nil]
                         defaultAudience:FBSessionDefaultAudienceFriends
                         urlSchemeSuffix:nil
                      tokenCacheStrategy:nil];
    }
    
    if (allowLoginUI ||
        (session.state == FBSessionStateCreatedTokenLoaded)) {
        [FBSession setActiveSession:session];
        [session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             [self sessionStateChanged:session state:state error:error];
         }];
        result = session.isOpen;
    }
    
    return result;
}

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    //NSLog(@"sessionStateChanged: %@ state: %d error: %@", session, state, error );
           
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                //NSLog(@"User session found");
                [self handleFacebookLogin];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    //[[NSNotificationCenter defaultCenter]
    // postNotificationName:FBSessionStateChangedNotification
     //object:session];
    if (error) {
        NSString* message = error.localizedDescription;
        
        if(error.code == 2){
            NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
            NSString * key = @"com.facebook.error.code.2";
            
            NSString *failReason = [error.userInfo objectForKeyNotNull:@"com.facebook.sdk:ErrorLoginFailedReason"];
            
            if([failReason rangeOfString:@"UserLoginCancelled"].location != NSNotFound){
                return;
            }
            
            message = [NSString stringWithFormat:ACLocalizedString(key,key), appName];
        }
        
        NSString *errorTitleString = [ACConstants getLocalizedStringForKey:@"ERROR" withDefaultValue:@"Error"];
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:errorTitleString
                                  message:message
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void) handleFacebookLogin {
    FBAccessTokenData * accessTokenData = [FBSession activeSession].accessTokenData;
    //NSLog(@"handleFacebookLogin accessTokenData: %@", accessTokenData);
    
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 //NSLog(@"ACLoginViewController.got user info: %@", user );
                 
                 [self authenticateWithFacebookUID:[user objectForKey:@"id"]
                                      emailAddress:[user objectForKey:@"email"]
                                         firstName:[user objectForKey:@"first_name"]
                                          lastName:[user objectForKey:@"last_name"]
                                     facebookToken:accessTokenData.accessToken];
                 
             } else {
                 NSLog(@"error: %@", error);
             }
         }];
        
        [[FBRequest requestWithGraphPath:@"me?fields=picture.type(large)" parameters: nil HTTPMethod:@"GET"] startWithCompletionHandler:
         ^(FBRequestConnection *connection, id result,NSError *error) {
             if (!error) {
                 //NSLog(@"ACLoginViewControllergot user result: %@", result );
                 NSString * url = [[[result objectForKey:@"picture"] objectForKey: @"data"] objectForKey:@"url"];
                 NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                 UIImage *profilePicture = [UIImage imageWithData:data];
                 [self saveToCache:profilePicture name:@"profilePicture"];
             } else {
                 NSLog(@"error: %@", error);
             }
         }];
        
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
- (void) authenticateWithFacebookUID:(NSString *)facebookUID
                        emailAddress:(NSString *)emailAddress
                           firstName:(NSString *)firstName
                            lastName:(NSString *)lastName
                       facebookToken:(NSString *)facebookToken {
    //NSLog(@"authenticateWithFacebookUID: %@, emailAddress: %@ firstName: %@ lastName: %@ facebookToken: %@",
    //      facebookUID, emailAddress, firstName, lastName,facebookToken);
    
    [SVProgressHUD showWithStatus:ACLocalizedString(@"AUTHENTICATING",@"AUTHENTICATING") maskType:SVProgressHUDMaskTypeClear];
    
    [ArtAPI
     requestForAccountAuthenticateWithFacebookUID:facebookUID emailAddress:emailAddress firstName:firstName lastName:lastName facebookToken:facebookToken
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
        
         AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
         if(currAppLoc==AppLocationNone){
             NSDictionary *accountDetails = [[JSON objectForKeyNotNull:@"d"] objectForKeyNotNull:@"Account"];
             NSDictionary *profileInfo = [accountDetails objectForKeyNotNull:@"ProfileInfo"];
             NSString *accountId = [[profileInfo objectForKeyNotNull:@"AccountId"] stringValue];
             
             [[NSUserDefaults standardUserDefaults] setObject:accountId forKey:@"USER_ACCOUNT_ID"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             [self getDefaultMobileGallery];
         }else{
             NSDictionary *responseDict = [JSON objectForKeyNotNull:@"d"];
             NSString *authTok = [responseDict objectForKeyNotNull:@"AuthenticationToken"];
             [ArtAPI setAuthenticationToken:authTok];
             
             // Call Delegate (Deprecate)
             if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess)]) {
                 [self.delegate loginSuccess];
             }
             
             // Call Delegate
             if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess:)]) {
                 [self.delegate loginSuccess:self];
             }
         }
         
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         // Failure
         [SVProgressHUD dismiss];
         
         //NSLog(@"request failed for URL: %@", request.URL);
         if(JSON && ACIsStringWithAnyText([JSON objectForKey:@"APIErrorMessage"])){
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ACLocalizedString(@"Login Failed",@"Login Failed")
                                                                 message:[JSON objectForKey:@"APIErrorMessage"]
                                                                delegate:nil cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
             [alertView show];
         } else {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ACLocalizedString(@"An error occurred. Please try again.",@"An error occurred. Please try again.")
                                                                 message:nil
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
             [alertView show];
             
         }
         NSString *errorMessagee = [JSON objectForKey:@"APIErrorMessage"];
         NSMutableDictionary *analyticsParams = [[NSMutableDictionary alloc] initWithCapacity:3];
         [analyticsParams setValue:[NSString stringWithFormat:@"%d",error.code] forKey:ANALYTICS_APIERRORCODE];
         [analyticsParams setValue:error.localizedDescription forKey:ANALYTICS_APIERRORMESSAGE];
         [analyticsParams setValue:[request.URL absoluteString] forKey:ANALYTICS_APIURL];
         [Analytics logGAEvent:ANALYTICS_CATEGORY_ERROR_EVENT withAction:errorMessagee withParams:analyticsParams];
         // Call Delegate
         if (self.delegate && [self.delegate respondsToSelector:@selector(loginFailure)]) {
             [self.delegate loginFailure];
         }
         
     }];
}

-(void) getDefaultMobileGallery {
    //NSLog(@"getDefaultMobileGallery()");
    
    // Get Mobile Gallery
    [ArtAPI requestForGalleryGetUserDefaultMobileGallerySuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        if(!self.shouldRetainHudOnLogin){
            [SVProgressHUD dismiss];
        }
        
        //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
        
        // Save Gallery Response
        NSDictionary *defaultGalleryResponse = [JSON objectForKeyNotNull:@"d"];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:defaultGalleryResponse];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"USER_DEFAULT_GALLERY_RESPONSE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Call Delegate (Deprecate)
        if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess)]) {
            [self.delegate loginSuccess];
        }
        
        // Call Delegate
        if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess:)]) {
            [self.delegate loginSuccess:self];
        }
        
    }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        [SVProgressHUD dismiss];
        if (self.delegate && [self.delegate respondsToSelector:@selector(loginFailure)]) {
            [self.delegate loginFailure];
        }
    }];
}

-(BOOL) validateForm
{
    [self.fieldErrors removeAllObjects];
    
    if( ![self.email validateAsEmail]){
        [self.fieldErrors setObject:ACLocalizedString(@"Please enter a valid email address", @"Please enter a valid email address")
                             forKey:[NSNumber numberWithInt:0]];
    }
    if( [self.password isEmpty]){
        [self.fieldErrors setObject:ACLocalizedString(@"Please enter a password", @"Please enter a password")
                             forKey:[NSNumber numberWithInt:1]];
    }
    //NSLog(@"fieldErrors: %@", self.fieldErrors);
    
    return ( [self.fieldErrors count]>0)?NO:YES;
}

// DOUG - Didn't really know if I should move the whole Datasource framework in to ArtAPI
// Just copied this one function.
- (void)saveToCache:(UIImage *)image name:(NSString *)name {
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:name];
    
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ACCreateAccountDelegate

- (void)createAccountDidPressCloseButton: (ACCreateAccountViewController*) createAccountViewController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginDidPressCloseButton:)]) {
        [self.delegate loginDidPressCloseButton:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)createAccountSuccess {
    //NSLog(@"ALoginViewController.createAccountSuccess... calling loginSuccess");
    
    // Call Delegate (Deprecate)
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess)]) {
        [self.delegate loginSuccess];
    }
    
    // Call Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess:)]) {
        [self.delegate loginSuccess:self];
    }
}

- (void)createAccountFailure {
    // Do nothing
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ACForgotPasswordDelegate

- (void)forgotPasswordDidPressCloseButton: (ACForgotPasswordViewController*) forgotPasswordViewController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginDidPressCloseButton:)]) {
        [self.delegate loginDidPressCloseButton:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath section: %d row: %d", indexPath.section, indexPath.row);
    if(indexPath.row == 2){
        UITableViewCell * cell = (UITableViewCell*)[tableView   dequeueReusableCellWithIdentifier:@"Cell"];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] init];
        }
        
        // Make cell unselectable
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Login Button
        CGFloat buttonWidth = 242, buttonHeight = 40;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchDown];
        [button setTitle:[ACLocalizedString(@"LOGIN", @"LOGIN") uppercaseString]  forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor darkTextColor]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //[button setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)];
        button.titleLabel.font = [ACConstants getStandardBoldFontWithSize:32.0f];
        button.layer.cornerRadius = 2.0f;
        button.frame = CGRectMake(self.view.bounds.size.width/2-buttonWidth/2,11,buttonWidth,buttonHeight);
        [cell addSubview:button];
        
        
        // Forgot Password Label
        UILabel * forgotPasswordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, buttonHeight + 15, self.view.bounds.size.width, 30)];
        forgotPasswordLabel.text = ACLocalizedString(@"Forgot Password?", @"Forgot Password?");
        forgotPasswordLabel.textColor = UIColorFromRGB(0x888888);
        forgotPasswordLabel.font = [UIFont fontWithName:@"Arial" size:12];
        forgotPasswordLabel.backgroundColor = [UIColor clearColor];
        forgotPasswordLabel.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:forgotPasswordLabel];
        
        
        // underline Forgot Password - to make it look like a link
        CGSize expectedLabelSize = [forgotPasswordLabel.text sizeWithFont:forgotPasswordLabel.font
                                                        constrainedToSize:forgotPasswordLabel.frame.size
                                                            lineBreakMode:NSLineBreakByWordWrapping];
        
        UIView *viewUnderline=[[UIView alloc] init];
        viewUnderline.frame=CGRectMake((forgotPasswordLabel.frame.size.width - expectedLabelSize.width)/2,
                                       forgotPasswordLabel.frame.origin.y + 20,
                                       expectedLabelSize.width, 1);
        viewUnderline.backgroundColor = UIColorFromRGB(0x888888);
        [cell addSubview:viewUnderline];
        
        // Forgot Password Button
        UIButton * forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        forgotPasswordButton.frame=CGRectMake((forgotPasswordLabel.frame.size.width - expectedLabelSize.width)/2,
                                              forgotPasswordLabel.frame.origin.y,
                                              expectedLabelSize.width, 30);
        forgotPasswordButton.backgroundColor = UIColor.clearColor;
        [forgotPasswordButton addTarget:self action:@selector(forgotPassword) forControlEvents:UIControlEventTouchDown];
        [cell addSubview:forgotPasswordButton];
        
        //cell.backgroundColor = [UIColor greenColor];
        
        return cell;
        
    } else {
        static NSString *SimpleTableIdentifier = @"LoginTableIdentifier";
        ACLoginCustomCell * cell = (ACLoginCustomCell*)[tableView   dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
        if (cell==nil) {
            cell = (ACLoginCustomCell *)[[ACBundle loadNibNamed:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ACLoginCustomCell-iPad" :@"ACLoginCustomCell"owner:self options:nil] objectAtIndex:0];
            
        }
        
        // Make cell unselectable
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Set tag
        cell.textField.tag=indexPath.row;
        
        // Make delegate of Text Field
        cell.textField.delegate = self;
        
        cell.textField.keyboardAppearance = UIKeyboardAppearanceLight;
        
        if(0 == indexPath.section)
        {
            switch ( indexPath.row )
            {
                case 0:
                    cell.textLabel.text = ACLocalizedString(@"Email Address", @"Email Address");
                    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                    cell.textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                    cell.textField.text = self.email;
                    [cell.textField setKeyboardType:UIKeyboardTypeEmailAddress];
                    [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                    cell.textLabel.textColor = [UIColor blackColor];
                    if([self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]] != nil){
                        cell.textField.text = @"";
                        cell.textLabel.textColor = [UIColor redColor];
                        cell.textField.placeholder = [self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]];
                    }
                    if( ACIsStringWithAnyText(self.error)){
                        cell.textLabel.textColor = [UIColor redColor];
                    }
                    break;
                case 1:
                    cell.textLabel.text = ACLocalizedString(@"Password", @"Password");
                    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                    cell.textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                    cell.textField.text = self.password;
                    [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                    cell.textField.secureTextEntry = YES;
                    cell.textLabel.textColor = [UIColor blackColor];
                    //cell.textLabel.textColor = (![cell.textField validateAsNotEmpty] && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                    if([self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]] != nil){
                        cell.textField.text = @"";
                        cell.textLabel.textColor = [UIColor redColor];
                        cell.textField.placeholder = [self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]];
                    }
                    if( ACIsStringWithAnyText(self.error)){
                        cell.textLabel.textColor = [UIColor redColor];
                    }
                    break;
            }
        }
        return cell;
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 2){
        return 95;
    } else {
        return 48;
    }
}


-(UIView *) tableViewFooter {
    CGFloat createButtonWidth = 242, createButtonHeight = 40, verticalPadding= 5;
    
    CGFloat viewHeight = verticalPadding*2+createButtonHeight;
     if(_showNotNowButton){
         viewHeight = viewHeight + verticalPadding + createButtonHeight;
     }
    
    CGRect bounds = self.view.bounds;
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, viewHeight)];
    //view.backgroundColor = [UIColor redColor];
    
    // Create Account Button
    UIButton * createAccountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [createAccountButton addTarget:self action:@selector(createAccount) forControlEvents:UIControlEventTouchDown];
    [createAccountButton setTitle:ACLocalizedString(@"CREATE ACCOUNT", @"CREATE ACCOUNT")  forState:UIControlStateNormal];
    [createAccountButton setBackgroundColor:[UIColor colorWithRed:0.353 green:0.718 blue:0.906 alpha:1.000]];
    [createAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    createAccountButton.titleLabel.font = [ACConstants getStandardBoldFontWithSize:30.0f];
    [createAccountButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)];
    createAccountButton.layer.cornerRadius = 2.0f;
    createAccountButton.frame = CGRectMake(self.view.bounds.size.width/2-createButtonWidth/2,
                                           verticalPadding,createButtonWidth,createButtonHeight);
    [view addSubview:createAccountButton];
    
    if(_showNotNowButton){
        // Create Not Now Button
        UIButton * notNowButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [notNowButton addTarget:self action:@selector(notNowButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [notNowButton setTitle:ACLocalizedString(@"NOT NOW, NEXT TIME", @"NOT NOW, NEXT TIME")  forState:UIControlStateNormal];
        [notNowButton setBackgroundColor:[UIColor colorWithRed:0.353 green:0.718 blue:0.906 alpha:1.000]];
        [notNowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        notNowButton.titleLabel.font = [ACConstants getStandardMediumFontWithSize:24.0f];
        [notNowButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)];
        notNowButton.layer.cornerRadius = 2.0f;
        notNowButton.frame = CGRectMake(self.view.bounds.size.width/2-createButtonWidth/2,
                                        createButtonHeight + verticalPadding*2,
                                        createButtonWidth,createButtonHeight);
        [view addSubview:notNowButton];
    }
    
    return view;
}


-(UIView *) tableViewHeader {
    
    CGRect bounds = self.view.bounds;
    
    // Initial Height
    CGFloat height = 144;
    
    // Add Height for Login Message
    if( _loginMessage ){
        height = height + 60;
    }
    
    // Add Height for Error
    if( ACIsStringWithAnyText(self.error)){
         height = height + 20;
    }
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, height)];
    
    CGFloat x = 0, y = 40;
    
    if( _loginMessage ){
        y = 20;
        UILabel *loginMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, y, bounds.size.width-10, 80)];
        loginMessageLabel.backgroundColor = [UIColor clearColor];
        loginMessageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        loginMessageLabel.textColor = [UIColor darkTextColor];
        loginMessageLabel.numberOfLines = 0;
        loginMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        loginMessageLabel.textAlignment = NSTextAlignmentCenter;
        loginMessageLabel.text = _loginMessage;
        //loginMessageLabel.backgroundColor = [UIColor redColor];
        [view addSubview:loginMessageLabel];
        y = y + 85;
    }
    
    CGFloat facebookButtonWidth = 242, facebookButtonHeight = 40;
    
    // Facebook Button Label
    UILabel * loginLabel =  [[UILabel alloc] initWithFrame:CGRectMake(110,0,facebookButtonWidth-110, facebookButtonHeight )];
    loginLabel.text = [ACLocalizedString(@"LOGIN", @"LOGIN") uppercaseString];
    loginLabel.font = [UIFont fontWithName:kACStandardFont size:32];
    loginLabel.textAlignment = NSTextAlignmentLeft;
    loginLabel.textColor = [UIColor whiteColor];
    loginLabel.backgroundColor = [UIColor clearColor];
    
    // Facebook Button Icon
    UIImageView *facebookIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: ARTImage(@"iconFacebook.png")]];
    facebookIconImageView.frame = CGRectMake(70,5,26,27);
    
    // Facebook Button
    UIButton * facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    x = self.view.bounds.size.width/2 - facebookButtonWidth/2;
    [facebookButton setFrame:CGRectMake(x,y, facebookButtonWidth, facebookButtonHeight)];
    facebookButton.backgroundColor = [UIColor colorWithRed:0.251 green:0.318 blue:0.525 alpha:1.000];
    facebookButton.layer.cornerRadius = 2.0f;
    [facebookButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [facebookButton addTarget:self action:@selector(facebookButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [facebookButton addSubview:loginLabel];
    [facebookButton addSubview:facebookIconImageView];
    [view addSubview:facebookButton];
    
    // Adjust y to make room for Facebook Login Button
    y = y + facebookButtonHeight;
    
    // Divider view
    y = y + 15;
    CGFloat dividerViewPadding = 0;
    x = dividerViewPadding;
    UIView * dividerView = [[UIView alloc] initWithFrame:CGRectMake(x,y,bounds.size.width-dividerViewPadding, 1)];
    dividerView.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:dividerView];
    
    // Or Label
    UILabel * orLabel = [[UILabel alloc] initWithFrame:CGRectMake((bounds.size.width-46)/2, y-(21/2), 46, 21)];
    orLabel.font = [UIFont boldSystemFontOfSize:13];
    orLabel.text = ACLocalizedString(@"OR", @"OR");
    orLabel.backgroundColor = [UIColor whiteColor];
    orLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:orLabel];
    
    // Sign In Label
    y = y + 7;
    UILabel *signLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, bounds.size.width, 30)];
    signLabel.backgroundColor = [UIColor clearColor];
    //signLabel.backgroundColor = [UIColor redColor];
    signLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    signLabel.textColor = [UIColor darkTextColor];
    signLabel.textAlignment = NSTextAlignmentCenter;
    signLabel.text = ACLocalizedString(@"Login with an Art.com account", @"Login with an Art.com account") ;
    [view addSubview:signLabel];
    
    // Error Label
    if( ACIsStringWithAnyText(self.error)){
        y = y + 20;
        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, bounds.size.width, 30)];
        errorLabel.backgroundColor = [UIColor clearColor];
        errorLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        errorLabel.textColor = [UIColor redColor];
        errorLabel.textAlignment = NSTextAlignmentCenter;
        errorLabel.text = self.error;
        [view addSubview:errorLabel];
    }
    
    //NSLog(@"y=%f", y);
    
    return view;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate



- (IBAction)textFieldFinished:(id)sender
{
    [sender resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //NSLog(@"textFieldDidBeginEditing: textField: %@", textField );
    
    self.txtActiveField = textField;
    
    //UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    //self.selectedIndexPath = [self.tableView indexPathForCell:cell];
    
    // Now add the view as an input accessory view to the selected textfield.
    //[textField setInputAccessoryView: [self createInputAccessoryView:YES]];
    ACKeyboardToolbarView * toolbar = [[ACKeyboardToolbarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([self.view getCurrentScreenBoundsDependOnOrientation]), 40)];
    toolbar.toolbarDelegate = self;
    [textField setInputAccessoryView:toolbar];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //NSLog(@"textFieldShouldEndEditing tag: %d text: %@", textField.tag, textField.text);
    return YES;
}

// Textfield value changed, store the new value.
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //NSLog(@"textFieldDidEndEditing tag: %d text: %@", textField.tag, textField.text);
    
    if (0 == textField.tag) {
        self.email = textField.text;
    }
    else if (1 == textField.tag) {
        self.password=textField.text;
    }
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ACKeyboardToolbarDelegate
- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectNext: (id) next {
    if( self.selectedIndexPath.row == 0 ){
        self.selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    } else if( self.selectedIndexPath.row == 1 ){
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    ACLoginCustomCell *cell = (ACLoginCustomCell*)[self.self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [cell.textField becomeFirstResponder];
}

- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectPrevious: (id) previous {
    if( self.selectedIndexPath.row == 0 ){
        self.selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    } else if( self.selectedIndexPath.row == 1 ){
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    ACLoginCustomCell *cell = (ACLoginCustomCell*)[self.self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [cell.textField becomeFirstResponder];
}

- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectDone: (id) done {
    [self.txtActiveField resignFirstResponder];
}

@end
