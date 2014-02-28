//
//  ACCreateAccountViewController.m
//  ArtAPI
//
//  Created by Doug Diego on 3/7/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ACCreateAccountViewController.h"
#import "ArtAPI.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Additions.h"
#import "ACCreateAccountViewController.h"
#import "ACLoginCustomCell.h"
#import "SVProgressHUD.h"
#import "NSString+Additions.h"
#import "UINavigationController+KeyboardDismiss.h"
#import "ACWebViewController.h"
#import "ACKeyboardToolbarView.h"


@interface ACCreateAccountViewController() <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ACKeyboardToolbarDelegate>
@property(nonatomic, copy) NSString *email;
@property(nonatomic, copy) NSString *password;
@property(nonatomic, copy) NSString *confirmPassword;
@property(nonatomic, strong) NSString * error;
@property(nonatomic, strong) NSMutableDictionary * fieldErrors;
@property(nonatomic, strong) UITextField * txtActiveField;
@property (nonatomic,retain) NSIndexPath *selectedIndexPath;
@end

@implementation ACCreateAccountViewController

@synthesize delegate = _delegate;
@synthesize email = _email;
@synthesize password = _password;
@synthesize confirmPassword = _confirmPassword;
@synthesize error = _error;
@synthesize fieldErrors = _fieldErrors;
@synthesize txtActiveField = _txtActiveField;
@synthesize selectedIndexPath = _selectedIndexPath;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Life Cycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    //self.title = ACLocalizedString(@"Sign In",@"Sign In");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissModal) name:kACNotificationDismissModal object:nil];
    
    // Customize Nav Bar
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:ACLocalizedString(@"CLOSE", @"CLOSE")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(closeButtonAction:)];
    self.navigationItem.rightBarButtonItem = closeButton;
    //closeButton.tintColor = UIColorFromRGB(0x32ccff);
    
    // Check for back button
    int n = [self.navigationController.viewControllers count] - 2;
    if (n >= 0) {
        // Override Button
        //self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //[self.backButton setBackgroundImage:[UIImage imageNamed:@"ArtAPI.bundle/TOP_NAV_BUTTONS.png"] forState:UIControlStateNormal];
        //[self.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //[self.backButton setTitle:ACLocalizedString(@"BACK", @"BACK")  forState:UIControlStateNormal];
        //[self.backButton.titleLabel setFont:[UIFont fontWithName:kACStandardFont size:23.0f]];
        //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    }
    
    
    // Initilize
    self.error = nil;
    self.fieldErrors = [NSMutableDictionary dictionary];
    self.password = @"";
    self.email = @"";
    self.confirmPassword = @"";
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, -20, 0);
    self.tableView.sectionHeaderHeight = 0.0;
    self.tableView.sectionFooterHeight = 0.0;
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:nil name:kACNotificationDismissModal object:nil];
    [super viewDidUnload];
}

- (void)dismissModal {
    [[NSNotificationCenter defaultCenter] removeObserver:nil name:kACNotificationDismissModal object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    //NSLog(@"ACCreateAccountViewController.viewWillAppear");
    
    [super viewWillAppear:animated];
    
    // Table Header
    self.tableView.tableHeaderView = [self tableViewHeader];
    
    // Table Footer
    self.tableView.tableFooterView = [self tableViewFooter];
    
    if( !self.showStandardBackButton ){
        UIButton *barBackButton = [ACConstants getBackButtonForTitle:[ACConstants getLocalizedStringForKey:@"BACK" withDefaultValue:@"Back"]];
        barBackButton.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
       
        [barBackButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:barBackButton];
        
        self.navigationItem.leftBarButtonItem = backBarButton;
        self.navigationItem.hidesBackButton = YES;
    }

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


-(void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Actions

- (void) closeButtonAction: (id) sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(createAccountDidPressCloseButton:)]) {
        [self.delegate createAccountDidPressCloseButton:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) backButtonAction: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)signup
{
    
    if([self.txtActiveField isFirstResponder])
    {
        [ self.txtActiveField resignFirstResponder];
    }
    
    self.error = nil;
    self.tableView.tableHeaderView = [self tableViewHeader];
    
    if ([self validateForm] ){
        //NSLog(@"passed validation");
        [SVProgressHUD showWithStatus:ACLocalizedString(@"SIGNING UP",@"SIGNING UP")];
        
        [ArtAPI
         requestForAccountCreateWithEmailAddress:self.email
         password:self.password
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
             } else {
                 NSDictionary *responseDict = [JSON objectForKeyNotNull:@"d"];
                 NSString *authTok = [responseDict objectForKeyNotNull:@"AuthenticationToken"];
                 [ArtAPI setAuthenticationToken:authTok];
                 
                 // Call Delegate
                 if (self.delegate && [self.delegate respondsToSelector:@selector(createAccountSuccess)]) {
                     [self.delegate createAccountSuccess];
                 }
             }
             
         }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
             //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
             // Failure
             [SVProgressHUD dismiss];
             
             self.error =  [JSON objectForKey:@"APIErrorMessage"];
             //ACLocalizedString(@"Your email address or password is incorrect", @"Your email address or password is incorrect");
             self.tableView.tableHeaderView = [self tableViewHeader];
             [self.tableView reloadData];
             
         }];
        
    } else {
         //NSLog(@"failed validation");
        // Reload and display error
        [self.tableView reloadData];
        self.tableView.tableHeaderView = [self tableViewHeader];
    }
}

