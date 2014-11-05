//
//  ACiPhoneLoginViewController.m
//  ArtAPI
//
//  Created by Jobin on 22/11/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ACiPhoneLoginViewController.h"
#import "UIColor+Additions.h"
#import "ACConstants.h"
#import "ACLoginCustomCell.h"
#import "ACKeyboardToolbarView.h"
#import "SVProgressHUD.h"
#import "ArtAPI.h"
#import "Analytics.h"
#import "NSString+Additions.h"

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

//@interface UINavigationBar (myNave)
//- (CGSize)changeHeight:(CGSize)size;
//@end
//
//@implementation UINavigationBar (customNav)
//- (CGSize)sizeThatFits:(CGSize)size {
//    CGSize newSize = CGSizeMake(320,200);
//    return newSize;
//}
//
//@end

@interface ACiPhoneLoginViewController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ACKeyboardToolbarDelegate,UIAlertViewDelegate>
{
    NSArray *mDataSourceArray;
}
@property(nonatomic, copy) NSString *email;
@property(nonatomic, copy) NSString *password;
@property(nonatomic, copy) NSString *confirmPassword;
@property(nonatomic, strong) NSString * error;
@property(nonatomic, strong) NSMutableDictionary * fieldErrors;
@property(nonatomic, strong) UITextField * txtActiveField;
@property(nonatomic,retain) NSIndexPath *selectedIndexPath;

@end

@implementation ACiPhoneLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"Frame is %@",NSStringFromCGRect(self.facebookLoginButton.frame));
    [self.navigationController setToolbarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    self.navigationController.navigationBarHidden = NO;
}



-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [ super viewWillDisappear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"Frame is %@",NSStringFromCGRect(self.facebookLoginButton.frame));
}

