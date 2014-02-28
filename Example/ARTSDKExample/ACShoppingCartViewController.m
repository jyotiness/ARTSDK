//
//  ACCartViewController.m
//  ArtAPI
//
//  Created by Doug Diego on 4/9/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ACShoppingCartViewController.h"
#import "UIColor+Additions.h"
#import "ACArtInfoViewController.h"
#import "UIBarButtonItem+ArtDotCom.h"
#import "SVProgressHUD.h"
#import "ArtAPI.h"

@implementation ACShoppingCartViewController {
    UITapGestureRecognizer *recognizer;
}


@synthesize tableView;
@synthesize data = _data;
@synthesize cellNib;
@synthesize tmpCell;

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    //[AppDel clearImageCache];
}

#pragma mark - View lifecycle

- (UIView *)titleViewForTitle:(NSString *)title {
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    titleView.text = title;
    titleView.font = [UIFont fontWithName:@"AvenirNextLTPro-Demi" size:20];
    //titleView.textColor = [UIColor artDotComLightGray_Light_Color_iPad];
    //titleView.shadowColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.4];
    titleView.backgroundColor = [UIColor clearColor];
    [titleView sizeToFit];
    return titleView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout:) name:@"USER_DID_LOGOUT" object:nil];
    
    self.navigationItem.titleView = [self titleViewForTitle:NSLocalizedString(@"Cart", nil)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cart", @"Cart") style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    self.tableView.rowHeight = 88;
    
    self.tableView.backgroundColor = [UIColor artDotComLightGray_Light_Color_iPad];
    self.cellNib = [UINib nibWithNibName:@"ACShoppingCartItemTableCell" bundle:ACBundle];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *fakeFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    fakeFooter.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = fakeFooter;
    
    
    pickerView = [[UIPickerView alloc] init];
    [pickerView sizeToFit];
    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    
    keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Update"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(updateServer)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flex, nextButton, nil]];
    
}


- (void)viewDidUnload {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
    self.tableView = nil;
    self.data = nil;
    self.tmpCell = nil;
    self.cellNib = nil;
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadDataFromAPI];
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    [recognizer setNumberOfTapsRequired:1];
    recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view.window addGestureRecognizer:recognizer];
}


- (void)viewWillDisappear:(BOOL)animated {
    [[self tableView] setEditing:NO animated:YES];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.tableView.scrollEnabled = YES;
    
    [self.view.window removeGestureRecognizer:recognizer];
}

#pragma mark -
#pragma mark API

- (void)userDidLogout:(id)sender {
    self.data = nil;
    [self loadDataFromAPI];
}


- (void)loadDataFromAPI {
    //self.data = [[ACAPI sharedAPI] cart];
    self.data = [ArtAPI cart];
    NSArray *shipments = [self.data objectForKeyNotNull:@"Shipments"];
    NSDictionary *shipment = [shipments objectAtIndex:0];
    NSArray *cartItems = [shipment objectForKeyNotNull:@"CartItems"];
    _cartItems = [[NSMutableArray alloc] initWithArray:cartItems];
    [[self tableView] reloadData];
    [self updateSubtotalLabel];
    [self updateNavigationBarButtons];
}


#pragma mark Button Handling
- (void)checkoutButtonPressed:(id)sender {
    
    [self.delegate presentCheckout:nil];
    return;

    
}

/*
- (IBAction)helpButtonPressed:(id)sender {
    CartHelpViewController *helpViewController = [[CartHelpViewController alloc] initWithNibName:@"CartHelpViewController" bundle:nil];
    helpViewController.baseURL = [NSURL URLWithString:@"http://www.art.com/help_web_view/index.html"];
    helpViewController.url = [NSURL URLWithString:@"http://www.art.com/help_web_view/index.html"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:helpViewController];
    [self.parentViewController presentModalViewController:navController animated:YES];
}


- (IBAction)quantityButtonPressed:(id)sender {
    
}
*/

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:18009525592"]];
    }
}


