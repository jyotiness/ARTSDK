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
        //ARTLog("initWithDictionary: %@", dictionary);
        
        // Moulding
        NSDictionary * moulding = [dictionary objectForKeyNotNull:@"Moulding"];
        if( moulding ){
            self.moulding = [[ARTMoulding alloc]  initWithDictionary: moulding ] ;
        }
        
        // Top Map
        NSDictionary * topMat = [dictionary objectForKeyNotNull:@"TopMat"];
        if( topMat ){
            self.topMat = [[ARTMat alloc]  initWithDictionary: topMat ] ;
        }
        
        // Middle Map
        NSDictionary * middleMat = [dictionary objectForKeyNotNull:@"MiddleMat"];
        if( middleMat ){
            self.middleMat = [[ARTMat alloc]  initWithDictionary: middleMat ] ;
        }
        
        // Top Map
        NSDictionary * bottomMat = [dictionary objectForKeyNotNull:@"BottomMat"];
        if( bottomMat ){
            self.bottomMat = [[ARTMat alloc]  initWithDictionary: topMat ] ;
        }
    }
    return self;
}

-(NSString* ) description {
    return [NSString stringWithFormat:@"moulding: %@",
            _moulding];
}

@end
