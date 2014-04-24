//
//  NSString+Additions.m
//  ArtAPI
//
//  Created by Doug Diego on 4/10/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

+ (id)stringWithFormat:(NSString *)format array:(NSArray*) arguments;
{
    // Solution found at http://stackoverflow.com/questions/8211996/fake-va-list-in-arc
    NSRange range = NSMakeRange(0, [arguments count]);
    
    NSMutableData* data = [NSMutableData dataWithLength: sizeof(id) * [arguments count]];
    
    [arguments getObjects: (__unsafe_unretained id *)data.mutableBytes range:range];
    
   return [[NSString alloc] initWithFormat: format arguments: data.mutableBytes];
}

+ (NSString *) formatedPriceFor: (NSNumber *)inPriceValue {
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey: @"Currency_Code_to_use"]){
        [currencyFormatter setCurrencyCode: [[NSUserDefaults standardUserDefaults] objectForKey: @"Currency_Code_to_use"]];
    }else{
        [currencyFormatter setCurrencyCode: @"USD"];
    }
    
    NSString * formatedPrice = [currencyFormatter stringFromNumber: inPriceValue];
    //[currencyFormatter release];
    formatedPrice = [formatedPrice stringByReplacingOccurrencesOfString:@" " withString:@""];
    formatedPrice = [formatedPrice stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return formatedPrice;
}

- (BOOL) validateAsEmail {
    
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    BOOL passed = [emailTest evaluateWithObject:[self lowercaseString]];
    
    return passed;
}

- (BOOL) isEmpty {
    return !([self isKindOfClass:[NSString class]] && [(NSString*)self length] > 0);
}

- (NSString *) maskCreditCard {
    // NSLog(@"credit card: %@ length: %d", self, self.length );
    
    // Most Credit Cards
    NSInteger rangeLength = 12;
    
    // Amex
    if([self length] == 15) {
        rangeLength = 10;
    }
    
    // Anything other than Amex or 16 digit cards, mask all characters
    if([self length] != 16 && [self length] != 15 ) {
        // NSLog(@"Unknown length");
        rangeLength = [self length];
    }
    
    NSString *replaceto=@"";
    
    for (int i=0;i<rangeLength;i++) {
        replaceto=[replaceto stringByAppendingString:@"●"];
    }
    
    NSRange range = NSMakeRange(0, rangeLength);
    NSString *charToReplace=[self substringWithRange:range];
    return [self stringByReplacingOccurrencesOfString:charToReplace withString:replaceto];
    //NSLog(@"string is %@",string);
    
}

- (NSString *) stringByAppendingValidString:(NSString *)aString {
    
    if ([aString length]) {
        return [self stringByAppendingString:aString];
    }
    else
        return self;
    
}

@end