- (void)editButtonPressed:(id)sender {
    //self.navigationItem.leftBarButtonItem = [UIBarButtonItem customButtonWithTitle:NSLocalizedString(@"Done", nil) target:self action:@selector(doneEditingButtonPressed:)];
    UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
    done.frame = CGRectMake(0, 0, 67, 36);
    [done setImage:[UIImage imageNamed:@"ArtAPI.bundle/done-button.png"] forState:UIControlStateNormal];
    [done addTarget:self action:@selector(doneEditingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:done];
    isEdit = YES;
    [(UITableView *) self.tableView setEditing:YES animated:YES];
}


- (void)doneEditingButtonPressed:(id)sender {
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customButtonWithTitle:NSLocalizedString(@"Edit", nil) target:self action:@selector(editButtonPressed:)];
    isEdit = NO;
    //[UIView beginAnimations:@"" context:nil];
    //[self.tableView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y + 63)];
    [(UITableView *) self.tableView setEditing:NO animated:YES];
    //[UIView commitAnimations];
    [self updateNavigationBarButtons];
}

- (void)refresh {
    [self.tableView reloadData];
    [self updateNavigationBarButtons];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_cartItems count];
}


//We have to loop though and add ourself so that the subtoatl can be updated while
//a network update for quanity change is happening
- (void)updateSubtotalLabel {
    float subtotalValue = 0;
    for (NSDictionary *cartItem in _cartItems) {
        NSNumber *subtotal = [cartItem objectForKeyNotNull:@"SubTotal"];
        subtotalValue += [subtotal floatValue];
    }
    NSNumber *st = [NSNumber numberWithFloat:subtotalValue];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    subtotalLabel.text = [currencyFormatter stringFromNumber:st];
}


