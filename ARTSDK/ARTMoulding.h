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
@property (nonatomic, copy) NSString * desc;
@property (nonatomic, copy) NSString * profileImageUrl;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * material;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * dimensionsTop;
@property (nonatomic, retain) NSNumber * dimensionsLeft;

-(ARTMoulding *)initWithDictionary:(NSDictionary *)dictionary;
-(NSString*) formattedPrice;

@end
