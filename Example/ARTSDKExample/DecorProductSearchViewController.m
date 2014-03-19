//
//  DecorProductSearchViewController.m
//  ArtAPIDemo
//
//  Created by Doug Diego on 1/27/14.
//  Copyright (c) 2014 Doug Diego. All rights reserved.
//

#import "DecorProductSearchViewController.h"
#import "ArtAPI.h"
#import "NINetworkImageView.h"
#import "ACLoginViewController.h"
#import "ACShoppingCartViewController.h"
#import "ACShipAddressViewController.h"
#import "ACNavigationController.h"
#import "ACOrderConfirmationViewController.h"
#import "SVProgressHUD.h"
#import "ARTLogger.h"

#define IMAGE_SIZE 100
#define IMAGE_PADDING 10


@interface DecorProductSearchViewController  () <ACLoginDelegate,ACShoppingCartViewDelegate>
@property (nonatomic, readwrite,retain) NSMutableArray* items;
@property(nonatomic, strong) UIPopoverController *cartPopOver;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation DecorProductSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.items = [NSMutableArray array];
        self.title = @"Decor Search";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Load Art
    [self loadArt];
    
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
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect  tableFrame = [[self view] bounds] ;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        NINetworkImageView* imageView =  [[NINetworkImageView alloc] initWithImage:nil];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = 1;
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
		titleLabel.tag = 2;
        
        UIView * cellView =  [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableFrame.size.width, tableFrame.size.height)];
        cellView.tag = 0;
        
        [cellView addSubview:imageView];
        [cellView addSubview:titleLabel];
		[cell.contentView addSubview:cellView];
        
    }
    
    NSDictionary * item = [self.items objectAtIndex:indexPath.row];
    
    //cell.textLabel.text = [item objectForKey:@"Title"];
    ARTLog("item: %@", item);
    NINetworkImageView * imageView = (NINetworkImageView *)[[cell.contentView viewWithTag:0] viewWithTag:1];
    ARTLog("imageUrl: %@", [[item objectForKey:@"UrlInfo"] objectForKey:@"GenericImageURL"]  );
    [imageView setPathToNetworkImage:[[item objectForKey:@"UrlInfo"] objectForKey:@"GenericImageURL"] ];
    imageView.frame = CGRectMake(IMAGE_PADDING,IMAGE_PADDING,IMAGE_SIZE,IMAGE_SIZE);
    
    UILabel * titleLabel = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:2];
    titleLabel.frame = CGRectMake(IMAGE_SIZE + IMAGE_PADDING + IMAGE_PADDING,
                                  IMAGE_PADDING,
                                  cell.bounds.size.width - (IMAGE_SIZE + IMAGE_PADDING + IMAGE_PADDING),
                                  50 );
    titleLabel.text = [item objectForKey:@"Title"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath      *)indexPath;
{
    return IMAGE_SIZE + IMAGE_PADDING + IMAGE_PADDING;
    //return 500;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark  UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NIDINFO("didSelectRowAtIndexPath() activeSession: %@ [FBSession activeSession].isOpen: %d",
            [FBSession activeSession], [FBSession activeSession].isOpen);
    
    [SVProgressHUD showWithStatus:@"Adding to Cart"];
    
    NSDictionary * item = [self.items objectAtIndex:indexPath.row];
    NSString *itemNumber =[item objectForKey:@"APNum"];
    NSString *lookupType = @"ItemNumber";
    
    [ArtAPI
     requestForCartAddItemForItemId:itemNumber lookupType:lookupType quantitiy:1 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
         
         // Success
         NSDictionary *cart = [[JSON objectForKeyNotNull:@"d"] objectForKeyNotNull:@"Cart"] ;
         [ArtAPI setCart:cart];
         [SVProgressHUD dismiss];
         [self cartAction:nil];
         
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         [SVProgressHUD dismiss];
         NSString * errorMessage = [JSON objectForKey:@"errorMessage"];
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [alert show];
     }];
}





///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private



- (void) loadArt {
    [SVProgressHUD showWithStatus: @"Loading..."];
    
    NSString * colors = @"62402A-695A57-231650";
    [ArtAPI
     productsForMoodId:nil colors:colors keyword:@"" numProducts:[NSNumber numberWithInt:30] page: [NSNumber numberWithInt:1]
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
         self.items = [NSMutableArray arrayWithArray:[JSON objectForKey:@"ImageDetails"]];
         [self.tableView reloadData];
         [SVProgressHUD dismiss];
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         [SVProgressHUD dismiss];
     }];
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
        cartVC.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
    }
    /*
     ACCartViewController *cartVC = [[ACCartViewController alloc] initWithNibName:@"ACCartViewController" bundle:ACBundle];
     cartVC.delegate = self;
     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cartVC];
     [nav setModalPresentationStyle:UIModalPresentationFormSheet];
     [self.parentController presentViewController:nav animated:YES completion:nil];
     nav.view.superview.frame = CGRectMake(0, 0, kCartPopoverWidth, kCartPopoverHeight);
     nav.view.superview.center = self.parentController.view.center;
     */
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


@end