- (void)updateNavigationBarButtons {
    NIDINFO("updateNavigationBarButtons() [_cartItems count]: %d", [_cartItems count]);
    if ([_cartItems count] > 0) {
        
        //self.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithTitle:NSLocalizedString(@"Checkout", nil) target:self action:@selector(checkoutButtonPressed:)];
        
        UIButton *checkout = [UIButton buttonWithType:UIButtonTypeCustom];
        checkout.frame = CGRectMake(0, 0, 83, 32);
        //[checkout setTitle:@"Checkout" forState:UIControlStateNormal];
        [checkout setImage:[UIImage imageNamed:@"ArtAPI.bundle/btn-cart-checkout.png"] forState:UIControlStateNormal];
        [checkout addTarget:self action:@selector(checkoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:checkout];
        
        if (self.tableView.editing) {
            //self.navigationItem.leftBarButtonItem = [UIBarButtonItem customButtonWithTitle:NSLocalizedString(@"Done", nil) target:self action:@selector(doneEditingButtonPressed:)];;
            
            UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
            done.frame = CGRectMake(0, 0, 63, 32);
            //[done setTitle:@"Done" forState:UIControlStateNormal];
            [done setImage:[UIImage imageNamed:@"ArtAPI.bundle/done-button.png"] forState:UIControlStateNormal];
            [done addTarget:self action:@selector(doneEditingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:done];
        } else {
            //self.navigationItem.leftBarButtonItem = [UIBarButtonItem customButtonWithTitle: NSLocalizedString(@"Edit", nil) target:self action:@selector(editButtonPressed:)];;
            
            UIButton *edit = [UIButton buttonWithType:UIButtonTypeCustom];
            edit.frame = CGRectMake(0, 0, 63, 32);
            //[edit setTitle:@"Edit" forState:UIControlStateNormal];
            [edit setImage:[UIImage imageNamed:@"ArtAPI.bundle/btn-cart-edit.png"] forState:UIControlStateNormal];
            [edit addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:edit];
        }
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tblView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    ACShoppingCartItemTableCell *cell = (ACShoppingCartItemTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [self.cellNib instantiateWithOwner:self options:nil];
        cell = (ACShoppingCartItemTableCell *) tmpCell;
        self.tmpCell = nil;
        //254-33-24-23
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(254, 33, 30, 26)];
        //textField.font = [UIFont fontWithName:@"AvenirNextLTPro-Demi" size:12];
        textField.textColor = [UIColor artDotComDarkGrayTextColor_iPad];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.delegate = self;
        [cell.contentView addSubview:textField];
        cell.quantityTextField = textField;
    }
    
    NSArray *cartItems = _cartItems;
    NSDictionary *cartItem = [cartItems objectAtIndex:indexPath.row];
    NSString *cartItemID = [cartItem objectForKeyNotNull:@"Id"];
    NSDictionary *item = [cartItem objectForKeyNotNull:@"Item"];
    NSDictionary *imgeInfomation = [item objectForKeyNotNull:@"ImageInformation"];
    NSDictionary *mediumImage = [imgeInfomation objectForKeyNotNull:@"MediumImage"];
    NSString *imageURLString = [mediumImage objectForKeyNotNull:@"HttpImageURL"];
    
    NSDictionary *itemAttributes = [item objectForKeyNotNull:@"ItemAttributes"];
    NSDictionary *artist = [itemAttributes objectForKeyNotNull:@"Artist"];
    NSString *firstName = [artist objectForKeyNotNull:@"FirstName"];
    NSString *lastName = [artist objectForKeyNotNull:@"lastName"];
    
    NSDictionary *physicalDimensions = [itemAttributes objectForKeyNotNull:@"PhysicalDimensions"];
    NSNumber *height = [physicalDimensions objectForKeyNotNull:@"Height"];
    NSNumber *width = [physicalDimensions objectForKeyNotNull:@"Width"];
    NSNumber *unitOfMeasure = [physicalDimensions objectForKeyNotNull:@"UnitOfMeasure"];
    NSString *title = [itemAttributes objectForKeyNotNull:@"Title"];
    
    NSDictionary *itemPrice = [item objectForKeyNotNull:@"ItemPrice"];
    NSNumber *price = [itemPrice objectForKeyNotNull:@"Price"];
    NSNumber *quantity = [cartItem objectForKeyNotNull:@"Quantity"];
    
    NSDictionary *framedDimensions = [[[[item objectForKeyNotNull:@"Service"] objectForKeyNotNull:@"Frame"] objectForKeyNotNull:@"Moulding"] objectForKeyNotNull:@"Dimensions"];
    if (framedDimensions) {
        NSNumber *frameWidth = [framedDimensions objectForKeyNotNull:@"Top"];
        NSNumber *frameHeight = [framedDimensions objectForKeyNotNull:@"Left"];
        cell.dimensions.text = [NSString stringWithFormat:@"%@ in x %@ in", frameWidth, frameHeight];
    }
    else {
        NSString *uom = @"in";
        if ([unitOfMeasure isEqualToNumber:[NSNumber numberWithInt:1]]) uom = @"in";
        if ([unitOfMeasure isEqualToNumber:[NSNumber numberWithInt:2]]) uom = @"cm";
        cell.dimensions.text = [NSString stringWithFormat:@"%@ %@ by %@ %@", [width stringValue], uom, [height stringValue], uom];
    }
    
    NSMutableString *name = [[NSMutableString alloc] init];
    if ([firstName length] > 0) {
        [name appendString:firstName];
    }
    if ([firstName length] > 0 && [lastName length] > 0) {
        [name appendString:@" "];
    }
    if ([lastName length] > 0) {
        [name appendString:lastName];
    }
    if ([title length] > 0) {
        cell.name.text = title;
    }
    else {
        cell.name.text = cartItemID;
    }
    
    //NSURL *imageURL = [[ACAPI sharedAPI] URLWithRawFrameURLString:imageURLString maxWidth:cell.photo.frame.size.width maxHeight:cell.photo.frame.size.height];
    NSString * imageURL = [ArtAPI cleanImageUrl:imageURLString withSize:cell.photo.frame.size.width];
    
    cell.photo.backgroundColor = [UIColor clearColor];
    //[cell.photo setImageURL:imageURL];
    [cell.photo setPathToNetworkImage:imageURL];
    cell.photo.contentMode = UIViewContentModeScaleAspectFit;
    cell.photo.clipsToBounds = YES;
    
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *priceString = [currencyFormatter stringFromNumber:price];
    
    cell.price.text = [NSString stringWithFormat:@"%@ @ %@", [quantity stringValue], priceString];
    
    [cell.quantityTextField setText:[NSString stringWithFormat:@"%@", [quantity stringValue]]];
    cell.quantityTextField.tag = indexPath.row;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return subtotalBar.frame.size.height;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return ([_cartItems count] > 0) ? subtotalBar : nil;
}


- (void)tableView:(UITableView *)tblView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ACArtInfoViewController *infoView = [[ACArtInfoViewController alloc] initWithNibName:@"ACArtInfoViewController" bundle:ACBundle];
    [infoView view];
    infoView.addToCartButton.hidden = YES;  //we are coming from the cart so it needs to be hidden
    
    NSDictionary *currentItem = [[[[[self.data objectForKeyNotNull:@"Shipments"] objectAtIndex:0] objectForKeyNotNull:@"CartItems"] objectAtIndex:indexPath.row] objectForKeyNotNull:@"Item"];
    
    UIButton *checkout = [UIButton buttonWithType:UIButtonTypeCustom];
    checkout.frame = CGRectMake(0, 0, 83, 32);
    [checkout setImage:[UIImage imageNamed:@"ArtAPI.bundle/btn-cart-checkout.png"] forState:UIControlStateNormal];
    [checkout addTarget:self action:@selector(checkoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    infoView.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:checkout];
    
    NSDictionary *itemAttributes = [currentItem objectForKeyNotNull:@"ItemAttributes"];
    NSDictionary *physicalDimensions = [itemAttributes objectForKeyNotNull:@"PhysicalDimensions"];
    NSString *type = [itemAttributes objectForKeyNotNull:@"Type"];
    infoView.itemType.text = type ? type : @"";
    NSNumber *width = [physicalDimensions objectForKeyNotNull:@"Width"];
    NSNumber *height = [physicalDimensions objectForKeyNotNull:@"Height"];
    NSNumber *unitOfMeasure = [physicalDimensions objectForKeyNotNull:@"UnitOfMeasure"];
    NSDictionary *itemPrice = [currentItem objectForKeyNotNull:@"ItemPrice"];
    NSNumber *displayPrice = [itemPrice objectForKeyNotNull:@"Price"];
    
    NSDictionary *artist = [itemAttributes objectForKeyNotNull:@"Artist"];
    NSString *firstName = [artist objectForKeyNotNull:@"FirstName"];
    NSString *lastName = [artist objectForKeyNotNull:@"LastName"];
    NSString *sku = [currentItem objectForKeyNotNull:@"Sku"];
    
    NSString *formattedName = @"";
    if (firstName) {
        formattedName = [formattedName stringByAppendingString:firstName];
    }
    if (firstName && lastName) {
        formattedName = [formattedName stringByAppendingString:@" "];
    }
    if (lastName) {
        formattedName = [formattedName stringByAppendingString:lastName];
    }
    
    NSString *title = [itemAttributes objectForKeyNotNull:@"Title"];
    NSString *itemNumber = [currentItem objectForKeyNotNull:@"ItemNumber"];
    //UIImage *image  = [[pagingScrollView curentPage] image];
    NSDictionary *imageInformation = [currentItem objectForKeyNotNull:@"ImageInformation"];
    NSDictionary *mediumInformation = [imageInformation objectForKeyNotNull:@"MediumImage"];
    NSString *httpURL = [mediumInformation objectForKeyNotNull:@"HttpImageURL"];
    
    
    //NSURL *imageURL = [[ACAPI sharedAPI] URLWithRawFrameURLString:httpURL maxWidth:90 maxHeight:72];
    //EGOImageView *image = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 72)];
    //image.contentMode = UIViewContentModeScaleAspectFit;
    //[image setImageURL:imageURL];
    
    NSString *imageURL = [ArtAPI cleanImageUrl:httpURL withSize:90];
    NINetworkImageView *image = [[NINetworkImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 72)];
    image.contentMode = UIViewContentModeScaleAspectFit;
    [image setPathToNetworkImage:imageURL];
    
    image.backgroundColor = [UIColor clearColor];
    image.clipsToBounds = YES;
    [infoView.scrollView addSubview:image];
    
    infoView.name.text = title;
    infoView.owner.text = formattedName;
    
    NSDictionary *framedDimensions = [[[[currentItem objectForKeyNotNull:@"Service"] objectForKeyNotNull:@"Frame"] objectForKeyNotNull:@"Moulding"] objectForKeyNotNull:@"Dimensions"];
    if (framedDimensions) {
        NSNumber *frameWidth = [framedDimensions objectForKeyNotNull:@"Top"];
        NSNumber *frameHeight = [framedDimensions objectForKeyNotNull:@"Left"];
        infoView.size.text = [NSString stringWithFormat:@"%@ in x %@ in", frameWidth, frameHeight];
    }
    else {
        NSString *uom = @"in";
        if ([unitOfMeasure isEqualToNumber:[NSNumber numberWithInt:1]]) uom = @"in";
        if ([unitOfMeasure isEqualToNumber:[NSNumber numberWithInt:2]]) uom = @"cm";
        infoView.size.text = [NSString stringWithFormat:@"%@ %@ x %@ %@", width, uom, height, uom];
    }
    
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    infoView.price.text = [currencyFormatter stringFromNumber:displayPrice];
    
    infoView.itemNumber = itemNumber;
    infoView.time.text = @"Usually ships in 1-2 days";
    infoView.description.text = @"";
    infoView.skuLabel.text = sku;
    //infoView.imageView.image = image;
    [infoView loadDataFromAPI];
    
    
    infoView.contentSizeForViewInPopover = CGSizeMake(320, 460);
    [self.navigationController pushViewController:infoView animated:YES];
}




#pragma make Editing

// Override to support editing the table view.
- (void)tableView:(UITableView *)tblView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *cartItem = [_cartItems objectAtIndex:indexPath.row];
        NSString *cartItemID = [cartItem objectForKeyNotNull:@"Id"];
        
        [_cartItems removeObjectAtIndex:indexPath.row];
        [tblView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateNavigationBarButtons];
        
        
        //self.hud = [[MBProgressHUD alloc] initWithView:self.view.window];
        //[[AppDel window] addSubview:self.hud];
        //self.hud.labelText = @"Removing Item";
        //[self.hud show:YES];
        [SVProgressHUD showWithStatus:@"Removing Item"];
        
        
        //ACJSONAPIRequest *request = [[ACAPI sharedAPI] requestForCartUpdateCartItemQuantityWithDelegate:self cartItemId:cartItemID quantity:0];
        //[self startRequest:request];
        [ArtAPI requestForCartUpdateCartItemQuantityForCartItemId:cartItemID quantity:0 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
            [SVProgressHUD dismiss];
            [self handleResponse:JSON];
        }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
            NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
            [SVProgressHUD dismiss];
            [self handleFailure:JSON];
        }];

    }
}

