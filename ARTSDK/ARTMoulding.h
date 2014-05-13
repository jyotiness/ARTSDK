//
//  ARTMoulding.h
//  Pods
//
//  Created by Doug Diego on 5/13/14.
//
//

#import <Foundation/Foundation.h>

@interface ARTMoulding : NSObject

@property (nonatomic, copy) NSString * cornerImageUrl;
@property (nonatomic, copy) NSString * description;
@property (nonatomic, copy) NSString * profileImageUrl;

-(ARTMoulding *)initWithDictionary:(NSDictionary *)dictionary;

@end