- (void)viewDidLayoutSubviews
{
    CGRect frame = self.facebookLoginButton.frame;
//    frame.origin.y = 0.5;
//    self.facebookLoginButton.frame = frame;
    
//    self.facebookLoginButton.center = self.facebookLoginHolderView.center;
    
    if(self.onlyFacebook){
        [self.segmentedButton removeFromSuperview];
        frame = self.facebookLoginHolderView.frame;
        frame.origin.y = frame.origin.y - 40;
        self.facebookLoginHolderView.frame = frame;
    }
    
    NSString *forgotPassString = ACLocalizedString(@"FORGOT_YOUR_PASSWORD", nil);
    
    [self.forgotPasswordButton setTitle:forgotPassString forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitle:forgotPassString forState:UIControlStateHighlighted];
    
    [self.forgotPasswordButton sizeToFit];
    
    [self.facebookLoginButton setTitle:ACLocalizedString(@"LOG_IN_WITH_FACEBOOK", nil) forState:UIControlStateNormal];
    [self.facebookLoginButton setTitle:ACLocalizedString(@"LOG_IN_WITH_FACEBOOK", nil) forState:UIControlStateHighlighted];
    
    [self.emailLoginButton setTitle:ACLocalizedString(@"LOG_IN_WITH_EMAIL", nil) forState:UIControlStateNormal];
    [self.emailLoginButton setTitle:ACLocalizedString(@"LOG_IN_WITH_EMAIL", nil) forState:UIControlStateHighlighted];
    
    [self.emailSignupButton setTitle:ACLocalizedString(@"SIGN_UP_WITH_EMAIL", nil) forState:UIControlStateNormal];
    [self.emailSignupButton setTitle:ACLocalizedString(@"SIGN_UP_WITH_EMAIL", nil) forState:UIControlStateHighlighted];
    
    [self.segmentedButton setTitle:ACLocalizedString(@"LOG_IN", nil) forSegmentAtIndex:0];
    [self.segmentedButton setTitle:ACLocalizedString(@"SIGN_UP", nil) forSegmentAtIndex:1];
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.loginMode = LoginModeLogin;

    if(self.loginMode == LoginModeSignup)
    {
        [self.segmentedButton setSelectedSegmentIndex:1];
    }
    else// else condition added for use in the P2A and AC apps not related to SwitchArt 
    {
    	self.loginMode = LoginModeLogin;
    }
    
    self.error = nil;
    self.email = @"";
    self.password = @"";
    self.confirmPassword = @"";
    self.tableview.tableHeaderView = nil;
    
    self.view.backgroundColor = [UIColor artDotComLightGray_Light_Color_iPad];
    self.segmentedButton.tintColor = [ACConstants getPrimaryLinkColor];
    
    self.fieldErrors = [NSMutableDictionary dictionary];
    
    [self.facebookLoginButton setTitleColor:[ACConstants getPrimaryLinkColor] forState:UIControlStateNormal];
    [self.facebookLoginButton setTitleColor:[ACConstants getHighlightedPrimaryLinkColor] forState:UIControlStateHighlighted];

    [self.emailLoginButton setTitleColor:[ACConstants getPrimaryLinkColor] forState:UIControlStateNormal];
    [self.emailLoginButton setTitleColor:[ACConstants getHighlightedPrimaryLinkColor] forState:UIControlStateHighlighted];
    [self.emailSignupButton setTitleColor:[ACConstants getPrimaryLinkColor] forState:UIControlStateNormal];
    [self.emailSignupButton setTitleColor:[ACConstants getHighlightedPrimaryLinkColor] forState:UIControlStateHighlighted];
    [self.forgotPasswordButton setTitleColor:[ACConstants getPrimaryLinkColor] forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitleColor:[ACConstants getHighlightedPrimaryLinkColor] forState:UIControlStateHighlighted];

    mDataSourceArray = [[NSArray alloc] initWithObjects:ACLocalizedString(@"Email Address",nil),ACLocalizedString(@"Password",nil),ACLocalizedString(@"Confirm Password", nil), nil];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:[ACConstants getLocalizedStringForKey:@"CANCEL" withDefaultValue:@"Cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelLogin:)];
    self.navigationItem.rightBarButtonItem = cancelItem;
    self.navigationItem.hidesBackButton = YES;
    
    UIView *loginSeparator = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.loginFooterView.frame)-0.5, 320, 0.5)];
    loginSeparator.backgroundColor = [UIColor lightGrayColor];
    [self.loginFooterView addSubview:loginSeparator];
    UIView *signupSeparator = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.signupFooterView.frame)-0.5, 320, 0.5)];
    signupSeparator.backgroundColor = [UIColor lightGrayColor];
    [self.signupFooterView addSubview:signupSeparator];
    
    CGRect frame = self.facebookLoginButton.frame;
    frame.origin.y = 2;
    self.facebookLoginButton.frame = frame;
    
    frame = self.loginHolderScrollView.frame;
    self.loginHolderScrollView.contentSize = CGSizeMake(320, 504);
    self.selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];

    
