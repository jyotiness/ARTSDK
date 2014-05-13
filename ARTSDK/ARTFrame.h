//
//  ARTFrame.h
//  Pods
//
//  Created by Doug Diego on 5/13/14.
//
//

#import <Foundation/Foundation.h>
#import "ARTMoulding.h"

@interface ARTFrame : NSObject

@property (nonatomic, retain) ARTMoulding * moulding;

-(ARTFrame *)initWithDictionary:(NSDictionary *)dictionary;

@end
