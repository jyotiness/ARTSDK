//
//  PAABillingAddressViewController.m
//  PhotosArt
//
//  Created by Anuj Agarwal on 10/09/12.
//  Copyright (c) 2012 Ness Technologies. All rights reserved.
//

#import "ACBillingAddressViewController.h"
#import "UIColor+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "ACOrderConfirmationViewController.h"
#import "ACCustomBillingCell.h"
#import "ACWebViewController.h"
#import "ArtAPI.h"
#import "ACCheckoutTextField.h"
#import "SVProgressHUD.h"
#import "NSString+Additions.h"
#import "Analytics.h"
#import "ACKeyboardToolbarView.h"
#import "NSString+Additions.h"
#import "AccountManager.h"
#import "CardIOPaymentViewController.h"

#ifdef SUPPORT_LILITAB_CARD_READER
#import "LTMagTekReader.h"
#endif

#define  CHECKOUT_PICKER_HEIGHT 256
#define  COUNTRY_PICKER_TAG 35
#define  STATE_PICKER_TAG 38
#define  CARD_TYPE_PICKER_TAG 10
#define  DATE_TYPE_PICKER_TAG 12
#define  NATIVE_PHONE_HEIGHT 480

#ifdef SUPPORT_LILITAB_CARD_READER
@interface ACBillingAddressViewController () <ACKeyboardToolbarDelegate,LTDeviceDelegate>
#else
@interface ACBillingAddressViewController () <ACKeyboardToolbarDelegate>
#endif
{
    BOOL mCountryPickerInvoked;
}
@property (nonatomic, retain) ACKeyboardToolbarView *inputAccView;
#ifdef SUPPORT_LILITAB_CARD_READER
@property (strong, nonatomic) LTMagTekReader *cardReader;
#endif
@property (nonatomic,copy) NSString *creditCardString;
@property (nonatomic, readwrite) BOOL maskCreditCard;
@end

@implementation ACBillingAddressViewController
@synthesize usesAddressFromShpping,resultString,resultString2,phoneField,selectedIndexPath,stateValue,selectedCardTypeIndex;
@synthesize billingAddressTableView,cardNumber,expDate,securityCode,dataCartItems,emailAddress,expDatePickerView,pickerHolderView,countries,states;
@synthesize failedTextField = mFailedTextField,cardTypeButton,countryButton;
@synthesize discountTotalLabel,expDateValue,stateButton,countryPickerValue,statePickerValue,tagFromPicker,btnDone,btnPrev,btnNext,inputAccView;
@synthesize txtActiveField,firstNameTextField,address1TextField,address2TextField,companyTextField,zipTextField,cityTextField,stateTextField;
@synthesize cardTypes,stateCode,stateFieldValue,stateValueToPassOrderConfirmationScreen,cityArray,zipUnderValidation,currentActiveTag;
@synthesize company = company_ ;
@synthesize footerBillingAddressVC,shipAddressSwitch,selectedCountryCode;
@synthesize countryNamesArray,countryIDArray,zipLabelText,phoneValidationRequired,stateValidationRequired,willShowCityAndState;

@synthesize phone = phone_ ;
@synthesize orderTotalLabel;
@synthesize shippingTotalLabel;
@synthesize subTotalLabel,selectedCountryIndex,selectedStateIndex;
@synthesize estimatedSalesTax,cardTypeField,cardNumberField,expDateField,securityCodeField,cardTypePickerView,dateColumn,yearColumn;
@synthesize firstName,lastName,addressLine1,addressLine2,city,postalCode,numberOfSections,cardType,lastNameTextField,contactAdresses;
@synthesize paymentOptions;

@synthesize subTotalValue;
@synthesize estimatedSalesTaxValue;
@synthesize shippingTotalValue;
@synthesize orderTotalValue;
@synthesize discountTotalValue;

@synthesize countryIndexPath;
@synthesize stateIndexPath;
@synthesize isUSAddressInvalid;



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notifications

