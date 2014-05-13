//
//  ARTService.m
//  Pods
//
//  Created by Doug Diego on 5/13/14.
//
//

#import "ARTService.h"
#import "ARTLogging.h"
#import "NSDictionary+Additions.h"

@implementation ARTService

-(ARTService *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        ARTLog("initWithDictionary: %@", dictionary);
        
        // Service
        NSDictionary * frame = [dictionary objectForKeyNotNull:@"Frame"];
        if( frame ){
            self.frame = [[ARTFrame alloc]  initWithDictionary: frame ] ;
        }
    }
    return self;
}

-(NSString* ) description {
    return [NSString stringWithFormat:@"frame: %@",
            _frame];
}

@end
