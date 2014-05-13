//
//  Item.m
//  ArtAPI
//
//  Created by Doug Diego on 11/18/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "Item.h"
#import "ArtAPI.h"
#import "NSString+Additions.h"
#import "ARTLogging.h"

@interface Item()
@property(nonatomic, strong) NSDictionary * itemDict;

@end

@implementation Item


-(NSString*)description {
    return [NSString stringWithFormat:@"itemId: %@, imageUrl: %@, title: %@ ,artist: %@, pixelWidth: %@, pixelHeight: %@, type: %@, service: %@",
            _itemId,_imageUrl,_title,_artist,_pixelWidth,_pixelHeight,_type,_service];
}

-(void) setItemDict:(NSDictionary *)itemDict {
    _itemDict = itemDict;
    
    if( _itemDict ){
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDict
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            _itemJSON  = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    } else {
        _itemJSON = nil;
    }
}

-(NSDictionary*) getItemDict {
    //NIDINFO("_itemJSON: %@", _itemJSON );
    
    if(!_itemJSON){
        return nil;
    }
    if(_itemDict) {
        return _itemDict;
    } else {
        NSError *error;
        _itemDict = [NSJSONSerialization
                     JSONObjectWithData:[_itemJSON dataUsingEncoding:NSUTF8StringEncoding]
                     options:kNilOptions
                     error:&error];
        return _itemDict;
    }
}

- (Item *)initWithFramedItemDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        //NSLog(@"dictionary: %@", dictionary);
        NSString * imageURLString = [[[dictionary objectForKey:@"ImageInformation"] objectForKey:@"LargeImage"] objectForKey:@"HttpImageURL"];
        self.itemId =  [dictionary objectForKeyNotNull:@"ItemNumber"];
        self.sku =  [dictionary objectForKeyNotNull:@"Sku"];
        self.imageUrl =  [ArtAPI cleanImageUrl:imageURLString withSize:600];
        self.thumbImageUrl =  [ArtAPI cleanImageUrl:imageURLString withSize:115];
        NSDictionary *itemPrice = [dictionary objectForKeyNotNull:@"ItemPrice"];
        self.price = [itemPrice objectForKeyNotNull:@"Price"];
        self.MSRP = [itemPrice objectForKeyNotNull:@"MSRP"];
        
        // Get Item Attributes
        NSDictionary * itemAttributes = [dictionary  objectForKeyNotNull:@"ItemAttributes"];
        
        // Title
        self.title = [itemAttributes objectForKeyNotNull:@"Title"];
        
        // Artist
        [self parseArtistDictionary:dictionary];
        
        // Type
        self.type = [itemAttributes objectForKeyNotNull:@"Type"];;
        
        // Size
        self.size = [self sizeFromDictionary:itemAttributes];
        
        // Item Url
        self.itemUrl = [itemAttributes objectForKeyNotNull:@"ProductPageUrl"];
        
        // Service
        NSDictionary * service = [dictionary objectForKeyNotNull:@"Service"];
        if( service ){
            self.service = [[ARTService alloc]  initWithDictionary: service ] ;
        }
        
        [self setItemDict:dictionary];
    }
    return self;
}

-(void) parseArtistDictionary: (NSDictionary* ) dictionary {
    NSDictionary *artist = [dictionary objectForKeyNotNull:@"Artist"];
    NSString *firstName = [artist objectForKeyNotNull:@"FirstName"];
    NSString *lastName = [artist objectForKeyNotNull:@"LastName"];
    NSString *formattedArtistName = @"";
    if (firstName) {
        formattedArtistName = [formattedArtistName stringByAppendingValidString:firstName];
    }
    if (firstName && lastName) {
        formattedArtistName = [formattedArtistName stringByAppendingValidString:@" "];
    }
    if (lastName) {
        formattedArtistName = [formattedArtistName stringByAppendingValidString:lastName];
    }
    self.artist = formattedArtistName;

}