/*    UIView *loginTopSeparator = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 2.5)];
    loginSeparator.backgroundColor = [UIColor lightGrayColor];
    [self.facebookLoginButton addSubview:loginTopSeparator];
    UIView *loginBottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.facebookLoginButton.frame)-2.5, 320, 2.5)];
    signupSeparator.backgroundColor = [UIColor lightGrayColor];
    [self.facebookLoginButton addSubview:loginBottomSeparator]; 
 */
    
    self.title = ACLocalizedString(@"LOGIN", nil);

    if(self.onlyFacebook)
    {
        self.tableview.hidden = YES;
    }
    else
    {
        self.tableview.hidden = NO;
    }
    
    
    self.screenName = @"Login Screen";
    
    // Do any additional setup after loading the view from its nib.
    [self.tableview setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    if(IS_OS_8_OR_LATER)
    {
        self.tableview.layoutMargins = UIEdgeInsetsZero;// CS:fix for the iOS 8 separator issue
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDelegate

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = (self.loginMode == LoginModeLogin) ? self.loginFooterView:self.signupFooterView;
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(footerView.frame)-0.275, CGRectGetWidth([UIScreen mainScreen].bounds), 0.275)];
    separator.backgroundColor = [UIColor lightGrayColor];
    [footerView addSubview:separator];

    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 51.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //self.tableview.tableFooterView = (self.loginMode == LoginModeLogin)?self.loginFooterView:self.signupFooterView;
    //self.tableview.tableFooterView.layoutMargins = UIEdgeInsetsZero;
    
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRows];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 51.0f;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //AppLocation currentAppLocation = [PAAUtilities getCurrentAppLocation];
    
    static NSString *SimpleTableIdentifier = @"ACLoginCustomCell";
    ACLoginCustomCell * cell = (ACLoginCustomCell*)[tableView
                                        dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell==nil)
    {
        cell = (ACLoginCustomCell *)[[ACBundle loadNibNamed:@"ACLoginCustomCell" owner:self options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(IS_OS_8_OR_LATER)
    {
        cell.layoutMargins = UIEdgeInsetsZero;// CS:fix for the iOS 8 separator issue
    }

    int numberOfRows = [self numberOfRows];
    
    
    if(0 == indexPath.row)
    {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 0.5)];
        separator.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:separator];
    }
    else if(numberOfRows-1 == indexPath.row)
    {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(cell.contentView.frame)-0.275, CGRectGetWidth([UIScreen mainScreen].bounds), 0.275)];
        separator.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:separator];
    }
    
    
    // Make cell unselectable
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.text = [ mDataSourceArray objectAtIndex:indexPath.row];
    cell.textField.text = @"";
    cell.textField.tag=indexPath.row;
    
    cell.textField.delegate = self;
    
    switch ( indexPath.row )
    {
        case 0:{
            cell.textField.text = self.email;
            [cell.textField setKeyboardType:UIKeyboardTypeEmailAddress];
            [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
            cell.textLabel.textColor = [UIColor blackColor];
            if([self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]] != nil){
//                cell.textField.text = @"";
                cell.textLabel.textColor = [UIColor redColor];
//                cell.textField.placeholder = [self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]];
            }
            break;
        }
        case 1:{
            cell.textField.text = self.password;
            [cell.textField setKeyboardType:UIKeyboardTypeDefault];
            cell.textField.secureTextEntry = YES;
            cell.textLabel.textColor = [UIColor blackColor];
            if([self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]] != nil){
                cell.textField.text = @"";
                cell.textLabel.textColor = [UIColor redColor];
//                cell.textField.placeholder = [self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]];
            }
            break;
        }
        case 2:{
            cell.textField.text = self.password;
            [cell.textField setKeyboardType:UIKeyboardTypeDefault];
            cell.textField.secureTextEntry = YES;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textField.text = self.confirmPassword;
            if([self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]] != nil){
                cell.textField.text = @"";
                cell.textLabel.textColor = [UIColor redColor];
//                cell.textField.placeholder = [self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]];
            }
            break;
        }
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ACLoginCustomCell * cell = (ACLoginCustomCell*)[tableView
                                                    cellForRowAtIndexPath:indexPath];
    [cell.textField becomeFirstResponder];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


-(int)numberOfRows
{
    return (self.loginMode == LoginModeLogin)?2:3;
}

-(UIView *) tableViewHeader {
    
//    if( ACIsStringWithAnyText(self.error)){
//        
//        CGRect bounds = self.view.bounds;
//        
//        // Initial Height
//        CGFloat height = 0;
//        if( ACIsStringWithAnyText(self.error)){
//            height = height + 25;
//        }
//        
//        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, height)];
//        
//        
//        // Error Label
//        if( ACIsStringWithAnyText(self.error)){
//            UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 20)];
//            errorLabel.backgroundColor = [UIColor clearColor];
//            errorLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
//            errorLabel.textColor = [UIColor redColor];
//            errorLabel.textAlignment = UITextAlignmentCenter;
//            errorLabel.text = self.error;
//            [view addSubview:errorLabel];
//        }
//        
//        return view;
//        
//    }else{
        return nil;
//    }
}

