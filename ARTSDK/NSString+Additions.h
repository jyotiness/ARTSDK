//
//  NSString+Additions.h
//  ArtAPI
//
//  Created by Doug Diego on 4/10/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)
+ (id)stringWithFormat:(NSString *)format array:(NSArray*) arguments;
+ (NSString *) formatedPriceFor: (NSNumber *)inPriceValue;
- (BOOL) validateAsEmail;
- (BOOL) isEmpty;
- (NSString *) maskCreditCard;
@end
