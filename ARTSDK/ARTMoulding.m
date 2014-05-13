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
        ARTLog("initWithDictionary: %@", dictionary);
        
        self.cornerImageUrl         = [[dictionary objectForKey:@"CornerImage"] objectForKeyNotNull:@"HttpImageURL"];
        self.description       = [dictionary objectForKeyNotNull:@"Description"];
        self.profileImageUrl       = [[dictionary objectForKey:@"ProfileImage"] objectForKeyNotNull:@"HttpImageURL"];
        
    }
    return self;
}

-(NSString* ) description {
    return [NSString stringWithFormat:@"cornerImageUrl: %@ profileImageUrl: %@ description: %@",
            _cornerImageUrl,_profileImageUrl, _description];
}

@end