-(BOOL) validateFormForSignUp
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
    
    if(((self.password.length > 0)&&(self.password.length < 7)) || ((self.confirmPassword.length > 0)&&(self.confirmPassword.length < 7))){
        
        UIAlertView *passLengthAlert = [[UIAlertView alloc] initWithTitle:ACLocalizedString(@"PASSWORD_AT_LEAST_SEVEN", nil) message:nil delegate:nil cancelButtonTitle:ACLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [passLengthAlert show];
        
        self.password = self.confirmPassword = @"";
        
        [self.fieldErrors setObject:ACLocalizedString(@"PASSWORD_AT_LEAST_SEVEN", @"PASSWORD_AT_LEAST_SEVEN")
                             forKey:[NSNumber numberWithInt:1]];
        
        [self.fieldErrors setObject:ACLocalizedString(@"PASSWORD_AT_LEAST_SEVEN", @"PASSWORD_AT_LEAST_SEVEN")
                             forKey:[NSNumber numberWithInt:2]];
        
        return NO;
        
    }

    if(ACIsStringWithAnyText(self.password ) &&
       ACIsStringWithAnyText(self.confirmPassword ) &&
       ![self.password isEqualToString:self.confirmPassword]) {
        
        self.error = ACLocalizedString(@"Your passwords did not match", @"Your passwords did not match");
        
        UIAlertView *passMatchAlert = [[UIAlertView alloc] initWithTitle:self.error message:nil delegate:nil cancelButtonTitle:ACLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [passMatchAlert show];
        
        self.password = self.confirmPassword = @"";
        [self.fieldErrors setObject:ACLocalizedString(@"Please enter a password", @"Please enter a password")
                             forKey:[NSNumber numberWithInt:1]];
        [self.fieldErrors setObject:ACLocalizedString(@"Please enter a password", @"Please enter a password")
                             forKey:[NSNumber numberWithInt:2]];
    }
    
    return ( [self.fieldErrors count]>0 || ACIsStringWithAnyText(self.error))?NO:YES;
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

- (IBAction)cancelLogin:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toggleSegmentedAction:(id)sender
{
    self.selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];

    self.loginMode = !self.loginMode;
    self.error = nil;
    self.email = @"";
    self.password = @"";
    self.confirmPassword = @"";
    self.tableview.tableHeaderView = nil;
    [self.fieldErrors removeAllObjects];
    [self.tableview reloadData];
}

- (IBAction)loginWithFacebook:(id)sender
{
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_LOGIN_FACEBOOK];
    [self openSessionWithAllowLoginUI: YES];
}

