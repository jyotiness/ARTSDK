//
//  PAAPaymentViewController.h
//  PhotosArt
//
//  Created by Jobin on 03/10/12.
//
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

/**
 * A view controller that collects a users payment information
 *
 * <h2>NSNotificationCenter</h2>
 *
 * Responds notification: NOTIFICATION_DISMISS_MODAL  This will close the modal
 *
 */

@interface ACPaymentViewController : GAITrackedViewController<UITextViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>
{
 
   // IBOutlet UIButton *applyCouponButton;
    NSString * standardShipping;
    NSString * expeditedShipping;
    NSString *overnightShipping;
    
    UITextField* cardNumberField ;
	UITextField* expDateField ;
	UITextField* securityCodeField ;
	UITextField* standardShippingField ;	
    UITextField* expeditedShippingField;
    UITextField* overnightShippingField;
    UIButton *contactsPicker ;
   // IBOutlet UILabel *orderTotalLabel;
    NSMutableArray *shipOptionsArray;
    NSString *couponCodetext;
    BOOL    mShowCoupon;
}
@property (nonatomic, retain) NSArray *dataShippingOptions;
@property (retain, nonatomic) IBOutlet UILabel *orderTotalLabel;
@property (nonatomic, retain) IBOutlet UINib *cellNib;
@property (retain, nonatomic) IBOutlet UILabel *paymentTableViewHeader;
@property (retain, nonatomic) IBOutlet UIButton *removeCouponButton;
@property (retain, nonatomic) IBOutlet UILabel *subtotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtotalTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTitleLabel;
@property (retain, nonatomic) IBOutlet UIButton *applyCouponBtton;
@property (retain, nonatomic) IBOutlet UIButton *shippingDetailsBtton;
@property (retain, nonatomic) IBOutlet UILabel *shippingTotalLabel;
@property (retain, nonatomic) IBOutlet UILabel *discountLabel;
@property (retain, nonatomic) IBOutlet UILabel *discountTitle;
@property (retain, nonatomic) IBOutlet UILabel *estimateSalesTaxLabel;
@property (retain, nonatomic) IBOutlet UILabel *estimatedSalesTaxTitle;
@property (retain, nonatomic) IBOutlet UIView *alwaysPriceView;
@property (retain, nonatomic) UITextField *couponCodeField;
@property (retain, nonatomic) IBOutlet UITableView *paymentShippingTableView;
@property (retain, nonatomic) IBOutlet UIView *sectionFooterView1;
@property (retain, nonatomic) IBOutlet UIView *sectionFooterView2;
@property (retain, nonatomic) IBOutlet UIButton *showCouponButton;
@property (retain, nonatomic) IBOutlet UIView *headerPaymentView;
@property (retain, nonatomic) IBOutlet UIView *footerView;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (retain, nonatomic) IBOutlet UILabel *paymentHeader;
@property (nonatomic, retain) NSDecimalNumber *productsSubTotal;
@property (nonatomic, retain) NSDecimalNumber *productsTotal;
@property (retain, nonatomic) IBOutlet UIButton *orderButton;
@property (nonatomic, retain) NSDecimalNumber *shippingTotal;
@property (nonatomic, retain) NSDecimalNumber *taxTotal;
@property (nonatomic, assign) int shippingType;
@property (nonatomic,copy) NSString* cardNumber ;
@property (nonatomic,copy) NSString* expDate ;
@property (nonatomic,copy) NSString* securityCode ;
@property (nonatomic,copy) NSString* standardShipping ;
@property (nonatomic,copy) NSString* expeditedShipping ;
@property (nonatomic,copy) NSString* overnightShipping ;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, retain) NSMutableArray *shipOptionsArray;
@property (nonatomic, copy) NSString *couponCodetext;
@property (retain, nonatomic) IBOutlet UIImageView *topNavBarImageView;
@property (retain, nonatomic) IBOutlet UIView *couponUnderLine;
@property (retain, nonatomic) IBOutlet UIView *shippingUnderLine;

-(UITextField*) makeTextField: (NSString*)text	
                  placeholder: (NSString*)placeholder  ;
- (IBAction)textFieldFinished:(id)sender ;
- (IBAction)showCouponSection:(id)sender;
- (IBAction)applyCouponAction:(id)sender;
- (IBAction)shipDetailsButtonPressed:(UIButton *)sender;
- (IBAction)removeCouponActions:(id)sender;
- (IBAction)proceedToBillingAddress:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)showOrderConfirmation:(id)sender;
- (IBAction)iButtonPressed:(UIButton *)sender;

@end
