//
//  ARTFrame.h
//  Pods
//
//  Created by Doug Diego on 5/13/14.
//
//

#import <Foundation/Foundation.h>
#import "ARTMoulding.h"
#import "ARTMat.h"

@interface ARTFrame : NSObject

@property (nonatomic, retain) ARTMoulding * moulding;
@property (nonatomic, retain) ARTMat * topMat;
@property (nonatomic, retain) ARTMat * middleMat;
@property (nonatomic, retain) ARTMat * bottomMat;

-(ARTFrame *)initWithDictionary:(NSDictionary *)dictionary;

@end
