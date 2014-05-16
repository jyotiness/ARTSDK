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
#import "ACShoppingCartItemTableCell.h"
#import "ACShipAddressViewController.h"
#import "ACConstants.h"
#import "NSString+Additions.h"

@interface ACShoppingCartViewController() <ACShipAddressViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@end

@implementation ACShoppingCartViewController  {
    UITapGestureRecognizer *recognizer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (UIView *)titleViewForTitle:(NSString *)title {
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    titleView.text = title;
    titleView.font = [UIFont fontWithName:@"AvenirNextLTPro-Demi" size:20];
    titleView.backgroundColor = [UIColor clearColor];
    [titleView sizeToFit];
    return titleView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogout:)
                                                 name:@"USER_DID_LOGOUT" object:nil];
    
    self.navigationItem.titleView = [self titleViewForTitle:NSLocalizedString(@"Cart", nil)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cart", @"Cart") style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    self.tableView.rowHeight = 88;
    
    self.cellNib = [UINib nibWithNibName:@"ACShoppingCartItemTableCell" bundle:ACBundle];
    UIView *fakeFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    fakeFooter.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = fakeFooter;
    
    // Localize Empty Cart Label
    self.emptyLabel.text = NSLocalizedString(@"CART_EMPTY",@"Your Shopping Cart is Empty");
    
    pickerView = [[UIPickerView alloc] init];
    [pickerView sizeToFit];
    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    
    keyboardDoneButtonView = [[UIToolbar alloc] init];
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
    
    // Update Checkout Button
    _checkoutButton.layer.cornerRadius = 2;
    _checkoutButton.backgroundColor = UIColorFromRGB(0xef9223);
    [_checkoutButton.titleLabel setFont:[UIFont fontWithName:@"GiorgioSans-Bold" size:40]];
    [_checkoutButton setTitle:NSLocalizedString(@"CHECKOUT", @"CHECKOUT") forState:UIControlStateNormal];
    
    //self.tableView.tableFooterView = subtotalBar;
    
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
    //NIDINFO("data: %@", self.data);
    NSArray *shipments = [self.data objectForKeyNotNull:@"Shipments"];
    NSDictionary *shipment = [shipments objectAtIndex:0];
    NSArray *cartItems = [shipment objectForKeyNotNull:@"CartItems"];
    _cartItems = [[NSMutableArray alloc] initWithArray:cartItems];
    [[self tableView] reloadData];
    [self updateSubtotalLabel];
    [self updateNavigationBarButtons];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Gestures

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:18009525592"]];
    }
}


- (void)editButtonPressed:(id)sender {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", @"Done")
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(doneEditingButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [(UITableView *) self.tableView setEditing:YES animated:YES];
}


- (void)doneEditingButtonPressed:(id)sender {
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EDIT", @"Edit")
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(editButtonPressed:)];
    self.navigationItem.rightBarButtonItem = editButton;
    [(UITableView *) self.tableView setEditing:NO animated:YES];
    [self updateNavigationBarButtons];
}

- (void)refresh {
    [self.tableView reloadData];
    [self updateNavigationBarButtons];
}

- (IBAction)checkoutButtonPressed:(id)sender {
    
    //NIDINFO("calling checkoutButtonPressed() sender: %@", sender);
    
    if ([self.delegate respondsToSelector:@selector(presentCheckout:)]){
        [self.delegate presentCheckout:nil];
    } else {
        ACShipAddressViewController *vc = [[ACShipAddressViewController alloc] initWithNibName:@"ACShipAddressViewController-iPad" bundle:ACBundle];
        vc.delegate = self;
        vc.artCheckoutType = ACCheckoutTypePrintReciept;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    return;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView

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
    //NIDINFO("updateNavigationBarButtons() [_cartItems count]: %d", [_cartItems count]);
    if ([_cartItems count] > 0) {
        
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Checkout" style:UIBarButtonItemStylePlain target:self action:@selector(checkoutButtonPressed:)];
        
        if (self.tableView.editing) {

            self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneEditingButtonPressed:)];
        
        } else {
            
            self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];
        }
        
        self.tableView.tableFooterView = subtotalBar;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.tableView.tableFooterView = nil;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLOSE", @"Close")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(closeButtonPressed:)];
}


