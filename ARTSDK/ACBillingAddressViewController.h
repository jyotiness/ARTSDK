//
//  PAABillingAddressViewController.h
//  PhotosArt
//
//  Created by Anuj Agarwal on 10/09/12.
//  Copyright (c) 2012 Ness Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACCheckoutTextField.h"
#import <AddressBookUI/AddressBookUI.h>
#import "GAITrackedViewController.h"
#import "CardIO.h"

/**
 * A view controller that collects a users billing information
 *
 * <h2>NSNotificationCenter</h2>
 *
 * Responds notification: NOTIFICATION_DISMISS_MODAL  This will close the modal
 *
 */

@interface ACBillingAddressViewController : GAITrackedViewController<UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate,UITextViewDelegate,ABPeoplePickerNavigationControllerDelegate,UIActionSheetDelegate,CardIOPaymentViewControllerDelegate>
{
    NSString * cardType;
    NSString * cardNumber;
    NSString * expDate;
    NSString *securityCode;
    
//    ACCheckoutTextField* cardTypeField;
//    ACCheckoutTextField* cardNumberField ;
//	ACCheckoutTextField* expDateField ;
//	ACCheckoutTextField* securityCodeField ;
    
    BOOL isDoingValidation;
	NSString* company_ ;
	NSString* phone_ ;
    BOOL isStateFieldHavingText;
	
//	UITextField* nameField_ ;
//	UITextField* companyField_ ;
	ACCheckoutTextField* phoneField ;
    
    NSString* addressLine1 ;
	NSString* addressLine2 ;
	NSString* postalCode ;
	NSString* city ;	
	
//	UITextField* addressLine1Field ;
//	UITextField* addressLine2Field ;
//	UITextField* postalCodeField ;
//	UITextField* cityField ;	
//    UITextField* stateField;
//    UITextField* countryField;
    UISwitch *shipAddressSwitch;
    NSMutableArray *numberOfSections;
    UIPickerView *CommonpickerView;
    
    UIToolbar *keyboardDoneButtonView;
    ACCheckoutTextField *mFailedTextField;
}

@property(nonatomic, strong) UITextField *addressLine1Field;
@property(nonatomic, strong) UITextField *addressLine2Field;
@property(nonatomic, strong) UITextField *postalCodeField;
@property(nonatomic, strong) UITextField *cityField;
@property(nonatomic, strong) UITextField *stateField;
@property(nonatomic, strong) UITextField *countryField;
@property(nonatomic, strong) UITextField *nameField;
@property(nonatomic, strong) UITextField *companyField;

