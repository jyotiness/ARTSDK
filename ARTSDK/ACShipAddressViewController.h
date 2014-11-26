//
//  PAAShippingAddressViewController.h
//  PhotosArt
//
//  Created by Jobin on 03/10/12.
//
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ACCheckoutTextField.h"
#import "ACConstants.h"
#import "GAITrackedViewController.h"
#import "ACiPhoneLoginViewController.h"
#import "AccountManager.h"


/**
 * A view controller that collects a users shipping address.
 *
 * <h2>NSNotificationCenter</h2>
 *
 * Responds notification: NOTIFICATION_DISMISS_MODAL  This will close the modal.
 *
 */

typedef enum ContactPickeMode {
    ContactPickeModeName,
    ContactPickeModeEmail,
    ContactPickeModeSignup
}ContactPickeMode;

@protocol ACShipAddressViewDelegate;

@interface ACShipAddressViewController : GAITrackedViewController<UITextFieldDelegate,UITextViewDelegate,ABPeoplePickerNavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource,UIActionSheetDelegate,UIAlertViewDelegate,ACiPhoneLoginDelegate,AccountManagerDelegate>//,PayPalPaymentDelegate,PayPalFuturePaymentDelegate>
{
    UIView   *mPickerHolderView;
    ACCheckoutTextField *mFailedTextField;
    BOOL isDoingValidation;
}
@property(nonatomic,assign) ContactPickeMode contactPickeMode;
@property(nonatomic,assign) NSInteger tagFromPicker;
@property(nonatomic,retain) NSString *countryPickerValue;
@property(nonatomic,retain) NSString *statePickerValue;
@property (retain, nonatomic) IBOutlet UIView *FooterNextViewButton;
@property (nonatomic,strong) IBOutlet UIView *loginHeaderView;

@property(nonatomic,copy) NSArray *emailArray;
@property(nonatomic,copy) NSArray *cityArray;
@property(nonatomic,assign) BOOL willShowCityAndState;

-(UITextField*) makeTextField: (NSString*)text
                  placeholder: (NSString*)placeholder  ;
@property (nonatomic, retain) NSArray *dataShippingOptions;

@property (readwrite) NSUInteger *selectedShippingType;
@property (readwrite) NSInteger selectedCountryIndex;
@property (readwrite) NSInteger selectedStateIndex;
@property(nonatomic,retain) NSString *selectedCountryCode;
@property(nonatomic,retain) UIPickerView *countrypickerView;
@property(nonatomic,retain) UITextField* stateField;
@property(nonatomic,retain) UITextField* nameField;
@property(nonatomic,retain) UITextField* companyField;
//@property(nonatomic,retain) UITextField* phoneField;
@property(nonatomic,retain) UITextField* addressLine1Field;
@property(nonatomic,retain) UITextField* addressLine2Field;
@property(nonatomic,retain) UITextField* cityField;
@property(nonatomic,retain) UITextField* postalCodeField;
@property(assign) BOOL isUSAddressInvalid;
@property(readwrite) ACCheckoutType artCheckoutType;

@property (nonatomic,strong) IBOutlet UISegmentedControl *segmentedButton;
@property (nonatomic,strong) IBOutlet UIButton *facebookLoginButton;
@property (nonatomic,strong) IBOutlet UIView *loginView;
@property (nonatomic,strong) IBOutlet UIView *signupView;
@property (nonatomic,strong) IBOutlet UIView *facebookLoginHolderView;

@property (nonatomic,strong) IBOutlet UILabel *loginTitleLabel;

@property (nonatomic,strong)  UITextField *signupFirstNameTextField;
@property (nonatomic,strong)  UITextField *signupLastNameTextField;

@property (nonatomic,strong) IBOutlet UITextField *emailLoginTextField;
@property (nonatomic,strong) IBOutlet UITextField *passwordLoginTextField;
@property (nonatomic,strong) IBOutlet UITextField *emailSignupTextField;
@property (nonatomic,strong) IBOutlet UITextField *passwordSignupTextField;
@property (nonatomic,strong) IBOutlet UITextField *confirmPasswordTextField;

