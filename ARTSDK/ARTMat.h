//
//  ARTMat.h
//  Pods
//
//  Created by Doug Diego on 5/15/14.
//
//

#import <Foundation/Foundation.h>

@interface ARTMat : NSObject

@property (nonatomic, copy) NSString * itemNumber;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, retain) NSNumber * price;


-(ARTMat *)initWithDictionary:(NSDictionary *)dictionary;


@end