- (Item *)initWithColorResponseDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        //NSLog(@"dictionary: %@", dictionary);
        
        // Item Details
        self.itemId = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"APNum"]];
        self.lookupType = @"ItemNumber";
        //NSLog(@"genericImageUrl: %@", [[dictionary objectForKey:@"UrlInfo"] objectForKey:@"GenericImageURL"] );
        self.itemUrl = [[dictionary objectForKey:@"UrlInfo"] objectForKey:@"ProductPageUrl"];
        
        // Image
        self.imageUrl = [[dictionary objectForKey:@"UrlInfo"] objectForKey:@"GenericImageURL"];
        self.genericImageUrl = [[dictionary objectForKey:@"UrlInfo"] objectForKey:@"GenericImageURL"];
        
        // Dimensions
        NSArray * imageDimensions = [dictionary objectForKey:@"ImageDimensions"];
        for(NSDictionary * imageDimension in imageDimensions){
            self.pixelWidth = [imageDimension objectForKey:@"PixelWidth"];
            self.pixelHeight =  [imageDimension objectForKey:@"PixelHeight"];
        }
    
        // Title
        self.title = [dictionary objectForKeyNotNull:@"Title"];
        
        // Artist
        [self parseArtistDictionary:dictionary];
        
        // Price
        self.price = [[dictionary objectForKey:@"ItemPrice"] objectForKey:@"Price"];
        
        // Type
        self.type = [dictionary objectForKeyNotNull:@"ItemDisplayedType"];
        
        
        
        // Save Item Dictionary
        [self setItemDict:dictionary];
    }
    return self;
}


- (Item *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        //NSLog(@"dictionary: %@", dictionary);
        
        //Item *item = [[Item alloc] init];
        
        // Get Item Attributes
        NSDictionary * itemAttributes = [dictionary  objectForKeyNotNull:@"ItemAttributes"];
        
        // Item Id
        self.itemId = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"ItemNumber"]];
        self.sku = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"Sku"]];
        
        // If SKU has pod, then remove it
        NSArray* skuParts = [self.sku  componentsSeparatedByString: @"-"];
        if(skuParts!=nil && skuParts.count >0){
            self.sku = [skuParts objectAtIndex:0];
        }
        
        // Lookup Type
        // http://dev-api.art.com/docs/html/987e1f91-59d2-04b1-0e2b-84a8131e33f5.htm
        NSNumber * itemType =[dictionary objectForKey:@"ItemType"];
        if(itemType.integerValue == 1){
            self.lookupType = @"ItemNumber";
        } else {
            self.lookupType = @"Sku";
        }
        
        // Image
        NSDictionary * image = [dictionary objectForKeyNotNull:@"ImageInformation"] ;
        
        // Get Width / Height
        NSNumber* imageWidth = [[[image objectForKeyNotNull:@"LargeImage"] objectForKeyNotNull:@"Dimensions"]  objectForKeyNotNull:@"Width"];
        NSNumber* imageHeight =[[[image objectForKeyNotNull:@"LargeImage"] objectForKeyNotNull:@"Dimensions"]  objectForKeyNotNull:@"Height"];
        
        self.genericImageUrl = [image objectForKeyNotNull:@"GenericImageUrl"];
        //self.imageUrl = [[image objectForKeyNotNull:@"LargeImage"] objectForKey:@"HttpImageURL"];
        self.imageUrl = [self genericImageUrlWithSize:CGSizeMake(imageWidth.floatValue, imageHeight.floatValue)];
        self.thumbImageUrl = [[image objectForKeyNotNull:@"SmallImage"] objectForKey:@"HttpImageURL"];
        self.croppedImageUrl = [[image objectForKeyNotNull:@"ThumbnailImage"] objectForKey:@"HttpImageURL"];
        
        // Dimensions
        NSDictionary * imageDimension = [[image objectForKeyNotNull:@"LargeImage"] objectForKey:@"Dimensions"];
        self.pixelWidth = [imageDimension objectForKey:@"Width"];
        self.pixelHeight = [imageDimension objectForKey:@"Height"];
        
        // Rank
        //item.rank = [NSNumber numberWithInt: index];
        
        // Title
        self.title = [itemAttributes objectForKeyNotNull:@"Title"];
        
        // Item Url
        self.itemUrl = [itemAttributes objectForKeyNotNull:@"ProductPageUrl"];
        
        // Artist
        [self parseArtistDictionary:itemAttributes];
        
        // Price
        self.price = [[dictionary objectForKey:@"ItemPrice"] objectForKey:@"Price"];
        self.MSRP = [[dictionary objectForKey:@"ItemPrice"] objectForKey:@"MSRP"];
        self.priceRange = [[dictionary objectForKey:@"ItemPrice"] objectForKey:@"DisplayPrice"];
        
        
        // Type
        self.type = [itemAttributes objectForKeyNotNull:@"Type"];;
        
        // Size
        self.size = [self sizeFromDictionary:itemAttributes];
        
        [self setItemDict:dictionary];
        
    }
    return self;
}