-(void) handleResponse: (id) resp {
    NIDINFO("handleResponse: %@", resp);
    NSDictionary *cart = [resp objectForKeyNotNull:@"Cart"];
    [ArtAPI setCart:cart];
    //[self removeHUD];
    
    self.data = [ArtAPI cart];
    NSArray *shipments = [self.data objectForKeyNotNull:@"Shipments"];
    NSDictionary *shipment = [shipments objectAtIndex:0];
    NSArray *cartItems = [shipment objectForKeyNotNull:@"CartItems"];
    _cartItems = [[NSMutableArray alloc] initWithArray:cartItems];
    [[self tableView] reloadData];
    [self updateSubtotalLabel];
    [self updateNavigationBarButtons];
    [self performSelector:@selector(refresh) withObject:nil afterDelay:0.1];
}

-(void) handleFailure: (id) resp {
    NIDINFO("handleFailure: %@", resp);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred"
                                                    message:[resp objectForKey:@"APIErrorMessage"]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [self loadDataFromAPI];
}

/*
- (void)super_requestDidFinish:(ACJSONAPIRequest *)request {
    [self.networkRequests removeObject:request];
}


- (void)super_requestDidFail:(ACJSONAPIRequest *)request {
    [self.networkRequests removeObject:request];
    [self hideActivityIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred" message:[request APIErrorMessage] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}


- (void)requestDidFinish:(ACJSONAPIRequest *)request {
    NSDictionary *response = [[request APIResponse] objectForKeyNotNull:@"Cart"];
    [[ACAPI sharedAPI] setCart:response];
    [self removeHUD];
    
    self.data = [[ACAPI sharedAPI] cart];
    NSArray *shipments = [self.data objectForKeyNotNull:@"Shipments"];
    NSDictionary *shipment = [shipments objectAtIndex:0];
    NSArray *cartItems = [shipment objectForKeyNotNull:@"CartItems"];
    _cartItems = [[NSMutableArray alloc] initWithArray:cartItems];
    [[self tableView] reloadData];
    [self updateSubtotalLabel];
    [self updateNavigationBarButtons];
    [self performSelector:@selector(refresh) withObject:nil afterDelay:0.1];
}


- (void)requestDidFail:(ACJSONAPIRequest *)request {
    [self super_requestDidFail:request];
    [self removeHUD];
    [self loadDataFromAPI];  // reload so the cell that was animated away reappears
}
*/