-(void) closeButtonPressed: (id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tblView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    ACShoppingCartItemTableCell *cell = (ACShoppingCartItemTableCell *) [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [self.cellNib instantiateWithOwner:self options:nil];
        cell = (ACShoppingCartItemTableCell *) _tmpCell;
        self.tmpCell = nil;
        //254-33-24-23
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(254, 33, 35, 26)];
        textField.textColor = [UIColor artDotComDarkGrayTextColor_iPad];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.textAlignment = NSTextAlignmentCenter;
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
    
    // Round to the nearest 0.5
    height = [NSNumber numberWithFloat:roundf(height.floatValue*2.0)/2.0];
    width = [NSNumber numberWithFloat:roundf(width.floatValue*2.0)/2.0];
    
    // Number formatter
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    NSNumber *unitOfMeasure = [physicalDimensions objectForKeyNotNull:@"UnitOfMeasure"];
    NSString *title = [itemAttributes objectForKeyNotNull:@"Title"];
    
    NSDictionary *itemPrice = [item objectForKeyNotNull:@"ItemPrice"];
    NSNumber *price = [itemPrice objectForKeyNotNull:@"Price"];
    NSNumber *quantity = [cartItem objectForKeyNotNull:@"Quantity"];
    
    NSDictionary *framedDimensions = [[[[item objectForKeyNotNull:@"Service"] objectForKeyNotNull:@"Frame"] objectForKeyNotNull:@"Moulding"] objectForKeyNotNull:@"Dimensions"];
    if (framedDimensions) {
        NSNumber *frameWidth = [framedDimensions objectForKeyNotNull:@"Top"];
        NSNumber *frameHeight = [framedDimensions objectForKeyNotNull:@"Left"];
        
        // Round to the nearest 0.5
        frameHeight = [NSNumber numberWithFloat:roundf(frameHeight.floatValue*2.0)/2.0];
        frameWidth = [NSNumber numberWithFloat:roundf(frameWidth.floatValue*2.0)/2.0];
        
        cell.dimensions.text = [NSString stringWithFormat:@"%@ in x %@ in", [fmt stringFromNumber:frameWidth], [fmt stringFromNumber:frameHeight]];
    }
    else {
        NSString *uom = @"in";
        if ([unitOfMeasure isEqualToNumber:[NSNumber numberWithInt:1]]) uom = @"in";
        if ([unitOfMeasure isEqualToNumber:[NSNumber numberWithInt:2]]) uom = @"cm";
        cell.dimensions.text = [NSString stringWithFormat:@"%@ %@ by %@ %@", [fmt stringFromNumber:width], uom, [fmt stringFromNumber:height], uom];
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
/*

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NIDINFO("heightForFooterInSection %f",  subtotalBar.frame.size.height );
    return subtotalBar.frame.size.height;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return ([_cartItems count] > 0) ? subtotalBar : nil;
}
*/

- (void)tableView:(UITableView *)tblView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ACArtInfoViewController *infoView = [[ACArtInfoViewController alloc] initWithNibName:@"ACArtInfoViewController" bundle:ACBundle];
    [infoView view];
    infoView.addToCartButton.hidden = YES;  //we are coming from the cart so it needs to be hidden
    
    NSDictionary *currentItem = [[[[[self.data objectForKeyNotNull:@"Shipments"] objectAtIndex:0] objectForKeyNotNull:@"CartItems"] objectAtIndex:indexPath.row] objectForKeyNotNull:@"Item"];
    
    //UIButton *checkout = [UIButton buttonWithType:UIButtonTypeCustom];
    //checkout.frame = CGRectMake(0, 0, 83, 32);
    //checkout.backgroundColor = [UIColor redColor];
    //DD[checkout setImage:[UIImage imageNamed:@"ArtAPI.bundle/btn-cart-checkout.png"] forState:UIControlStateNormal];
    //[checkout addTarget:self action:@selector(checkoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //infoView.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:checkout];
    
    NSDictionary *itemAttributes = [currentItem objectForKeyNotNull:@"ItemAttributes"];
    NSDictionary *physicalDimensions = [itemAttributes objectForKeyNotNull:@"PhysicalDimensions"];
    NSString *type = [itemAttributes objectForKeyNotNull:@"Type"];
    infoView.itemType.text = type ? type : @"";
    NSNumber *width = [physicalDimensions objectForKeyNotNull:@"Width"];
    NSNumber *height = [physicalDimensions objectForKeyNotNull:@"Height"];
    
    // Round to the nearest 0.5
    height = [NSNumber numberWithFloat:roundf(height.floatValue*2.0)/2.0];
    width = [NSNumber numberWithFloat:roundf(width.floatValue*2.0)/2.0];
    
    // Number formatter
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    NSNumber *unitOfMeasure = [physicalDimensions objectForKeyNotNull:@"UnitOfMeasure"];
    NSDictionary *itemPrice = [currentItem objectForKeyNotNull:@"ItemPrice"];
    NSNumber *displayPrice = [itemPrice objectForKeyNotNull:@"Price"];
    
    NSDictionary *artist = [itemAttributes objectForKeyNotNull:@"Artist"];
    NSString *firstName = [artist objectForKeyNotNull:@"FirstName"];
    NSString *lastName = [artist objectForKeyNotNull:@"LastName"];
    NSString *sku = [currentItem objectForKeyNotNull:@"Sku"];
    
    NSString *formattedName = @"";
    if (firstName) {
        formattedName = [formattedName stringByAppendingValidString:firstName];
    }
    if (firstName && lastName) {
        formattedName = [formattedName stringByAppendingValidString:@" "];
    }
    if (lastName) {
        formattedName = [formattedName stringByAppendingValidString:lastName];
    }
    
    NSString *title = [itemAttributes objectForKeyNotNull:@"Title"];
    NSString *itemNumber = [currentItem objectForKeyNotNull:@"ItemNumber"];
    //UIImage *image  = [[pagingScrollView curentPage] image];
    NSDictionary *imageInformation = [currentItem objectForKeyNotNull:@"ImageInformation"];
    NSDictionary *mediumInformation = [imageInformation objectForKeyNotNull:@"MediumImage"];
    NSString *httpURL = [mediumInformation objectForKeyNotNull:@"HttpImageURL"];
    
    
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

        // Round to the nearest 0.5
        frameHeight = [NSNumber numberWithFloat:roundf(frameHeight.floatValue*2.0)/2.0];
        frameWidth = [NSNumber numberWithFloat:roundf(frameWidth.floatValue*2.0)/2.0];
        
        infoView.size.text = [NSString stringWithFormat:@"%@ in x %@ in", [fmt stringFromNumber:frameWidth], [fmt stringFromNumber:frameHeight]];
    }
    else {
        NSString *uom = @"in";
        if ([unitOfMeasure isEqualToNumber:[NSNumber numberWithInt:1]]) uom = @"in";
        if ([unitOfMeasure isEqualToNumber:[NSNumber numberWithInt:2]]) uom = @"cm";
        infoView.size.text = [NSString stringWithFormat:@"%@ %@ x %@ %@", [fmt stringFromNumber:width], uom, [fmt stringFromNumber:height], uom];
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
    
    
//    /infoView.contentSizeForViewInPopover = CGSizeMake(320, 460);
    [self.navigationController pushViewController:infoView animated:YES];
}




#pragma make Editing

// Override to support editing the table view.
- (void)tableView:(UITableView *)tblView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *cartItem = [_cartItems objectAtIndex:indexPath.row];
        NSString *cartItemID = [cartItem objectForKeyNotNull:@"Id"];
        //NIDINFO("removing cartItemId: %@ of cartItem: %@", cartItemID, cartItem );
        
        [_cartItems removeObjectAtIndex:indexPath.row];
        [tblView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateNavigationBarButtons];
        
        [SVProgressHUD showWithStatus:@"Removing Item"];
        
        [ArtAPI requestForCartUpdateCartItemQuantityForCartItemId:cartItemID quantity:0 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
            
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
    //NIDINFO("handleResponse: %@", resp);
    NSDictionary *cart = [[resp objectForKeyNotNull:@"d"] objectForKeyNotNull:@"Cart"];
    [ArtAPI setCart:cart];
    
    // Post notification that cart was updated - update badges
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CART_UPDATED
                                                        object:self];
    //NIDINFO("[ArtAPI cart]: %@", [ArtAPI cart] );
    
    self.data = [ArtAPI cart];
    //self.data = cart;
    NSArray *shipments = [self.data objectForKeyNotNull:@"Shipments"];
    NSDictionary *shipment = [shipments objectAtIndex:0];
    NSArray *cartItems = [shipment objectForKeyNotNull:@"CartItems"];
    //NIDINFO("cartItems.count: %d", cartItems.count);
    _cartItems = [[NSMutableArray alloc] initWithArray:cartItems];
    [[self tableView] reloadData];
    [self updateSubtotalLabel];
    [self updateNavigationBarButtons];
    [self performSelector:@selector(refresh) withObject:nil afterDelay:0.1];
}

