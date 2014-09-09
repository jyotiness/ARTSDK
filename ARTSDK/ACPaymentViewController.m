//
//  PAAPaymentViewController.m
//  PhotosArt
//
//  Created by Jobin on 03/10/12.
//
//

#import "ACPaymentViewController.h"
#import "ACOrderConfirmationViewController.h"
#import "ACBillingAddressViewController.h"
#import "ACShipOptionsTableViewCell.h"
#import "UIColor+Additions.h"
#import "ACWebViewController.h"
#import "ArtAPI.h"
#import "NSString+Additions.h"
#import "SVProgressHUD.h"
#import "Analytics.h"
#import "ACKeyboardToolbarView.h"
//#import "Helpshift.h"

@interface ACPaymentViewController () <ACKeyboardToolbarDelegate>
@property (nonatomic, retain) ACKeyboardToolbarView *inputAccView;
@end

@implementation ACPaymentViewController
@synthesize shippingTotalLabel;
@synthesize discountLabel;
@synthesize removeCouponButton;
@synthesize subtotalLabel;
@synthesize applyCouponBtton;
@synthesize estimateSalesTaxLabel;
@synthesize headerPaymentView;
@synthesize footerView;
@synthesize shippingType = _shippingType;
@synthesize paymentShippingTableView;
@synthesize standardShipping,expeditedShipping
,overnightShipping,cellNib,selectedIndexPath,productsSubTotal,shippingTotal,taxTotal,productsTotal;
@synthesize dataShippingOptions = _dataShippingOptions;
@synthesize orderTotalLabel;
@synthesize shipOptionsArray;
@synthesize couponCodetext,couponCodeField;
@synthesize sectionFooterView2,sectionFooterView1;


- (void)viewDidLoad
{
    
    if([self canPerformAction:@selector(setEdgesForExtendedLayout:) withSender:self]){
        [self setEdgesForExtendedLayout:(UIRectEdgeBottom|UIRectEdgeLeft|UIRectEdgeRight)];
    }
    
    self.title = [ACConstants getLocalizedStringForKey:@"&&_CHECKOUT" withDefaultValue:@"ART.COM CHECKOUT"];

    // Listen for notification kACNotificationDismissModal
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissModal) name:kACNotificationDismissModal object:nil];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    self.shipOptionsArray = arr;
    
    for(int i=0;i<self.dataShippingOptions.count;i++){
        [self.shipOptionsArray addObject:[NSNull null]];
    }

    //self.alwaysPriceView.backgroundColor = [UIColor redColor];
    
    [super viewDidLoad];
    //[self createInputAccessoryView];
    
    _inputAccView = [[ACKeyboardToolbarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([self.view getCurrentScreenBoundsDependOnOrientation]), 40) hideNextPrevButtons:YES];
    _inputAccView.toolbarDelegate = self;
    
    [self.backButton.titleLabel setFont:[ACConstants getStandardBoldFontWithSize:23.0f]];
    [self.closeButton.titleLabel setFont:[ACConstants getStandardBoldFontWithSize:23.0f]];
    
    //[self.orderButton setBackgroundColor:[UIColor colorWithRed:0.353 green:0.718 blue:0.906 alpha:1.000]];
    [self.orderButton setBackgroundColor:[ACConstants getPrimaryButtonColor]];
    [self.orderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.orderButton.titleLabel.font = [ACConstants getStandardBoldFontWithSize:32.0f];
    
    CALayer *btnLayer = [self.orderButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:2.0f];
    
    [self.paymentHeader setFont:[ACConstants getStandardBoldFontWithSize:30.0f]];
    if (!self.cellNib)
    {
        self.cellNib =  [UINib nibWithNibName:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
                         @"ACShipOptionsTableViewCell-iPad" : @"ACShipOptionsTableViewCell" bundle:ACBundle];
    }

    self.standardShipping=@"";
    self.expeditedShipping=@"";
    self.overnightShipping=@"";
    self.paymentShippingTableView.tableFooterView=self.footerView;
    self.paymentShippingTableView.tableHeaderView=self.headerPaymentView;
    [self.paymentTableViewHeader setFont:[ACConstants getStandardBoldFontWithSize:26.0f]];
    [self.paymentShippingTableView setBackgroundColor:[UIColor clearColor]];
    [self.headerPaymentView setBackgroundColor: [UIColor clearColor]];
    [self.footerView setBackgroundColor: [UIColor clearColor]];
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.applyCouponBtton.enabled = NO;
    self.removeCouponButton.enabled = NO;
    
    self.paymentTableViewHeader.text = [ACConstants getLocalizedStringForKey:@"SHIPPING_CAPS" withDefaultValue:@"SHIPPING"];
    self.subtotalTitleLabel.text = [ACConstants getLocalizedStringForKey:@"SUBTOTAL" withDefaultValue:@"Subtotal"];
    self.estimatedSalesTaxTitle.text = [ACConstants getLocalizedStringForKey:@"ESTIMATED_SALES_TAX" withDefaultValue:@"Estimated Sales Tax"];
    self.shippingTitleLabel.text = [ACConstants getLocalizedStringForKey:@"SHIPPING" withDefaultValue:@"Shipping"];
    self.discountTitle.text = [ACConstants getLocalizedStringForKey:@"DISCOUNT" withDefaultValue:@"Discount"];
    self.totalTitleLabel.text = [ACConstants getLocalizedStringForKey:@"TOTAL" withDefaultValue:@"Total"];
/*    self.paymentHeader.text = [ACConstants getLocalizedStringForKey:@"&&_CHECKOUT" withDefaultValue:@"ART.COM CHECKOUT"];
    [self.backButton setTitle:[ACConstants getLocalizedStringForKey:@"BACK" withDefaultValue:@"BACK"] forState:UIControlStateNormal];
    [self.backButton setTitle:[ACConstants getLocalizedStringForKey:@"BACK" withDefaultValue:@"BACK"] forState:UIControlStateHighlighted ]; */

    [self.orderButton setTitle:[ACConstants getLocalizedStringForKey:@"CONTINUE_CAPS" withDefaultValue:@"CONTINUE"] forState:UIControlStateNormal];
    [self.orderButton setTitle:[ACConstants getLocalizedStringForKey:@"CONTINUE_CAPS" withDefaultValue:@"CONTINUE"] forState:UIControlStateHighlighted];

//    [self.shippingDetailsBtton setTitle:[ACConstants getLocalizedStringForKey:@"SHIPPING_DETAILS" withDefaultValue:@"Shipping Details"] forState:UIControlStateNormal];
//    [self.shippingDetailsBtton setTitle:[ACConstants getLocalizedStringForKey:@"SHIPPING_DETAILS" withDefaultValue:@"Shipping Details"] forState:UIControlStateHighlighted];
    
    NSString *shippingDetails = [ACConstants getLocalizedStringForKey:@"SHIPPING_DETAILS" withDefaultValue:@"Shipping Details"];
    NSMutableAttributedString *mat = [[NSMutableAttributedString alloc] initWithString:shippingDetails];
    [mat addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSForegroundColorAttributeName: [UIColor artDotComTextCyan],NSFontAttributeName: [UIFont systemFontOfSize:11.0f]} range:NSMakeRange (0, mat.length)];
    [self.shippingDetailsBtton setAttributedTitle:mat forState:UIControlStateNormal];
    [self.shippingDetailsBtton setAttributedTitle:mat forState:UIControlStateHighlighted];

    [self.shippingDetailsBtton sizeToFit];
    CGRect frame = [self.shippingDetailsBtton frame];
    
    frame.origin.x = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?521:320) - frame.size.width-10;
    self.shippingDetailsBtton.frame = frame;
    self.shippingUnderLine.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame)-4, frame.size.width, 1);
    