- (IBAction)loginWithEmail:(id)sender
{
//    if([self.txtActiveField isFirstResponder])
//    {
//        [ self.txtActiveField resignFirstResponder];
    //    }
    [self.view endEditing:YES];
    
    self.error = nil;
    
    if ([self validateForm] ){
        
        [SVProgressHUD showWithStatus:ACLocalizedString(@"AUTHENTICATING",@"AUTHENTICATING") maskType:SVProgressHUDMaskTypeClear];
        
        [ArtAPI
         requestForAccountAuthenticateWithEmailAddress:self.email
         password:self.password
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
             //[SVProgressHUD dismiss];
             
             // ANALYTICS: log event - LOG IN (completed)
             [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_LOGIN_EMAIL];
             
             AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
             if(currAppLoc==AppLocationNone){
                 NSDictionary *accountDetails = [[JSON objectForKeyNotNull:@"d"] objectForKeyNotNull:@"Account"];
                 NSDictionary *profileInfo = [accountDetails objectForKeyNotNull:@"ProfileInfo"];
                 NSString *accountId = [[profileInfo objectForKeyNotNull:@"AccountId"] stringValue];
                 
                 [[NSUserDefaults standardUserDefaults] setObject:accountId forKey:@"USER_ACCOUNT_ID"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
             }else{
                 NSDictionary *responseDict = [JSON objectForKeyNotNull:@"d"];
                 NSString *authTok = [responseDict objectForKeyNotNull:@"AuthenticationToken"];
                 [ArtAPI setAuthenticationToken:authTok];
                 
                 [SVProgressHUD dismiss];

                 // Call Delegate
                 if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess)]) {
                     [self.delegate loginSuccess];
                 }
             }
             
             
         }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
             NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
             // Failure
             [SVProgressHUD dismiss];
             
             self.error =  ACLocalizedString(@"Your email address or password is incorrect", @"Your email address or password is incorrect");
             
             self.password = self.confirmPassword = @"";
             
             [self.fieldErrors setObject:ACLocalizedString(@"Login Failed", @"Login Failed")
                                  forKey:[NSNumber numberWithInt:0]];
             
             [self.fieldErrors setObject:ACLocalizedString(@"Please enter a password", @"Please enter a password")
                                  forKey:[NSNumber numberWithInt:1]];
             [self.fieldErrors setObject:ACLocalizedString(@"Please enter a password", @"Please enter a password")
                                  forKey:[NSNumber numberWithInt:2]];
             
             
             NSString *errorMessagee = [JSON objectForKey:@"APIErrorMessage"];
             NSMutableDictionary *analyticsParams = [[NSMutableDictionary alloc] initWithCapacity:3];
             [analyticsParams setValue:[NSString stringWithFormat:@"%d",error.code] forKey:ANALYTICS_APIERRORCODE];
             [analyticsParams setValue:error.localizedDescription forKey:ANALYTICS_APIERRORMESSAGE];
             [analyticsParams setValue:[request.URL absoluteString] forKey:ANALYTICS_APIURL];
             [Analytics logGAEvent:ANALYTICS_CATEGORY_ERROR_EVENT withAction:errorMessagee withParams:analyticsParams];
             
             UIAlertView *authFailAlert = [[UIAlertView alloc] initWithTitle:self.error message:nil delegate:nil cancelButtonTitle:ACLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
             [authFailAlert show];
             
//             UIAlertView *loginFailedAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:self.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//             [loginFailedAlert show];
             
             self.tableview.tableHeaderView = [self tableViewHeader];
             
             [self.tableview reloadData];
             
         }];
    } else {
        [self.tableview reloadData];
    }
}

- (void)forgotPasswordForEmail:(NSString *)mail {
    
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_FORGOT_PASSWORD];
    
//    if([self.txtActiveField isFirstResponder])
//    {
//        [ self.txtActiveField resignFirstResponder];
//    }
    [self.view endEditing:YES];
    
    
    if(mail&&(![mail isKindOfClass:[NSNull class]])&&[mail validateAsEmail]){
        
        [SVProgressHUD showWithStatus:ACLocalizedString(@"RETRIEVING PASSWORD",@"RETRIEVING PASSWORD")];
        
        [ArtAPI
         accountRetrievePasswordWithEmailAddress:mail
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
             [SVProgressHUD dismiss];
             
             UIAlertView *forgotPassSuccessAlert = [[UIAlertView alloc] initWithTitle:ACLocalizedString(@"NEW_PASSWORD_SENT", nil)  message:nil delegate:nil cancelButtonTitle:ACLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
             [forgotPassSuccessAlert show];
             
//             [self.navigationController popViewControllerAnimated:YES];
             
         }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
             //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
             // Failure
             NSString *errorMessagee = [JSON objectForKey:@"APIErrorMessage"];
             NSMutableDictionary *analyticsParams = [[NSMutableDictionary alloc] initWithCapacity:3];
             [analyticsParams setValue:[NSString stringWithFormat:@"%d",error.code] forKey:ANALYTICS_APIERRORCODE];
             [analyticsParams setValue:error.localizedDescription forKey:ANALYTICS_APIERRORMESSAGE];
             [analyticsParams setValue:[request.URL absoluteString] forKey:ANALYTICS_APIURL];
             [Analytics logGAEvent:ANALYTICS_CATEGORY_ERROR_EVENT withAction:errorMessagee withParams:analyticsParams];
             
             UIAlertView *forgotPassErrorAlert = [[UIAlertView alloc] initWithTitle:ACLocalizedString(@"NO_ACCOUNT_INFO_FOUND", nil) message:nil delegate:nil cancelButtonTitle:ACLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
             [forgotPassErrorAlert show];
             [SVProgressHUD dismiss];
             
         }];
        
    } else {
        UIAlertView *invalidMailAlert = [[UIAlertView alloc] initWithTitle:ACLocalizedString(@"ERROR", nil) message:ACLocalizedString(@"Please enter a valid email address", @"Please enter a valid email address") delegate:nil cancelButtonTitle:ACLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [invalidMailAlert show];
    }
}