-(void)termsOfService {
    ACWebViewController * webViewController = [[ACWebViewController alloc] initWithURL:[NSURL URLWithString:URL_TERMS_OF_SERVICE]];
    webViewController.toolbarHidden = YES;
    webViewController.titleHidden = YES;
    NSString *versionStr = [NSString stringWithFormat:@"v%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    UIBarButtonItem *versionBtn = [[UIBarButtonItem alloc] initWithTitle:versionStr style:UIBarButtonItemStyleBordered target:nil action:nil];
    versionBtn.tintColor = UIColorFromRGB(0x4a4a4a);
    versionBtn.enabled = NO;
    webViewController.leftButtonItem = versionBtn;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self.navigationController presentViewController:navigationController animated: YES completion:nil];
}

- (void) facebookButtonTapped: (id) sender {
    //NSLog(@"facebookButtonTapped");
    [self openSessionWithAllowLoginUI: YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Facebook
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    BOOL result = NO;
    FBSession *session =
    [[FBSession alloc] initWithAppID:nil
                         permissions:nil
                     urlSchemeSuffix:@"artcircles"
                  tokenCacheStrategy:nil];
    
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
            message = [NSString stringWithFormat:ACLocalizedString(key,key), appName];
        }
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:message
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void) handleFacebookLogin {
    FBAccessTokenData * accessTokenData = [FBSession activeSession].accessTokenData;
   // NSLog(@"handleFacebookLogin accessTokenData: %@", accessTokenData);
    
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
    //NSLog(@"ACCreateAccountViewContoller.authenticateWithFacebookUID: %@, emailAddress: %@ firstName: %@ lastName: %@", facebookUID, emailAddress, firstName, lastName);
    [SVProgressHUD showWithStatus:@"AUTHENTICATING"];
    
    [ArtAPI
     requestForAccountAuthenticateWithFacebookUID:facebookUID emailAddress:emailAddress firstName:firstName lastName:lastName facebookToken:facebookToken
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"ACCreateAccountViewContoller.SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
         
         AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
         if(currAppLoc==AppLocationNone){
             
             [self getDefaultMobileGallery];
             
         }else{
             NSDictionary *responseDict = [JSON objectForKeyNotNull:@"d"];
             NSString *authTok = [responseDict objectForKeyNotNull:@"AuthenticationToken"];
             [ArtAPI setAuthenticationToken:authTok];
             
             // Call Delegate
             if (self.delegate && [self.delegate respondsToSelector:@selector(createAccountSuccess)]) {
                 [self.delegate createAccountSuccess];
             }
         }
         
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         // Failure
         [SVProgressHUD dismiss];
         
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ACLocalizedString(@"Login Failed",@"Login Failed")
                                                             message:[JSON objectForKey:@"APIErrorMessage"]
                                                            delegate:nil cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
         [alertView show];
         
         // Call Delegate
         if (self.delegate && [self.delegate respondsToSelector:@selector(createAccountFailure)]) {
             [self.delegate createAccountFailure];
         }
         
     }];
}