@property (nonatomic, assign) id <ACiPhoneLoginDelegate> loginDelegate;
@property (nonatomic,assign) LoginMode loginMode;

- (IBAction)toggleSegmentedAction:(id)sender;

- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)loginWithEmail:(id)sender;
- (IBAction)forgotPassword:(id)sender;

-(IBAction)textFieldFinished:(id)sender ;
-(IBAction)goBack:(id)sender;
-(IBAction)close:(id)sender;
-(IBAction)continueToPayment:(id)sender;

@property (retain, nonatomic) NSString *zipLabelText;

@property (nonatomic,copy) NSString* name ;
@property (nonatomic,copy) NSString* lastName ;
@property (nonatomic,copy) NSString* company ;
@property (strong, nonatomic) IBOutlet UITableView *shippingAddressTableView;
@property (nonatomic,copy) NSString* phone ;

@property (nonatomic,copy) NSString* addressLine1 ;
@property (nonatomic,copy) NSString* addressLine2 ;
@property (nonatomic,copy) NSString* postalCode ;
@property (nonatomic,copy) NSString* city ;
@property(nonatomic,retain) UIButton *countryButton;
@property(nonatomic,retain) UIButton *stateButton;
@property (nonatomic, retain) NSArray *countries;
@property (nonatomic, retain) NSArray *countryNamesArray;
@property (nonatomic, retain) NSArray *countryIDArray;
@property (nonatomic, retain) NSArray *states;
@property (nonatomic,retain) NSIndexPath *selectedIndexPath;
@property (nonatomic,retain) IBOutlet UIView *pickerHolderView;
@property (nonatomic,copy) NSString* stateValue ;
@property(nonatomic,copy) NSString *emailAddress;
@property(nonatomic,copy) NSString * zipUnderValidation;

@property (nonatomic, retain) UITextField *txtActiveField;
@property (nonatomic, assign) ABMultiValueRef contactAdresses;

@property (nonatomic, strong)  ACCheckoutTextField *firstNameTextField;
@property (nonatomic, strong)  ACCheckoutTextField *lastNameTextField;
@property (nonatomic, strong)  ACCheckoutTextField *emailTextField;
@property (nonatomic, strong)  ACCheckoutTextField *address1TextField;
@property (nonatomic, strong)  ACCheckoutTextField *address2TextField;
@property (nonatomic, strong)  ACCheckoutTextField *companyTextField;
@property (nonatomic, strong)  ACCheckoutTextField *cityTextField;
@property (nonatomic, strong)  ACCheckoutTextField *failedTextField;
@property (nonatomic, strong)  ACCheckoutTextField *stateTextField;
@property (nonatomic, strong)  ACCheckoutTextField *zipTextField;
@property (nonatomic, strong)  ACCheckoutTextField *phoneField ;

@property (nonatomic, strong)  NSArray *addressArray;

@property(nonatomic,assign) BOOL stateValidationRequired;
@property(nonatomic,assign) BOOL phoneValidationRequired;
@property(nonatomic,assign) BOOL isModal;
@property(nonatomic,assign) BOOL didTapNext;
@property(nonatomic,assign) BOOL needSignUp;
@property(nonatomic,assign) BOOL isDoingAccountMerge;

@property (retain, nonatomic) IBOutlet UIImageView *topNavBarImageView;

@property (nonatomic,strong) NSString* orderNumber;

-(void)configureThePicker;
-(void)hidePicker;

-(int)getCharacterCount:(NSString*)str;
-(void)prepareCountryList;
-(void)validateSelectedCountry:(int)countryIndex;
-(void)cityAndStateSuggestionForZip:(NSString*)newStr;
-(void) populateDataWithLoginResponse:(NSDictionary*)dict;
-(IBAction)loginWithFacebook:(id)sender;
-(IBAction)loginWithEmail:(id)sender;


@property (assign, nonatomic) id <ACShipAddressViewDelegate> delegate;

@end


@protocol ACShipAddressViewDelegate <NSObject>
- (void)didPressBackButton: (ACShipAddressViewController*) shipAddressViewController;
@end