- (IBAction)signupWithEmail:(id)sender
{
    
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_CREATE_ACCOUNT];
    
//    if([self.txtActiveField isFirstResponder])
//    {
//        [ self.txtActiveField resignFirstResponder];
    //    }
    [self.view endEditing:YES];
    
    self.error = nil;
    self.tableview.tableHeaderView = [self tableViewHeader];
    
    if ([self validateFormForSignUp] ){
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
                 
             }else{
                 NSDictionary *responseDict = [JSON objectForKeyNotNull:@"d"];
                 NSString *authTok = [responseDict objectForKeyNotNull:@"AuthenticationToken"];
                 [ArtAPI setAuthenticationToken:authTok];
                 
                 // Call Delegate
                 if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess)]) {
                     [self.delegate loginSuccess];
                 }
             }
             
             
             
         }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
             //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
             // Failure
             [SVProgressHUD dismiss];
             
             self.error =  [JSON objectForKey:@"APIErrorMessage"];
             
             self.password = self.confirmPassword = @"";
             
             [self.fieldErrors setObject:ACLocalizedString(@"Account Create Failed", @"Account Create Failed")
                                  forKey:[NSNumber numberWithInt:0]];
             
             [self.fieldErrors setObject:ACLocalizedString(@"Please enter a password", @"Please enter a password")
                                  forKey:[NSNumber numberWithInt:1]];
             [self.fieldErrors setObject:ACLocalizedString(@"Please enter a password", @"Please enter a password")
                                  forKey:[NSNumber numberWithInt:2]];
             
             NSMutableDictionary *analyticsParams = [[NSMutableDictionary alloc] initWithCapacity:3];
             [analyticsParams setValue:[NSString stringWithFormat:@"%d",error.code] forKey:ANALYTICS_APIERRORCODE];
             [analyticsParams setValue:error.localizedDescription forKey:ANALYTICS_APIERRORMESSAGE];
             [analyticsParams setValue:[request.URL absoluteString] forKey:ANALYTICS_APIURL];
             [Analytics logGAEvent:ANALYTICS_CATEGORY_ERROR_EVENT withAction:self.error withParams:analyticsParams];
             
             UIAlertView *accountCreateAlert = [[UIAlertView alloc] initWithTitle:self.error message:nil delegate:nil cancelButtonTitle:ACLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
             [accountCreateAlert show];
             
             //ACLocalizedString(@"Your email address or password is incorrect", @"Your email address or password is incorrect");
             self.tableview.tableHeaderView = [self tableViewHeader];
             [self.tableview reloadData];
             
         }];
        
    } else {
        //NSLog(@"failed validation");
        // Reload and display error
        [self.tableview reloadData];
        self.tableview.tableHeaderView = [self tableViewHeader];
    }
}

- (IBAction)forgotPassword:(id)sender
{
    UIAlertView *forgotPasswordAlert = [[UIAlertView alloc] initWithTitle:ACLocalizedString(@"ENTER_EMAIL_ACCOUNT", nil) message:nil delegate:self cancelButtonTitle:ACLocalizedString(@"CANCEL", nil) otherButtonTitles:ACLocalizedString(@"OK", nil), nil];
    forgotPasswordAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[forgotPasswordAlert textFieldAtIndex:0] setDelegate:self];
    [forgotPasswordAlert textFieldAtIndex:0].tag = 100;
    [forgotPasswordAlert show];
}

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
         }else{
             NSDictionary *responseDict = [JSON objectForKeyNotNull:@"d"];
             NSString *authTok = [responseDict objectForKeyNotNull:@"AuthenticationToken"];
             [ArtAPI setAuthenticationToken:authTok];
             
             // Call Delegate
             if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess)]) {
                 [self.delegate loginSuccess];
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
                                                                delegate:nil cancelButtonTitle:ACLocalizedString(@"OK", nil)
                                                       otherButtonTitles:nil];
             [alertView show];
         } else {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ACLocalizedString(@"An error occurred. Please try again.",@"An error occurred. Please try again.")
                                                                 message:nil
                                                                delegate:nil
                                                       cancelButtonTitle:ACLocalizedString(@"OK", nil)
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

- (void)saveToCache:(UIImage *)image name:(NSString *)name {
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:name];
    
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
}