-(NSString*) sizeFromDictionary:(NSDictionary *)itemDict {
    NSDictionary *physicalDimensions = [itemDict objectForKeyNotNull:@"PhysicalDimensions"];
    if(!ACIsDictionaryWithObjects( physicalDimensions ) ){
        //NIDINFO("can't find PhysicalDimensions");
        physicalDimensions = [[itemDict  objectForKeyNotNull:@"ItemAttributes"] objectForKeyNotNull:@"PhysicalDimensions"];
    }
    //NIDINFO("PhysicalDimensions: %@", physicalDimensions );
    NSNumber *width = [physicalDimensions objectForKeyNotNull:@"Width"];
    NSNumber *height = [physicalDimensions objectForKeyNotNull:@"Height"];
    // Round to the nearest 0.5
    height = [NSNumber numberWithFloat:roundf(height.floatValue*2.0)/2.0];
    width = [NSNumber numberWithFloat:roundf(width.floatValue*2.0)/2.0];
    NSNumber *unitOfMeasure = [physicalDimensions objectForKeyNotNull:@"UnitOfMeasure"];
    NSString *uom = @"in";
    if ([unitOfMeasure isEqualToNumber:[NSNumber numberWithInt:1]]) uom = @"\"";
    if ([unitOfMeasure isEqualToNumber:[NSNumber numberWithInt:2]]) uom = @"cm";
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    
    return [NSString stringWithFormat:@"%@%@ x %@%@",[fmt stringFromNumber:width], uom, [fmt stringFromNumber:height], uom];
    
}

-(NSString*) croppedImageUrlWithSize: (CGSize) size {
    NSString * sub1 = @"maxw=100&maxh=100";
    NSString * sub2 = @"MXW:640+MXH:640";
    
    NSString *imageURLString = [[self croppedImageUrl] copy];
    
    NSString *sizeOverrideString = [NSString stringWithFormat:@"maxw=%.0f&maxh=%.0f", size.width, size.height];
    
    if ([imageURLString rangeOfString:sub1].location != NSNotFound) {
        imageURLString = [imageURLString stringByReplacingOccurrencesOfString:sub1 withString:sizeOverrideString];
    }
    
    if ([imageURLString rangeOfString:sub2].location != NSNotFound) {
        imageURLString = [imageURLString stringByReplacingOccurrencesOfString:sub2 withString:sizeOverrideString];
    }
    
    NSString *imageURLStringEscaped = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) imageURLString, NULL, NULL, kCFStringEncodingUTF8));
    return imageURLStringEscaped;
}

-(NSString* ) genericImageUrlWithSize: (CGSize) size {
    if(!_genericImageUrl){
        return nil;
    }
    if(size.width == CGSizeZero.width && size.height == CGSizeZero.height){
        return _genericImageUrl;
    }
    return [[NSString alloc] initWithData:[[NSString stringWithFormat:@"%@?w=%.0f&h=%.0f", self.genericImageUrl, size.width, size.height]
                                           dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                                 encoding:NSASCIIStringEncoding];
}

-(NSString* ) genericImageUrlWithSize: (CGSize) size appId:(NSString *) appId {
    if(!_genericImageUrl){
        return nil;
    }
    if(size.width == CGSizeZero.width && size.height == CGSizeZero.height){
        return _genericImageUrl;
    }
    if ([self.genericImageUrl rangeOfString:@"http://frame"].location != NSNotFound) {
        CGFloat biggerSize = size.width;
        if( size.height > size.width){
            biggerSize = size.height;
        }
        return [ArtAPI cleanImageUrl:self.genericImageUrl withSize:biggerSize];
    }
    return [[NSString alloc] initWithData:[[NSString stringWithFormat:@"%@?w=%.0f&h=%.0f&appId=%@", self.genericImageUrl, size.width, size.height, appId]
                                           dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                                 encoding:NSASCIIStringEncoding];
}

-(NSString* ) formattedPrice {
    if (self.price) {
        NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        return [currencyFormatter stringFromNumber:_price];
    }
    else {
        return nil;
    }
}

-(NSString* ) formattedMSRP {
    if (self.MSRP) {
        NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        return [currencyFormatter stringFromNumber:_MSRP];
    }
    else {
        return nil;
    }
}

@end
