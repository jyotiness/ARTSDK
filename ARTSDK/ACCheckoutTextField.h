//
//  ACTextField.h
//  Art
//
//  Created by BradSmith on 5/1/11.


#import <Foundation/Foundation.h>


@interface ACCheckoutTextField : UITextField {
    
}

@property (nonatomic, retain) UIImage *normalBackgound;
@property (nonatomic, retain) NSIndexPath *cellIndexPath;

//- (void) setValidationHighlight:(BOOL)highlighted;

- (BOOL) validateAsNotEmpty;
- (BOOL) validateAsGermanPhoneNumber;
- (BOOL) validateAsEmail;
- (BOOL) validateAsPhone; 

- (BOOL) validateAsZip;
//- (BOOL) validateAsState;
- (BOOL) validateAsCountry;


- (BOOL) validateAsCCNumber;
- (BOOL) validateAsCCMonth;
- (BOOL) validateAsCCYear;
- (BOOL) validateAsCCCVS2ForCreditCardType:(NSString *)cardType;


@end
