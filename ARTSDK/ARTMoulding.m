//
//  ARTMoulding.m
//  Pods
//
//  Created by Doug Diego on 5/13/14.
//
//

#import "ARTMoulding.h"
#import "ARTLogging.h"
#import "NSDictionary+Additions.h"

@implementation ARTMoulding

-(ARTMoulding *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        //ARTLog("initWithDictionary: %@", dictionary);
        
        self.cornerImageUrl     = [[dictionary objectForKey:@"CornerImage"] objectForKeyNotNull:@"HttpImageURL"];
        self.description        = [dictionary objectForKeyNotNull:@"Description"];
        self.profileImageUrl    = [[dictionary objectForKey:@"ProfileImage"] objectForKeyNotNull:@"HttpImageURL"];
        self.name               = [dictionary objectForKey:@"Name"];
        self.material           = [dictionary objectForKey:@"Material"];
        self.price              = [[dictionary objectForKey:@"Price"] objectForKeyNotNull:@"Price"];
        self.dimensionsTop      = [[dictionary objectForKey:@"Dimensions"] objectForKeyNotNull:@"Top"];
        self.dimensionsLeft     = [[dictionary objectForKey:@"Dimensions"] objectForKeyNotNull:@"Left"];
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
    return [NSString stringWithFormat:@"cornerImageUrl: %@ profileImageUrl: %@ description: %@ name: %@ price: %@",
            _cornerImageUrl,_profileImageUrl, _description, _name, _price];
}

@end