//    [self.showCouponButton setTitle:[ACConstants getLocalizedStringForKey:@"ENTER_&&_COUPON_CODE" withDefaultValue:@"Enter Art.com Coupon Code"] forState:UIControlStateNormal];
    
    NSString *couponButtonTitle = [ACConstants getLocalizedStringForKey:@"ENTER_&&_COUPON_CODE" withDefaultValue:@"Enter Art.com Coupon Code"];
    NSMutableAttributedString *mat1 = [[NSMutableAttributedString alloc] initWithString:couponButtonTitle];
    [mat1 addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSForegroundColorAttributeName: [UIColor artDotComTextCyan],NSFontAttributeName: [UIFont systemFontOfSize:11.0f]} range:NSMakeRange (0, mat1.length)];
    [self.self.showCouponButton setAttributedTitle:mat1 forState:UIControlStateNormal];
    [self.self.showCouponButton setAttributedTitle:mat1 forState:UIControlStateHighlighted];

    [self.showCouponButton sizeToFit];
    frame = [self.showCouponButton frame];
    frame.origin.x = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?522:320) - frame.size.width-10;
    self.showCouponButton.frame = frame;
    self.couponUnderLine.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame)-4, frame.size.width, 1);

    [self.applyCouponBtton setTitle:[ACConstants getLocalizedStringForKey:@"APPLY_COUPON" withDefaultValue:@"Apply Coupon"] forState:UIControlStateNormal];
    [self.removeCouponButton setTitle:[ACConstants getLocalizedStringForKey:@"REMOVE_COUPON" withDefaultValue:@"Remove Coupon"] forState:UIControlStateNormal];

    [self.applyCouponBtton setTitleColor:[UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.applyCouponBtton.layer setCornerRadius:7.0f];
    [[self.applyCouponBtton layer] setBorderWidth:1.0f];
    //[self.applyCouponBtton.layer setBorderColor:[UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0].CGColor];
    [self.applyCouponBtton.layer setBorderColor:[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0].CGColor];
    [self.applyCouponBtton.layer masksToBounds];
    
    [self.removeCouponButton setTitleColor:[UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.removeCouponButton.layer setCornerRadius:7.0f];
    [[self.removeCouponButton layer] setBorderWidth:1.0f];
    [self.removeCouponButton.layer setBorderColor:[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0].CGColor];
    [self.removeCouponButton.layer masksToBounds];
    
    [self processCartData];
    
    self.screenName = @"Payment Screen";
}

- (void)dismissModal {
    [[NSNotificationCenter defaultCenter] removeObserver:nil name:kACNotificationDismissModal object:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:nil name:kACNotificationDismissModal object:nil];
    self.shipOptionsArray = nil;
    [self setPaymentShippingTableView:nil];
    [self setFooterView:nil];
    [self setHeaderPaymentView:nil];
    [self setRemoveCouponButton:nil];
    [self setApplyCouponBtton:nil];
    [self setSubtotalLabel:nil];
    [self setEstimateSalesTaxLabel:nil];
    [self setShippingTotalLabel:nil];
    [self setOrderTotalLabel:nil];
    [self setDiscountLabel:nil];
    [self setDiscountTitle:nil];
    [self setPaymentTableViewHeader:nil];
    [self setAlwaysPriceView:nil];
    [self setBackButton:nil];
    [self setOrderButton:nil];
    [self setPaymentHeader:nil];
    self.dataShippingOptions = nil;
    [self setSectionFooterView1:nil];
    [self setSectionFooterView2:nil];
    [self setShowCouponButton:nil];
    [self setEstimatedSalesTaxTitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
    UIButton *barBackButton = [ACConstants getBackButtonForTitle:[ACConstants getLocalizedStringForKey:@"BACK" withDefaultValue:@"Back"]];
    [barBackButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:barBackButton];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoButton setFrame:CGRectMake(4.0, 4.0f, 24.0f, 24.0f)];
    [infoButton setImage:[UIImage imageNamed:ARTImage(@"InfoButton23")] forState:UIControlStateNormal];
    [infoButton addTarget:self action:@selector(iButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.navigationItem.rightBarButtonItem = infoBarButton;
    
    self.navigationItem.hidesBackButton = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return mShowCoupon?2:1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==1) {
        return 42.0;
    }else if(section==0){
        return 0;
    }
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0 && !mShowCoupon)
    {
        return 60;
    }
    else if(1 == section)
        return 60;

    return 1 / [UIScreen mainScreen].scale;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(((0 == section) && !mShowCoupon))
        return self.sectionFooterView1;
    else if(1 == section)
        return self.sectionFooterView2;
    
    return nil;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    label.font=[UIFont boldSystemFontOfSize:label.font.pointSize+3];
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[ACConstants getStandardBoldFontWithSize:26.0f]];
    [label setTextColor:[UIColor artPhotosSectionTextColor]];
    
    if (section == 1)
    {
        label.text = [ACConstants getLocalizedStringForKey:@"&&_COUPON" withDefaultValue:@"ART.COM COUPON"];
    }
    [view addSubview:label];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section)
    {
        case 0:
            return [self.dataShippingOptions count];
            break;
        
        case 1:
            return 1;
            break;
        
        default:
            return 0;
            break;
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary  *cart = [ArtAPI cart];
    self.shippingType = [[[[cart objectForKeyNotNull:@"Shipments"] objectAtIndex:0] objectForKeyNotNull:@"ShippingPriority"] intValue];
    
	int rownum=indexPath.row;

    NSDictionary *cellData = nil;
    if(rownum<self.dataShippingOptions.count){
        cellData = [self.dataShippingOptions objectAtIndex:rownum];
    }
    //  NSDictionary *transitTimeData = [cellData objectForKeyNotNull:@"TransitTime"];
    
    NSString *deliveryDateMaxResponse = [cellData objectForKeyNotNull:@"EstimatedShipmentReceiptDateMaximum"];
    NSString *deliveryDateMinResponse = [cellData objectForKeyNotNull:@"EstimatedShipmentReceiptDateMinimum"];
    NSDate *deliveryDateMax = [ArtAPI extractDataFromAPIString:deliveryDateMaxResponse];
    NSDate *deliveryDateMin = [ArtAPI extractDataFromAPIString:deliveryDateMinResponse];
    
    AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if((currAppLoc==AppLocationFrench)||(currAppLoc==AppLocationGerman)){
        NSString *currentlyUsedLocale = [[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENT_LOCATION_IN_USE"];
//        NSLog(@"Currently used locale is %@",currentlyUsedLocale);
        if([[currentlyUsedLocale lowercaseString] isEqualToString:@"fr"]){
            [formatter setDateFormat:@"dd/MM/yyyy"];
        }else if([[currentlyUsedLocale lowercaseString] isEqualToString:@"de"]){
            [formatter setDateFormat:@"dd.MM.yyyy"];
        }else{
            [formatter setDateFormat:@"MM/dd/yyyy"];
        }
    }else{
        [formatter setDateFormat:@"MM/dd/yyyy"];
    }
    
    NSString *displayDeliveryDate = [NSString stringWithFormat:@"%@ - %@",[formatter stringFromDate:deliveryDateMin],[formatter stringFromDate:deliveryDateMax]];
    
    NSNumber *shippingTypeID = [cellData objectForKeyNotNull:@"ShippingOption"];
    NSString *shippingTypeName = [cellData objectForKeyNotNull:@"Name"];
    NSDecimalNumber *shippingPrice = [cellData objectForKeyNotNull:@"ShippingCharge"];
    
     switch (indexPath.section)
    {            
        case 0:
        {
            static NSString *CellIdentifier = @"Cell";
            ACShipOptionsTableViewCell * cell = (ACShipOptionsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            if (cell==nil)
            {
                cell = (ACShipOptionsTableViewCell *)[[ACBundle loadNibNamed:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
                                                           @"ACShipOptionsTableViewCell-iPad" : @"ACShipOptionsTableViewCell"  owner:self options:nil] objectAtIndex:0];
            }
            
            [tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            
            NSString *arrives = [ACConstants getLocalizedStringForKey:@"ARRIVES" withDefaultValue:@"Arrives"];
            
            //FREE SHIPPING STRING - 
            //check for shipping discount and free shipping boolean on cart
            //these values to be used in the standard shipping row
            NSArray *discounts = [cart objectForKeyNotNull:@"Discounts"];
            NSNumber *hasFreeShippingDiscountNumber = 0;
            BOOL hasFreeShippingDiscount = NO;
            
            if(discounts){
                for(NSDictionary *discount in discounts){
                    hasFreeShippingDiscountNumber = [discount objectForKeyNotNull:@"IsFreeShippingDiscount"];
                    if(hasFreeShippingDiscountNumber){
                        hasFreeShippingDiscount = [hasFreeShippingDiscountNumber boolValue];
                        break;
                    }
                }
            }
            
            if(hasFreeShippingDiscount){
                //NSLog(@"Has Free Ship Coupon");
            }else{
                //NSLog(@"Has NO Free Ship Coupon");
            }
            
            switch (rownum)
            {
                case 0:
                {
                    cell.shippingDescriptionLabel.text = [NSString stringWithFormat:@"%@ : %@ %@*", shippingTypeName,arrives,displayDeliveryDate];
                    [cell.textLabel sizeToFit ];
                    cell.shippingCost = [cellData objectForKeyNotNull:@"ShippingCharge"];
                    cell.shippingPriceLabel.text = [NSString formatedPriceFor: shippingPrice];//[self.currencyFormatter stringFromNumber:shippingPrice];
                    cell.shippingType = [[cellData objectForKeyNotNull:@"ShippingOption"] intValue];
                    
                    if(hasFreeShippingDiscount && [shippingTypeID intValue] == 1){
                        //it is FREE STANDARD SHIPPING
                        cell.shippingPriceLabel.text = [ACConstants getLocalizedStringForKey:@"FREESHIP" withDefaultValue:@"FREE"];
                    }
                    
                     break ;
                }
                case 1:
                {
                    cell.shippingDescriptionLabel.text = [NSString stringWithFormat:@"%@ : %@ %@*", shippingTypeName,arrives,displayDeliveryDate];
                    [cell.textLabel sizeToFit ];
                    cell.shippingCost = [cellData objectForKeyNotNull:@"ShippingCharge"];
                    cell.shippingPriceLabel.text = [NSString formatedPriceFor: shippingPrice];//[self.currencyFormatter stringFromNumber:shippingPrice];
                    cell.shippingType = [[cellData objectForKeyNotNull:@"ShippingOption"] intValue];
                    
                    if(hasFreeShippingDiscount && [shippingTypeID intValue] == 1){
                        //it is FREE STANDARD SHIPPING
                        cell.shippingPriceLabel.text = [ACConstants getLocalizedStringForKey:@"FREESHIP" withDefaultValue:@"FREE"];
                    }
                    
                    break ;
                }
                case 2:
                {
                    cell.shippingDescriptionLabel.text = [NSString stringWithFormat:@"%@ : %@ %@*", shippingTypeName,arrives,displayDeliveryDate];
                    [cell.textLabel sizeToFit ];
                    cell.shippingCost = [cellData objectForKeyNotNull:@"ShippingCharge"];
                    cell.shippingPriceLabel.text = [NSString formatedPriceFor: shippingPrice];//[self.currencyFormatter stringFromNumber:shippingPrice];
                    cell.shippingType = [[cellData objectForKeyNotNull:@"ShippingOption"] intValue];
                    
                    if(hasFreeShippingDiscount && [shippingTypeID intValue] == 1){
                        //it is FREE STANDARD SHIPPING
                        cell.shippingPriceLabel.text = [ACConstants getLocalizedStringForKey:@"FREESHIP" withDefaultValue:@"FREE"];
                    }
                    
                    break ;
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if(cell.shippingType == self.shippingType)
            {
                [cell.shippingDescriptionLabel setTextColor:[UIColor artDotComTextCyan]];
                [cell.shippingPriceLabel setTextColor:[UIColor artDotComTextCyan]];
                cell.checkMarkButton.hidden = NO;
            }
            else
            {
                [cell.shippingDescriptionLabel setTextColor:[UIColor blackColor]];
                [cell.shippingPriceLabel setTextColor:[UIColor blackColor]];
                cell.checkMarkButton.hidden = YES;
            }
            [self.shipOptionsArray replaceObjectAtIndex:rownum withObject:cell];
            return cell;
            break;
        }
        case 1:
        {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (rownum == 0)
            {
                //mkl FONT CHANGE
                cell.textLabel.text = [ACConstants getLocalizedStringForKey:@"COUPON_CODE" withDefaultValue:@"Coupon Code"];
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
                if(!self.couponCodeField){
                    UITextField* tf = [self makeTextField:nil placeholder:[ACConstants getLocalizedStringForKey:@"OPTIONAL" withDefaultValue:@"Optional"]];
                    tf.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
                    self.couponCodeField = tf;
                }
               
                self.couponCodeField.textAlignment = NSTextAlignmentRight;
                CGFloat cellWidth = 145;
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){ cellWidth = 370;}
                self.couponCodeField.frame = CGRectMake(150, cell.frame.size.height/2 - 9, cellWidth, 18);
                [self.couponCodeField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
                //self.couponCodeField.backgroundColor=UIColor.redColor;
                
                // We want to handle textFieldDidEndEditing
               	self.couponCodeField.delegate = self ;
                [cell.contentView addSubview:self.couponCodeField];
            }


            return cell;
            break;
        }
            
        default:
            break;
    }    
	// Textfield dimensions
    return defaultCell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    int rownum=indexPath.row;
    switch (indexPath.section)
    {
        case 0:
        {
            ACShipOptionsTableViewCell *aCell =  (ACShipOptionsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            self.selectedIndexPath = indexPath;
            
            if(self.shippingType!=aCell.shippingType){
                self.shippingType=aCell.shippingType;
                [self callServerToSetShippingMethod];
            }
            break;
        }
        case 1:
        {
            if(![self.couponCodeField isFirstResponder] && self.couponCodeField.userInteractionEnabled){
                [self.couponCodeField becomeFirstResponder];
                self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                [self.paymentShippingTableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }
        default:
            break;
    }
}

-(void) callServerToSetShippingMethod
{
//    ACCShippingPriority currentPriority = nil;
    
//    switch (self.shippingType)
//    {
//        case 1:
//            currentPriority = ACCShippingPriorityStandard;
//            break;
//        case 2:
//            currentPriority = ACCShippingPriorityExpedited;
//            break;
//        case 3:
//            currentPriority = ACCShippingPriorityOvernight;
//            break;
//        default:
//            currentPriority = ACCShippingPriorityStandard;
//            break;
//    }
    
//    if (currentPriority)
//    {
        [SVProgressHUD showWithStatus:[ACConstants getUpperCaseStringIfNeededForString:[ACConstants getLocalizedStringForKey:@"UPDATING_PRIORITY" withDefaultValue:@"UPDATING PRIORITY..."]] maskType:SVProgressHUDMaskTypeClear];

        [ArtAPI
         cartUpdateShipmentPriority:self.shippingType success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
             [self updateShipmentPriorityFinished: JSON];
         }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
             NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
             [SVProgressHUD dismiss];
         }];
//    }
//    else
//    {
//        NSLog(@"Error: Unknown Shipping Priority");
//    }
}

-(void)keyboardWillShow:(NSNotification *)notiFication
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        CGRect rect = self.paymentShippingTableView.frame;
        
        //iPhone5 compatibility
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height*[UIScreen mainScreen].scale;
        if(screenHeight == 480){
            //iphone no retina
            rect.size.height = 416-225;
        }else if(screenHeight == 960){
            //iphone with retina
            rect.size.height = 416-225;
        }else{
            //iphone5
            rect.size.height = 504 - 225;
        }
        
        self.paymentShippingTableView.frame = rect;
        [self.paymentShippingTableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

-(void)keyboardWillHide:(NSNotification *)notiFication
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        CGRect rect = self.paymentShippingTableView.frame;
        
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
        
        self.paymentShippingTableView.frame = rect;
    }
}

-(void) processCartData
{
    NSDictionary  *cart = [ArtAPI cart];
    NSDictionary *cartTotal = [cart objectForKeyNotNull:@"CartTotal"];
    
    NSString *discountCoupon = nil;
    NSArray *discountCouponArray = [cart objectForKeyNotNull:@"Discounts"];
    if(discountCouponArray.count>0){
        discountCoupon = [[discountCouponArray objectAtIndex:0] objectForKeyNotNull:@"DiscountCode"];
    }
    if(discountCoupon){
        self.removeCouponButton.enabled = YES;
        [self.removeCouponButton.layer setBorderColor:[UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0].CGColor];
        
        self.applyCouponBtton.enabled = NO;
        [self.applyCouponBtton.layer setBorderColor:[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0].CGColor];
        
        self.couponCodeField.text = discountCoupon;
        self.couponCodeField.userInteractionEnabled = NO;
        if(self.paymentShippingTableView.numberOfSections == 1){
            [self showCouponSection:nil];
        }
        
        CGRect alwaysPriceViewFrame = self.alwaysPriceView.frame;
        alwaysPriceViewFrame.origin.y = 61;
        self.alwaysPriceView.frame = alwaysPriceViewFrame;
        
    }else{
        self.removeCouponButton.enabled = NO;
        [self.removeCouponButton.layer setBorderColor:[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0].CGColor];
//        self.applyCouponBtton.enabled = YES;
        
        CGRect alwaysPriceViewFrame = self.alwaysPriceView.frame;
        alwaysPriceViewFrame.origin.y = 36;
        self.alwaysPriceView.frame = alwaysPriceViewFrame;
        
        self.couponCodeField.userInteractionEnabled = YES;
    }
    
    NSNumber *normalShippingRate = [NSNumber numberWithFloat:0.0f];
    self.shippingType = [[[[cart objectForKeyNotNull:@"Shipments"] objectAtIndex:0] objectForKeyNotNull:@"ShippingPriority"] intValue];
    
    for (NSDictionary *shippingData in self.dataShippingOptions){
        if(self.shippingType == [[shippingData objectForKeyNotNull:@"ShippingOption"] intValue]){
            normalShippingRate = [shippingData objectForKeyNotNull:@"ShippingCharge"];
            break;
        }
    }
    
    NSNumber *discount=[cartTotal objectForKeyNotNull:@"DiscountTotal"];
    
    self.shippingTotal =  [cartTotal objectForKeyNotNull:@"ShippingTotal"];
    
    CGFloat shippingDifference = 0.0f;
    
    if([self.shippingTotal floatValue] < [normalShippingRate floatValue]){
        shippingDifference = [normalShippingRate floatValue] - [self.shippingTotal floatValue];
    }
    
    if(shippingDifference > 0){
        discount = [NSNumber numberWithFloat:([discount floatValue] - shippingDifference)];
    }
    
    self.productsSubTotal = [cartTotal objectForKeyNotNull:@"ProductSubTotal"];
    
    if([discount floatValue] > 0){
        self.productsSubTotal = (NSDecimalNumber *)[NSNumber numberWithFloat:([self.productsSubTotal floatValue] + [discount floatValue])];
        self.discountLabel.alpha = 1.0f;
        self.discountTitle.alpha = 1.0f;
        self.discountLabel.text= [NSString stringWithFormat:@"-%@",[NSString formatedPriceFor:discount]];
        //self.alwaysPriceView.frame = DISCOUNT_FRAME;
        CGRect alwaysPriceViewFrame = self.alwaysPriceView.frame;
        alwaysPriceViewFrame.origin.y = 61;
        self.alwaysPriceView.frame = alwaysPriceViewFrame;
    }else{
        self.discountLabel.text= @"";
        self.discountLabel.alpha = 0.0f;
        self.discountTitle.alpha = 0.0f;
        //self.alwaysPriceView.frame = NO_DISCOUNT_FRAME;
        CGRect alwaysPriceViewFrame = self.alwaysPriceView.frame;
        alwaysPriceViewFrame.origin.y = 36;
        self.alwaysPriceView.frame = alwaysPriceViewFrame;
    }
    
    //  self.shippingType = [aShipment objectForKeyNotNull:@"ShippingPriority"];
    NSString *shipmentCountry = [[[[cart objectForKeyNotNull:@"Shipments"] objectAtIndex:0] objectForKeyNotNull:@"Address"] objectForKeyNotNull:@"CountryIsoA2"];
    shipmentCountry = [[shipmentCountry stringByTrimmingCharactersInSet:[ NSCharacterSet whitespaceCharacterSet]] uppercaseString];
    self.taxTotal =  [cartTotal objectForKeyNotNull:@"TaxTotal"];
    //Note: we fixed the missing tax rate by hiding it in th UI
    //TODO: Need the api to start passing back the tax rate...
    //taxRate =  self.[cartTotal objectForKeyNotNull:@"TaxRate"];
    self.productsTotal =  [cartTotal objectForKeyNotNull:@"Total"];
    [self.discountLabel setTextAlignment:NSTextAlignmentRight];
    [self.subtotalLabel setTextAlignment:NSTextAlignmentRight];
    [self.estimateSalesTaxLabel setTextAlignment:NSTextAlignmentRight];
    [self.shippingTotalLabel setTextAlignment:NSTextAlignmentRight];
    [self.orderTotalLabel setTextAlignment:NSTextAlignmentRight];
    
    self.subtotalLabel.text = [NSString formatedPriceFor: self.productsSubTotal];//[self.currencyFormatter stringFromNumber:self.productsSubTotal];
    // self.salesTaxRateLabel.text = [self.taxRate stringValue]; //hidden in UI
    self.estimateSalesTaxLabel.text = [NSString formatedPriceFor: self.taxTotal];//[self.currencyFormatter stringFromNumber:self.taxTotal];
    
    self.orderTotalLabel.text = [NSString formatedPriceFor: self.productsTotal];//[self.currencyFormatter stringFromNumber:self.productsTotal];
    self.shippingTotalLabel.text= ([self.shippingTotal floatValue]==0)?[ACConstants getLocalizedStringForKey:@"FREE" withDefaultValue:@"FREE"]:[NSString formatedPriceFor: self.shippingTotal];

    if((![shipmentCountry isEqualToString:@"US"])||([self.taxTotal floatValue]==0)){
        self.estimateSalesTaxLabel.alpha = 0.0f;
        self.estimatedSalesTaxTitle.alpha = 0.0f;
        CGRect alwaysPriceFrame = self.alwaysPriceView.frame;
        alwaysPriceFrame.origin.y = alwaysPriceFrame.origin.y - 25;
        alwaysPriceFrame.size.height = alwaysPriceFrame.size.height - 25;
        self.alwaysPriceView.frame = alwaysPriceFrame;
        [self.paymentShippingTableView reloadData];
    }else{
        self.estimateSalesTaxLabel.alpha = 1.0f;
        self.estimatedSalesTaxTitle.alpha = 1.0f;
    }
}

- (void) updateShipmentPriorityFinished:(id)JSON
{
    [SVProgressHUD dismiss];
    //NSDictionary *response = [[JS] APIResponse];
    
    NSDictionary *cart = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"Cart"];
    
    if ([cart objectForKeyNotNull:@"CartId"] != nil)
    {
        [ArtAPI setCart:cart];
    }
    
    [self processCartData];
    [self.paymentShippingTableView reloadData];
}

-(UITextField*) makeTextField: (NSString*)text placeholder: (NSString*)placeholder
{
	UITextField *tf = [[UITextField alloc] init];
	tf.placeholder = placeholder ;
	tf.text = text ;
	tf.autocorrectionType = UITextAutocorrectionTypeNo ;
	tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
	tf.adjustsFontSizeToFitWidth = YES;
	tf.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
	return tf ;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ACKeyboardToolbarDelegate

- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectDone: (id) done {
//    [self.couponCodeField resignFirstResponder];
    [self.view endEditing:YES];
}


- (IBAction)textFieldFinished:(id)sender
{
//    [sender resignFirstResponder];
    [self.view endEditing:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.couponCodeField)
    {
        UITableViewCell *cell = (UITableViewCell *)[textField superview];
        if([ cell isKindOfClass:[UITableViewCell class]])
            self.selectedIndexPath = [self.paymentShippingTableView indexPathForCell:cell];

        textField.inputAccessoryView = _inputAccView;
        [textField setKeyboardAppearance:UIKeyboardAppearanceLight];
        
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [self.paymentShippingTableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *newStr = [textField.text stringByAppendingFormat:@"%@",string ];
    int length = (0 == string.length)?newStr.length-1:newStr.length;
 
    self.applyCouponBtton.enabled = (length > 0);
    
    if(self.applyCouponBtton.enabled){
        [self.applyCouponBtton.layer setBorderColor:[UIColor colorWithRed:59.0/255 green:184.0/255 blue:232.0/255 alpha:1.0].CGColor];
    }else{
       [self.applyCouponBtton.layer setBorderColor:[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0].CGColor];
    }
    return YES;
}

#pragma mark -  Action Methods

-(IBAction)goBack:(id)sender
{
    [ self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)showOrderConfirmation:(id)sender
{
    ACOrderConfirmationViewController *controller = [[ACOrderConfirmationViewController alloc] initWithNibName:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ACOrderConfirmationViewController-iPad" :@"ACOrderConfirmationViewController"
                                                                                                        bundle:ACBundle];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)dealloc
{
    /*
    [paymentShippingTableView release];
    [footerView release];
    [headerPaymentView release];
    [removeCouponButton release];
    [applyCouponBtton release];
    [subtotalLabel release];
    [estimateSalesTaxLabel release];
    [shippingTotalLabel release];
    [orderTotalLabel release];
    [discountLabel release];
    [_discountTitle release];
    [_paymentTableViewHeader release];
    [_alwaysPriceView release];
    [_backButton release];
    [_orderButton release];
    [_paymentHeader release];
    */
    self.sectionFooterView1 = nil;
    self.sectionFooterView2 = nil;
    /*[_showCouponButton release];
    [_estimatedSalesTaxTitle release];
    [super dealloc];*/
}

- (IBAction)proceedToBillingAddress:(id)sender
{
    
    [SVProgressHUD showWithStatus:[ACConstants getUpperCaseStringIfNeededForString:[ACConstants getLocalizedStringForKey:@"GETTING_PAYMENT_TYPES" withDefaultValue:@"GETTING PAYMENT TYPES"]] maskType:SVProgressHUDMaskTypeClear];

    /*
    [ArtAPI cartGetPaypalToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        [self cartGetPaymentOptionsRequestDidFinish: JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
        [SVProgressHUD dismiss];
    }];
    
    return;
    */
    [ArtAPI
     cartGetPaymentOptionsWithSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
         [self cartGetPaymentOptionsRequestDidFinish: JSON];
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         [SVProgressHUD dismiss];
     }];
    
    
}

- (IBAction)applyCouponAction:(id)sender
{
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_APPLY_COUPON];
    
//    [self.couponCodeField resignFirstResponder];
    [self.view endEditing:YES];
    if(self.couponCodeField.text.length<1)
    {
        [SVProgressHUD dismiss];
        UIAlertView *noCouponAlert = [[UIAlertView alloc] initWithTitle:[ACConstants getLocalizedStringForKey:@"ERROR" withDefaultValue:@"Error"]
                                                message:[ACConstants getLocalizedStringForKey:@"ENTER_COUPON_CODE_ABOVE" withDefaultValue:@"Please enter a coupon code above"]
                                                               delegate:nil
                                                      cancelButtonTitle:[ACConstants getLocalizedStringForKey:@"OK" withDefaultValue:@"OK"]
                                                      otherButtonTitles:nil, nil];
        [noCouponAlert show];
        return;
    }
    [SVProgressHUD showWithStatus:[ACConstants getUpperCaseStringIfNeededForString:[ACConstants getLocalizedStringForKey:@"APPLYING_COUPON" withDefaultValue:@"APPLYING COUPON..."]] maskType:SVProgressHUDMaskTypeClear];
    
    [ArtAPI
     cartAddCouponCode:self.couponCodeField.text success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
         [self applyCoupnCodeFinished: JSON];
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         [self applyCoupnCodeFailed: JSON];
     }];
    
}

- (void) applyCoupnCodeFailed:(id)JSON
{
    NSString *couponErrorString = [ACConstants getLocalizedStringForKey:@"COUPON_ERROR" withDefaultValue:@"COUPON_ERROR"];
    
    [SVProgressHUD dismiss];
    
    self.couponCodeField.text = nil;
    self.couponCodetext = nil;
    self.applyCouponBtton.enabled = NO;
    [self.applyCouponBtton.layer setBorderColor:[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0].CGColor];
    
    if([[[JSON objectForKey:@"APIErrorMessage"] lowercaseString] rangeOfString:@"coupon collection"].location == NSNotFound)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[ACConstants getLocalizedStringForKey:@"ERROR" withDefaultValue:@"Error"]
                                                        message:couponErrorString
                                                       delegate:nil
                                              cancelButtonTitle:[ACConstants getLocalizedStringForKey:@"OK" withDefaultValue:@"OK"]
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[ACConstants getLocalizedStringForKey:@"PLEASE_ENTER_COUPON_CODE" withDefaultValue:@"Please enter a valid coupon code"]message:nil
                                                       delegate:nil
                                              cancelButtonTitle:[ACConstants getLocalizedStringForKey:@"OK" withDefaultValue:@"OK"]
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
}


- (void) applyCoupnCodeFinished:(id)JSON
{
    [SVProgressHUD dismiss];
    
    //MKL - for P2A Apps, need to display FREE in the standard shipping if the apply coupon
    //resulted in a 0 cost standard shipping
    [self updateStandardShippingAfterCoupon];
    
    NSDictionary *cart = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"Cart"];
    
    if ([cart objectForKeyNotNull:@"CartId"] != nil)
    {
        [ArtAPI setCart:cart];
    }
    [self processCartData];
}


- (void) updateStandardShippingAfterCoupon
{
    // Fetch a list of Countries
    [ArtAPI
     cartGetShippingOptionsWithSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
         [self cartGetShippingOptionsRequestDidFinish: JSON];
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         //[SVProgressHUD dismiss];
     }];
}


-(void) cartGetShippingOptionsRequestDidFinish:(id)JSON
{
    //[SVProgressHUD dismiss];
    NSDictionary *response = [JSON objectForKey:@"d"];
    
    // Pull out the shipping options:
    NSArray *shippingOptions = [response objectForKeyNotNull:@"ShippingOptions"];
    self.dataShippingOptions = shippingOptions;
    [self.paymentShippingTableView reloadData];
    
}




- (IBAction)removeCouponActions:(id)sender
{
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_REMOVE_COUPON];
    
//    [self.couponCodeField resignFirstResponder];
    [self.view endEditing:YES];

    [SVProgressHUD showWithStatus:[ACConstants getUpperCaseStringIfNeededForString:[ACConstants getLocalizedStringForKey:@"REMOVING_COUPON" withDefaultValue:@"REMOVING COUPON..."]] maskType:SVProgressHUDMaskTypeClear];
    
    NSString *discountCoupon = nil;
    if(self.couponCodeField.text.length<1)
    {
        NSDictionary *currentCart = [ArtAPI cart];
        NSArray *discountCouponArray = [currentCart objectForKeyNotNull:@"Discounts"];
        if(discountCouponArray.count>0){
            discountCoupon = [[discountCouponArray objectAtIndex:0] objectForKeyNotNull:@"DiscountCode"];
        }
        if(!discountCoupon){
            [SVProgressHUD dismiss];
            UIAlertView *noCouponAlert = [[UIAlertView alloc] initWithTitle:[ACConstants getLocalizedStringForKey:@"ERROR" withDefaultValue:@"Error"]
                                                                    message:[ACConstants getLocalizedStringForKey:@"ENTER_COUPON_CODE_ABOVE" withDefaultValue:@"Please enter a coupon code above"]
                                                          delegate:nil
                                                          cancelButtonTitle:[ACConstants getLocalizedStringForKey:@"OK" withDefaultValue:@"OK"]
                                                          otherButtonTitles:nil, nil];
            [noCouponAlert show];
            return;
        }
    }

    NSString *couponCodeToRemove = self.couponCodeField.text;
    if([couponCodeToRemove stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0){
        couponCodeToRemove = discountCoupon;
    }

    [ArtAPI
     cartRemoveCoupon:couponCodeToRemove  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
         [self removeCoupnCodeFinished: JSON];
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         [SVProgressHUD dismiss];
     }];
}



- (void) removeCoupnCodeFinished:(id)JSON
{
    [SVProgressHUD dismiss];
    
    //MKLupdate free standard shipping if coupon removed
    [self updateStandardShippingAfterCoupon];
    
    
    NSDictionary *cart = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"Cart"];
    
    if ([cart objectForKeyNotNull:@"CartId"] != nil)
    {
        [ArtAPI setCart:cart];
    }
    
    [self processCartData];
    ;
    self.applyCouponBtton.enabled = NO;
    [self.applyCouponBtton.layer setBorderColor:[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0].CGColor];
    
    self.couponCodeField.text = @"";
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(0 == buttonIndex)
    {
        //[Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_INFO_BUTTON_PRESSED];
        
        [self showAbout];
    }
    else if(1 == buttonIndex)
    {
        //[[Helpshift sharedInstance] showSupport:self];
    }
}

-(void)showAbout{
    NSString *aboutURL = [ArtAPI sharedInstance].aboutURL;
    
    ACWebViewController * webViewController = [[ACWebViewController alloc] initWithURL:[NSURL URLWithString:aboutURL]];
    webViewController.toolbarHidden = YES;
    webViewController.titleHidden = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    navigationController.navigationBarHidden = NO;
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)shipDetailsButtonPressed:(UIButton *)sender
{
    NSString *shipURL = [ArtAPI sharedInstance].shippingURL;
    
    ACWebViewController * webViewController = [[ACWebViewController alloc] initWithURL:[NSURL URLWithString:shipURL]];
    webViewController.toolbarHidden = YES;
    webViewController.titleHidden = YES;
    NSString *versionStr = [NSString stringWithFormat:@"v%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    UIBarButtonItem *versionBtn = [[UIBarButtonItem alloc] initWithTitle:versionStr style:UIBarButtonItemStyleBordered target:nil action:nil];
    versionBtn.tintColor = UIColorFromRGB(0x4a4a4a);
    versionBtn.enabled = NO;
    webViewController.leftButtonItem = versionBtn;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];

}

- (IBAction)iButtonPressed:(UIButton *)sender
{
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_INFO_BUTTON_PRESSED];
    
    [self showAbout];
    
    /* DISABLING HELPSHIFT
    NSString *aboutTitle = nil;
    AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
    
    if(currAppLoc == AppLocationFrench){
        aboutTitle = NSLocalizedString(@"ABOUT_TITLE_MESPHOTOS", nil);
    }else if(currAppLoc == AppLocationGerman){
        aboutTitle = NSLocalizedString(@"ABOUT_TITLE_MYPHOTOS", nil);
    }else{
        aboutTitle = NSLocalizedString(@"ABOUT_TITLE_PHOTOSTOART", nil);
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:aboutTitle,NSLocalizedString(@"HELP", nil), nil];
    [actionSheet showInView:self.view];
     
     */
}

- (IBAction)showCouponSection:(id)sender
{
    mShowCoupon = YES;
    [self.paymentShippingTableView beginUpdates];
    [self.paymentShippingTableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    [self.paymentShippingTableView endUpdates];
    [self.paymentShippingTableView reloadData];
    [self performSelector:@selector(processCartData) withObject:nil afterDelay:0.75];
}



-(void) cartGetPaymentOptionsRequestDidFinish:(id)JSON
{
    [SVProgressHUD dismiss];
    NSDictionary *response = [JSON objectForKey:@"d"];
    
    NSLog(@"response %@",response);
    
    NSArray *paymentOptions = [response objectForKeyNotNull:@"CreditCardOptions"];
    
    if(paymentOptions && ![paymentOptions isKindOfClass:[NSNull class]]){
    
        [self proceedToBillingScreenWithPaymentOptions:paymentOptions];
        
    }
    
}

-(void)proceedToBillingScreenWithPaymentOptions:(NSArray *)paymentOptions{
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_SHIPPING_METHOD_CONTINUE];
    
    ACBillingAddressViewController *billingCheckOutController = [[ACBillingAddressViewController alloc] initWithNibName:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ACBillingAddressViewController-iPad" :@"ACBillingAddressViewController" bundle:ACBundle];
    
    //anuj moving the code to the right place
    billingCheckOutController.paymentOptions = paymentOptions;
    
    [ self.navigationController pushViewController:billingCheckOutController animated:YES];
    
    billingCheckOutController.subTotalValue = self.subtotalLabel.text;
    billingCheckOutController.estimatedSalesTaxValue = self.estimateSalesTaxLabel.text;
    billingCheckOutController.shippingTotalValue = self.shippingTotalLabel.text;
    billingCheckOutController.orderTotalValue = self.orderTotalLabel.text;
    billingCheckOutController.discountTotalValue= self.discountLabel.text;
    
    //mkl adding payment options
//    billingCheckOutController.paymentOptions = paymentOptions;
////    billingCheckOutController.dataShippingOptions = self.dataShippingOptions;
//    
//    [ self.navigationController pushViewController:billingCheckOutController animated:YES];
}
@end
