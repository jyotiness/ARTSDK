//
//  ACForgotPasswordViewController.m
//  ArtAPI
//
//  Created by Doug Diego on 5/7/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ACForgotPasswordViewController.h"
#import "ArtAPI.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Additions.h"
#import "ACCreateAccountViewController.h"
#import "ACLoginCustomCell.h"
#import "SVProgressHUD.h"
#import "NSString+Additions.h"
#import "UINavigationController+KeyboardDismiss.h"
#import "ACKeyboardToolbarView.h"

@interface ACForgotPasswordViewController() <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ACKeyboardToolbarDelegate>
@property(nonatomic, copy) NSString *email;
@property(nonatomic, strong) NSString * error;
@property(nonatomic, strong) NSMutableDictionary * fieldErrors;
@property(nonatomic, strong) UITextField * txtActiveField;
@property (nonatomic,retain) NSIndexPath *selectedIndexPath;
@end

@implementation ACForgotPasswordViewController

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
    
    // Listen for notification kACNotificationDismissModal
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissModal) name:kACNotificationDismissModal object:nil];
    
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
    self.email = @"";
    
    
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
    [super viewWillAppear:animated];
    
    // Table Header
    self.tableView.tableHeaderView = [self tableViewHeader];
    
    if( !self.showStandardBackButton ){
        UIButton *barBackButton = [ACConstants getBackButtonForTitle:[ACConstants getLocalizedStringForKey:@"BACK" withDefaultValue:@"Back"]];
        
        [barBackButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:barBackButton];
        
        self.navigationItem.leftBarButtonItem = backBarButton;
        self.navigationItem.hidesBackButton = YES;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Actions

-(IBAction)goBack:(id)sender
{
    [ self.navigationController popViewControllerAnimated:YES];
}

- (void) closeButtonAction: (id) sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(forgotPasswordDidPressCloseButton:)]) {
        [self.delegate forgotPasswordDidPressCloseButton:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) backButtonAction: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)forgotPassword {
    
    if([self.txtActiveField isFirstResponder])
    {
        [ self.txtActiveField resignFirstResponder];
    }
    
    self.error = nil;
    self.tableView.tableHeaderView = [self tableViewHeader];
    
    if ([self validateForm] ){
        
        [SVProgressHUD showWithStatus:ACLocalizedString(@"RETRIEVING PASSWORD",@"RETRIEVING PASSWORD")];
        
        [ArtAPI
         accountRetrievePasswordWithEmailAddress:self.email
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
             [SVProgressHUD dismiss];
             
             [self.navigationController popViewControllerAnimated:YES];
             
         }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
             //NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
             // Failure
             [SVProgressHUD dismiss];
             
             self.error =  [JSON objectForKey:@"APIErrorMessage"];
             //ACLocalizedString(@"Your email address or password is incorrect", @"Your email address or password is incorrect");
             self.tableView.tableHeaderView = [self tableViewHeader];
             
         }];
        
    } else {
        // Reload and display error
        [self.tableView reloadData];
        self.tableView.tableHeaderView = [self tableViewHeader];
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private

-(BOOL) validateForm
{
    [self.fieldErrors removeAllObjects];
    // NSLog(@"validateForm email: %@ password: %@ confirmPassword: %@", self.email, self.password, self.confirmPassword);
    
    if( ![self.email validateAsEmail]){
        [self.fieldErrors setObject:ACLocalizedString(@"Please enter a valid email address", @"Please enter a valid email address")
                             forKey:[NSNumber numberWithInt:0]];
    }
    
    
    return ( [self.fieldErrors count]>0)?NO:YES;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath section: %d row: %d", indexPath.section, indexPath.row);
    if(indexPath.row == 1){
        UITableViewCell * cell = (UITableViewCell*)[tableView   dequeueReusableCellWithIdentifier:@"Cell"];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] init];
        }
        
        // Make cell unselectable
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat buttonWidth = 182, buttonHeight = 40;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(forgotPassword) forControlEvents:UIControlEventTouchDown];
        [button setTitle:[ACLocalizedString(@"SUBMIT", @"SUBMIT") uppercaseString]  forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor darkTextColor]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [ACConstants getStandardBoldFontWithSize:32.0f];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)];
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
                    cell.textField.keyboardAppearance = UIKeyboardAppearanceLight;
                    if([self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]] != nil){
                        cell.textField.text = @"";
                        cell.textLabel.textColor = [UIColor redColor];
                        cell.textField.placeholder = [self.fieldErrors objectForKey:[NSNumber numberWithInt:indexPath.row]];
                   }
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1){
        return 60;
    } else {
        return 48;
    }
}

-(UIView *) tableViewHeader {
    CGRect bounds = self.view.bounds;
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 20+20+20)];
    
    CGFloat x = 0, y = 20;
    
    // Sign In Label
    UILabel *signLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, bounds.size.width, 30)];
    signLabel.backgroundColor = [UIColor clearColor];
    signLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    signLabel.textColor = [UIColor darkTextColor];
    signLabel.textAlignment = NSTextAlignmentCenter;
    signLabel.text = ACLocalizedString(@"Retrieve your password", @"Retrieve your password") ;
    [view addSubview:signLabel];
    
    
    // Error Label
    if( ACIsStringWithAnyText(self.error)){
        y = y + 16;
        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, bounds.size.width, 30)];
        errorLabel.backgroundColor = [UIColor clearColor];
        errorLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        errorLabel.textColor = [UIColor redColor];
        errorLabel.textAlignment = NSTextAlignmentCenter;
        errorLabel.text = self.error;
        [view addSubview:errorLabel];
    }
    
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
    ACKeyboardToolbarView * toolbar = [[ACKeyboardToolbarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([self.view getCurrentScreenBoundsDependOnOrientation]), 40)
                                                               hideNextPrevButtons:YES];
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
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ACKeyboardToolbarDelegate

- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectDone: (id) done {
    [self.txtActiveField resignFirstResponder];
}


@end