-(void)keyboardWillShow:(NSNotification *)notiFication
{
    //NSLog(@"keyboardWillShow");
//    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
    
        //NSLog(@"iPhone");
        CGRect rect = self.loginHolderScrollView.frame;
        
        //iPhone5 compatibility
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height*[UIScreen mainScreen].scale;
        if(screenHeight == 480){
            //iphone no retina
            rect.size.height = 416-175;
        }else if(screenHeight == 960){
            //iphone with retina
            rect.size.height = 416-175;
        }else{
            //iphone5
            rect.size.height = 504 - 200;
        }
        
        self.loginHolderScrollView.frame = rect;
    
    if(self.loginMode==LoginModeLogin){
        
        if(screenHeight == 480){
            //iphone no retina
            self.loginHolderScrollView.contentSize = CGSizeMake(320, 380);
        }else if(screenHeight == 960){
            //iphone with retina
            self.loginHolderScrollView.contentSize = CGSizeMake(320, 380);
        }else{
            //iphone5
            self.loginHolderScrollView.contentSize = CGSizeMake(320, 355);
        }
    }else{
        
        if(screenHeight == 480){
            //iphone no retina
            self.loginHolderScrollView.contentSize = CGSizeMake(320, 400);
        }else if(screenHeight == 960){
            //iphone with retina
            self.loginHolderScrollView.contentSize = CGSizeMake(320, 400);
        }else{
            //iphone5
            self.loginHolderScrollView.contentSize = CGSizeMake(320, 380);
        }
        
    }

/*        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.loginHolderView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }); */
//    }
//else
//    {
//        //NSLog(@"iPad");
//        // Adjust table to fit keyboard
///*        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 225, 0.0);
//        self.loginHolderView.contentInset = contentInsets;
//        self.loginHolderView.scrollIndicatorInsets = contentInsets;
//        [self.loginHolderView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES]; */
//    }
}

-(void)keyboardWillHide:(NSNotification *)notiFication
{
    //NSLog(@"keyboardWillHide");
//    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        CGRect rect = self.loginHolderScrollView.frame;
        
        //iPhone5 compatibility
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height*[UIScreen mainScreen].scale;
        if(screenHeight == 480){
            //iphone no retina
            rect.size.height = 416;
        }else if(screenHeight == 960){
            //iphone with retina
            rect.size.height = 416;
        }else{
            //iphone5
            rect.size.height = 504;
        }
        self.loginHolderScrollView.frame = rect;
    
    CGRect frame = self.loginHolderScrollView.frame;
    self.loginHolderScrollView.contentSize = CGSizeMake(320, frame.size.height);

    
        //NSLog(@"Rect at Hide: %@", NSStringFromCGRect(rect));
        
//    }
//    else {
//        // Adjust table to fit keyboard
//        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//        self.loginHolderView.contentInset = contentInsets;
//        self.loginHolderView.scrollIndicatorInsets = contentInsets;
//    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        UITextField *thisField = [alertView textFieldAtIndex:0];
        //NSLog(@"Text is %@",thisField.text);
        [self forgotPasswordForEmail:thisField.text];
    }
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITextFieldDelegate



