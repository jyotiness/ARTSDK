//
//  ARTMat.m
//  Pods
//
//  Created by Doug Diego on 5/15/14.
//
//

#import "ARTMat.h"
#import "ARTLogging.h"
#import "NSDictionary+Additions.h"

@implementation ARTMat

-(ARTMat *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        //ARTLog("initWithDictionary: %@", dictionary);
        self.itemNumber         = [dictionary objectForKey:@"ItemNumber"];
        self.name               = [dictionary objectForKey:@"Name"];
        self.price              = [[dictionary objectForKey:@"Price"] objectForKeyNotNull:@"Price"];
        
    }
    return self;
}

-(NSString*) formattedPrice {
    if( _price ){
        NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        return [currencyFormatter stringFromNumber:_price];
    } else {
        return @"";
    }
}

-(NSString* ) description {
    return [NSString stringWithFormat:@"itemNumber %@ name: %@ price: %@",_itemNumber, _name, _price];
}


@end
