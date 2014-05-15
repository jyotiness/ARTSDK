//
//  Item.h
//  ArtAPI
//
//  Created by Doug Diego on 11/18/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARTService.h"

@interface Item : NSObject

@property (nonatomic, copy) NSString * imageUrl;
@property (nonatomic, copy) NSString * croppedImageUrl;
@property (nonatomic, copy) NSString * thumbImageUrl;
@property (nonatomic, copy) NSString * itemId;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * artist;
@property (nonatomic, retain) NSNumber * pixelWidth;
@property (nonatomic, retain) NSNumber * pixelHeight;
@property (nonatomic, copy) NSString * type;
@property (nonatomic, copy) NSString * itemJSON;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, copy) NSString * priceRange;
@property (nonatomic, retain) NSNumber * MSRP;
@property (nonatomic, copy) NSString * itemUrl;
@property (nonatomic, copy) NSString * lookupType;
@property (nonatomic, copy) NSString * sku;
@property (nonatomic, copy) NSString * size;
@property (nonatomic, copy) NSString * genericImageUrl;
@property (nonatomic, retain) ARTService * service;
@property (nonatomic, copy) NSString * frammedUrl;
@property (nonatomic, retain) NSNumber *itemWidth;
@property (nonatomic, retain) NSNumber *itemHeight;
@property (nonatomic, retain) NSNumber *canFrame;

- (Item *)initWithFramedItemDictionary:(NSDictionary *)dictionary;
- (Item *)initWithColorResponseDictionary:(NSDictionary *)dictionary;
- (Item *)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary*) getItemDict;
-(void) setItemDict:(NSDictionary *)itemDict;
-(NSString*) genericImageUrlWithSize: (CGSize) size;
-(NSString*) genericImageUrlWithSize: (CGSize) size appId:(NSString *) appId;
-(NSString*) croppedImageUrlWithSize: (CGSize) size;
-(NSString*) formattedPrice;
-(NSString*) formattedMSRP;

@end