-(void) getDefaultMobileGallery {
    // Get Mobile Gallery
    
    [ArtAPI requestForGalleryGetUserDefaultMobileGallerySuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if(!self.shouldRetainHudOnLogin)
            [SVProgressHUD dismiss];
        //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
        
        // Call Delegate
        
        NSDictionary *defaultGalleryResponse = [JSON objectForKeyNotNull:@"d"];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:defaultGalleryResponse];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"USER_DEFAULT_GALLERY_RESPONSE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(createAccountSuccess)]) {
            [self.delegate createAccountSuccess];
        }
    }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        if (self.delegate && [self.delegate respondsToSelector:@selector(createAccountFailure)]) {
            [self.delegate createAccountFailure];
        }
    }];
}

-(BOOL) validateForm
{
    [self.fieldErrors removeAllObjects];
    //NSLog(@"validateForm email: %@ password: %@ confirmPassword: %@", self.email, self.password, self.confirmPassword);
    
    if( ![self.email validateAsEmail]){
        [self.fieldErrors setObject:ACLocalizedString(@"Please enter a valid email address", @"Please enter a valid email address")
                             forKey:[NSNumber numberWithInt:0]];
    }
    if( [self.password isEmpty]){
        [self.fieldErrors setObject:ACLocalizedString(@"Please enter a password", @"Please enter a password")
                             forKey:[NSNumber numberWithInt:1]];
    }
    if( [self.confirmPassword isEmpty]){
        [self.fieldErrors setObject:ACLocalizedString(@"Please enter a password", @"Please enter a password")
                             forKey:[NSNumber numberWithInt:2]];
    }
    
    if(ACIsStringWithAnyText(self.password ) &&
       ACIsStringWithAnyText(self.confirmPassword ) &&
       ![self.password isEqualToString:self.confirmPassword]) {
        self.error = ACLocalizedString(@"Your passwords did not match", @"Your passwords did not match");
    }
    
    //NSLog(@"fieldErrors: %@ error: %@", self.fieldErrors, self.error);
    
    return ( [self.fieldErrors count]>0 || ACIsStringWithAnyText(self.error))?NO:YES;
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
#pragma mark UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath section: %d row: %d", indexPath.section, indexPath.row);
    if(indexPath.row == 3){
        UITableViewCell * cell = (UITableViewCell*)[tableView   dequeueReusableCellWithIdentifier:@"Cell"];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] init];
        }
        
        // Make cell unselectable
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat buttonWidth = 182, buttonHeight = 40;
        
        // Signup Button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(signup) forControlEvents:UIControlEventTouchDown];
        [button setTitle:ACLocalizedString(@"SIGN UP", @"SIGN UP")  forState:UIControlStateNormal];
        //[button setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)];
        [button setBackgroundColor:[UIColor darkTextColor]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [ACConstants getStandardBoldFontWithSize:32.0f];
        button.layer.cornerRadius = 2.0f;
        button.frame = CGRectMake(self.view.bounds.size.width/2-buttonWidth/2,10,buttonWidth,buttonHeight);
        [cell addSubview:button];
        
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
                        cell.textLabel.textColor = [UIColor redColor];
                        cell.textField.placeholder = [self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]];
                    }
                    if( ACIsStringWithAnyText(self.error)){
                        //cell.textLabel.textColor = [UIColor redColor];
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
                    if([self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]] != nil ){
                        cell.textLabel.textColor = [UIColor redColor];
                        cell.textField.placeholder = [self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]];
                    } else if( ACIsStringWithAnyText(self.error)){
                        cell.textField.text = @"";
                        cell.textField.placeholder = ACLocalizedString(@"Please enter a password", @"Please enter a password");
                    }
                    break;
                case 2:
                    cell.textLabel.text = ACLocalizedString(@"Confirm Password", @"Confirm Password");
                    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                    cell.textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
                    cell.textField.text = self.confirmPassword;
                    [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                    cell.textField.secureTextEntry = YES;
                    cell.textLabel.textColor = [UIColor blackColor];
                    if([self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]] != nil ){
                        cell.textLabel.textColor = [UIColor redColor];
                        cell.textField.placeholder = [self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]];
                    } else if( ACIsStringWithAnyText(self.error)){
                        cell.textField.text = @"";
                        cell.textField.placeholder = ACLocalizedString(@"Please enter a password", @"Please enter a password");
                    }
                    break;
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 3){
        return 60;
    } else {
        return 48;
    }
}