-(void)keyboardWillShow:(NSNotification *)notiFication
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
//        CGRect rect = self.billingAddressTableView.frame;
//        
//        //iPhone5 compatibility
//        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height*[UIScreen mainScreen].scale;
//        if(screenHeight == 480){
//            //iphone no retina
//            rect.size.height = 416-258;
//        }else if(screenHeight == 960){
//            //iphone with retina
//            rect.size.height = 416-258;
//        }else{
//            //iphone5
//            rect.size.height = 504 - 258;
//        }
//        
//        self.billingAddressTableView.frame = rect;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 270, 0.0);
        self.billingAddressTableView.contentInset = contentInsets;
        self.billingAddressTableView.scrollIndicatorInsets = contentInsets;
        [self.billingAddressTableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else {
        // Adjust table to fit keyboard
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 245, 0.0);
        self.billingAddressTableView.contentInset = contentInsets;
        self.billingAddressTableView.scrollIndicatorInsets = contentInsets;
        // Solution from : http://imobiledevelopment.blogspot.com/2012/02/show-uitableview-textfield-cell-above.html
        [self.billingAddressTableView scrollToRowAtIndexPath:self.selectedIndexPath
                                             atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

-(void)keyboardWillHide:(NSNotification *)notiFication
{
//    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
//        CGRect rect = self.billingAddressTableView.frame;
//        
//        //iPhone5 compatibility
//        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height*[UIScreen mainScreen].scale;
//        if(screenHeight == 480){
//            //iphone no retina
//            rect.size.height = 416;
//        }else if(screenHeight == 960){
//            //iphone with retina
//            rect.size.height = 416;
//        }else{
//            //iphone5
//            rect.size.height = 504;
//        }
//        
//        self.billingAddressTableView.frame = rect;
//    } else {
        // Adjust table to fit keyboard
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        self.billingAddressTableView.contentInset = contentInsets;
        self.billingAddressTableView.scrollIndicatorInsets = contentInsets;
//    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self= [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.usesAddressFromShpping = NO;
        self.resultString = @"01";
        self.resultString2 = [ArtAPI getCurrentYear];
        isDoingValidation = NO;
        isStateFieldHavingText = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = [ACConstants getLocalizedStringForKey:@"&&_CHECKOUT" withDefaultValue:@"ART.COM CHECKOUT"];

    [super viewDidLoad];
    
    self.currentActiveTag = -1;
    
    
    if([self canPerformAction:@selector(setEdgesForExtendedLayout:) withSender:self]){
        [self setEdgesForExtendedLayout:(UIRectEdgeBottom|UIRectEdgeLeft|UIRectEdgeRight)];
    }
    // Listen for notification kACNotificationDismissModal
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissModal) name:kACNotificationDismissModal object:nil];
    
    //[self createInputAccessoryViewIsModal:YES];
    CGFloat screenWidth = CGRectGetWidth([self.view getCurrentScreenBoundsDependOnOrientation]);
    if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ){
        screenWidth = self.view.bounds.size.width;
    }
    self.inputAccView = [[ACKeyboardToolbarView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    self.inputAccView.toolbarDelegate = self;

    
    [self preLoadEmailFromShipping];
    self.willShowCityAndState = NO;
    
    [self.billingViewBackButton.titleLabel setFont:[ACConstants getStandardBoldFontWithSize:23.0f]];
    [self.closeButton.titleLabel setFont:[ACConstants getStandardBoldFontWithSize:23.0f]];
    [self.billingViewHeader setFont:[ACConstants getStandardBoldFontWithSize:30.0f]];
    
    //[self.orderConfirmButton setBackgroundColor:[UIColor colorWithRed:0.353 green:0.718 blue:0.906 alpha:1.000]];
    [self.orderConfirmButton setBackgroundColor:[ACConstants getPrimaryButtonColor]];
    [self.orderConfirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.orderConfirmButton.titleLabel.font = [ACConstants getStandardBoldFontWithSize:30.0f];
    
    CALayer *btnLayer = [self.orderConfirmButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:2.0f];

    
    NSMutableArray *yearValuesArray = [[NSMutableArray alloc] init];
    NSString *currentYear = [ArtAPI getCurrentYear];
    for(int i=0;i<50;i++)
    {
        [yearValuesArray addObject:[NSString stringWithFormat:@"%d",([currentYear intValue]+i)]];
    }
    
    self.dateColumn=[NSArray arrayWithObjects:@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",nil];
    self.yearColumn=[NSArray arrayWithArray:yearValuesArray];
    yearValuesArray = nil;
    
    if([ArtAPI isDeviceConfigForUS])
    {
        self.selectedCountryIndex = 0;
        self.countryPickerValue = @"United States";
    }
    else
    { 
        self.selectedCountryIndex = -1;
        self.countryPickerValue = [ACConstants getLocalizedStringForKey:@"SELECT_COUNTRY" withDefaultValue:@"Select Country"];
    } 
    self.selectedStateIndex = -1;
    self.selectedCardTypeIndex = -1;
    
    self.firstName = @"" ;
    self.lastName = @"" ;
	self.company = @"" ;
	self.phone = @"" ;
    self.zipLabelText = [ACConstants getLocalizedStringForKey:@"ZIP_POSTAL_CODE" withDefaultValue:@"ZIP/Postal Code"];
    self.addressLine1 = @"";
    self.addressLine2 = @"";
    self.city = @"";
    self.postalCode = @"";
    self.cardNumber = @"" ;
   	self.expDate = @"" ;
 	self.securityCode = @"" ;
    self.cardType = [ACConstants getLocalizedStringForKey:@"SELECT_CARD_TYPE" withDefaultValue:@"Select Card Type"];
    self.statePickerValue = [ACConstants getLocalizedStringForKey:@"SELECT_STATE" withDefaultValue:@"Select State"];
    mCountryPickerInvoked = NO;
    self.billingViewHeader.text = [ACConstants getLocalizedStringForKey:@"&&_CHECKOUT" withDefaultValue:@"ART.COM CHECKOUT"];
    [self.billingViewBackButton setTitle:[ACConstants getLocalizedStringForKey:@"BACK" withDefaultValue:@"Back"] forState:UIControlStateNormal];
    [self.billingViewBackButton setTitle:[ACConstants getLocalizedStringForKey:@"BACK" withDefaultValue:@"Back"] forState:UIControlStateHighlighted ];

    self.numberOfSections = [NSMutableArray arrayWithObjects:ACLocalizedString(@"CREDIT_CARD_DETAILS", @"Credit Card Details"),ACLocalizedString(@"SWITCH_SHIPPING", @"Switch for same as Shipping Details"),ACLocalizedString(@"SHIPPING_ADDRESS_DETAILS", @"Shipping Address Details"), nil];
    
    //MKL - SETTING PAYMENT TYPES IN THE VIEW WILL APPEAR SO THE VARIABLE IS SET
    //self.cardTypes = [NSArray arrayWithObjects:ACLocalizedString(@"AMERICAN_EXPRESS", @"American Express"),ACLocalizedString(@"DISCOVER", @"Discover"),ACLocalizedString(@"MASTERCARD", @"MasterCard"),ACLocalizedString(@"VISA", @"Visa"),nil];
    
    //self.cardTypes = [self getCreditCardDisplayArrayFromPaymentTypes];
    
    [self.orderConfirmButton setTitle:[ACConstants getLocalizedStringForKey:@"PLACE_ORDER" withDefaultValue:@"PLACE ORDER"] forState:UIControlStateNormal];
    [self.orderConfirmButton setTitle:[ACConstants getLocalizedStringForKey:@"PLACE_ORDER" withDefaultValue:@"PLACE ORDER"] forState:UIControlStateHighlighted];

    self.subtotalTitleLabel.text = [ACConstants getLocalizedStringForKey:@"SUBTOTAL" withDefaultValue:@"Subtotal"];
    self.estimatedSalesTaxTitle.text = [ACConstants getLocalizedStringForKey:@"ESTIMATED_SALES_TAX" withDefaultValue:@"Estimated Sales Tax"];
    self.shippingTitleLabel.text = [ACConstants getLocalizedStringForKey:@"SHIPPING" withDefaultValue:@"Shipping"];
    self.discountTitleLabel.text = [ACConstants getLocalizedStringForKey:@"DISCOUNT" withDefaultValue:@"Discount"];
    self.totalTitleLabel.text = [ACConstants getLocalizedStringForKey:@"TOTAL" withDefaultValue:@"Total"];
    
    self.billingAddressTableView.tableFooterView=self.footerBillingAddressVC;
    [self.billingAddressTableView setBackgroundColor:[UIColor clearColor]];
    
//    self.cityTextField = [[ ACCheckoutTextField alloc] init];
//    self.zipTextField = [[ ACCheckoutTextField alloc] init];
    
    self.countries = [ArtAPI getCountries];
    self.states = [ArtAPI getStates];
    self.tagFromPicker = COUNTRY_PICKER_TAG;
    
    [ self prepareCountryList];
    
    self.screenName = @"Billing Address Screen";
    _creditCardString = [ACConstants getLocalizedStringForKey:@"CREDIT_CARD" withDefaultValue:@"CREDIT CARD"];
    
    // Intitlize Masking of Credit Card to False
    _maskCreditCard = NO;

    AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
    if(AppLocationSwitchArt == currAppLoc){ //Address Prepopulate
        
        NSDictionary *workingPack = [AccountManager sharedInstance].purchasedWorkingPack;
        if(workingPack){
            NSString *shippingAddressID = [workingPack objectForKey:@"shippingAddressId"];
            
            if(shippingAddressID){
                
                NSDictionary *shippingAddress = [[AccountManager sharedInstance]getAddressForAddressID:shippingAddressID];
                [self prePopulateAddressFromDict:shippingAddress];
            }
            else
            {
                [self getAddressFromAddress];
            }
        }
        else{
            [self getAddressFromAddress];
        }
    }
}

-(void)getAddressFromAddress
{
    NSDictionary *sddressDict = [[AccountManager sharedInstance] getAddressForAddressID: [[AccountManager sharedInstance] billingAddressIdentifier]];
    [self prePopulateAddressFromDict:sddressDict];
}

-(void)prePopulateAddressFromDict:(NSDictionary*)shippingAddress
{
    if(shippingAddress)
    {
        NSString *firstNameSA = [[shippingAddress objectForKeyNotNull:@"Name"] objectForKeyNotNull:@"FirstName"];
        NSString *lastNameSA = [[shippingAddress objectForKeyNotNull:@"Name"] objectForKeyNotNull:@"LastName"];
        NSString *companyNameSA = [shippingAddress objectForKeyNotNull:@"CompanyName"];
        NSString *phoneSA = [[shippingAddress objectForKeyNotNull:@"Phone"] objectForKeyNotNull:@"Primary"];
        NSString *address1SA = [shippingAddress objectForKeyNotNull:@"Address1"];
        NSString *address2SA = [shippingAddress objectForKeyNotNull:@"Address2"];
        NSString *citySA = [shippingAddress objectForKeyNotNull:@"City"];
        NSString *stateSA = [shippingAddress objectForKeyNotNull:@"State"];
        NSString *zipSA = [shippingAddress objectForKeyNotNull:@"ZipCode"];
        NSString *countrySA = [shippingAddress objectForKeyNotNull:@"Country"];
        
        self.firstName = firstNameSA;
        self.lastName = lastNameSA;
        self.company = companyNameSA;
        self.phone = phoneSA;
        self.addressLine1 = address1SA;
        self.addressLine2 = address2SA;
        self.city = citySA;
        self.stateValue = stateSA;
        self.postalCode = zipSA;
        self.countryPickerValue = countrySA;
        self.selectedCountryCode = [shippingAddress objectForKeyNotNull:@"CountryIsoA2"];
        self.emailAddress = [[AccountManager sharedInstance] userEmailAddress];
        self.willShowCityAndState = YES;
        
        if ([self.selectedCountryCode isEqualToString:@"US"])
        {
            if([stateSA isEqualToString:@""])
            {
                if(zipSA && 5 == zipSA.length)
                {
                    [ self cityAndStateSuggestionForZip:zipSA];
                }
            }
            else{
                NSDictionary *stateDict = [ self getStateForCode:self.stateValue];
                NSString *stateName = [stateDict objectForKeyNotNull:@"Name"];
                if(stateName)
                {
                    self.selectedStateIndex = [ self.states indexOfObject:stateDict];
                    self.statePickerValue = [stateDict objectForKeyNotNull:@"Name"];
                }
            }
        }
        
        [self.billingAddressTableView reloadData];
    }
}

+(int)getCCIndexFromCCTypeID:(NSString *)ccTypeID fromPaymentOptions:(NSArray *)paymentOptions{
    
    int notFoundIndex = -1;
    NSString *tempPaymentOptionType = @"";
    int trackIndex = 0;
    
    for(NSDictionary *dict in paymentOptions){
        tempPaymentOptionType = [NSString stringWithFormat:@"%@", [dict objectForKeyNotNull:@"CreditCardType"]];
        if([tempPaymentOptionType isEqualToString:ccTypeID]){
            //it is a match
            return trackIndex;
        }else{
            trackIndex++;
        }
    }
    
    return notFoundIndex;
}

-(NSArray *) getCreditCardDisplayArrayFromPaymentTypes{
    
    NSMutableArray *retArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSString *tempPaymentOptionName = @"";
    
    for(NSDictionary *dict in self.paymentOptions){
        tempPaymentOptionName = [dict objectForKeyNotNull:@"DisplayName"];
        if(tempPaymentOptionName != nil){
            if(![tempPaymentOptionName isEqualToString:@""]){
                //add it
                [retArray addObject:tempPaymentOptionName];
            }
        }
    }
    
    return retArray;
}

-(void)viewWillAppear:(BOOL)animated
{
    [ super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    UIButton *barBackButton = [ACConstants getBackButtonForTitle:[ACConstants getLocalizedStringForKey:@"BACK" withDefaultValue:@"Back"]];
    [barBackButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:barBackButton];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    self.navigationItem.hidesBackButton = YES;
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoButton setFrame:CGRectMake(4.0, 4.0f, 24.0f, 24.0f)];
    [infoButton setImage:[UIImage imageNamed:ARTImage(@"InfoButton23")] forState:UIControlStateNormal];
    [infoButton addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.navigationItem.rightBarButtonItem = infoBarButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //MKL SET PAYMENT TYPES DROPDOWN
    if(self.paymentOptions == nil){
        [self setHardCodedCreditCardTypes];
    }else if([self.paymentOptions count] == 0){
        [self setHardCodedCreditCardTypes];
    }
    
    self.cardTypes = [self getCreditCardDisplayArrayFromPaymentTypes];
    

    #ifdef SUPPORT_LILITAB_CARD_READER
    // Initilize Lilitab Card Reader
    _cardReader = [[LTMagTekReader alloc] initWithDelegate:self andProtocolString:@"com.lilitab.p1"];
    #endif
    
    
    //PHOTOIOS-1333 edited by jyoti
    if([self.pickerHolderView isDescendantOfView:self.view])
    {
        [self.pickerHolderView removeFromSuperview];
    }
    
    [self configureThePicker];
    
   
}

-(void)setHardCodedCreditCardTypes{
    NSLog(@"No card types retrieved from API call.  Using Hard Coded values");
    
    //self.cardTypes = [NSArray arrayWithObjects:ACLocalizedString(@"AMERICAN_EXPRESS", @"American Express"),ACLocalizedString(@"DISCOVER", @"Discover"),ACLocalizedString(@"MASTERCARD", @"MasterCard"),ACLocalizedString(@"VISA", @"Visa"),nil];
    
    NSMutableArray *hardCodedPaymentOptions = [[NSMutableArray alloc] initWithCapacity:4];
    
    NSMutableDictionary *tempDict;
    
    tempDict=[[NSMutableDictionary alloc] init];
    [tempDict setObject:@"Visa" forKey:@"DisplayName"];
    [tempDict setObject:@"5" forKey:@"CreditCardType"];
    [hardCodedPaymentOptions addObject:tempDict];
    
    tempDict=[[NSMutableDictionary alloc] init];
    [tempDict setObject:@"MasterCard" forKey:@"DisplayName"];
    [tempDict setObject:@"3" forKey:@"CreditCardType"];
    [hardCodedPaymentOptions addObject:tempDict];
    
    tempDict=[[NSMutableDictionary alloc] init];
    [tempDict setObject:@"Discover" forKey:@"DisplayName"];
    [tempDict setObject:@"1" forKey:@"CreditCardType"];
    [hardCodedPaymentOptions addObject:tempDict];
    
    tempDict=[[NSMutableDictionary alloc] init];
    [tempDict setObject:@"American Express" forKey:@"DisplayName"];
    [tempDict setObject:@"0" forKey:@"CreditCardType"];
    [hardCodedPaymentOptions addObject:tempDict];
    
    self.paymentOptions = hardCodedPaymentOptions;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.subTotalLabel.text = self.subTotalValue;
    self.estimatedSalesTax.text = self.estimatedSalesTaxValue;
    self.shippingTotalLabel.text = self.shippingTotalValue;
    self.orderTotalLabel.text = self.orderTotalValue;
    self.discountTotalLabel.text = self.discountTotalValue;
    
    if([self.discountTotalLabel.text isEqualToString:@""])
    {
        //self.fixedPriceDetailsView.frame = NO_DISCOUNT_FRAME;
        CGRect fixedPriceDetailsViewFrame = self.fixedPriceDetailsView.frame;
        fixedPriceDetailsViewFrame.origin.y = 16;
        self.fixedPriceDetailsView.frame = fixedPriceDetailsViewFrame;
        
        self.discountTotalLabel.alpha = 0.0f;
        self.discountTitleLabel.alpha = 0.0f;
    }else{
        //self.fixedPriceDetailsView.frame = DISCOUNT_FRAME;
        CGRect fixedPriceDetailsViewFrame = self.fixedPriceDetailsView.frame;
        fixedPriceDetailsViewFrame.origin.y = 40;
        self.fixedPriceDetailsView.frame = fixedPriceDetailsViewFrame;
    }
    NSDictionary *currentCart = [ArtAPI cart];
    NSDictionary *cartTotal = [currentCart objectForKeyNotNull:@"CartTotal"];
    NSString *shipmentCountry = [[[[currentCart objectForKeyNotNull:@"Shipments"] objectAtIndex:0] objectForKeyNotNull:@"Address"] objectForKeyNotNull:@"CountryIsoA2"];
    shipmentCountry = [[shipmentCountry stringByTrimmingCharactersInSet:[ NSCharacterSet whitespaceCharacterSet]] uppercaseString];
    NSNumber *taxTotal =  [cartTotal objectForKeyNotNull:@"TaxTotal"];
    
    //mkl - probably need to change this United States comparison
    if((![shipmentCountry isEqualToString:@"US"])||([taxTotal floatValue]==0)){
        self.estimatedSalesTax.alpha = 0.0f;
        self.estimatedSalesTaxTitle.alpha = 0.0f;
        CGRect alwaysPriceFrame = self.fixedPriceDetailsView.frame;
        alwaysPriceFrame.origin.y = alwaysPriceFrame.origin.y - 25;
        alwaysPriceFrame.size.height = alwaysPriceFrame.size.height - 25;
        self.fixedPriceDetailsView.frame = alwaysPriceFrame;
    }
    
    [ self.billingAddressTableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    
    #ifdef SUPPORT_LILITAB_CARD_READER
    [self.cardReader tearDown];
    #endif
    
    [ super viewWillDisappear:animated];
}

- (void)dismissModal {
    [[NSNotificationCenter defaultCenter] removeObserver:nil name:kACNotificationDismissModal object:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:nil name:kACNotificationDismissModal object:nil];
    [self setBillingAddressTableView:nil];
    [self setFooterBillingAddressVC:nil];
    [self setDiscountTotalLabel:nil];
    [self setSubTotalLabel:nil];
    [self setEstimatedSalesTax:nil];
    [self setOrderTotalLabel:nil];
    [self setShippingTotalLabel:nil];
    [self setOrderConfirmButton:nil];
    [self setBillingViewHeader:nil];
    [self setBillingViewBackButton:nil];
    [self setFixedPriceDetailsView:nil];
    [self setDiscountTitleLabel:nil];
    [self setEstimatedSalesTaxTitle:nil];
    [super viewDidUnload];
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


-(void)preLoadEmailFromShipping
{
    NSDictionary *cart = [ArtAPI cart];
    self.emailAddress = [cart objectForKeyNotNull:@"CustomerEmailAddress"];
}

/*
-(void) countryListDidFinishLoading:(id)JSON
{
    self.countries = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"Countries"];
    
    if (self.countries&&![self.countries isKindOfClass:[NSNull class]]) {
        if(self.countries.count>0){
            [ArtAPI setCountries:self.countries];
            self.tagFromPicker = COUNTRY_PICKER_TAG;
            [self configureThePicker];
            [SVProgressHUD showWithStatus:[ACConstants getUpperCaseStringIfNeededForString:[ACConstants getLocalizedStringForKey:@"LOADING_STATES" withDefaultValue:@"LOADING STATES..."]] maskType:SVProgressHUDMaskTypeClear];
            
            [ self prepareCountryList];
            
            NSString *countryCode = @"US";
//            for (NSDictionary *country in self.countries)
//             {
//             NSString *countryName=self.countryPickerValue;
//             if ([[[country objectForKeyNotNull:@"Name"] uppercaseString] isEqualToString:[countryName uppercaseString]])
//             {
//             countryCode = [country objectForKeyNotNull:@"IsoA2"];
//             break;
//             }
//             }
 
            [ArtAPI
             requestForCartGetActiveStateListByTwoDigitIsoCountryCode:countryCode success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
                 [self stateListDidFinishLoading: JSON];
             }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
                 NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
                 [SVProgressHUD dismiss];
             }];
        }else{
            self.countries = nil;
            [SVProgressHUD dismiss];
        }
    }else{
        self.countries = nil;
        [SVProgressHUD dismiss];
    }
}
 
 */

-(void)prepareCountryList
{
    NSMutableArray *countryNameArray = [[NSMutableArray alloc] initWithCapacity:self.countries.count];
    NSMutableArray *countryIdArray = [[NSMutableArray alloc] initWithCapacity:self.countries.count];
    //[countryNameArray addObject:@"United States"];
    //[countryIdArray addObject:@"US"];
    
    for (NSDictionary *dict in self.countries)
    {
        NSString *name = [dict objectForKeyNotNull:@"Name"];
        //if (![name isEqualToString:@"United States"])
        //{
            [countryNameArray addObject:name];
            [countryIdArray addObject:[dict objectForKeyNotNull:@"IsoA2"]];
        //}
    }

    self.countryNamesArray = countryNameArray;
    self.countryIDArray = countryIdArray;
    
    AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
    
    if(AppLocationFrench == currAppLoc)
    {
        int countryCodeIndex = [countryIdArray indexOfObject:@"FR"];
        if(NSNotFound != countryCodeIndex)
        {
            self.selectedCountryCode = [self.countryIDArray objectAtIndex:countryCodeIndex];
            self.selectedCountryIndex = countryCodeIndex;
            self.countryPickerValue = [self.countryNamesArray objectAtIndex:countryCodeIndex];
            self.willShowCityAndState = YES;
            [self validateSelectedCountry:countryCodeIndex];
        }else{
            self.selectedCountryCode = nil;
            self.selectedCountryIndex = -1;
            self.countryPickerValue = [ACConstants getLocalizedStringForKey:@"SELECT_COUNTRY"  withDefaultValue:@"Select Country"];
        }
    }
    else if(AppLocationGerman == currAppLoc)
    {
        int countryCodeIndex = [countryIdArray indexOfObject:@"DE"];
        if(NSNotFound != countryCodeIndex)
        {
            self.selectedCountryCode = [self.countryIDArray objectAtIndex:countryCodeIndex];
            self.selectedCountryIndex = countryCodeIndex;
            self.countryPickerValue = [self.countryNamesArray objectAtIndex:countryCodeIndex];
            self.willShowCityAndState = YES;
            [self validateSelectedCountry:countryCodeIndex];
        }else{
            self.selectedCountryCode = nil;
            self.selectedCountryIndex = -1;
            self.countryPickerValue = [ACConstants getLocalizedStringForKey:@"SELECT_COUNTRY"  withDefaultValue:@"Select Country"];
        }
    }
    else
    {
        if([ArtAPI isDeviceConfigForUS])
        {
            int countryCodeIndex = [countryIdArray indexOfObject:@"US"];
            if(NSNotFound != countryCodeIndex)
            {
                self.selectedCountryCode = @"US";
                self.selectedCountryIndex = countryCodeIndex;
                self.countryPickerValue = [self.countryNamesArray objectAtIndex:countryCodeIndex];
                self.willShowCityAndState = NO;
                [self validateSelectedCountry:countryCodeIndex];
            }else{
                self.selectedCountryCode = nil;
                self.selectedCountryIndex = -1;
                self.countryPickerValue = [ACConstants getLocalizedStringForKey:@"SELECT_COUNTRY"  withDefaultValue:@"Select Country"];
            }
        }
        else
        {
            self.selectedCountryCode = nil;
            self.selectedCountryIndex = -1;
            self.countryPickerValue = [ACConstants getLocalizedStringForKey:@"SELECT_COUNTRY"  withDefaultValue:@"Select Country"];
        }
    }
    
    //in order to get the field changes
    //[self.billingAddressTableView reloadData];
}


/*
-(void) stateListDidFinishLoading:(id)JSON
{
    [SVProgressHUD dismiss];
    self.states = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"States"];
    [ self.billingAddressTableView reloadData];
    self.tagFromPicker = STATE_PICKER_TAG;
    
    [ self configureThePicker];
    [ self pickerView:CommonpickerView didSelectRow:self.selectedStateIndex inComponent:0];
    
    NSDictionary *state = nil;
    NSString *stateName=self.statePickerValue;
    
    for (state in self.states)
    {
        if ([[[state objectForKeyNotNull:@"Name"] uppercaseString] isEqualToString:[stateName uppercaseString]])
        {
            stateName = [state objectForKeyNotNull:@"Name"];
            break;
        }
    }
    [stateButton setTitle:stateName forState:UIControlStateNormal];
    [ArtAPI setStates:self.states];
}
*/

- (void) loadData
{
    NSDictionary *cart = [ArtAPI cart];
    
    NSDictionary *cartTotal = [cart objectForKeyNotNull:@"CartTotal"];
    NSArray *shipments = [cart objectForKeyNotNull:@"Shipments"];
    //TODO: Fix UI to support multiple shipments pre order....
    //HACK: UI does not support mulitple shipments so we alwasy take the first one :-(
    
    NSDictionary *aShipment = [shipments objectAtIndex:0];
    
    self.dataCartItems = [aShipment objectForKeyNotNull:@"CartItems"];
    
    NSNumber *discountTotal=[cartTotal objectForKeyNotNull:@"DiscountTotal"];
    
    NSNumber *shippingTotal =  [cartTotal objectForKeyNotNull:@"ShippingTotal"];
    NSNumber *taxTotal =  [cartTotal objectForKeyNotNull:@"TaxTotal"];
    //TODO: Need the api to start passing back the tax rate...
    
    NSNumber *productsTotal =  [cartTotal objectForKeyNotNull:@"Total"];
    
    NSNumber *productsSubTotal = [cartTotal objectForKeyNotNull:@"ProductSubTotal"];
    
    productsSubTotal = [NSNumber numberWithFloat:([productsSubTotal floatValue] + [discountTotal floatValue])];
    
    self.subTotalLabel.text = [NSString formatedPriceFor: productsSubTotal];
    self.estimatedSalesTax.text = [NSString formatedPriceFor: taxTotal];
    self.shippingTotalLabel.text = ([shippingTotal floatValue]==0)?[ACConstants getLocalizedStringForKey:@"FREE" withDefaultValue:@"FREE"]:[NSString formatedPriceFor: shippingTotal];
    self.orderTotalLabel.text = [NSString formatedPriceFor: productsTotal];

    
    //MKL putting in same logic for hiding and showing the discount line
    //still something funky here
    CGFloat shippingDifference = 0.0f;
    NSNumber *normalShippingRate = [NSNumber numberWithFloat:0.0f];
    //int shippingType = [[[[cart objectForKeyNotNull:@"Shipments"] objectAtIndex:0] objectForKeyNotNull:@"ShippingPriority"] intValue];
    
//    for (NSDictionary *shippingData in self.dataShippingOptions){
//        if(shippingType == [[shippingData objectForKeyNotNull:@"ShippingOption"] intValue]){
//            normalShippingRate = [shippingData objectForKeyNotNull:@"ShippingCharge"];
//            break;
//        }
//    }
    
    if([shippingTotal floatValue] < [normalShippingRate floatValue]){
        shippingDifference = [normalShippingRate floatValue] - [shippingTotal floatValue];
    }
    
    if(shippingDifference > 0){
        discountTotal = [NSNumber numberWithFloat:([discountTotal floatValue] - shippingDifference)];
    }
    
    //hide discount if it is zero
    if([discountTotal floatValue] > 0){
        self.discountTotalLabel.alpha = 1.0f;
        self.discountTitleLabel.alpha = 1.0f;
        self.discountTotalLabel.text= [NSString stringWithFormat:@"-%@",[NSString formatedPriceFor:discountTotal]];

        //CGRect alwaysPriceViewFrame = self.alwaysPriceView.frame;
        //alwaysPriceViewFrame.origin.y = 61;
        //self.alwaysPriceView.frame = alwaysPriceViewFrame;
    }else{
        self.discountTotalLabel.text= @"";
        self.discountTotalLabel.alpha = 0.0f;
        self.discountTitleLabel.alpha = 0.0f;
        //CGRect alwaysPriceViewFrame = self.alwaysPriceView.frame;
        //alwaysPriceViewFrame.origin.y = 36;
        //self.alwaysPriceView.frame = alwaysPriceViewFrame;
    }
    
}

#pragma mark- Phone Book Contacts
-(void)phoneBookContacts
{
    [self.view endEditing:YES];
    
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    peoplePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentViewController:peoplePicker animated:YES completion:nil];
}

#pragma mark- Scan Credit Card
-(void)scanCreditCard
{
    
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_SCAN_CARD_PRESS];
    

    [self.view endEditing:YES];
    

    [SVProgressHUD showWithStatus:[ACConstants getUpperCaseStringIfNeededForString:[ACConstants getLocalizedStringForKey:@"LOADING_CARD_SCANNER" withDefaultValue:@"Loading Card Scanner"]] maskType:SVProgressHUDMaskTypeClear];
    
    __unused NSString *cardIOToken = [ACConstants getCardIOToken]; // CS;- not required now as we are using the latest CardIO classes from PayPal iOS SDK

    [[UINavigationBar appearance] setTintColor:[ACConstants getPrimaryLinkColor]];
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.useCardIOLogo = YES;
    scanViewController.keepStatusBarStyle = NO;
    scanViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    //mkl - this doesnt seem to work to change the link button color in iPad version of card.io
    //scanViewController.navigationBar.tintColor = [ACConstants getPrimaryLinkColor];
    
    //scanViewController.appToken = cardIOToken;// CS;- appToken is not required it has been removed in the latest PayPal SDK
    
    [self presentViewController:scanViewController animated:YES completion:^(void)
    {
        [SVProgressHUD dismiss];
    }];

}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.numberOfSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
        {
            return 4;
            break;
        }
        case 1:{
            return 1;
            break;
        }
        case 2:{
            return self.willShowCityAndState?10:8;
            break;
        }
        default:{
            return 0;
            break;
        }
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    if (section== 0)
    {
        
        //MKL Add SCAN Card
        UIButton *buttonImage = [UIButton buttonWithType:UIButtonTypeCustom];
        UIButton *buttonText = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *scanCamera;
        
        scanCamera = [UIImage imageNamed:ARTImage(@"CameraButton25")];

        [buttonImage setBackgroundImage:scanCamera forState:UIControlStateNormal];

        NSString *scanTitle = [ACConstants getLocalizedStringForKey:@"SCAN_CARD" withDefaultValue:@"Scan your card"];
        CGSize size = CGSizeZero;
        size = [scanTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]}];
        
        buttonImage.frame = CGRectMake(10, 8, 39, 25);
        buttonText.frame = CGRectMake(42, 8, size.width, 25);
        buttonText.titleLabel.textAlignment = NSTextAlignmentLeft;
        
        [buttonText.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [buttonText setTitleColor:[ACConstants getPrimaryLinkColor] forState:UIControlStateNormal];
        [buttonText setTitleColor:[ACConstants getDisabledPrimaryLinkColor] forState:UIControlStateDisabled];
        [buttonText setTitleColor:[ACConstants getHighlightedPrimaryLinkColor] forState:UIControlStateHighlighted];
        
        [buttonText setTitle:scanTitle forState:UIControlStateNormal];
        
        [buttonImage addTarget:self action:@selector(scanCreditCard) forControlEvents:UIControlEventTouchUpInside];
        [buttonText addTarget:self action:@selector(scanCreditCard) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:buttonImage];
        [view addSubview:buttonText];
        
    }
    return view;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 90)];
    
    if (section==0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 40)];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.font=[UIFont boldSystemFontOfSize:label.font.pointSize+3];
        label.textAlignment = NSTextAlignmentCenter;
        [label setFont:[ACConstants getStandardBoldFontWithSize:26.0f]];
        [label setTextColor:[UIColor artPhotosSectionTextColor]];
        label.text = _creditCardString;
        [view addSubview:label];
        
        //MKL add CC image
        //switch CC image based on app
        UIImage *myImage;
        
        AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
        
        if(AppLocationFrench == currAppLoc)
        {
            myImage = [UIImage imageNamed:ARTImage(@"icon_creditCardsFR")];
        }
        else if(AppLocationGerman == currAppLoc)
        {
            myImage = [UIImage imageNamed:ARTImage(@"icon_creditCardsEuro")];
        }
        else
        {
            //for GB use card image with MAESTRO
            NSString *currentlyUsedLocale = [[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENT_LOCATION_IN_USE"];
            
            //NSLog(@"Currently used locale is %@",currentlyUsedLocale);
            if([[currentlyUsedLocale lowercaseString] isEqualToString:@"gb"]){
                myImage = [UIImage imageNamed:ARTImage(@"icon_creditCardsGB")];
            }else{
                myImage = [UIImage imageNamed:ARTImage(@"icon_creditCards")];
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
        imageView.frame = CGRectMake(0,52,self.view.frame.size.width,30);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [view addSubview:imageView];
        
        return view;
    }
    else if (section == 1)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.font=[UIFont boldSystemFontOfSize:label.font.pointSize+3];
        label.textAlignment = NSTextAlignmentCenter;
        [label setFont:[ACConstants getStandardBoldFontWithSize:26.0f]];
        [label setTextColor:[UIColor artPhotosSectionTextColor]];
        label.text = [ACConstants getLocalizedStringForKey:@"BILLING_ADDRESS" withDefaultValue:@"BILLING ADDRESS"];
        [view addSubview:label];
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==1)
    {
        return 50.0;
    }
    if (section==0) {
        return 90.0;
    }
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==0)
    {
        return  40.0f;
    }
    return 0.0f;
}

