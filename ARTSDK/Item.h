//
//  Item.h
//  ArtAPI
//
//  Created by Doug Diego on 11/18/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * croppedImageUrl;
@property (nonatomic, retain) NSString * thumbImageUrl;
@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSNumber * pixelWidth;
@property (nonatomic, retain) NSNumber * pixelHeight;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * itemJSON;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * priceRange;
@property (nonatomic, retain) NSNumber * MSRP;
@property (nonatomic, retain) NSString * itemUrl;
@property (nonatomic, retain) NSString * lookupType;
@property (nonatomic, retain) NSString * sku;
@property (nonatomic, retain) NSString * size;
@property(nonatomic, copy) NSString * genericImageUrl;

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