-(UIView *) tableViewHeader
{
    CGRect bounds = self.view.bounds;
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 184)];
    
    CGFloat x = 0, y = 35;
    CGFloat facebookButtonWidth = 242, facebookButtonHeight = 40;
    
    // Facebook Button Label
    UILabel * loginLabel =  [[UILabel alloc] initWithFrame:CGRectMake(110,0,facebookButtonWidth-110, facebookButtonHeight )];
    loginLabel.text = ACLocalizedString(@"SIGN UP", @"SIGN UP") ;
    loginLabel.font = [UIFont fontWithName:kACStandardFont size:32];
    loginLabel.textAlignment = NSTextAlignmentLeft;
    loginLabel.textColor = [UIColor whiteColor];
    loginLabel.backgroundColor = [UIColor clearColor];
    
    // Facebook Button Icon
    UIImageView *facebookIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"ArtAPI.bundle/iconFacebook.png"]];
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
    y = y + 35;
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
    y = y + 20;
    UILabel *signLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, bounds.size.width, 30)];
    signLabel.backgroundColor = [UIColor clearColor];
    signLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    signLabel.textColor = [UIColor darkTextColor];
    signLabel.textAlignment = NSTextAlignmentCenter;
    signLabel.text = ACLocalizedString(@"Sign up using your email address", @"Sign up using your email address") ;
    [view addSubview:signLabel];
    
    
    // Error Label
    if( ACIsStringWithAnyText(self.error)){
        y = y + 20;
        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, bounds.size.width, 30)];
        errorLabel.backgroundColor = [UIColor clearColor];
        errorLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        errorLabel.textColor = [UIColor redColor];
        errorLabel.textAlignment = NSTextAlignmentCenter;
        errorLabel.text = self.error;
        [view addSubview:errorLabel];
    }
    
    return view;
}

-(UIView*) tableViewFooter {
    
    CGRect bounds = self.view.bounds;
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 60)];
    
    CGFloat x = 0, y = 30;
    
    // Forgot Password Label
    UILabel * forgotPasswordLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.view.bounds.size.width, 30)];
    forgotPasswordLabel.text = ACLocalizedString(@"Terms of Service", @"Terms of Service");
    forgotPasswordLabel.textColor = UIColorFromRGB(0x888888);
    forgotPasswordLabel.font = [UIFont fontWithName:@"Arial" size:12];
    forgotPasswordLabel.backgroundColor = [UIColor clearColor];
    forgotPasswordLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:forgotPasswordLabel];
    
    
    // underline code
    CGSize expectedLabelSize = [forgotPasswordLabel.text sizeWithFont:forgotPasswordLabel.font
                                                    constrainedToSize:forgotPasswordLabel.frame.size
                                                        lineBreakMode:NSLineBreakByWordWrapping];
    
    UIView *viewUnderline=[[UIView alloc] init];
    viewUnderline.frame=CGRectMake((forgotPasswordLabel.frame.size.width - expectedLabelSize.width)/2,
                                   forgotPasswordLabel.frame.origin.y + 20,
                                   expectedLabelSize.width, 1);
    viewUnderline.backgroundColor =  UIColorFromRGB(0x888888);
    [view addSubview:viewUnderline];
    
    // Button
    UIButton * forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    forgotPasswordButton.frame=CGRectMake((forgotPasswordLabel.frame.size.width - expectedLabelSize.width)/2,
                                          forgotPasswordLabel.frame.origin.y,
                                          expectedLabelSize.width, 30);
    forgotPasswordButton.backgroundColor = UIColor.clearColor;
    [forgotPasswordButton addTarget:self action:@selector(termsOfService) forControlEvents:UIControlEventTouchDown];
    [view addSubview:forgotPasswordButton];
    
    
    return view;
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
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
    else if (2 == textField.tag) {
        self.confirmPassword=textField.text;
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
        self.selectedIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    } else if( self.selectedIndexPath.row == 2 ){
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    ACLoginCustomCell *cell = (ACLoginCustomCell*)[self.self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [cell.textField becomeFirstResponder];
}

- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectPrevious: (id) previous {
    if( self.selectedIndexPath.row == 0 ){
        self.selectedIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    } else if( self.selectedIndexPath.row == 1 ){
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    } else if( self.selectedIndexPath.row == 2 ){
        self.selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    
    ACLoginCustomCell *cell = (ACLoginCustomCell*)[self.self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [cell.textField becomeFirstResponder];
}

- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectDone: (id) done {
    [self.txtActiveField resignFirstResponder];
}

@end