-(CGFloat) widthForTableView: (UITableView*) tableView {
    CGFloat groupedStyleMarginWidth;
    CGFloat tableViewWidth = tableView.frame.size.width;
    
    
    if([ACConstants isArtCircles]){
        groupedStyleMarginWidth = 0.0f;
    }else{
        if (tableView.style == UITableViewStyleGrouped) {
            if (tableViewWidth > 20)
                groupedStyleMarginWidth = (tableViewWidth < 400) ? 10 : MAX(31, MIN(45, tableViewWidth*0.06));
            else
                groupedStyleMarginWidth = tableViewWidth - 10;
            if((tableViewWidth < 400)&&IS_IOS_7_ABOVE){
                groupedStyleMarginWidth = 0;
            }
        }
        else
            groupedStyleMarginWidth = 0.0;
    }
    
    return  tableView.frame.size.width - groupedStyleMarginWidth*2;
    
    //return groupedStyleMarginWidth;
}

- (void)resetTextFields
{
    self.cardNumberField = nil;
    self.expDateField = nil;
    self.securityCodeField = nil;
    self.firstNameTextField = nil;
    self.lastNameTextField = nil;
    self.companyTextField = nil;
    self.address1TextField = nil;
    self.address2TextField = nil;
    self.zipTextField = nil;
    self.phoneField = nil;
    self.cityTextField = nil;
    self.stateTextField = nil;
    self.phoneField = nil;
    self.cardTypeButton = nil;
    self.countryButton = nil;
    self.stateButton = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"ACCustomBillingCell";
    ACCustomBillingCell * cell = (ACCustomBillingCell*)[tableView
                                                        dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell==nil) {
        
        cell = (ACCustomBillingCell *)[[ACBundle loadNibNamed:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ACCustomBillingCell-iPad" :@"ACCustomBillingCell" owner:cell options:nil] objectAtIndex:0];
        cell.textField.delegate=self;
        cell.textField.font = [UIFont systemFontOfSize:15.0f];
        cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    cell.textField.cellIndexPath = indexPath;
    
    // Make cell unselectable
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    int rownum = indexPath.row;
    cell.textField.hidden = NO;
    cell.textLabel.hidden = NO;
    cell.textField.delegate=self;
    cell.pickerButton.hidden = YES;
    cell.contactPickerButton.hidden=YES;
    cell.sameShippingAddress.hidden=YES;
    cell.scanCardButton.hidden=YES;
    [cell.textField setKeyboardType:UIKeyboardTypeDefault];

    CGRect textFrame = cell.textField.frame;
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        textFrame.origin.x = 156;
    } else {
        textFrame.origin.x = 135;
    }
    cell.textField.frame = textFrame;
        
    if(0 == indexPath.section)
    {
        switch(rownum)
        {
            case 0:
                cell.pickerButton.tag = CARD_TYPE_PICKER_TAG;
                cell.pickerButton.hidden = NO;
                cell.textField.hidden = YES;
                cell.textLabel.hidden = YES;
                cell.cellTitleButton.hidden = YES;
                if(-1 != self.selectedCardTypeIndex) {
                    [cell.pickerButton setTitle:[ self.cardTypes objectAtIndex:self.selectedCardTypeIndex] forState:UIControlStateNormal];
                }
                [cell.pickerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                cell.pickerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                CGRect pickerButtonFrame = cell.pickerButton.frame;
                cell.pickerButton.frame = pickerButtonFrame;
                cell.textLabel.textColor = (![cell.textField validateAsNotEmpty] && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                self.cardTypeButton = cell.pickerButton;
                [self.cardTypeButton setTitle:self.cardType forState:UIControlStateNormal];
                
                self.cardTypeButton.selected = isDoingValidation && (-1 == self.selectedCardTypeIndex);
                [cell.pickerButton addTarget:self
                                      action:@selector(pickerPressed:)
                            forControlEvents:UIControlEventTouchUpInside];
                
                break ;
            case 1:
                self.cardNumberField = cell.textField;
                cell.textLabel.text = [ACConstants getLocalizedStringForKey:@"CARD_NUMBER" withDefaultValue:@"Card Number"];
                [cell.textField setKeyboardType:UIKeyboardTypeNumberPad];
                cell.textField.text=self.cardNumber;
                cell.textField.tag=11;
                cell.cellTitleButton.hidden = NO;
                cell.textField.textAlignment = NSTextAlignmentRight;
                [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                cell.textField.placeholder=@"";
                
                cell.textLabel.textColor = ((![cell.textField validateAsNotEmpty] && isDoingValidation) || ([cell.textField validateAsNotEmpty] && ![cell.textField validateAsCCNumber]))?[UIColor redColor]:[ UIColor blackColor];
                if( _maskCreditCard){
                     cell.textField.text=[self.cardNumber maskCreditCard];
                }
                
                cell.scanCardButton.hidden=YES;
                
                break ;
            case 2:
                self.expDateField = cell.textField;
                cell.textLabel.text = [ACConstants getLocalizedStringForKey:@"EXP_DATE" withDefaultValue:@"Exp. Date"];
                cell.textField.text=self.expDate;
                cell.textField.tag=12;
                cell.cellTitleButton.hidden = NO;
                cell.textField.textAlignment = NSTextAlignmentRight;
                cell.textField.placeholder = [ACConstants getLocalizedStringForKey:@"MONTH_YEAR" withDefaultValue:@"Month / Year"];
                cell.textLabel.textColor = (((![self.expDateField validateAsNotEmpty])||([self.resultString2 isEqualToString:[ArtAPI getCurrentYear]]&&([self.resultString intValue]<[[ArtAPI getCurrentMonth] intValue]))) && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                [cell.pickerButton addTarget:self
                                      action:@selector(pickerPressed:)
                            forControlEvents:UIControlEventTouchUpInside];
                break ;
            case 3:
                cell.textLabel.text = [ACConstants getLocalizedStringForKey:@"SECURITY_CODE_CVV" withDefaultValue:@"Security Code / CVV"];
                cell.textField.text=self.securityCode;
                [cell.textField setKeyboardType:UIKeyboardTypeNumberPad];
                cell.textField.tag=13;
                cell.cellTitleButton.hidden = NO;
                cell.textField.textAlignment = NSTextAlignmentRight;
                [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                cell.textField.placeholder=@"";
                self.securityCodeField=cell.textField;
                
                if( _maskCreditCard ){
                    cell.textField.secureTextEntry = YES;
                }

                BOOL validationPassed = [self.securityCodeField validateAsCCCVS2ForCreditCardType:(-1 == self.selectedCardTypeIndex)?[ACConstants getLocalizedStringForKey:@"SELECT_CARD_TYPE" withDefaultValue:@"Select Card Type"]:[self.cardTypes objectAtIndex:self.selectedCardTypeIndex]];
                cell.textLabel.textColor = (!validationPassed && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                break ;
            default:
                break;
        }
    }
    else if(1 == indexPath.section)
    {
        if (rownum == 0)
        {
            cell.textField.hidden = YES;
            cell.cellTitleButton.hidden = YES;
            CGRect textLabelFrame = cell.textLabel.frame;
            textLabelFrame.size.width = 200;
            cell.textLabel.frame = textLabelFrame;
            cell.textLabel.text = [ACConstants getLocalizedStringForKey:@"SAME_AS_SHIPPING_ADDRESS" withDefaultValue:@"Same as Shipping Address"];
            cell.sameShippingAddress.hidden = NO;
            cell.textField.tag = 27;
            cell.sameShippingAddress.on = self.usesAddressFromShpping;
            
            //this should never turn red
            cell.textLabel.textColor = [UIColor blackColor];
            
            [cell.sameShippingAddress addTarget:self
                                         action:@selector(toggleButtonPressed:)
                               forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    else if(2 == indexPath.section)
    {
        switch ( rownum )
        {
            case 0:
                cell.textLabel.text = [ACConstants getLocalizedStringForKey:@"FIRST_NAME" withDefaultValue:@"First Name"];
                cell.textField.text = self.firstName;
                cell.textField.placeholder = @"";
                cell.contactPickerButton.hidden=NO;
                cell.cellTitleButton.hidden = NO;
                CGRect nameFrame = cell.textField.frame;
                if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
                    nameFrame.origin.x = 120;
                } else {
                    nameFrame.origin.x = 90;
                }
                cell.textField.frame = nameFrame;
                cell.textField.tag=20;
                cell.textField.textAlignment = NSTextAlignmentRight;
                [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                //cell.textField.backgroundColor = [UIColor redColor];
                
                [cell.contactPickerButton addTarget:self
                                             action:@selector(phoneBookContacts)
                                   forControlEvents:UIControlEventTouchUpInside];
                // Adjust picker button
                //CGRect contactPickerButtonFrame = cell.contactPickerButton.frame;
                //contactPickerButtonFrame.origin.x = [self widthForTableView:tableView] - contactPickerButtonFrame.size.width;
                //cell.contactPickerButton.frame = contactPickerButtonFrame;
                
                self.firstNameTextField = cell.textField;
                cell.textLabel.textColor = (![cell.textField validateAsNotEmpty] && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                break ;
            case 1:
                self.lastNameTextField=cell.textField;
                cell.textLabel.text =  [ACConstants getLocalizedStringForKey:@"LAST_NAME" withDefaultValue:@"Last Name"];
                cell.textField.text = self.lastName;
                cell.cellTitleButton.hidden = NO;
                cell.textField.tag=21;
                cell.textField.textAlignment = NSTextAlignmentRight;
                [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                cell.textField.placeholder = @"";
                [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                cell.textLabel.textColor = (![cell.textField validateAsNotEmpty] && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                break ;
            case 2:
                cell.textLabel.text =  [ACConstants getLocalizedStringForKey:@"COMPANY" withDefaultValue:@"Company"] ;
                cell.textField.text=self.company;
                cell.cellTitleButton.hidden = NO;
                cell.textField.tag=22;
                cell.textField.textAlignment = NSTextAlignmentRight;
                cell.textField.placeholder =  [ACConstants getLocalizedStringForKey:@"OPTIONAL" withDefaultValue:@"Optional"];
                [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                
                //this should never turn red
                cell.textLabel.textColor = [UIColor blackColor];
                
                self.companyTextField=cell.textField;
                break ;
            case 3:
                self.address1TextField=cell.textField;
                cell.textLabel.text =  [ACConstants getLocalizedStringForKey:@"ADDRESS" withDefaultValue:@"Address"] ;
                cell.textField.text = self.addressLine1;
                cell.textField.tag=23;
                cell.cellTitleButton.hidden = NO;
                cell.textField.textAlignment = NSTextAlignmentRight;
                [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                cell.textField.placeholder = @"";
                [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                cell.textLabel.textColor = (![cell.textField validateAsNotEmpty] && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                break ;
            case 4:
                cell.textLabel.text =  [ACConstants getLocalizedStringForKey:@"ADDRESS_LINE_2" withDefaultValue:@"Address Line 2"];
                cell.textField.text=self.addressLine2;
                cell.textField.tag=24;
                cell.cellTitleButton.hidden = NO;
                cell.textField.textAlignment = NSTextAlignmentRight;
                cell.textField.placeholder =  [ACConstants getLocalizedStringForKey:@"OPTIONAL" withDefaultValue:@"Optional"];
                [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                
                //this should never turn red
                cell.textLabel.textColor = [UIColor blackColor];
                
                self.address2TextField=cell.textField;
                break ;
            case 5:
                cell.pickerButton.tag = COUNTRY_PICKER_TAG;
                [cell.pickerButton setBackgroundImage:nil forState:UIControlStateNormal];
                cell.textField.hidden = YES;
                cell.textLabel.hidden = YES;
                cell.cellTitleButton.hidden = YES;
                cell.pickerButton.hidden = NO;
                
                self.countryIndexPath = indexPath;
                
                [cell.pickerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                cell.pickerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                CGRect pickerButtonFrame = cell.pickerButton.frame;
                cell.pickerButton.frame = pickerButtonFrame;
                
                self.countryButton = cell.pickerButton;
                [cell.pickerButton setTitle:self.countryPickerValue forState:UIControlStateNormal];
                self.countryButton.selected = isDoingValidation && (-1 == self.selectedCountryIndex);
                [cell.pickerButton addTarget:self
                                      action:@selector(pickerPressed:)
                            forControlEvents:UIControlEventTouchUpInside];
                break ;
            case 6:
                self.zipTextField = cell.textField;
                cell.textLabel.text = self.zipLabelText;
                cell.textField.text=self.postalCode;
                cell.textField.tag=26;
                cell.cellTitleButton.hidden = NO;
                cell.textField.placeholder=@"";
                cell.textField.textAlignment = NSTextAlignmentRight;
                [cell.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
                [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                BOOL cityNotChoosenForUS = ([ self getCharacterCount:self.postalCode] > 0 && !self.willShowCityAndState);
                cell.textLabel.textColor = (((![cell.textField validateAsNotEmpty]) || ([ self.selectedCountryCode isEqualToString:@"US"] && self.isUSAddressInvalid) || cityNotChoosenForUS)  && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                break ;
            case 7:
                
                if(!self.willShowCityAndState)
                {
                    self.phoneField=cell.textField;
                    cell.textLabel.text =  [ACConstants getLocalizedStringForKey:@"PHONE" withDefaultValue:@"Phone"];
                    [cell.textField setKeyboardType:UIKeyboardTypeNumberPad];
                    cell.textField.text = self.phone;
                    cell.textField.tag = 29;
                    cell.cellTitleButton.hidden = NO;
                    cell.textField.textAlignment = NSTextAlignmentRight;
                    cell.textField.placeholder = self.phoneValidationRequired?@"": [ACConstants getLocalizedStringForKey:@"OPTIONAL" withDefaultValue:@"Optional"];
                    [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                    
                    //default to black
                    cell.textLabel.textColor = [UIColor blackColor];
                    
                    if([self.selectedCountryCode isEqualToString:@"DE"])
                    {
                        cell.textLabel.textColor = (self.phoneValidationRequired && ![cell.textField validateAsGermanPhoneNumber] && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                    }
                    else
                    {
                        cell.textLabel.textColor = (self.phoneValidationRequired && ![cell.textField validateAsNotEmpty] && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                        
                    }
                }
                else
                {
                    cell.textLabel.text =  [ACConstants getLocalizedStringForKey:@"CITY" withDefaultValue:@"City"];
                    cell.textField.text=self.city;
                    cell.textField.tag=27;
                    cell.cellTitleButton.hidden = NO;
                    cell.textField.placeholder=@"";
                    [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                    cell.textField.textAlignment = NSTextAlignmentRight;
                    [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                    self.cityTextField = cell.textField;
                    cell.textLabel.textColor = (((![cell.textField validateAsNotEmpty]) || ([ self.selectedCountryCode isEqualToString:@"US"] && self.isUSAddressInvalid)) && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];            }
                
                
                break ;
            case 8:
                if([ self.selectedCountryCode isEqualToString:@"US"])
                {
                    cell.pickerButton.tag = STATE_PICKER_TAG;
                    cell.pickerButton.hidden = NO;
                    cell.textField.hidden = YES;
                    cell.textLabel.hidden = YES;
                    cell.cellTitleButton.hidden = YES;
                    
                    self.stateIndexPath = indexPath;
                    
                    [cell.pickerButton setTitle:self.statePickerValue forState:UIControlStateNormal];
                    [cell.pickerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    cell.pickerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    CGRect pickerButtonFrame = cell.pickerButton.frame;
                    cell.pickerButton.frame = pickerButtonFrame;
                    [cell.pickerButton setTitle:self.statePickerValue forState:UIControlStateNormal];
                    [cell.pickerButton addTarget:self
                                          action:@selector(pickerPressed:)
                                forControlEvents:UIControlEventTouchUpInside];
                    [cell.pickerButton setTitleColor:(isDoingValidation && ((-1 == self.selectedStateIndex) || ([ self.selectedCountryCode isEqualToString:@"US"] && self.isUSAddressInvalid)))?[UIColor redColor]:[UIColor blackColor] forState:UIControlStateNormal];
                }
                else
                {
                    cell.textLabel.text =  [ACConstants getLocalizedStringForKey:@"STATE" withDefaultValue:@"State"];
                    cell.textField.text = self.stateFieldValue;
                    cell.textField.tag = 28;
                    cell.cellTitleButton.hidden = NO;
                    [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                    self.stateTextField=cell.textField;
                    cell.textField.textAlignment = NSTextAlignmentRight;
                    cell.textField.placeholder = self.stateValidationRequired?@"": [ACConstants getLocalizedStringForKey:@"OPTIONAL" withDefaultValue:@"Optional"];
                    [cell.textField setKeyboardType:UIKeyboardTypeDefault];
                    cell.textLabel.textColor = (self.stateValidationRequired && ![cell.textField validateAsNotEmpty] && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                }
                
                self.stateButton = cell.pickerButton;
                self.stateButton.selected = isDoingValidation && (-1 == self.selectedStateIndex);
                break ;
            case 9:
                cell.textLabel.text = [ACConstants getLocalizedStringForKey:@"PHONE" withDefaultValue:@"Phone"];
                [cell.textField setKeyboardType:UIKeyboardTypeNumberPad];
                cell.textField.text = self.phone;
                cell.textField.tag = 29;
                cell.cellTitleButton.hidden = NO;
                cell.textField.textAlignment = NSTextAlignmentRight;
                cell.textField.placeholder = self.phoneValidationRequired?@"": [ACConstants getLocalizedStringForKey:@"OPTIONAL" withDefaultValue:@"Optional"];
                [cell.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                self.phoneField=cell.textField;
                
                //default to black
                cell.textLabel.textColor = [UIColor blackColor];
                
                if([self.selectedCountryCode isEqualToString:@"DE"])
                {
                    cell.textLabel.textColor = (self.phoneValidationRequired && ![cell.textField validateAsGermanPhoneNumber] && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                }
                else
                {
                    cell.textLabel.textColor = (self.phoneValidationRequired && ![cell.textField validateAsNotEmpty] && isDoingValidation)?[UIColor redColor]:[ UIColor blackColor];
                }
                break;
            default:
                break;
        }
    }
    
//    if(self.failedTextField) /* If validation fails */
//    {
//        [self.failedTextField becomeFirstResponder];
//    }
    cell.textField.keyboardAppearance = UIKeyboardAppearanceLight;
    return cell;
}





-(int)getCharacterCount:(NSString*)str
{
    return [str stringByTrimmingCharactersInSet:[ NSCharacterSet whitespaceCharacterSet]].length;
}

- (BOOL) validateAsCCNumber:(NSString*)text {
    if ([text length] < 10) {
        return NO;
    }
    
	NSMutableArray *stringAsChars = [[NSMutableArray alloc] initWithCapacity:[text length]] ;
    
    
    for (int i=0; i < [text length]; i++) {
		NSString *ichar  = [NSString stringWithFormat:@"%c", [text characterAtIndex:i]];
		[stringAsChars addObject:ichar];
	}
    
    if ([stringAsChars count] < 10) {
        return NO;
    }
    
	BOOL isOdd = YES;
	int oddSum = 0;
	int evenSum = 0;
    
	for (int i = [text length] - 1; i >= 0; i--) {
        
		int digit = [(NSString *)[stringAsChars objectAtIndex:i] intValue];
        
		if (isOdd)
			oddSum += digit;
		else
			evenSum += digit/5 + (2*digit) % 10;
        
		isOdd = !isOdd;
	}
    
	BOOL passed = ((oddSum + evenSum) % 10 == 0);
    //  [self setValidationHighlight:!passed];
    return passed;
}

- (BOOL) validateAsCCCVS2ForCreditCardType:(NSString *)inCardType number:(NSString*)text
{
    BOOL passed = YES;
    
    if([ inCardType isEqualToString:@""])
    {
        passed = NO;
    }
    else if([[inCardType lowercaseString] isEqualToString:@"american express"])
    {
        if(text.length!=4)
        {
            passed = NO;
        }
    }
    else
    {
        if(text.length!=3)
        {
            passed = NO;
        }
    }
    
    //  [self setValidationHighlight:!passed];
    return passed;
}

-(BOOL) validateForm
{
    //NSLog(@"validateForm: %d", self.selectedCardTypeIndex);
    self.failedTextField = nil;
    
    if (![self validateAsCCNumber:self.cardNumber])
    {
        self.failedTextField = self.cardNumberField;
        [self.billingAddressTableView scrollToRowAtIndexPath:[ NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    else if (([self.expDate isEmpty])||([self.resultString2 isEqualToString:[ArtAPI getCurrentYear]]&&([self.resultString intValue]<[[ArtAPI getCurrentMonth] intValue])))
    {
        self.failedTextField = self.expDateField;
        [self.billingAddressTableView scrollToRowAtIndexPath:[ NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    else if (self.selectedCardTypeIndex == -1) {
        //NSLog(@"self.failedTextField = self.cardTypeField");
        self.failedTextField = self.securityCodeField;
        [self.billingAddressTableView scrollToRowAtIndexPath:[ NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    else if (![self validateAsCCCVS2ForCreditCardType:(-1 == self.selectedCardTypeIndex)?[ACConstants getLocalizedStringForKey:@"SELECT_CARD_TYPE" withDefaultValue:@"Select Card Type"]:[self.cardTypes objectAtIndex:self.selectedCardTypeIndex] number:self.securityCode])
    {
        self.failedTextField = self.securityCodeField;
        [self.billingAddressTableView scrollToRowAtIndexPath:[ NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    else if(self.usesAddressFromShpping) /* Skip validation for Address is copied from Shipping screen */
    {
        self.failedTextField = nil;
        return YES;
    }
    else if (0 == [ self getCharacterCount:self.firstName])
    {
        self.failedTextField = self.firstNameTextField;
        [self.billingAddressTableView scrollToRowAtIndexPath:[ NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    else if (0 == [ self getCharacterCount:self.lastName])
    {
        self.failedTextField = self.lastNameTextField;
        [self.billingAddressTableView scrollToRowAtIndexPath:[ NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    else if (0 == [ self getCharacterCount:self.addressLine1])
    {
        self.failedTextField = self.address1TextField;
        [self.billingAddressTableView scrollToRowAtIndexPath:[ NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    else if ((0 == [ self getCharacterCount:self.city]) && self.willShowCityAndState)
    {
        self.failedTextField = self.cityTextField;
        [self.billingAddressTableView scrollToRowAtIndexPath:[ NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    else if (self.phoneValidationRequired &&  (0 == [ self getCharacterCount:self.phone]))
    {
        self.failedTextField = self.phoneField;
        [self.billingAddressTableView scrollToRowAtIndexPath:[ NSIndexPath indexPathForRow:9 inSection:2] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    
    
    else if ([self.selectedCountryCode isEqualToString:@"US"])
    {
        if(!self.statePickerValue || [self.statePickerValue isEqualToString:[ACConstants getLocalizedStringForKey:@"SELECT_STATE" withDefaultValue:@"Select State"]])
        {
            [self.billingAddressTableView scrollToRowAtIndexPath:[ NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionNone animated:YES];
            return NO;
        }
        if(0 == [ self getCharacterCount:self.postalCode])
            self.failedTextField = self.zipTextField;
    }
    else if(![self.selectedCountryCode isEqualToString:@"US"])
    {
        if(0 == [ self getCharacterCount:self.postalCode]){
            self.failedTextField = self.zipTextField;
        }
        if(self.stateValidationRequired && 0 == [ self getCharacterCount:self.stateFieldValue]){
            self.failedTextField = self.stateTextField;
        }
    }
    else if (0 == [ self getCharacterCount:self.phone])
    {
        self.failedTextField = self.phoneField;
        [self.billingAddressTableView scrollToRowAtIndexPath:[ NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    else
    {
        self.failedTextField = nil;
    }
    
    if([self.selectedCountryCode isEqualToString:@"DE"])
    {
        NSString *phoneNumber = [self.phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phoneNumber = [ phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
        if(6 > [ self getCharacterCount:phoneNumber])
            self.failedTextField = self.phoneField;
    }
    
    [self.billingAddressTableView reloadData];
    
    return (self.failedTextField == nil)?YES:NO;
}
/*
-(void)doneTyping
{
    // When the "done" button is tapped, the keyboard should go away.
    // That simply means that we just have to resign our first responder.
    [txtActiveField resignFirstResponder];
    if(self.failedTextField)
    {
        [ self.failedTextField resignFirstResponder];
    }
    [ self hidePickerWithAnimation:YES];
}*/

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
#pragma mark UITextFieldDelegate

// Workaround to hide keyboard when Done is tapped
- (IBAction)textFieldFinished:(id)sender
{
//    [sender resignFirstResponder];
    [self.view endEditing:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentActiveTag = textField.tag;
    
    if([ self.pickerHolderView superview])
        [ self hidePickerWithAnimation:YES];
    
    if(textField && [textField isKindOfClass:[ACCheckoutTextField class]]){
        ACCheckoutTextField *tField = (ACCheckoutTextField *)textField;
        self.selectedIndexPath = tField.cellIndexPath;
    }
    
//    UITableViewCell *cell = (UITableViewCell *)[tField celll];
//    self.selectedIndexPath = [self.billingAddressTableView indexPathForCell:cell];
    
    if (textField.tag == 11)
    {
        //[self.cardTypeField resignFirstResponder];
        self.cardTypePickerView = [self generatePickerView:textField];
        textField.inputView = self.cardTypePickerView;
    }
    if (textField.tag == 12)
    {
        self.expDatePickerView = [self generatePickerView:textField];
        textField.inputView = self.expDatePickerView;
    }
    else
    {
        textField.inputView = nil;
    }
    
    //[self createInputAccessoryViewIsModal:NO];
    //[textField setInputAccessoryView:inputAccView];
    self.inputAccView = [[ACKeyboardToolbarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([self.view getCurrentScreenBoundsDependOnOrientation]), 40)];
    self.inputAccView.toolbarDelegate = self;
    [textField setInputAccessoryView:self.inputAccView];
    
    // Set the active field. We' ll need that if we want to move properly
    // between our textfields.
    self.txtActiveField = textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    if(textField == self.zipTextField)
    if(26 == textField.tag)
    {
        if ([self.selectedCountryCode isEqualToString:@"US"])
        {
            NSString *newStr = [textField.text stringByAppendingValidString:string];
            if([@"" isEqualToString:string]){
                if([newStr length] > 0){
                    newStr = [newStr substringToIndex:[newStr length] - 1];
                }
            }
            if(5 == newStr.length)
            {
                self.zipUnderValidation = newStr;
                self.zipTextField.text = newStr;
                [self.view endEditing:YES];
                
                [ self cityAndStateSuggestionForZip:newStr];
            }
        }
    }
    
    return YES;
}

-(void)cityAndStateSuggestionForZip:(NSString*)newStr
{
    [SVProgressHUD showWithStatus:[ACConstants getUpperCaseStringIfNeededForString:[ACConstants getLocalizedStringForKey:@"FETCHING_DETAILS" withDefaultValue:@"FETCHING DETAILS"]] maskType:SVProgressHUDMaskTypeClear];
    
    [ArtAPI
     cartGetCityStateSuggestionsCountryCode:@"US" zipCode:newStr success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
         [self cartCityStateSuggestionDidFinishLoading: JSON];
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         [self carttCityStateSuggestionDidFailLoading: JSON];
     }];
    
}


-(void) cartCityStateSuggestionDidFinishLoading:(id)JSON
{
    [SVProgressHUD dismiss];
    
    NSArray *addresses = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"Addresses"];
    
    if(!addresses){
        self.willShowCityAndState = YES;
        [self.billingAddressTableView reloadData];
        return;
    }
    
    if(1 <= addresses.count)
    {
        NSMutableArray *array = [ NSMutableArray array];
        for(NSDictionary *addrDict in addresses)
        {
            NSString *cityName = [ addrDict objectForKeyNotNull:@"City"];
            if(![array containsObject:cityName])
                [array addObject:cityName];
        }
        
        if(1< array.count)
        {
            NSString *title = [ACConstants getLocalizedStringForKey:@"CHOOSE_YOUR_CITY" withDefaultValue:@"Choose your City"];
            
            
            int currentDeviceOSVersion = [UIDevice currentDevice].systemVersion.intValue;//CS:fixing CIRCLESIOS-1667
            if(currentDeviceOSVersion < 8)// For iOS 7 versions
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                         delegate:self
                                                                cancelButtonTitle:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad?nil:[ACConstants getLocalizedStringForKey:@"CANCEL" withDefaultValue:@"Cancel"]
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:nil, nil];
                
                for(NSString *cName in array)
                {
                    [actionSheet addButtonWithTitle:cName];
                }
                
                self.cityArray = addresses;
                actionSheet.tag = 777;
                [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            }
            else // For iOS 8
            {
                UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:nil];
                
                for(NSString *cityName in array)
                {
                    [anAlert addButtonWithTitle:cityName];
                }
                
                self.cityArray = addresses;
                anAlert.tag = 777;
                
                [anAlert show];
            }

            
        }
        else
        {
            NSDictionary *cityDict = [ addresses objectAtIndex:0];
            
            NSString *stateCodee = [cityDict objectForKeyNotNull:@"State"];
            NSDictionary *stateDict = [ self getStateForCode:stateCodee];
            NSString *stateName = [stateDict objectForKeyNotNull:@"Name"];
            if(stateName)
            {
                self.selectedStateIndex = [ self.states indexOfObject:stateDict];
                self.statePickerValue = [stateDict objectForKeyNotNull:@"Name"];
                self.postalCode = [cityDict objectForKeyNotNull:@"ZipCode"];
                self.city = [cityDict objectForKeyNotNull:@"City"];
                
                self.willShowCityAndState = YES;
                
                [ self.billingAddressTableView reloadData];
            }
        }
    }
    else if(0 == addresses.count)
    {
        self.selectedStateIndex = -1;
        self.statePickerValue = [ACConstants getLocalizedStringForKey:@"SELECT_STATE" withDefaultValue:@"Select State"];
        self.city = @"";
        self.willShowCityAndState = YES;
        [self.billingAddressTableView reloadData];
    }
}

-(void) carttCityStateSuggestionDidFailLoading:(id)JSON
{
    [SVProgressHUD dismiss];
    self.willShowCityAndState = YES;
    [self.billingAddressTableView reloadData];
}

-(void) scrollTextFieldToVisablePosition:(UITextField *)textField
{
    NSUInteger h = textField.frame.origin.y;
    [self.billingAddressTableView setContentOffset:CGPointMake(0, h-49) animated:YES];
    
}

/******************Custom View for the Next,Previous and Done Keyborad Control************/

-(CGRect)getCurrentScreenBoundsDependOnOrientation
{
    
    CGRect screenBounds = [UIScreen mainScreen].bounds ;
    CGFloat width = CGRectGetWidth(screenBounds)  ;
    CGFloat height = CGRectGetHeight(screenBounds) ;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        screenBounds.size = CGSizeMake(width, height);
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        screenBounds.size = CGSizeMake(height, width);
    }
    return screenBounds ;
}


// Textfield value changed, store the new value.
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ( textField.tag == 11 )
    {
        self.cardNumber = textField.text ;
    } else if ( textField.tag == 12 )
    {
        self.expDate = textField.text ;
    }
    else if ( textField.tag == CARD_TYPE_PICKER_TAG )
    {
        self.cardType = textField.text ;
    }
    else if(textField.tag == 13)
    {
        self.securityCode=textField.text;
    }
    if ( textField.tag == 20 )
    {
        self.firstName = textField.text ;
    }
    if ( textField.tag == 21 )
    {
        self.lastName = textField.text ;
    }
    else if ( textField.tag == 22 )
    {
        self.company = textField.text ;
    }
    
    else if(textField.tag == 23)
    {
        self.addressLine1=textField.text;
    }
    else if (textField.tag== 24) {
        self.addressLine2=textField.text;
    }
    else if (textField.tag== 26) {
        self.postalCode=textField.text;
    }
    else if (textField.tag== 27) {
        self.city=textField.text;
    }
    /*    else if (textField==emailTextField)
     {
     self.emailAddress=textField.text;
     } */
    else if (textField.tag== 29)
    {
        self.phone=textField.text;
    }
    else if (textField.tag== 28)
    {
        self.stateFieldValue=textField.text;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ACKeyboardToolbarDelegate
- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectNext: (id) next {
    int sectionToScroll = 0;
    BOOL scrollToNameField = NO;
    
    
    switch (self.currentActiveTag) {
        case CARD_TYPE_PICKER_TAG:{
            [self.cardNumberField becomeFirstResponder];
            sectionToScroll = 0;
            break;
        }
        case 11:{
            [self.expDateField becomeFirstResponder];
            sectionToScroll = 0;
            break;
        }
        case 12:{
            [self.securityCodeField becomeFirstResponder];
            sectionToScroll = 0;
            break;
        }
        case 13:{
            if(!self.usesAddressFromShpping)
            {
                [self.firstNameTextField becomeFirstResponder];
                sectionToScroll = 2;
                scrollToNameField = YES;
            }
            else
            {
//                [ self.securityCodeField resignFirstResponder];
                [self.view endEditing:YES];
                sectionToScroll = 0;
            }
            break;
        }
        case 20:{
            [self.lastNameTextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case 21:{
            [self.companyTextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case 22:{
            [self.address1TextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case 23:{
            [self.address2TextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case 24:{
            self.tagFromPicker = COUNTRY_PICKER_TAG;
            [self pickerPressed:[self.billingAddressTableView viewWithTag:COUNTRY_PICKER_TAG]];
            sectionToScroll = 2;
            break;
        }
        case COUNTRY_PICKER_TAG:{
            [self hidePickerWithAnimation:NO];
            [self.zipTextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case 26:{
            if(!self.willShowCityAndState)
            {
                [self.phoneField becomeFirstResponder];
            }
            else
            {
                [self.cityTextField becomeFirstResponder];
            }
            sectionToScroll = 2;
            break;
        }
        case 27:{
            if([ self.selectedCountryCode isEqualToString:@"US"]){
                self.tagFromPicker = STATE_PICKER_TAG;
                [self pickerPressed:[self.billingAddressTableView viewWithTag:STATE_PICKER_TAG]];
            }
            else
                [self.stateTextField becomeFirstResponder];
            
            sectionToScroll = 2;
            break;
        }
        case 28:{
            [self.phoneField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case STATE_PICKER_TAG:{
            [ self hidePickerWithAnimation:NO];
            [self.phoneField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case 29:{
//            [self.txtActiveField resignFirstResponder];
            [self.view endEditing:YES];
            break;
        }
        default:
            break;
    }
    
    self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row inSection:sectionToScroll];
    
    if(!scrollToNameField){
//        [self.billingAddressTableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }else{
        
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.45 animations:^{
                [self.billingAddressTableView setContentOffset:CGPointMake(0, 270 - ([UIScreen mainScreen].bounds.size.height - NATIVE_PHONE_HEIGHT)/2)];
            }completion:^(BOOL finished) {
                [self.firstNameTextField becomeFirstResponder];
            }];
        });
    }
}

- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectPrevious: (id) previous {
    int sectionToScroll = 0;
    BOOL isInNameField = NO;
    
    switch (self.currentActiveTag) {
        case CARD_TYPE_PICKER_TAG:{
//            [self.txtActiveField resignFirstResponder];
            [self.view endEditing:YES];
            sectionToScroll = 0;
            break;
        }
        case 11:{
            self.tagFromPicker = CARD_TYPE_PICKER_TAG;
            [self pickerPressed:[self.billingAddressTableView viewWithTag:CARD_TYPE_PICKER_TAG]];
            sectionToScroll = 0;
            break;
        }
        case 12:{
            [self.cardNumberField becomeFirstResponder];
            sectionToScroll = 0;
            break;
        }
        case 13:{
            [self.expDateField becomeFirstResponder];
            sectionToScroll = 0;
            break;
        }
        case 20:{
//            [self.securityCodeField becomeFirstResponder];
            sectionToScroll = 0;
            isInNameField = YES;
            break;
        }
        case 21:{
            [self.firstNameTextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case 22:{
            [self.lastNameTextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case 23:{
            [self.companyTextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case 24:{
            [self.address1TextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case COUNTRY_PICKER_TAG:{
            [self hidePickerWithAnimation:NO];
            [self.address2TextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case 26:{
            self.tagFromPicker = COUNTRY_PICKER_TAG;
            [self pickerPressed:[self.billingAddressTableView viewWithTag:COUNTRY_PICKER_TAG]];
            sectionToScroll = 2;
            break;
        }
        case 27:{
            [self.zipTextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case 28:{
            [self.cityTextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case STATE_PICKER_TAG:{
            [self.cityTextField becomeFirstResponder];
            sectionToScroll = 2;
            break;
        }
        case 29:{
            if(!self.willShowCityAndState)
            {
                [self.zipTextField becomeFirstResponder];
                sectionToScroll = 2;
            }
            else{
                if([ self.selectedCountryCode isEqualToString:@"US"]){
                    self.tagFromPicker = STATE_PICKER_TAG;
                    [self pickerPressed:[self.billingAddressTableView viewWithTag:STATE_PICKER_TAG]];
                }
                else
                    [self.stateTextField becomeFirstResponder];
                sectionToScroll = 2;
            }
            break;
        }
        default:
            break;
    }
    
    self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row inSection:sectionToScroll];
    
    //    NSLog(@"selectedIndexPath = %@",self.selectedIndexPath);
    if(!isInNameField){
        [self.billingAddressTableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }else{
        [UIView animateWithDuration:0.40 animations:^{
            [self.billingAddressTableView setContentOffset:CGPointMake(0, 175 - ([UIScreen mainScreen].bounds.size.height - NATIVE_PHONE_HEIGHT)/2)];
        }completion:^(BOOL finished) {
            [self.securityCodeField becomeFirstResponder];
        }];
    }
}

- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectDone: (id) done {
    // When the "done" button is tapped, the keyboard should go away.
    // That simply means that we just have to resign our first responder.
//    [self.txtActiveField resignFirstResponder];
//    if(self.failedTextField)
//    {
//        [ self.failedTextField resignFirstResponder];
//    }
    
    [self.view endEditing:YES];
    [ self hidePickerWithAnimation:YES];
}


-(void)hidePickerWithAnimation:(BOOL)animated
{
    if(self.pickerHolderView.frame.origin.y == (self.view.frame.size.height - CHECKOUT_PICKER_HEIGHT))
    {
        if(animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
        }
        
        [self keyboardWillHide:nil];
        
        self.pickerHolderView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, CHECKOUT_PICKER_HEIGHT);
        
        
        if(animated){
            [UIView commitAnimations];
        }
    }
}

#pragma mark -
#pragma mark UIPickerViewDataSource and Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.tagFromPicker == CARD_TYPE_PICKER_TAG)
    {
        [self.cardTypeButton setTitle:[self pickerView:pickerView titleForRow:row forComponent:component] forState:UIControlStateNormal];;
        self.selectedCardTypeIndex = row;
        self.cardType = (-1 == row)?[ACConstants getLocalizedStringForKey:@"SELECT_CARD_TYPE" withDefaultValue:@"Select Card Type"]:[ self.cardTypes objectAtIndex:row];
        [self.billingAddressTableView reloadData];
        
    }
    else if (self.tagFromPicker == DATE_TYPE_PICKER_TAG)
    {
        
        if (component == 0)
        {
            self.resultString = [self.dateColumn objectAtIndex:row];
            //self.expDateField.text = resultString;
        } else {
            self.resultString2 =
            [self.yearColumn objectAtIndex:row];
            
        }
        self.expDateField.text = [NSString stringWithFormat:@"%@/%@",self.resultString,self.resultString2];
        
    }
    else  if (self.tagFromPicker == COUNTRY_PICKER_TAG)
    {
        self.countryPickerValue = [self pickerView:pickerView titleForRow:row forComponent:component];
        self.selectedCountryIndex = row;
        self.selectedCountryCode = [self.countryIDArray objectAtIndex:row];
        [self validateSelectedCountry:row];
        
        if([ self.selectedCountryCode isEqualToString:@"US"])
        {
            if((5 == self.postalCode.length) && !mCountryPickerInvoked)
            {
                [ self cityAndStateSuggestionForZip:self.postalCode];
                mCountryPickerInvoked = YES;
            }
        }
        else{
            self.willShowCityAndState = (!self.willShowCityAndState)?![ self.selectedCountryCode isEqualToString:@"US"]:YES;
            mCountryPickerInvoked = NO;
        }
        
        //        if(mCountryPickerInvoked)
        //            mCountryPickerInvoked = NO;
        
        [self.billingAddressTableView reloadData];
    }
    else if (self.tagFromPicker==STATE_PICKER_TAG)
    {
        self.statePickerValue = [self pickerView:pickerView titleForRow:row forComponent:component];
        self.selectedStateIndex = row;
        [self.billingAddressTableView reloadData];
    }
}

-(void)validateSelectedCountry:(int)countryIndex
{
    self.stateValidationRequired = NO;
    self.phoneValidationRequired = NO;
    
    NSString *countryID = [ self.countryIDArray objectAtIndex:countryIndex];
    self.zipLabelText = [@"US" isEqualToString:countryID]?[ACConstants getLocalizedStringForKey:@"ZIP" withDefaultValue:@"ZIP"]:[ACConstants getLocalizedStringForKey:@"POSTAL_CODE" withDefaultValue:@"Postal Code"];
    
    if([@"US" isEqualToString:countryID] || [@"JP" isEqualToString:countryID])
    {
        self.stateValidationRequired = YES;
    }
    if([@"DE" isEqualToString:countryID] || [@"JP" isEqualToString:countryID] || [@"AT" isEqualToString:countryID] || [@"CH" isEqualToString:countryID])
    {
        self.phoneValidationRequired = YES;
    }
}

-(void)validateSelectedCountryName:(NSString*)countryName
{
    self.stateValidationRequired = NO;
    self.phoneValidationRequired = NO;
    
    for (NSString *name in self.countryNamesArray)
    {
        if ([name isEqualToString:self.countryPickerValue])
        {
            [self validateSelectedCountry:[ self.countryNamesArray indexOfObject:name]];
            [self.billingAddressTableView reloadData];
            break;
        }
    }
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSMutableArray *stateArray = [[NSMutableArray alloc] initWithCapacity:self.states.count];
    NSMutableArray *countryArray = [[NSMutableArray alloc] initWithCapacity:self.countries.count];
    
    //NSLog(@"Tag from picker:       %i", self.tagFromPicker);
    //NSLog(@"Tag for card selector: %i", CARD_TYPE_PICKER_TAG);
    
    if (row == - 1)
    {
        if(self.tagFromPicker == STATE_PICKER_TAG){
            return self.statePickerValue;
        }else if(self.tagFromPicker == COUNTRY_PICKER_TAG){
            return self.countryPickerValue;
        }else{
            return self.cardType;
        }
    }
    
    //NSLog(@"Tag from picker:       %i", self.tagFromPicker);
    //NSLog(@"Tag for card selector: %i", CARD_TYPE_PICKER_TAG);
    
    //MKL changing to switch statement
    
    switch(self.tagFromPicker){
        case CARD_TYPE_PICKER_TAG:
            //NSLog(@"CARD TYPE: Tag from picker:       %i", self.tagFromPicker);
            return [self.cardTypes objectAtIndex:row];
            break;
        case DATE_TYPE_PICKER_TAG:
            //NSLog(@"DATE TYPE: Tag from picker:       %i", self.tagFromPicker);
            if (component == 0)
            {
                return [self.dateColumn objectAtIndex:row];
            }
            return [self.yearColumn objectAtIndex:row];
            break;
        case STATE_PICKER_TAG:
            //NSLog(@"STATE TYPE: Tag from picker:       %i", self.tagFromPicker);
            for (NSDictionary *dict in self.states)
            {
                [stateArray addObject:[dict objectForKey:@"Name"]];
            }
            return (row < stateArray.count)?[stateArray objectAtIndex:row]:[stateArray objectAtIndex:0];
            break;
        case COUNTRY_PICKER_TAG:
            //NSLog(@"COUNTRY TYPE: Tag from picker:       %i", self.tagFromPicker);
            for (NSDictionary *dict in self.countries)
            {
                NSString *name = [dict objectForKeyNotNull:@"Name"];
                [countryArray addObject:name];
            }
            return (row < countryArray.count)?[countryArray objectAtIndex:row]:[countryArray objectAtIndex:0];
            break;
        default:
            //NSLog(@"NO TYPE: Tag from picker:       %i", self.tagFromPicker);
            return @"";
            break;
    }
    /*
    if (self.tagFromPicker == CARD_TYPE_PICKER_TAG)
    {
        return [self.cardTypes objectAtIndex:row];
    }
    else if (self.tagFromPicker == DATE_TYPE_PICKER_TAG)
    {
        
        if (component == 0)
        {
            return [self.dateColumn objectAtIndex:row];
        }
        return [self.yearColumn objectAtIndex:row];
        
    }
    else  if (self.tagFromPicker==STATE_PICKER_TAG)
    {
        
        NSMutableArray *c = [[NSMutableArray alloc] initWithCapacity:self.states.count];
        for (NSDictionary *dict in self.states)
        {
            [c addObject:[dict objectForKey:@"Name"]];
        }
        return [c objectAtIndex:row];
        
    }
    else if (self.tagFromPicker==COUNTRY_PICKER_TAG)
    {
        
        NSMutableArray *c = [[NSMutableArray alloc] initWithCapacity:self.countries.count];
        //[c addObject:@"United States"];
        for (NSDictionary *dict in self.countries)
        {
            NSString *name = [dict objectForKeyNotNull:@"Name"];
            //if ([name isEqualToString:@"United States"] == NO) {
                [c addObject:name];
            //}
        }
        return [c objectAtIndex:row];
    }
    
    else {
        return @"";
    }
     */
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.tagFromPicker == CARD_TYPE_PICKER_TAG)
    {
        return 1;
    }
    else if (self.tagFromPicker == DATE_TYPE_PICKER_TAG)
    {
        return 2;
    }
    else if (self.tagFromPicker == COUNTRY_PICKER_TAG)
    {
        return 1;
    }
    else if (self.tagFromPicker==STATE_PICKER_TAG)
    {
        return 1;
    }
    else {
        return 0;
    }
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.tagFromPicker == CARD_TYPE_PICKER_TAG)
    {
        return [self.paymentOptions count];
    }
    else if (self.tagFromPicker == DATE_TYPE_PICKER_TAG)
    {
        if (component == 0)
        {
            return [self.dateColumn count];
        }
        return [self.yearColumn count];
    }
    
    else  if (self.tagFromPicker==STATE_PICKER_TAG)
    {
        NSMutableArray *c = [[NSMutableArray alloc] initWithCapacity:self.states.count];
        for (NSDictionary *dict in self.states)
        {
            [c addObject:[dict objectForKey:@"Name"]];
        }
        return [c count];
    }
    if (self.tagFromPicker==COUNTRY_PICKER_TAG)
    {
        
        NSMutableArray *c = [[NSMutableArray alloc] initWithCapacity:self.countries.count];
        //[c addObject:@"United States"];
        for (NSDictionary *dict in self.countries)
        {
            NSString *name = [dict objectForKeyNotNull:@"Name"];
            //if ([name isEqualToString:@"United States"] == NO)
            //{
                [c addObject:name];
            //}
        }
        return [c count];
    }
    else {
        return 0;
    }
}

#pragma mark -  CardIO Methods

//Action method for Scanning Card
- (IBAction)scanCard:(id)sender {
    NSLog(@"scanCard");
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.useCardIOLogo = YES;
    //scanViewController.appToken = [ACConstants getCardIOToken];
    [self.navigationController presentViewController:scanViewController animated:YES completion:nil];
   
    
}

#pragma mark -  CardIODelegate Methods

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_SCAN_CARD_CANCEL];
    
    //NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    //NSLog(@"Received card info. Number: %@, expiry: %02i/%i, cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv);
    // Use the card info..
    
    //@Mike : Check and Use the values as below
    
    //set card type
    
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_SCAN_CARD_DONE];
    
    int ccIndex = -1;
    
    if(info.cardType){
        switch(info.cardType){
        
            case CardIOCreditCardTypeVisa:
                ccIndex = [ACBillingAddressViewController getCCIndexFromCCTypeID:CC_TYPE_VISA fromPaymentOptions:self.paymentOptions];
                self.selectedCardTypeIndex = ccIndex;
                break;
            case CardIOCreditCardTypeAmex:
                ccIndex = [ACBillingAddressViewController getCCIndexFromCCTypeID:CC_TYPE_AMEX fromPaymentOptions:self.paymentOptions];
                self.selectedCardTypeIndex = ccIndex;
                break;
            case CardIOCreditCardTypeDiscover:
                ccIndex = [ACBillingAddressViewController getCCIndexFromCCTypeID:CC_TYPE_DISCOVER fromPaymentOptions:self.paymentOptions];
                self.selectedCardTypeIndex = ccIndex;
                break;
            case CardIOCreditCardTypeMastercard:
                ccIndex = [ACBillingAddressViewController getCCIndexFromCCTypeID:CC_TYPE_MASTERCARD fromPaymentOptions:self.paymentOptions];
                self.selectedCardTypeIndex = ccIndex;
                break;
            default:
                ccIndex = -1;
                //do nothing because CC is not supported
                break;
        }
    }
    
    self.cardType = (-1 == ccIndex)?[ACConstants getLocalizedStringForKey:@"SELECT_CARD_TYPE" withDefaultValue:@"Select Card Type"]:[ self.cardTypes objectAtIndex:ccIndex];
    
    if(ccIndex > -1){
    
        //set card number
        if(info.cardNumber){
            //populate card number
            self.cardNumber = info.cardNumber;
        }
        
        NSString *monthString = @"";  //needed to pad to 2 digits
        NSString *yearString = @"";
        
        //set card expiration
        if(info.expiryMonth && info.expiryYear){

            monthString = [NSString stringWithFormat:@"%d",info.expiryMonth];
            if(info.expiryMonth > 0 && info.expiryMonth < 10){
                //pad if 0-9
                monthString = [@"0" stringByAppendingValidString:monthString];
            }
            
            yearString = [NSString stringWithFormat:@"%d",info.expiryYear];
            
            self.expDate = [NSString stringWithFormat:@"%@/%@",monthString,yearString];
            self.expDateField.text = self.expDate;
            self.resultString2 = yearString;
            self.resultString = monthString;
        }
        
        //set card CVV
        if(info.cvv){
            //populate cvv
            self.securityCode = info.cvv;
        }
    
    }
    
    [self.billingAddressTableView reloadData];

    [scanViewController dismissViewControllerAnimated:YES completion:nil];
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

- (void)infoButtonTapped:(UIButton *)sender
{
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_INFO_BUTTON_PRESSED];

    [self showAbout];
    
    /*  DISABLING HELPSHIFT
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
    actionSheet.tag = 'n';
    [actionSheet showInView:self.view];
     
     */
}

-(void) toggleButtonPressed:(UISwitch *) sender
{
    self.usesAddressFromShpping = sender.isOn;
    isStateFieldHavingText = YES;
    
    if(self.usesAddressFromShpping)
    {
        self.willShowCityAndState = YES;
        
        if(3 == self.billingAddressTableView.numberOfSections)
        {
            [self.numberOfSections removeLastObject];
            
            [self.billingAddressTableView beginUpdates];
            [self.billingAddressTableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
            [self.billingAddressTableView endUpdates];
        }
        
        NSDictionary *cart = [ArtAPI cart];
        NSArray *shipments = [cart objectForKeyNotNull:@"Shipments"];
        
        NSDictionary *aShipment = [shipments objectAtIndex:0];
        NSDictionary *address = [aShipment objectForKeyNotNull:@"Address"];
        
        NSDictionary *name = [address objectForKeyNotNull:@"Name"];
        
        self.firstNameTextField.text = [name objectForKeyNotNull:@"FirstName"];
        self.firstName = [name objectForKeyNotNull:@"FirstName"];
        
        self.lastNameTextField.text = [name objectForKeyNotNull:@"LastName"];
        self.lastName = [name objectForKeyNotNull:@"LastName"];
        
        self.addressLine1 = [address objectForKeyNotNull:@"Address1"];
        self.address1TextField.text = [address objectForKeyNotNull:@"Address1"];
        
        self.addressLine2 = [address objectForKeyNotNull:@"Address2"];
        self.address2TextField.text = [address objectForKeyNotNull:@"Address2"];
        
        self.company = [address objectForKeyNotNull:@"CompanyName"];
        self.companyTextField.text = [address objectForKeyNotNull:@"CompanyName"];
        
        self.city= [address objectForKeyNotNull:@"City"];
        self.cityTextField.text = [address objectForKeyNotNull:@"City"];
        
        self.postalCode= [address objectForKeyNotNull:@"ZipCode"];
        self.zipTextField.text = [address objectForKeyNotNull:@"ZipCode"];
        
        NSDictionary *PhonesDict = [address objectForKeyNotNull:@"Phone"];
        self.phone= [PhonesDict objectForKeyNotNull:@"Primary"];
        self.phoneField.text = [PhonesDict objectForKeyNotNull:@"Primary"];
        
        NSString *countryName = [ArtAPI getShippingCountryCode];
        self.selectedCountryCode = [ArtAPI getShippingCountryCode];
        self.countryPickerValue = [self getCountryNameForCode:countryName];
        
        if (![self.selectedCountryCode isEqualToString:@"US"])
        {
            self.stateFieldValue=[address objectForKeyNotNull:@"State"];
        }
        else
        {
            if ([self.selectedCountryCode isEqualToString:@"US"]) //Jobin
            {
                self.stateCode = @"CO";
                NSString *stateCodeFromShipping = [address objectForKeyNotNull:@"State"];//self.statePickerValue; Jobin: changed
                
                for (NSDictionary *state in self.states)
                {
                    NSString *stCode = [state objectForKeyNotNull:@"StateCode"];
                    if ([[stCode uppercaseString] isEqualToString:[stateCodeFromShipping uppercaseString]])
                    {
                        self.stateCode = stCode;
                        
                        int index = [ self.states indexOfObject:state];
                        self.tagFromPicker = STATE_PICKER_TAG;
                        
                        [ self configureThePicker];
                        [ self pickerView:CommonpickerView didSelectRow:index inComponent:0];
                        
                        break;
                    }
                }
                
                self.stateFieldValue=self.stateCode;
            }
            
        }
        self.postalCode = [address objectForKeyNotNull:@"ZipCode"];
        [ self validateSelectedCountryName:self.countryPickerValue];
        
    }
    else
    {
        if(2 == self.billingAddressTableView.numberOfSections)
        {
            [self.numberOfSections addObject:ACLocalizedString(@"SHIPPING_ADDRESS_DETAILS", @"Shipping Address Details")];
            if(sender)
            {
                [self.billingAddressTableView beginUpdates];
                
                [self.billingAddressTableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
                [self.billingAddressTableView endUpdates];
            }
        }
        
        //commented by jyoti PHOTOIOS -1325
        
      /*  NSDictionary *cart = [ArtAPI cart];
        NSArray *shipments = [cart objectForKeyNotNull:@"Shipments"];
        
        NSDictionary *aShipment = [shipments objectAtIndex:0];
        NSDictionary *address = [aShipment objectForKeyNotNull:@"Address"];
        
        NSDictionary *name = [address objectForKeyNotNull:@"Name"];
        
        self.firstNameTextField.text = [name objectForKeyNotNull:@"FirstName"];
        self.firstName = [name objectForKeyNotNull:@"FirstName"];
        
        self.lastNameTextField.text = [name objectForKeyNotNull:@"LastName"];
        self.lastName = [name objectForKeyNotNull:@"LastName"];
        
        self.addressLine1 = [address objectForKeyNotNull:@"Address1"];
        self.address1TextField.text = [address objectForKeyNotNull:@"Address1"];
        
        self.addressLine2 = [address objectForKeyNotNull:@"Address2"];
        self.address2TextField.text = [address objectForKeyNotNull:@"Address2"];
        
        self.company = [address objectForKeyNotNull:@"CompanyName"];
        self.companyTextField.text = [address objectForKeyNotNull:@"CompanyName"];
        
        self.city= [address objectForKeyNotNull:@"City"];
        self.cityTextField.text = [address objectForKeyNotNull:@"City"];
        
        self.selectedCountryCode = [ArtAPI getShippingCountryCode]; //Jobin
        
        self.stateValueToPassOrderConfirmationScreen=[address objectForKeyNotNull:@"State"];
        if (![self.selectedCountryCode isEqualToString:@"US"])
        {
            self.stateFieldValue=self.stateValueToPassOrderConfirmationScreen;
        }
        self.postalCode = [address objectForKeyNotNull:@"ZipCode"];
        
        [ self.billingAddressTableView reloadData];*/
        
        //added by jyoti PHOTOIOS -1325
        
        self.firstNameTextField.text = @"";
        self.firstName = @"";
        
        self.lastNameTextField.text = @"";
        self.lastName = @"";
        
        self.addressLine1 = @"";
        self.address1TextField.text = @"";
        
        self.addressLine2 = @"";
        self.address2TextField.text = @"";
        
        self.company = @"";
        self.companyTextField.text = @"";
        
        self.city= @"";
        self.cityTextField.text = @"";
        
        self.selectedCountryCode = [ArtAPI getShippingCountryCode];
        
        self.stateValueToPassOrderConfirmationScreen=@"";;
        if (![self.selectedCountryCode isEqualToString:@"US"])
        {
            self.stateFieldValue=self.stateValueToPassOrderConfirmationScreen;
        }
        self.postalCode = @"";
        
        [ self.billingAddressTableView reloadData];

        }
    
}

-(NSString*)getCountryNameForCode:(NSString*)countryCode
{
    NSString *name = nil;
    for (NSDictionary *country in self.countries)
    {
        if ([[[country objectForKeyNotNull:@"IsoA2"] uppercaseString] isEqualToString:[countryCode uppercaseString]])
        {
            name = [country objectForKeyNotNull:@"Name"];
            break;
        }
    }
    
    return name;
}

- (IBAction)proceedToOrderConfirmation:(id)sender
{
    isDoingValidation=YES;
    [self.view endEditing:YES];
    [self hidePickerWithAnimation:YES];
    if ([self validateForm])
    {
        self.isUSAddressInvalid = NO;
        
        if (!self.usesAddressFromShpping)
        {
            if ([self.selectedCountryCode isEqualToString:@"US"])
            {
                self.stateCode = @"CO";
                for (NSDictionary *state in self.states)
                {
                    NSString *stateName=self.statePickerValue;
                    if ([[[state objectForKeyNotNull:@"Name"] uppercaseString] isEqualToString:[stateName uppercaseString]])
                    {
                        self.stateCode = [state objectForKeyNotNull:@"StateCode"];
                        break;
                    }
                }
                
                self.stateValueToPassOrderConfirmationScreen = self.stateCode;
            }
            else
            {
                self.stateValueToPassOrderConfirmationScreen=self.stateFieldValue;
            }
        }
        else
        {
            self.stateValueToPassOrderConfirmationScreen=self.stateFieldValue;
        }
        
        int cardIndex = self.selectedCardTypeIndex;
        
        NSDictionary *paymentType = [self.paymentOptions objectAtIndex:cardIndex];
        NSString *cardTypesForPayment = [paymentType objectForKeyNotNull:@"CreditCardType"];
        //NSString *cardName = [paymentType objectForKeyNotNull:@"DisplayName"];
        
        //NSLog(@"Using card: %@ with numeric cardType: %@", cardName, cardTypesForPayment);
        
        //if([[cardTypesForPayment lowercaseString] isEqualToString:@"american express"]){
        //    cardTypesForPayment = ACLocalizedString(@"AMERICAN_EXPRESS", @"American_Express");;
        //}
        
        [SVProgressHUD showWithStatus:[ACConstants getUpperCaseStringIfNeededForString:[ACConstants getLocalizedStringForKey:@"SUBMITTING_ORDER" withDefaultValue:@"SUBMITTING ORDER..."]] maskType:SVProgressHUDMaskTypeClear];
        
        [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_PLACE_ORDER];
        
        //NSDictionary *cart = [ArtAPI cart];
        //NSDictionary *cartTotal = [cart objectForKeyNotNull:@"CartTotal"];
        //NSNumber *orderTotal = [cartTotal objectForKeyNotNull:@"Total"];
    
        //MKL need to do revenue tracking before order is submitted because cart gets blanked out
        //NSNumber *taxTotal = [cartTotal objectForKeyNotNull:@"TaxTotal"];
        //NSNumber *shippingTotal = [cartTotal objectForKeyNotNull:@"ShippingTotal"];
        //NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"Currency_Code_to_use"];
        
        //[Analytics logGARevenueEvent:orderNumber withRevenue:orderTotal withTax:taxTotal withShipping:shippingTotal withCurrencyCode:currencyCode];
        
        NSMutableDictionary *addressDict = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *nameDict = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *phoneDict = [[NSMutableDictionary alloc] init];

        //phone
        NSString *primaryPhone4Dict = self.phone;
        NSString *secondaryPhone4Dict = @"";
        if(!primaryPhone4Dict) primaryPhone4Dict=@"";
        [phoneDict setObject:primaryPhone4Dict forKey:@"Primary"];
        [phoneDict setObject:secondaryPhone4Dict forKey:@"Secondary"];
        [addressDict setObject:phoneDict forKey:@"Phone"];
        
        //name
        NSString *firstName4Dict = self.firstName;
        NSString *lastName4Dict = self.lastName;
        if(!firstName4Dict) firstName4Dict=@"";
        if(!lastName4Dict) lastName4Dict=@"";
        [nameDict setObject:self.firstName forKey:@"FirstName"];
        [nameDict setObject:self.lastName forKey:@"LastName"];
        [addressDict setObject:nameDict forKey:@"Name"];
        

        NSString *address14Dict = self.addressLine1;
        if(!address14Dict) address14Dict = @"";
        NSString *address24Dict = self.addressLine2;
        if(!address24Dict) address24Dict = @"";
        NSString *addressIdentifier4Dict = @"";
        NSString *addressType4Dict = @"2";  //3 is shipping
        NSString *city4Dict = self.city;
        if(!city4Dict) city4Dict = @"";
        NSString *companyName4Dict = self.company;
        if(!companyName4Dict) companyName4Dict = @"";
        NSString *country4Dict = self.countryPickerValue;
        if(!country4Dict) country4Dict = @"";
        NSString *country2ISO4Dict = self.selectedCountryCode;
        if(!country2ISO4Dict) country2ISO4Dict = @"";
        NSString *country3ISO4Dict = @"";
        NSString *county4Dict = @"";
        NSString *state4Dict = self.stateValueToPassOrderConfirmationScreen;
        if(!state4Dict) state4Dict = @"";
        NSString *zip4Dict = self.postalCode;
        if(!zip4Dict) zip4Dict = @"";
        
        [addressDict setObject:self.addressLine1 forKey:@"Address1"];
        [addressDict setObject:self.addressLine2 forKey:@"Address2"];
        [addressDict setObject:addressIdentifier4Dict forKey:@"AddressIdentifier"];
        [addressDict setObject:addressType4Dict forKey:@"AddressType"];
        [addressDict setObject:city4Dict forKey:@"City"];
        [addressDict setObject:companyName4Dict forKey:@"CompanyName"];
        [addressDict setObject:country4Dict forKey:@"Country"];
        [addressDict setObject:country2ISO4Dict forKey:@"CountryIsoA2"];
        [addressDict setObject:country3ISO4Dict forKey:@"CountryIsoA3"];
        [addressDict setObject:county4Dict forKey:@"County"];
        [addressDict setObject:state4Dict forKey:@"State"];
        [addressDict setObject:zip4Dict forKey:@"ZipCode"];

        [AccountManager sharedInstance].billingAddressUsedInCheckout = addressDict;
        
        [ArtAPI
         cartAddCreditCardNumber:self.cardNumber
         cardType:cardTypesForPayment
         cvv2:self.securityCodeField.text
         expiryDateMonth:[self.resultString intValue]
         expiryDateYear:[self.resultString2 intValue]
         soloIssueNumber:
         @""
         firstName:self.firstName
         lastName:self.lastName
         addressLine1:self.addressLine1
         addressLine2:(self.addressLine2.length > 0)? self.addressLine2:@""
         companyName:(self.company.length > 0)? self.company:@""
         city:self.city
         state:(self.stateValueToPassOrderConfirmationScreen.length > 0)?self.stateValueToPassOrderConfirmationScreen:@""
         twoDigitIsoCountryCode:self.selectedCountryCode
         zip:self.postalCode
         primaryPhone:(self.phone.length > 0)?self.phone:@""
         secondaryPhone:@""
         emailAddress:self.emailAddress success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
             [self cartAddCreditCardRequestDidFinish: JSON];
         }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
             NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
             
             NSString *errorMessagee = [JSON objectForKey:@"APIErrorMessage"];
             
             if([errorMessagee rangeOfString:@"combination"].location != NSNotFound){
                 self.isUSAddressInvalid = YES;
             }
             
             NSMutableDictionary *analyticsParams = [[NSMutableDictionary alloc] initWithCapacity:3];
             [analyticsParams setValue:[NSString stringWithFormat:@"%d",error.code] forKey:ANALYTICS_APIERRORCODE];
             [analyticsParams setValue:error.localizedDescription forKey:ANALYTICS_APIERRORMESSAGE];
             [analyticsParams setValue:[request.URL absoluteString] forKey:ANALYTICS_APIURL];
             [Analytics logGAEvent:ANALYTICS_CATEGORY_ERROR_EVENT withAction:errorMessagee withParams:analyticsParams];
             
             UIAlertView *alert = [[ UIAlertView alloc] initWithTitle:[ACConstants getLocalizedStringForKey:@"ERROR" withDefaultValue:@"Error"]
                                                              message: [JSON objectForKey:@"APIErrorMessage"]
                                                             delegate:nil
                                                    cancelButtonTitle:[ACConstants getLocalizedStringForKey:@"OK" withDefaultValue:@"OK"]
                                                    otherButtonTitles:nil, nil];
             
             [ alert show];
             alert = nil;
             [SVProgressHUD dismiss];
             [self.billingAddressTableView reloadData];
         }];
    }
    else
    {
        
        [self.billingAddressTableView reloadData];
    }
}

-(void) cartAddCreditCardRequestDidFinish:(id)JSON {
    isDoingValidation=NO;
    
    [ArtAPI
     cartSubmitForOrderWithSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
         [self requestOrderSubmitDidFinish: JSON];
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         NSString *errorMessagee = [JSON objectForKey:@"APIErrorMessage"];
         NSMutableDictionary *analyticsParams = [[NSMutableDictionary alloc] initWithCapacity:3];
         [analyticsParams setValue:[NSString stringWithFormat:@"%d",error.code] forKey:ANALYTICS_APIERRORCODE];
         [analyticsParams setValue:error.localizedDescription forKey:ANALYTICS_APIERRORMESSAGE];
         [analyticsParams setValue:[request.URL absoluteString] forKey:ANALYTICS_APIURL];
         [Analytics logGAEvent:ANALYTICS_CATEGORY_ERROR_EVENT withAction:errorMessagee withParams:analyticsParams];
         
         UIAlertView *alert = [[ UIAlertView alloc] initWithTitle:[ACConstants getLocalizedStringForKey:@"ERROR" withDefaultValue:@"Error"]
                                                          message: [JSON objectForKey:@"APIErrorMessage"]
                                                         delegate:nil
                                                cancelButtonTitle:[ACConstants getLocalizedStringForKey:@"OK" withDefaultValue:@"OK"]
                                                otherButtonTitles:nil, nil];
         
         [ alert show];
         alert = nil;
         [SVProgressHUD dismiss];
     }];
}


-(void) requestOrderSubmitDidFinish:(id)JSON
{
    NSDictionary *orderAttributes = [[JSON objectForKey:@"d"] objectForKeyNotNull:@"OrderAttributes"];
    NSString *orderNumber = [orderAttributes objectForKeyNotNull:@"OrderNumber"];
    self.orderNumber = orderNumber;
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction: ANALYTICS_EVENT_NAME_ORDER_CONFIRM_SHOWN withLabel:orderNumber];
    
    NSDictionary *cart = [ArtAPI cart];
    NSDictionary *cartTotal = [cart objectForKeyNotNull:@"CartTotal"];
    NSNumber *orderTotal = [cartTotal objectForKeyNotNull:@"Total"];
    
    //MKL need to do revenue tracking before order is submitted because cart gets blanked out
    NSNumber *taxTotal = [cartTotal objectForKeyNotNull:@"TaxTotal"];
    NSNumber *shippingTotal = [cartTotal objectForKeyNotNull:@"ShippingTotal"];
    NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"Currency_Code_to_use"];
    
    [Analytics logGARevenueEvent:orderNumber withRevenue:orderTotal withTax:taxTotal withShipping:shippingTotal withCurrencyCode:currencyCode];
    
    NSArray *shipmentsArray = [cart objectForKeyNotNull:@"Shipments"];
    if(shipmentsArray && (![shipmentsArray isKindOfClass:[NSNull class]]) && (shipmentsArray.count > 0)){
        for(NSDictionary *shipment in shipmentsArray){
            NSArray *cartItemsArray = [shipment objectForKeyNotNull:@"CartItems"];
            if(cartItemsArray && (![cartItemsArray isKindOfClass:[NSNull class]]) && (cartItemsArray.count > 0)){
                for(NSDictionary *cartItem in cartItemsArray){
                    NSDictionary *currentItem = [cartItem objectForKeyNotNull:@"Item"];
                    
                    NSNumber *itemQuant = (NSNumber *)[cartItem objectForKeyNotNull:@"Quantity"];
                    int quantity = 0;
                    if(itemQuant && ![itemQuant isKindOfClass:[NSNull class]]){
                        quantity = (int)[itemQuant integerValue];
                    }
                    
                    if(currentItem && ![currentItem isKindOfClass:[NSNull class]]){
                        
                        NSString *itemSku = [currentItem objectForKeyNotNull:@"Sku"];
                        
                        NSNumber *itemPrice = nil;
                        
                        NSString *itemName = @"";
                        NSString *itemCategory = @"";
                        
                        NSDictionary *itemAttributes = [currentItem objectForKeyNotNull:@"ItemAttributes"];
                        
                        if(itemAttributes && ![itemAttributes isKindOfClass:[NSNull class]]){
                            NSString *type = [itemAttributes objectForKeyNotNull:@"Type"];
                            NSString *title = [itemAttributes objectForKeyNotNull:@"Title"];
                            
                            if(type && ![type isKindOfClass:[NSNull class]]){
                                itemName = type;
                            }
                            
                            if(title && ![title isKindOfClass:[NSNull class]]){
                                itemCategory = title;
                            }
                        }
                        
                        NSDictionary *itemPriceDictionary = [currentItem objectForKeyNotNull:@"ItemPrice"];
                        if(itemPriceDictionary && ![itemPriceDictionary isKindOfClass:[NSNull class]]){
                            NSNumber *price = (NSNumber *)[itemPriceDictionary objectForKeyNotNull:@"Price"];
                            if(price && ![price isKindOfClass:[NSNull class]]){
                                itemPrice = price;
                            }
                        }
                        
                        
                        
                        [Analytics logGACartItemEventWithTransactionID:orderNumber forName:itemName withSku:itemSku forCategory:itemCategory atPrice:itemPrice forQuantity:quantity havingCurrencyCode:currencyCode];
                    }
                    
                }
            }
        }
    }
    
    if([ACConstants getCurrentAppLocation] == AppLocationSwitchArt){
        //need to set bundle if it is SwitchArt app
        
        //[SVProgressHUD dismiss];
        //[SVProgressHUD showWithStatus:@"Updating Account..." maskType:SVProgressHUDMaskTypeClear];
        
        NSLog(@"SwitchArt App - needs to set the billing address on the account");
        if(![AccountManager sharedInstance].isJustFrameSelected)////CS;== Added this method while fixing SWIT-131
            [[AccountManager sharedInstance] setBillingAddressForLastPurchase:self forOrderID:orderNumber];
        else//CS;== Added this method while fixing SWIT-131
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SHOW-TABBAR"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SHOW-ORDER"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IS-REORDER"];
            [[NSUserDefaults standardUserDefaults] setObject:self.orderNumber forKey:@"ORDER-NUMBER"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            [SVProgressHUD dismiss];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        
    }else{
        
        [SVProgressHUD dismiss];
        
        [ArtAPI setCart:nil];
        //[ArtAPI initilizeApp];
        
        ACOrderConfirmationViewController *controller = [[ACOrderConfirmationViewController alloc] initWithNibName:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ACOrderConfirmationViewController-iPad" :@"ACOrderConfirmationViewController" bundle:ACBundle];
        controller.orderNumber=orderNumber;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}



-(void)billingAddressSetSuccess:(NSString *)theOrderNumber withAddressID:(NSString *)addressID{
    
    NSLog(@"SwitchArt App - set billing address successfully");

    if(![AccountManager sharedInstance].isJustFrameSelected)//CS;== Added this method while fixing SWIT-131
        [[AccountManager sharedInstance] setShippingAddressForLastPurchase:self forOrderID:theOrderNumber];
    
}

-(void)billingAddressSetFailed:(NSString *)theOrderNumber{
    
    NSLog(@"Failed to set billing address");
    
    //need to do the same thing though even though the UserProperties update failed
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message: @"There was an error updating account information."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    
    [ alert show];
    
    [[AccountManager sharedInstance] setShippingAddressForLastPurchase:self forOrderID:theOrderNumber];
    
}

-(void)shippingAddressSetSuccess:(NSString *)theOrderNumber withAddressID:(NSString *)addressID{
    
    NSInteger printCount = [AccountManager sharedInstance].lastPrintCountPurchased;
    
    
    NSLog(@"SwitchArt App - set shipping address successfully");
    
    [[AccountManager sharedInstance] setBundlesForLoggedInUser:self forOrderID:theOrderNumber withAddressID:addressID subtractingPrintCount:printCount];
    
}

-(void)shippingAddressSetFailed:(NSString *)theOrderNumber{
    
    NSLog(@"Failed to set shipping address");
    
    NSInteger printCount = [AccountManager sharedInstance].lastPrintCountPurchased;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message: @"There was an error updating account information."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    
    [ alert show];
    
    //need to do the same thing though even though the UserProperties update failed
    
    [[AccountManager sharedInstance] setBundlesForLoggedInUser:self forOrderID:theOrderNumber withAddressID:@"" subtractingPrintCount:printCount];
    
}

-(void)bundlesSetSuccess{
    NSLog(@"Set bundles successfully");
    
    [ArtAPI setCart:nil];
    //[ArtAPI initilizeApp];
    
    //need to retrieve purchased bundles if SwitchArt
    //[SVProgressHUD showWithStatus:@"Updating Account..." maskType:SVProgressHUDMaskTypeClear];
    
    [[AccountManager sharedInstance] retrieveBundlesArrayForLoggedInUser:self];
    
}


-(void)bundlesSetFailed{
    NSLog(@"Failed to set bundles");
    
    //need to do the same thing though even though the UserProperties update failed
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message: @"There was an error updating the pack information on the account."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
    
    [ alert show];
    
    [ArtAPI setCart:nil];
    //[ArtAPI initilizeApp];
    
    //need to retrieve purchased bundles if SwitchArt
    
    [[AccountManager sharedInstance] retrieveBundlesArrayForLoggedInUser:self];
    
}


-(void)bundlesLoadedSuccessfully:(NSArray *)purchasedBundles
{
    [[AccountManager sharedInstance] setBundlesArray:purchasedBundles];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SHOW-TABBAR"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SHOW-ORDER"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IS-REORDER"];
    [[NSUserDefaults standardUserDefaults] setObject:self.orderNumber forKey:@"ORDER-NUMBER"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SVProgressHUD dismiss];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(void)bundlesLoadingFailed
{
    [SVProgressHUD dismiss];
    NSLog(@" requestForAccountGet failed ");
}

-(void)pickerPressed:(id)sender
{
    if(sender){
        self.tagFromPicker = (int)[sender tag];
    }
    
    if([ACConstants isSwitchArt] && COUNTRY_PICKER_TAG == self.tagFromPicker ) /* SWIT-238 : SwicthArt is only for US */
    {
        return;
    }
    
    [self.view endEditing:YES];
    
    ACCustomBillingCell *cell = (ACCustomBillingCell *)[[(UIButton*)sender superview] superview];
    self.selectedIndexPath = [self.billingAddressTableView indexPathForCell:cell];

    
    self.currentActiveTag = self.tagFromPicker;
    
    if(self.tagFromPicker == COUNTRY_PICKER_TAG){
        self.selectedIndexPath = self.countryIndexPath;
    }else if(self.tagFromPicker == STATE_PICKER_TAG){
        self.selectedIndexPath = self.stateIndexPath;
    }else{
        //do nothing
    }
    
    CommonpickerView.delegate = self;
    CommonpickerView.dataSource = self;
    
    [self keyboardWillShow:nil];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    if(CARD_TYPE_PICKER_TAG == self.tagFromPicker )
    {
        if(-1 == self.selectedCardTypeIndex){
            self.selectedCardTypeIndex = 0;
        }
        
        [CommonpickerView selectRow:self.selectedCardTypeIndex inComponent:0 animated:NO];
        [self pickerView:CommonpickerView didSelectRow:self.selectedCardTypeIndex inComponent:0];
    }
    else if(COUNTRY_PICKER_TAG == self.tagFromPicker )
    {
        if(-1 == self.selectedCountryIndex)
            self.selectedCountryIndex = 0;
        
        [ CommonpickerView selectRow:self.selectedCountryIndex inComponent:0 animated:NO];
        [ self pickerView:CommonpickerView didSelectRow:self.selectedCountryIndex inComponent:0];
    }
    else
    {
        if(-1 == self.selectedStateIndex)
            self.selectedStateIndex = 0;
        
        [ CommonpickerView selectRow:self.selectedStateIndex inComponent:0 animated:NO];
        [ self pickerView:CommonpickerView didSelectRow:self.selectedStateIndex inComponent:0];
    }
    
    self.pickerHolderView.frame = CGRectMake(0, self.view.frame.size.height - CHECKOUT_PICKER_HEIGHT, self.view.frame.size.width, CHECKOUT_PICKER_HEIGHT);
    //NSLog(@"pickerHolderView.frame: %@", NSStringFromCGRect(pickerHolderView.frame));
    
    [UIView commitAnimations];
}


-(void)configureThePicker
{
    self.pickerHolderView = [[ UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)+80, self.view.frame.size.width, CHECKOUT_PICKER_HEIGHT)];
    self.pickerHolderView.backgroundColor = [UIColor whiteColor];
    
    CommonpickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40,  self.view.frame.size.width, CHECKOUT_PICKER_HEIGHT-40)];
    
    //[CommonpickerView sizeToFit];
    CommonpickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    CommonpickerView.delegate = self;
    CommonpickerView.dataSource = self;
    CommonpickerView.showsSelectionIndicator = YES;
    
    if([ACConstants isArtCircles]){
        [CommonpickerView setBackgroundColor:[UIColor whiteColor]];
    }
    
    CGFloat screenWidth = CGRectGetWidth([self.view getCurrentScreenBoundsDependOnOrientation]);
    if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ){
        screenWidth = self.view.bounds.size.width;
    }
    self.inputAccView = [[ACKeyboardToolbarView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    self.inputAccView.toolbarDelegate = self;

    self.inputAccView.isModalKeyboard = YES;
    [self.inputAccView layoutDoneButton];

    UIView *pickerHeadView = inputAccView;
    pickerHeadView.alpha = 1.0f;
    CGRect pickerHeadFrame = pickerHeadView.frame;
    pickerHeadFrame.size = CGSizeMake(pickerHeadFrame.size.width+10, pickerHeadFrame.size.height);
    pickerHeadView.frame = pickerHeadFrame;
    
    [pickerHolderView addSubview:pickerHeadView];
    [pickerHolderView addSubview:CommonpickerView];
    [self.view addSubview:pickerHolderView];
}



-(UIPickerView *) generatePickerView:(UITextField *)sender
{
    self.tagFromPicker = [sender tag];
    //NSLog(@"Generated PickerView - type: %i", self.tagFromPicker);
    UIPickerView *picker = [[UIPickerView alloc] init];
    [picker sizeToFit];
    picker.autoresizingMask = (UIViewAutoresizingFlexibleWidth);// fixing CIRCLESIOS-827, so removing UIViewAutoresizingFlexibleHeight
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
    [picker setBackgroundColor:[UIColor whiteColor]];
    return picker;
}

-(void)chooseAdressAtIndex:(int)index
{
    NSDictionary *address      = (__bridge_transfer NSDictionary *)ABMultiValueCopyValueAtIndex(self.contactAdresses, index);
    self.postalCode = [address objectForKey: @"ZIP"];
    self.city = [address objectForKey: @"City"];
    
    NSString *countryFromAddress = [[[address objectForKey:@"Country"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
    
    NSString *countryCodeFromAddress = [[[address objectForKeyNotNull:@"CountryCode"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
    
    if([[countryFromAddress uppercaseString] isEqualToString:@"USA"])
        countryFromAddress = @"US";
    
    if([[countryCodeFromAddress uppercaseString] isEqualToString:@"USA"])
        countryCodeFromAddress = @"US";
    
    if(([ACConstants getCurrentAppLocation] == AppLocationSwitchArt) && !([@"US" isEqualToString:countryCodeFromAddress])) // For SwitchArt, Shipping only to US - SWIT-238
    {
        countryCodeFromAddress = @"US";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Address" message:@"At the moment, we are shipping to US address only" delegate:nil  cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        // return;
    }
    
    for(NSDictionary *country in self.countries)
    {
        NSString *loopCountryName = [[[country objectForKeyNotNull:@"Name"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
        NSString *loopCountryCode = [[[country objectForKeyNotNull:@"IsoA2"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
        if([countryFromAddress isEqualToString:loopCountryName]||[countryFromAddress isEqualToString:loopCountryCode]||[countryCodeFromAddress isEqualToString:loopCountryName]||[countryCodeFromAddress isEqualToString:loopCountryCode])
        {
            self.countryPickerValue = [country objectForKeyNotNull:@"Name"];
            self.selectedCountryIndex = [self.selectedCountryCode isEqualToString:@"US"]?0:[ self.countries indexOfObject:country]+1;
            self.selectedCountryCode = [country objectForKeyNotNull:@"IsoA2"];
            break;
        }
    }
    
    if(self.selectedCountryIndex < 0){
        self.selectedCountryCode = nil;
    }
    
    if([self.selectedCountryCode isEqualToString:@"US"])
    {
        NSString *stateFromAddress = [[[address objectForKey:@"State"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
        for(NSDictionary *state in self.states)
        {
            NSString *loopStateName = [[[state objectForKeyNotNull:@"Name"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
            NSString *loopStateCode = [[[state objectForKeyNotNull:@"StateCode"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
            if([stateFromAddress isEqualToString:loopStateName]||[stateFromAddress isEqualToString:loopStateCode])
            {
                self.selectedStateIndex = [ self.states indexOfObject:state];
                self.statePickerValue = [state objectForKeyNotNull:@"Name"];
                break;
            }
        }
    }
    else
    {
        self.stateTextField.text = [address objectForKey:@"State"];
    }
    
    NSString *streetAddress = [address objectForKey:@"Street"];
    self.addressLine1 = [streetAddress stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    [ self.billingAddressTableView reloadData];

    #ifndef __clang_analyzer__
    if (self.contactAdresses) {
        CFRelease(self.contactAdresses);
    }
    #endif
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIAlertViewDelegate --
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex//CS: fixing added this for the iOS 8 issues fixes //CIRCLESIOS-1667
{
    if(777 == alertView.tag)
    {
        if(0 == buttonIndex)
            return;
        
        NSDictionary *cityDict = [ self.cityArray objectAtIndex:buttonIndex-1];
        self.cityTextField.text = [cityDict objectForKeyNotNull:@"City"];
        
        NSString *stateCodee = [cityDict objectForKeyNotNull:@"State"];
        NSDictionary *stateDict = [ self getStateForCode:stateCodee];
        NSString *stateName = [stateDict objectForKeyNotNull:@"Name"];
        if(stateName)
        {
            self.selectedStateIndex = [ self.states indexOfObject:stateDict];
            self.statePickerValue = stateName;
            self.city = [cityDict objectForKeyNotNull:@"City"];
            self.postalCode = [cityDict objectForKeyNotNull:@"ZipCode"];
            
            self.willShowCityAndState = YES;
            [self hidePickerWithAnimation:NO]; /*Diss miss country picker*/
            
            /*            [self.billingAddressTableView beginUpdates];
             NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:8 inSection:0],[NSIndexPath indexPathForRow:9 inSection:0],nil];
             [self.billingAddressTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
             [self.billingAddressTableView endUpdates]; */
            
            [ self.billingAddressTableView reloadData];
        }
    }
    else
    {
        if(0 == buttonIndex){
#ifndef __clang_analyzer__
            if (self.contactAdresses)
            {
                CFRelease(self.contactAdresses);
            }
#endif
            return;
        }
        
        [ self chooseAdressAtIndex:buttonIndex-1];
    }

}

#pragma mark -
#pragma mark UIActionSheetDelete
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    // iPad does not have cancel button, increase index to think it does
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        buttonIndex++;
    }
    
    if(777 == actionSheet.tag)
    {
        if(0 == buttonIndex)
            return;

        NSDictionary *cityDict = [ self.cityArray objectAtIndex:buttonIndex-1];
        self.cityTextField.text = [cityDict objectForKeyNotNull:@"City"];
        
        NSString *stateCodee = [cityDict objectForKeyNotNull:@"State"];
        NSDictionary *stateDict = [ self getStateForCode:stateCodee];
        NSString *stateName = [stateDict objectForKeyNotNull:@"Name"];
        if(stateName)
        {
            self.selectedStateIndex = [ self.states indexOfObject:stateDict];
            self.statePickerValue = stateName;
            self.city = [cityDict objectForKeyNotNull:@"City"];
            self.postalCode = [cityDict objectForKeyNotNull:@"ZipCode"];
            
            self.willShowCityAndState = YES;
            [self hidePickerWithAnimation:NO]; /*Diss miss country picker*/
            
            /*            [self.billingAddressTableView beginUpdates];
             NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:8 inSection:0],[NSIndexPath indexPathForRow:9 inSection:0],nil];
             [self.billingAddressTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
             [self.billingAddressTableView endUpdates]; */
            
            [ self.billingAddressTableView reloadData];
        }
    }
    else if ('n' == actionSheet.tag)
    {
        if(0 == buttonIndex)
        {
            [self showAbout];
        }
        else if(1 == buttonIndex)
        {
            //[[Helpshift sharedInstance] showSupport:self];
        }
        
    }
    else
    {
        if(0 == buttonIndex){
#ifndef __clang_analyzer__
            if (self.contactAdresses)
            {
                CFRelease(self.contactAdresses);
            }
#endif
            return;
        }

        [ self chooseAdressAtIndex:buttonIndex-1];
    }
    
}

-(void)showAbout{
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_INFO_BUTTON_PRESSED];
    
    ACWebViewController * webViewController = [[ACWebViewController alloc] initWithURL:[NSURL URLWithString:[ArtAPI sharedInstance].aboutURL]];
    webViewController.toolbarHidden = YES;
    webViewController.titleHidden = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

-(NSDictionary*)getStateForCode:(NSString*)stateCodee
{
    for(NSDictionary *state in self.states)
    {
        NSString *loopStateCode = [[[state objectForKeyNotNull:@"StateCode"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
        if([stateCodee isEqualToString:loopStateCode])
        {
            return state;
        }
    }
    
    return  nil;
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

// Called after the user has pressed cancel
// The delegate is responsible for dismissing the peoplePicker
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}


- (void) populateDataWithPerson:(ABRecordRef)person
{
    self.firstName = @"";
    self.lastName = @"";
    self.company = @"";
    self.phone = @"";
    self.addressLine1 = @"";
    self.addressLine2 = @"";
    self.city = @"";
    self.postalCode = @"";
    self.selectedCountryIndex = -1;
    self.selectedStateIndex = -1;
    self.countryPickerValue = [ACConstants getLocalizedStringForKey:@"SELECT_COUNTRY" withDefaultValue:@"Select Country"];
    self.statePickerValue = [ACConstants getLocalizedStringForKey:@"SELECT_STATE" withDefaultValue:@"Select State"];
    self.zipLabelText = [ACConstants getLocalizedStringForKey:@"ZIP_POSTAL_CODE" withDefaultValue:@"ZIP/Postal Code"];

    self.willShowCityAndState = YES;
    
    NSString *fName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    self.firstName = [NSString stringWithFormat:@"%@",fName];
    self.lastName = lName?[NSString stringWithFormat:@"%@",lName]:@"";
    
    //self.firstName =[NSString stringWithFormat:@"%@",fName];
    
    //if(fName)
    //    CFRelease(fName);
    //if(lName)
    //    CFRelease(lName);
    
    NSString *company = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
    self.company = company;
    
    //if(company)
    //    CFRelease(company);
    
    
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    for (CFIndex i = 0; i < ABMultiValueGetCount(emails); i++)
    {
        //NSString *label = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(emails, i);
        //NSString *email  = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, i);
        if (i == 0) {
            // self.emailTextField.text = email;
        }
        //if (label) {
        //    CFRelease(label);
        //}
        //if (email) {
        //    CFRelease(email);
        //}
        
    }
    if (emails) {
        CFRelease(emails);
    }
    
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    int phoneCount = ABMultiValueGetCount(phones);
    if(1 <= phoneCount)
    {
        NSString *ph = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, 0);
        self.phone =  ph;
    }
    
    if (phones) {
        CFRelease(phones);
    }
    
    ABMultiValueRef addresses = ABRecordCopyValue(person, kABPersonAddressProperty);
    self.contactAdresses = addresses;
//    if (addresses) {
//        CFRelease(addresses);
//    }
    
    
    int count = ABMultiValueGetCount(self.contactAdresses);
    if(1 == count)
    {
        [ self chooseAdressAtIndex:0];
    }
    else if(1 < count)
    {
        NSString *title = [ACConstants getLocalizedStringForKey:@"CHOOSE_AN_ADDRESS_FOR_SHIPMENT" withDefaultValue:@"Choose an Address for Shipment"];
        
        
        int currentDeviceOSVersion = [UIDevice currentDevice].systemVersion.intValue;//CS:fixing CIRCLESIOS-1667
        if(currentDeviceOSVersion < 8)// For iOS 7 versions
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                     delegate:self
                                                            cancelButtonTitle:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad?nil:[ACConstants getLocalizedStringForKey:@"CANCEL" withDefaultValue:@"Cancel"]
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:nil, nil];
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(self.contactAdresses); i++)
            {
                CFStringRef labelStringRef = ABMultiValueCopyLabelAtIndex(self.contactAdresses, i);
                //mkl localizing label
                NSString *phoneLabelLocalized = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(labelStringRef);
                NSString *labelName = [NSString stringWithFormat:@"%@",phoneLabelLocalized];
                CFRelease(labelStringRef);
                labelName = [ labelName stringByReplacingOccurrencesOfString:@"_$!<" withString:@""];
                labelName = [ labelName stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
                [actionSheet addButtonWithTitle:labelName];
            }
            actionSheet.tag = 888;
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];

        }
        else // For iOS 8
        {
            UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:nil];
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(self.contactAdresses); i++)
            {
                CFStringRef labelStringRef = ABMultiValueCopyLabelAtIndex(self.contactAdresses, i);

                NSString *phoneLabelLocalized = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(labelStringRef);
                NSString *labelName = [NSString stringWithFormat:@"%@",phoneLabelLocalized];
                CFRelease(labelStringRef);
                labelName = [ labelName stringByReplacingOccurrencesOfString:@"_$!<" withString:@""];
                labelName = [ labelName stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
                [anAlert addButtonWithTitle:labelName];
            }
            
            anAlert.tag = 888;
            
            [anAlert show];
        }

    }
    
    
    [self.billingAddressTableView reloadData];
    
    //Advaance to the first required cell:
    if ([self.nameField.text length] < 1)
    {
        [self.nameField becomeFirstResponder];
        return;
    }
    //    if ([self.lastNameTextField.text length] < 1) {
    //        [self.lastNameTextField becomeFirstResponder];
    //        return;
    //    }
    if ([self.addressLine1Field.text length] < 1)
    {
        [self.addressLine1Field becomeFirstResponder];
        return;
    }
    if ([self.cityField.text length] < 1)
    {
        [self.cityField becomeFirstResponder];
        return;
    }
    if ([self.countryField.text length] < 1)
    {
        [self.countryField becomeFirstResponder];
        return;
    }
    if ([self.stateField.text length] < 1)
    {
        [self.stateField becomeFirstResponder];
        return;
    }
    if ([self.postalCodeField.text length] < 1)
    {
        [self.postalCodeField becomeFirstResponder];
        return;
    }
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self populateDataWithPerson:person];
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

//!-- CS:iOS 8 new methods of ABPeopleNavigationController
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person
{
    [self populateDataWithPerson:person];
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark #pragma mark

#ifdef SUPPORT_LILITAB_CARD_READER
- (void)accessoryWasConnected:(EAAccessory *)accessory {
    //NSLog(@"reader was connected %@", accessory);
    //self.readerStatusLabel.text = @"Please swipe your credit card through the reader now.";
    
    // Set Default Credit Card Label String
    _creditCardString = [ACConstants getLocalizedStringForKey:@"SWIPE_CARD_TITLE" withDefaultValue:@"Please swipe your credit card through the reader now"];
    
    // Is KIOSK, Mask Credit Card
    _maskCreditCard = YES;
}

- (void)accessoryWasDisconnected {
    //NSLog(@"reader was connected");
    //self.readerStatusLabel.text = @"Unable to process credit cards at this time.";
    _creditCardString = [ACConstants getLocalizedStringForKey:@"CREDIT_CARD" withDefaultValue:@"CREDIT CARD"];
    
    // Is NOT KIOSK, No Mask Credit Card
    _maskCreditCard = NO;
}

- (void) accessoryDidPassRawDataOnly:(NSString *)rawData    {
    BOOL DEBUG_LILI_TAB = NO;
    
    if(DEBUG_LILI_TAB)NSLog(@"accessoryDidPassRawDataOnly complete string passed in: %@",rawData);
    
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_LILITAB_SWIPE];
    
    // With specially formatted cards, you'll have to customize this to
    // look for the last character in the data passed in. For Bank cards
    // and the default 2 track reader config, there should be two '?' end
    // sentinels...one at the end of T1 and one at the end of T1
    
    // Since the actual RAW data from the reader is coming over, you'll get
    // non-ASCII characters in front of and at the end of the raw string. To
    // use them parse them out. Here, I extract starting with the first start sentinel '%',
    // break it up into two "halves", stop at the second half end sentinel '?', and
    // send it to the view controller's label.
    //
    NSRange t1StartSentinel = [rawData  rangeOfString:@"%"];    // Find T1 Start Sentinel
    NSMutableString *firstHalf = [NSMutableString stringWithString:[rawData  substringFromIndex:t1StartSentinel.location]];
    NSRange t1EndSentinel = [firstHalf rangeOfString:@"?"];
    firstHalf = [NSMutableString stringWithString:[firstHalf  substringToIndex:t1EndSentinel.location+1]];
    //NSLog(@"****accessoryDidPassRawDataOnly: T1= %@",[firstHalf substringToIndex:t1EndSentinel.location+1]);
    
    // VERY CRUDE extractions...you'll want to customize how you do it for your UI
    
    // Pull out account number and stick it into a field
    NSRange firstAccountNumberDelimiter = [firstHalf rangeOfString:@"B"];
    if(DEBUG_LILI_TAB)NSLog(@"firstAccountNumberDelimiter location: %d length: %d", firstAccountNumberDelimiter.location, firstAccountNumberDelimiter.length );
    if(  firstAccountNumberDelimiter.length == 0){
        
        [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_LILITAB_CARD_INVALID];
        
        UIAlertView *alert = [[ UIAlertView alloc] initWithTitle:[ACConstants getLocalizedStringForKey:@"ERROR" withDefaultValue:@"Error"]
                                                         message: [ACConstants getLocalizedStringForKey:@"SWIPE_CARD_ERROR_MSG" withDefaultValue:@"Sorry but this card cannot be read.  Please type in your credit card in the fields provided."]
                                                        delegate:nil
                                               cancelButtonTitle:[ACConstants getLocalizedStringForKey:@"OK" withDefaultValue:@"OK"]
                                               otherButtonTitles:nil, nil];
        
        [alert show];
        alert = nil;
        return;
    }
    NSMutableString *workingString = [NSMutableString stringWithString:[firstHalf substringFromIndex:firstAccountNumberDelimiter.location+1]];
    NSRange lastAccountNumberDelimiter = [workingString rangeOfString:@"^"];
    NSMutableString *accountNumber = [NSMutableString stringWithString:[workingString substringToIndex:lastAccountNumberDelimiter.location]];
    if(DEBUG_LILI_TAB)NSLog(@"cardNumber: %@",accountNumber);
    self.cardNumber = accountNumber;
    
    // Display card type - this is a VERY SIMPLE calculation for one of four basic US card types
    // DETERMINE CARD TYPE
    // This bit is the most complicated because there are so many variations and this
    // stuff changes monthly. Here, we look at the issuerIDNumber and determine the card type.
    // For this "demo code" we're only going to consider four card types: AMEX, Discover, MC, and VISA.
    // Determination Algorithm:
    // 1) AMEX:  1st TWO characters of issuerIDNumber is either "34" or "37"
    // 2) DISC:  1st FOUR characters of issuerIDNumber is "6011"
    // 3) MC:    1st TWO characters of issuerIDNumber is one of: 51,52,53,54,55
    // 4) VISA:  1st character of issuerIDNumber = '4'
    // 5) otherwise set it to 5
    //
    // In an ideal world, we'd tap into an Issuer database to get the most current info,
    // but these are the 4 most common card types in the US and should work 95% of the time or more.
    
    NSString *issuerIDNumber = [accountNumber   substringWithRange:NSMakeRange(0, 6)];
    
    int ccIndex = -1;
    
    if ( ([issuerIDNumber  rangeOfString:@"34"].location == 0) ||
        ([issuerIDNumber  rangeOfString:@"37"].location == 0) ) {
        if(DEBUG_LILI_TAB)NSLog(@"AMEX");
        ccIndex  = [ACBillingAddressViewController getCCIndexFromCCTypeID:CC_TYPE_AMEX
                                                       fromPaymentOptions:self.paymentOptions];
        self.selectedCardTypeIndex = ccIndex;
        
    } else if ( [issuerIDNumber  rangeOfString:@"6011"].location == 0) {
        if(DEBUG_LILI_TAB)NSLog(@"DISCOVER");
        self.selectedCardTypeIndex  = [ACBillingAddressViewController getCCIndexFromCCTypeID:CC_TYPE_DISCOVER
                                                                          fromPaymentOptions:self.paymentOptions];
        
        
    } else if ( ([issuerIDNumber  rangeOfString:@"51"].location == 0) ||
               ([issuerIDNumber  rangeOfString:@"52"].location == 0) ||
               ([issuerIDNumber  rangeOfString:@"53"].location == 0) ||
               ([issuerIDNumber  rangeOfString:@"54"].location == 0) ||
               ([issuerIDNumber  rangeOfString:@"55"].location == 0) ) {
        if(DEBUG_LILI_TAB)NSLog(@"MASTERCARD");
        ccIndex = [ACBillingAddressViewController getCCIndexFromCCTypeID:CC_TYPE_MASTERCARD
                                                      fromPaymentOptions:self.paymentOptions];
        self.selectedCardTypeIndex = ccIndex;
        
        
    } else if ( [issuerIDNumber  rangeOfString:@"4"].location == 0) {
        if(DEBUG_LILI_TAB)NSLog(@"VISA");
        ccIndex = [ACBillingAddressViewController getCCIndexFromCCTypeID:CC_TYPE_VISA
                                                      fromPaymentOptions:self.paymentOptions];
        self.selectedCardTypeIndex = ccIndex;
    } else {
        ccIndex = -1;
    }
    //NSLog(@"ccIndex: %d self.selectedCardTypeIndex: %d",  ccIndex, self.selectedCardTypeIndex );
    
    self.cardType = (-1 == ccIndex)?[ACConstants getLocalizedStringForKey:@"SELECT_CARD_TYPE" withDefaultValue:@"Select Card Type"]:[ self.cardTypes objectAtIndex:ccIndex];
    
    if(ccIndex > -1){
        
        // remove account number from working string
        workingString = [NSMutableString stringWithString:[workingString substringFromIndex:lastAccountNumberDelimiter.location+1]];
        
        // Pull out last name and stick it into a field
        NSRange nameSeparator = [workingString rangeOfString:@"/"];
        self.lastName = [NSMutableString stringWithString:[workingString substringToIndex:nameSeparator.location]];
        
        // remove last name from working string
        workingString = [NSMutableString stringWithString:[workingString substringFromIndex:nameSeparator.location+1]];
        
        // pull out first name and stick it into a field
        nameSeparator = [workingString rangeOfString:@"^"];
        self.firstName = [NSMutableString stringWithString:[workingString substringToIndex:nameSeparator.location]];
        
        // remove first name from working string
        workingString = [NSMutableString stringWithString:[workingString substringFromIndex:nameSeparator.location+1]];
        
        // pull out year and stick it into a field
        NSMutableString *year = [NSMutableString stringWithString:[workingString substringToIndex:2]];
        if( year && year.length == 2){
            // TODO: Fix me before the year 3000
            year = [NSMutableString stringWithFormat:@"20%@", year];
        }
        if(DEBUG_LILI_TAB)NSLog(@"year: %@", year);
        self.resultString2 = year;
        
        // remove year from working string
        workingString = [NSMutableString stringWithString:[workingString substringFromIndex:2]];
        
        // pull out month and stick it into a field
        NSMutableString *month = [NSMutableString stringWithString:[workingString substringToIndex:2]];
        //NSLog(@"month: %@", month);
        self.resultString = month;
        
        if(DEBUG_LILI_TAB)NSLog(@"expDate: %@", [NSString stringWithFormat:@"%@/%@",month,year] );
        self.expDate = [NSString stringWithFormat:@"%@/%@",month,year];
        self.expDateField.text = self.expDate;
        
        [self.billingAddressTableView reloadData];
    }
}
#endif

@end
