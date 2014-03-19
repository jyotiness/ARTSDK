//
//  ViewController.m
//  ArtAPIDemo
//
//  Created by Doug Diego on 3/29/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ViewController.h"
#import "ArtAPI.h"
#import "NINetworkImageView.h"
#import "ACLoginViewController.h"
#import "ACShoppingCartViewController.h"
#import "ACShipAddressViewController.h"
#import "ACNavigationController.h"
#import "ACOrderConfirmationViewController.h"
#import "DecorProductSearchViewController.h"
#import "ACSharingActivityProvider.h"
#import "ACPinterestActivity.h"
#import "ACActivityViewController.h"
#import "ACMailActivity.h"

#define IMAGE_SIZE 100
#define IMAGE_PADDING 10

/*
@interface ViewCell : UITableViewCell

@end

@implementation ViewCell

@end*/

@interface ViewController () <ACLoginDelegate,ACShoppingCartViewDelegate>
@property (nonatomic, readwrite,retain) NSMutableArray* items;
@property(nonatomic, strong) UIPopoverController *cartPopOver;
@end

@implementation ViewController {
    UIBarButtonItem * _loginButton;
}

@synthesize items=_items;
@synthesize cartPopOver = _cartPopOver;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Life cycle 

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.items = [NSMutableArray array];
        self.title = @"ArtAPI Demo";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _loginButton = [[UIBarButtonItem alloc]
                                initWithTitle:@"LOGIN"
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(loginButtonTapped:)];
    self.navigationItem.leftBarButtonItem = _loginButton;
    [self updateLoginButton];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    
    if( indexPath.section == 0){
        switch( indexPath.row ) {
            case 0: {
                cell.textLabel.text = @"Decor Search";
                break;
            }
            case 1: {
                cell.textLabel.text = @"Share";
                break;
            }
        }
    }
    
    return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark  UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0){
        switch( indexPath.row ) {
            case 0: {
                DecorProductSearchViewController * vc = [[DecorProductSearchViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 1: {
                [self showShare];
                break;
            }
        }
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark  Button Action
-(void) loginButtonTapped: (id) sender {
    NIDINFO("loginButtonTapped");
    
    if ([ArtAPI isLoggedIn]) {
        // Logout
        [ArtAPI logoutAndReset];
        // Update button
        [self updateLoginButton];
    } else {
        
        // Show Login View Controller
        ACLoginViewController *loginViewController = [[ACLoginViewController alloc] init];
        loginViewController.delegate = self;
        // PLEASE PUT STRING IN RESOURCE FILE
        loginViewController.loginMessage = @"By using an account, you will be able to permanently access your recently uploaded photos on your device, across devices and on the Art.com website.";
        loginViewController.showNotNowButton = YES;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
    }
}

-(void) cancelLoginButton: (id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ACLoginDelegate

- (void)loginSuccess {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self updateLoginButton];
    
    // Get Mobile Gallery
    [ArtAPI requestForGalleryGetUserDefaultMobileGallerySuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
    }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
    }];
}

- (void)loginFailure {
    [self dismissViewControllerAnimated:YES completion:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private

- (void) updateLoginButton {
    NIDINFO("updateLoginButton() activeSession: %@ [FBSession activeSession].isOpen: %d", [FBSession activeSession], [FBSession activeSession].isOpen);
    
    if ([FBSession activeSession].isOpen && [ArtAPI isLoggedIn]) {
        // Have a facebook session and is logged into art.com
        [_loginButton setTitle:@"LOGOUT"];
        NIDINFO("updateLoginButton() Have a facebook session and is logged into art.com");
    } else if ([FBSession activeSession].isOpen && ![ArtAPI isLoggedIn]) {
        // Has a facebook session but is not logged into art.com
        [ArtAPI logoutAndReset];
        [_loginButton setTitle:@"LOGIN"];
         NIDINFO("updateLoginButton() Has a facebook session but is not logged into art.com");
    } else {
        [_loginButton setTitle:@"LOGIN"];
         NIDINFO("updateLoginButton() No facebook session or art.com session");
    }
}



- (void)cartAction:(UIButton *)sender
{

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (!self.cartPopOver) {
            NSInteger kCartPopoverWidth = 320;
            NSInteger kCartPopoverHeight = 500;
            ACShoppingCartViewController *cartVC = [[ACShoppingCartViewController alloc] initWithNibName:@"ACShoppingCartViewController" bundle:nil];
            cartVC.delegate = self;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cartVC];
            nav.contentSizeForViewInPopover = CGSizeMake(kCartPopoverWidth, kCartPopoverHeight);
            self.cartPopOver = [[UIPopoverController alloc] initWithContentViewController:nav];
        }
        
        [self.cartPopOver presentPopoverFromRect: sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        ACShoppingCartViewController *cartVC = [[ACShoppingCartViewController alloc] initWithNibName:@"ACShoppingCartViewController" bundle:nil];
        cartVC.delegate = self;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cartVC];
        [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
        //navigationController.navigationBar.barStyle = UIBarStyleBlack;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        // Add Cancel Button
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, 0, 60, 32);
        [cancelButton setTitle:@"Close" forState:UIControlStateNormal];
        UIFont *buttonFont = [UIFont fontWithName:kACStandardFont size:23.0f];
        [cancelButton.titleLabel setFont:buttonFont];
        cancelButton.titleLabel.shadowColor = [ UIColor blackColor];
        cancelButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [cancelButton addTarget:self action:@selector(cancelLoginButton:) forControlEvents:UIControlEventTouchUpInside];
        cartVC.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ACCartViewDelegate
- (void)presentCheckout:(id)sender
{
    //ACOrderConfirmationViewController *vc = [[ACOrderConfirmationViewController alloc] initWithNibName:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ACOrderConfirmationViewController-iPad" :@"ACOrderConfirmationViewController"
    //                                                                                                    bundle:ACBundle];
    //vc.orderNumber=@"123456789";
    
    
    ACShipAddressViewController *vc = [[ACShipAddressViewController alloc] initWithNibName:@"ACShipAddressViewController" bundle:ACBundle];
    vc.isModal = YES;
    ACNavigationController *nav = [[ACNavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [self.cartPopOver dismissPopoverAnimated:YES];
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:nav animated:YES completion:nil];
        }];
    }
    
    
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Share



-(void) showShare {
    
    NSArray * excludeActivities = @[UIActivityTypeMail, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
    
    ACSharingActivityProvider *sharingActivityProvider = [[ACSharingActivityProvider alloc] init];
    sharingActivityProvider.title = @"Foggy landscape at sunrise";
    sharingActivityProvider.imageURL = @"http://imgc.artprintimages.com/images/photographic-print/frank-krahmer-foggy-landscape-at-sunrise_i-G-61-6164-R7UG100Z.jpg?w=894&h=671";
    sharingActivityProvider.sourceURL = @"http://www.art.com/products/p12819174139-sa-i8659786/frank-foggy-landscape-at-sunrise.htm?upi=ap8659786_pc4990875_fi0_sv6_it1_vrv1&PodConfigID=4990875";
    sharingActivityProvider.iTunesURL = @"https://itunes.apple.com/us/app/artdials/id762656439?mt=8";
    sharingActivityProvider.appName = NSLocalizedString(@"APP_NAME", @"artDials™ iPad app");
    
    ACPinterestActivity * pinterestActivity = [[ACPinterestActivity alloc] initWithClientId:@"1433645"
                                                                            urlSchemeSuffix:@"prod"];
    
    ACMailActivity * mailActivity = [[ACMailActivity alloc] init];
    
    // DEMO only, do not load an image like this.
   UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: sharingActivityProvider.imageURL]]];

    ACActivityViewController* vc = [[ACActivityViewController alloc] initWithActivityItems:@[sharingActivityProvider,image, sharingActivityProvider.title, sharingActivityProvider.sourceURL]
                                                                     applicationActivities:@[mailActivity,pinterestActivity]];
    vc.excludedActivityTypes = excludeActivities;
    vc.itemId = @"12819174139A"; // APNum
    
    [self presentViewController:vc animated:YES completion:nil];
}



@end