- (IBAction)textFieldFinished:(id)sender
{
//    [sender resignFirstResponder];
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    [textField resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(100 != textField.tag) /* TextField from UIAlertView */
    {
        self.txtActiveField = textField;
        
        self.selectedIndexPath = [NSIndexPath indexPathForRow:textField.tag inSection:1];

        ACKeyboardToolbarView * toolbar = [[ACKeyboardToolbarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([self.view getCurrentScreenBoundsDependOnOrientation]), 40)];
        toolbar.toolbarDelegate = self;
        [textField setInputAccessoryView:toolbar];
        
        //    self.loginHolderScrollView.contentOffset = CGPointMake(0, 100);
        
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.loginHolderScrollView scrollRectToVisible:self.tableview.frame animated:YES];
        });
    }
    
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
    }else if (2 == textField.tag) {
        self.confirmPassword=textField.text;
    }
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ACKeyboardToolbarDelegate
- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectNext: (id) next
{
    if( self.selectedIndexPath.row == 0 )
    {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    else if( self.selectedIndexPath.row == 1 )
    {
        if(self.loginMode == LoginModeLogin)
        {
            self.selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
            //            [ self.txtActiveField resignFirstResponder];
            [self.view endEditing:YES];
        }
        else
        {
            self.selectedIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        }
    }
    else if( self.selectedIndexPath.row == 2 )
    {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
        //        [ self.txtActiveField resignFirstResponder];
        [self.view endEditing:YES];
    }

    
    ACLoginCustomCell *cell = (ACLoginCustomCell*)[self.tableview cellForRowAtIndexPath:self.selectedIndexPath];
    [cell.textField becomeFirstResponder];
}

- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectPrevious: (id) previous
{
    if( self.selectedIndexPath.row == 0 )
    {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
        //        [ self.txtActiveField resignFirstResponder];
        [self.view endEditing:YES];
    }
    else if( self.selectedIndexPath.row == 1 )
    {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else if( self.selectedIndexPath.row == 2 )
    {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    
    ACLoginCustomCell *cell = (ACLoginCustomCell*)[self.tableview cellForRowAtIndexPath:self.selectedIndexPath];
    [cell.textField becomeFirstResponder];
}

- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectDone: (id) done {
    //    [self.txtActiveField resignFirstResponder];
    [self.view endEditing:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Facebook
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    BOOL result = NO;
//    if(!FBSession.activeSession.isOpen){
        FBSession *session = nil;
        if([ACConstants isArtCircles]){
            session =
            [[FBSession alloc] initWithAppID:nil
                                 permissions:nil
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
//    }else{
//        [self handleFacebookLogin];
//    }
    
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
        
        NSString *errorTitleString = [ACConstants getLocalizedStringForKey:@"ERROR" withDefaultValue:@"Error"];
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:errorTitleString
                                  message:message
                                  delegate:nil
                                  cancelButtonTitle:ACLocalizedString(@"OK", nil)
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
                 
                 if(user && accessTokenData){
                     [self authenticateWithFacebookUID:[user objectForKey:@"id"]
                                          emailAddress:[user objectForKey:@"email"]
                                             firstName:[user objectForKey:@"first_name"]
                                              lastName:[user objectForKey:@"last_name"]
                                         facebookToken:accessTokenData.accessToken];
                 }else{
                     NSLog(@"Either no FB user or accesstokendata");
                 }
                 
             } else {
                 NSLog(@"error: %@", error);
             }
         }];
        
//        [[FBRequest requestWithGraphPath:@"me?fields=picture.type(large)" parameters: nil HTTPMethod:@"GET"] startWithCompletionHandler:
//         ^(FBRequestConnection *connection, id result,NSError *error) {
//             if (!error) {
//                 //NSLog(@"ACLoginViewControllergot user result: %@", result );
//                 NSString * url = [[[result objectForKey:@"picture"] objectForKey: @"data"] objectForKey:@"url"];
//                 NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
//                 UIImage *profilePicture = [UIImage imageWithData:data];
//                 [self saveToCache:profilePicture name:@"profilePicture"];
//             } else {
//                 NSLog(@"error: %@", error);
//             }
//         }];
        
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
