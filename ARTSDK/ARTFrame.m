//
//  ARTFrame.m
//  Pods
//
//  Created by Doug Diego on 5/13/14.
//
//

#import "ARTFrame.h"
#import "ARTLogging.h"
#import "NSDictionary+Additions.h"

@implementation ARTFrame

-(ARTFrame *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        ARTLog("initWithDictionary: %@", dictionary);
        
        // Moulding
        NSDictionary * moulding = [dictionary objectForKeyNotNull:@"Moulding"];
        if( moulding ){
            self.moulding = [[ARTMoulding alloc]  initWithDictionary: moulding ] ;
        }
    }
    return self;
}

-(NSString* ) description {
    return [NSString stringWithFormat:@"moulding: %@",
            _moulding];
}

@end