#pragma mark uipicker stuff
- (void)scroll:(NSIndexPath *)path {
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    self.tableView.scrollEnabled = NO;
}


- (void)updateServer {
    self.tableView.scrollEnabled = YES;
    NSDictionary *cartItem = [_cartItems objectAtIndex:textFieldBeingEdited.tag];
    NSString *cartItemID = [cartItem objectForKeyNotNull:@"Id"];
    //self.hud = [[MBProgressHUD alloc] initWithView:self.view.window];
    //[[AppDel window] addSubview:self.hud];
    //self.hud.labelText = @"Updating Quantity";
    //[self.hud show:YES];
    [SVProgressHUD showWithStatus:@"Updating Quantity"];
    NSUInteger quan = [textFieldBeingEdited.text intValue];
    //ACJSONAPIRequest *request = [[ACAPI sharedAPI] requestForCartUpdateCartItemQuantityWithDelegate:self cartItemId:cartItemID quantity:quan];
    //[self startRequest:request];
    [ArtAPI requestForCartUpdateCartItemQuantityForCartItemId:cartItemID quantity:quan success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
        [SVProgressHUD dismiss];
        [self handleResponse:JSON];
    }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        [SVProgressHUD dismiss];
        [self handleFailure:JSON];
    }];
    
    [self updateSubtotalLabel];
    [self updateNavigationBarButtons];
}