@property (nonatomic, assign)  int selectedCardTypeIndex;
@property (nonatomic, strong)  ACCheckoutTextField *failedTextField;
@property(nonatomic,strong) NSArray *cardTypes;
@property(nonatomic,strong) NSString *resultString;
@property(nonatomic,strong) NSString *resultString2;
@property(nonatomic,strong) NSArray *dateColumn;
@property(nonatomic,strong) NSArray *yearColumn;
@property(nonatomic, strong) UIPickerView *cardTypePickerView;
@property(nonatomic, strong) UIPickerView *expDatePickerView;
@property(nonatomic,strong) ACCheckoutTextField* cardTypeField;
@property(nonatomic,strong) ACCheckoutTextField* cardNumberField ;
@property(nonatomic,strong) ACCheckoutTextField* expDateField ;
@property(nonatomic,strong) ACCheckoutTextField* securityCodeField ;
@property(nonatomic,strong) NSString *expDateValue;
@property(nonatomic,assign) int tagFromPicker;
@property(nonatomic,strong) NSString *countryPickerValue;
@property(nonatomic,strong) NSString *selectedCountryCode;
@property(nonatomic,strong) NSString *statePickerValue;
@property(strong, nonatomic) IBOutlet UITableView *billingAddressTableView;
@property(nonatomic,copy)  NSString * cardType;
@property(nonatomic,copy) NSString* cardNumber ;
@property(nonatomic,copy) NSString *stateFieldValue;
@property(nonatomic,copy) NSString *emailAddress;
@property(nonatomic,copy) NSString* stateValue ;
@property(nonatomic, strong) UITextField *txtActiveField;
@property(nonatomic, strong) UIButton *btnDone;
@property(nonatomic, strong) UIButton *btnNext;
@property(nonatomic, strong) UIButton *btnPrev;
@property(nonatomic,copy) NSString* expDate ;
@property(nonatomic,copy) NSString* securityCode ;
@property(nonatomic,strong)  UISwitch *shipAddressSwitch;
@property(nonatomic, strong) NSArray *dataCartItems;
@property (nonatomic, strong)  ACCheckoutTextField *lastNameTextField;
@property(nonatomic, strong)  ACCheckoutTextField *firstNameTextField;
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;
@property(nonatomic,strong) NSString *stateCode ;
@property(nonatomic,strong) NSString *stateValueToPassOrderConfirmationScreen;
@property(nonatomic, strong) ACCheckoutTextField *address1TextField;
@property(nonatomic, strong) ACCheckoutTextField *address2TextField;
@property(nonatomic, strong) ACCheckoutTextField *companyTextField;
@property(nonatomic, strong) ACCheckoutTextField *cityTextField;
@property(nonatomic,strong) ACCheckoutTextField *phoneField;
@property(nonatomic,strong) ACCheckoutTextField *stateTextField;
@property(nonatomic,strong) UIButton *countryButton;
@property(nonatomic,strong) UIButton *stateButton;
@property(nonatomic,strong) UIButton *cardTypeButton;
@property(nonatomic,strong) UIView *pickerHolderView;
@property(nonatomic, strong) NSArray *countries;
@property(nonatomic, strong) NSArray *states;
@property(nonatomic, strong) ACCheckoutTextField *zipTextField;
@property(nonatomic,assign) BOOL usesAddressFromShpping;
@property(nonatomic,strong) NSMutableArray *numberOfSections;
@property(strong, nonatomic) IBOutlet UILabel *discountTotalLabel;
@property (nonatomic, strong) NSArray *countryNamesArray;
@property (nonatomic, strong) NSArray *countryIDArray;
@property(nonatomic,copy) NSString* company;
@property(strong, nonatomic) IBOutlet UIView *footerBillingAddressVC;
@property(nonatomic,copy) NSString* phone;
@property (weak, nonatomic) IBOutlet UILabel *subtotalTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTitleLabel;
@property(strong, nonatomic) IBOutlet UILabel *orderTotalLabel;
@property(strong, nonatomic) IBOutlet UILabel *shippingTotalLabel;
@property(strong, nonatomic) IBOutlet UILabel *subTotalLabel;
@property(strong, nonatomic) IBOutlet UILabel *estimatedSalesTax;
@property (strong, nonatomic) IBOutlet UILabel *estimatedSalesTaxTitle;
@property(strong, nonatomic) IBOutlet UIButton *orderConfirmButton;
@property(strong, nonatomic) IBOutlet UILabel *billingViewHeader;
@property(strong, nonatomic) IBOutlet UIButton *billingViewBackButton;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIView *fixedPriceDetailsView;
@property (strong, nonatomic) IBOutlet UILabel *discountTitleLabel;
@property(nonatomic,copy) NSArray *cityArray;
@property(nonatomic,assign) BOOL willShowCityAndState;
@property(nonatomic,copy)NSString *zipUnderValidation;
@property (nonatomic, assign) ABMultiValueRef contactAdresses;
@property (strong, nonatomic) IBOutlet UIView *accessoryButtonView;
@property (strong, nonatomic) IBOutlet UIView *pickerAccessoryButtonView;

@property(nonatomic,copy) NSString* firstName ;
@property (nonatomic,copy) NSString* lastName;
@property(nonatomic,copy) NSString* addressLine1 ;
@property(nonatomic,copy) NSString* addressLine2 ;
@property(nonatomic,copy) NSString* postalCode ;
@property(nonatomic,copy) NSString* city ;
@property (readwrite) NSInteger selectedCountryIndex;
@property (readwrite) NSInteger selectedStateIndex;
@property(nonatomic,assign) BOOL stateValidationRequired;
@property(nonatomic,assign) BOOL phoneValidationRequired;
@property (strong, nonatomic) NSString *zipLabelText;

@property (strong, nonatomic) NSArray *paymentOptions;

@property (strong, nonatomic) NSString *subTotalValue;
@property (strong, nonatomic) NSString *estimatedSalesTaxValue;
@property (strong, nonatomic) NSString *shippingTotalValue;
@property (strong, nonatomic) NSString *orderTotalValue;
@property (strong, nonatomic) NSString *discountTotalValue;

@property (strong, nonatomic) NSIndexPath *countryIndexPath;
@property (strong, nonatomic) NSIndexPath *stateIndexPath;
@property (readwrite) int currentActiveTag;
@property(assign) BOOL isUSAddressInvalid;

//@property (nonatomic, strong) NSArray *dataShippingOptions;

- (UITextField*) makeTextField: (NSString*)text
                  placeholder: (NSString*)placeholder  ;

-(void)hidePickerWithAnimation:(BOOL)animated;
-(void)preLoadEmailFromShipping;
-(void)prepareCountryList;
-(void)validateSelectedCountry:(int)countryIndex;
-(void)chooseAdressAtIndex:(int)index;
-(void)cityAndStateSuggestionForZip:(NSString*)newStr;

- (IBAction)textFieldFinished:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)proceedToOrderConfirmation:(id)sender;
+(int)getCCIndexFromCCTypeID:(NSString *)ccTypeID fromPaymentOptions:(NSArray *)paymentOptions;

@end