-(void) handleFailure: (id) resp {
    //NIDINFO("handleFailure: %@", resp);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred"
                                                    message:[resp objectForKey:@"APIErrorMessage"]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [self loadDataFromAPI];
}


#pragma mark uipicker stuff
- (void)scroll:(NSIndexPath *)path {
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    self.tableView.scrollEnabled = NO;
}


- (void)updateServer {
    self.tableView.scrollEnabled = YES;
    NSDictionary *cartItem = [_cartItems objectAtIndex:textFieldBeingEdited.tag];
    NSString *cartItemID = [cartItem objectForKeyNotNull:@"Id"];

    [SVProgressHUD showWithStatus:@"Updating Quantity"];
    NSUInteger quan = [textFieldBeingEdited.text intValue];

    [ArtAPI requestForCartUpdateCartItemQuantityForCartItemId:cartItemID quantity:quan success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
        [SVProgressHUD dismiss];
        [self handleResponse:JSON];
    }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        [SVProgressHUD dismiss];
        [self handleFailure:JSON];
    }];
    
    //[self updateSubtotalLabel];
    //[self updateNavigationBarButtons];
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
    //NIDINFO("handleTapBehind() sender: %@", sender );
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

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ACShipAddressViewDelegate
- (void)didPressBackButton: (ACShipAddressViewController*) shipAddressViewController {
    //NIDINFO("didPressBackButton: %@", shipAddressViewController);
    [shipAddressViewController.navigationController popViewControllerAnimated:YES];
}


@end