#pragma mark -
#pragma mark UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textFieldBeingEdited = textField;
    NSInteger row = [textField.text intValue] - 1;
    textField.inputView = pickerView;
    textField.inputAccessoryView = keyboardDoneButtonView;
    [pickerView selectRow:row inComponent:0 animated:NO];
    [pickerView sizeToFit];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}


#pragma mark -
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%d", row + 1];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    textFieldBeingEdited.text = [NSString stringWithFormat:@"%d", row + 1];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 25;
}

#pragma mark Activity Indicator
- (void)showActivityIndicator:(ACActivityIndicatorType)type {
    if (!activityIndicator) {
        activityIndicator = [[ACActivityIndicator alloc] initWithActivityIndicatorType:type];
        activityIndicator.center = self.view.center;
        [self.view addSubview:activityIndicator];
    }
}

- (void)hideActivityIndicator {
    //[self.hud removeFromSuperview];
    //self.hud = nil;
    [activityIndicator removeFromSuperview];
    activityIndicator = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITapGestureRecognizer

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    NIDINFO("handleTapBehind() sender: %@", sender );
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil]  &&
            ![self.parentViewController.view pointInside:[self.parentViewController.view convertPoint:location fromView:self.parentViewController.view.window] withEvent:nil] )
        {
            // Remove the recognizer first so it's view.window is valid.
            [self.view.window removeGestureRecognizer:sender];
            //[self dismissModalViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


@end
