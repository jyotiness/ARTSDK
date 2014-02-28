//
//  ACTextField.m
//  Art
//
//  Created by BradSmith on 5/1/11.


#import "ACCheckoutTextField.h"
#import "NSString+Additions.h"


@implementation ACCheckoutTextField

@synthesize normalBackgound;
@synthesize cellIndexPath;


- (void) awakeFromNib
{
  [self setBorderStyle:UITextBorderStyleNone];
    // TODO: why are we setting the font size here?  This should be removed an be up to the xib to set.
  if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
//self.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
  } else {
      self.font = [UIFont systemFontOfSize:12.0f];
  }
  self.clipsToBounds = NO;
}

- (BOOL) isEmpty {
    /*
  BOOL empty = NO;
    NSString *validationString = self.text;
  if (self.text == nil)
      empty = YES;
  if ([[validationString stringByReplacingOccurrencesOfString:@" " withString:@"" ] isEqualToString:@""])
      empty = YES;
  
  return empty;*/
    return [self.text isEmpty];
}

- (BOOL) validateAsNotEmpty
{
  
//  BOOL passed = ![self isEmpty];
//  [self setValidationHighlight:!passed];
  
  return ![self isEmpty];
}

- (BOOL) validateAsGermanPhoneNumber
{
    NSString *phoneNumber = [self.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNumber = [ phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
    if(6 <= [ self getCharacterCount:phoneNumber])
        return YES;
    
    return NO;
}

-(int)getCharacterCount:(NSString*)str
{
    return [ str stringByTrimmingCharactersInSet:[ NSCharacterSet whitespaceCharacterSet]].length;
}

- (BOOL) validateAsEmail {
  /*
  NSString *emailRegex =
  @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
  @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
  @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
  @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
  @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
  @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
  @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
  
  NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
  
  BOOL passed = [emailTest evaluateWithObject:[self.text lowercaseString]];

  return passed;*/
    return [self.text validateAsEmail];
}

/*
- (BOOL) validateAsState{
  
  BOOL passed = YES;
  
  //TODO: Make this really check for valid States...
  if ([self.text length] < 1)
  {
    passed = NO;
  }
  
  [self setValidationHighlight:!passed];
  return passed;
} */

- (BOOL) validateAsZip {
  
  // If we are shipping to Canada you should use this as the predicate: [A-CEGHJ-NPR-TVXY][0-9][A-CEGHJ-NPR-TV-Z] [0-9][A-CEGHJ-NPR-TV-Z][0-9]
  
  // Note: this is only for the US zips only... 
  NSString *zipRegex = @"([0-9]{4}[1-9])|([0-9]{3}[1-9][0-9])|(20500)";
  
  NSPredicate *zipTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", zipRegex]; 
  
  BOOL passed = [zipTest evaluateWithObject:self.text];
  
  //[self setValidationHighlight:!passed];
  return passed;
}

- (BOOL) validateAsCountry {
  
  BOOL passed = YES;;
  
  
  //TODO: Make this really check for valid Countries...
  if ([self.text length] < 1) passed = NO;
  
  
//  [self setValidationHighlight:!passed];
  return passed;
}

- (BOOL) validateAsPhone {
  
  BOOL passed = YES;
  
  
  //[self setValidationHighlight:!passed];
  return passed;
}




- (BOOL) validateAsCCNumber {
  if ([self.text length] < 10) {
    return NO;
  }
  
	NSMutableArray *stringAsChars = [[NSMutableArray alloc] initWithCapacity:[self.text length]] ;

  
  for (int i=0; i < [self.text length]; i++) {
		NSString *ichar  = [NSString stringWithFormat:@"%c", [self.text characterAtIndex:i]];
		[stringAsChars addObject:ichar];
	}
  
  if ([stringAsChars count] < 10) {
    return NO;
  }
  
	BOOL isOdd = YES;
	int oddSum = 0;
	int evenSum = 0;
  
	for (int i = [self.text length] - 1; i >= 0; i--) {
    
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

- (BOOL) validateAsCCMonth {
  
  BOOL passed = YES;
  
  if ([self isEmpty]) passed = NO;
  
//  [self setValidationHighlight:!passed];
  return passed;
}

- (BOOL) validateAsCCYear {
  
  BOOL passed = YES;
  
  if ([self isEmpty]) passed = NO;
  
//  [self setValidationHighlight:!passed];
  return passed;
}

- (BOOL) validateAsCCCVS2ForCreditCardType:(NSString *)cardType
{
    BOOL passed = YES;

    if([ cardType isEqualToString:@""])
    {
        passed = NO;
    }
    else if([[cardType lowercaseString] isEqualToString:@"american express"])
    {
        if(self.text.length!=4)
        {
            passed = NO;
        }
    }
    else
    {
        if(self.text.length!=3)
        {
            passed = NO;
        }
    }

    //  [self setValidationHighlight:!passed];
    return passed;
}



@end
