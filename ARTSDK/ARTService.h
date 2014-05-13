//
//  ARTService.h
//  Pods
//
//  Created by Doug Diego on 5/13/14.
//
//

#import <Foundation/Foundation.h>
#import "ARTFrame.h"

@interface ARTService : NSObject

@property (nonatomic, retain) ARTFrame * frame;

-(ARTService *)initWithDictionary:(NSDictionary *)dictionary;

@end
