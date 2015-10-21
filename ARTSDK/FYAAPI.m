//
//  FYAAPI.m
//  Pods
//
//  Created by Ness User on 10/19/15.
//
//

#import "FYAAPI.h"
#import "ArtAPI.h"


//@interface FYAAPI()
//@property(nonatomic, strong) NSArray * itemArray;
//
//@end

@implementation FYAAPI

//@synthesize itemArray = _itemArray;
@synthesize PaperdataArray;
@synthesize CanvasdataArray;
@synthesize CatalogFrameItemDataArray;

+(void) loadAPI
{  [[FYAAPI sharedInstance ] getPaperimageDataAPI ];
    [[FYAAPI sharedInstance ] getCanvasimageDataAPI ];
    [[FYAAPI sharedInstance ]catalogItemGetFrameRecommendationsData];
}

+ (FYAAPI*) sharedInstance {
    static FYAAPI* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) {
            _one = [[ FYAAPI alloc ] init ];
        }
    }
    
    return _one;
}

-(void) getPaperimageDataAPI{
    
    self.PaperdataArray=[[NSArray alloc]init];
    
    NSString *itemID = @"5129599";
    NSString *lookupType = @"ItemNumber";
    [ArtAPI
     requestForCatalogItemGetVariations:itemID lookupType:lookupType success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
         
         NSLog(@"json %@",[[JSON objectForKey:@"d"]objectForKey:@"Items"]);
         [self PaperImageDataDictionary:JSON];
         
         //NSArray * items = [[JSON objectForKeyNotNull:@"d"] objectForKeyNotNull:@"Items"];
         //self.dataArray = items;
         
        
        
         
         
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         
     }];

    //return self.dataArray;
}

-(void) getCanvasimageDataAPI{
    
    self.CanvasdataArray=[[NSArray alloc]init];
    
    NSString *itemID = @"4129599";
    NSString *lookupType = @"ItemNumber";
    [ArtAPI
     requestForCatalogItemGetVariations:itemID lookupType:lookupType success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
         
         NSLog(@"json %@",[[JSON objectForKey:@"d"]objectForKey:@"Items"]);
         [self CanvasImageDataDictionary:JSON];
         
         //NSArray * items = [[JSON objectForKeyNotNull:@"d"] objectForKeyNotNull:@"Items"];
         //self.dataArray = items;
         
         
         
         
         
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         
     }];
    
    //return self.dataArray;
}

+(void) GetcatalogItemGetFrameRecommendationsData{
    [[FYAAPI sharedInstance] catalogItemGetFrameRecommendationsData] ;
}

-(void) catalogItemGetFrameRecommendationsData{
    
    //self.PaperdataArray=[[NSArray alloc]init];
    
    NSString *itemID = @"5129599-13726662";
    NSString *lookupType = @"ItemNumber";
    NSNumber *maxNumberOfRecommendations = [NSNumber numberWithInt:500];
    int  *maxJpegImageWidth = 400;
    int *maxJpegImageHeight = 350;
//    [ArtAPI frameRecomendationsForItemId:itemID maxNumberOfRecommendations:maxNumberOfRecommendations maxJpegImageWidth:maxJpegImageWidth maxJpegImageHeight:maxJpegImageHeight success:<#^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)success#> failure:<#^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)failure#>]
    
    [ArtAPI frameRecomendationsForItemId:itemID maxNumberOfRecommendations:maxNumberOfRecommendations maxJpegImageWidth:maxJpegImageWidth maxJpegImageHeight:maxJpegImageHeight success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);
         
         NSLog(@"json %@",[[JSON objectForKey:@"d"]objectForKey:@"Items"]);
         [self UpdatecatalogItemGetFrameRecommendationsData:JSON];
         
         //NSArray * items = [[JSON objectForKeyNotNull:@"d"] objectForKeyNotNull:@"Items"];
         //self.dataArray = items;
         
         
         
         
         
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         
     }];
    
    //return self.dataArray;
}
+(NSArray*)GetPaperImageVariable {
    return [[FYAAPI sharedInstance] getPaperImageVariable];
}
- (NSArray*)getPaperImageVariable {
    return self.PaperdataArray;
}

+(NSArray*)GetCanvasImageVariable {
    return [[FYAAPI sharedInstance] getCanvasImageVariable];
}
- (NSArray*)getCanvasImageVariable {
    return self.CanvasdataArray;
}

+(NSArray*)GetcatalogItemGetFrameRecommendationsDataArray {
    return [[FYAAPI sharedInstance] getcatalogItemGetFrameRecommendationsData];
}
- (NSArray*)getcatalogItemGetFrameRecommendationsData {
    return self.CatalogFrameItemDataArray;
}

- (void)PaperImageDataDictionary:(NSDictionary *)response
{
    NSDictionary *responseToUse = [response objectForKeyNotNull:@"d"];
    NSArray *Items = [responseToUse objectForKeyNotNull:@"Items"];
    //NSDictionary *ItemsDict = [responseToUse objectForKeyNotNull:@"Items"];
     //NSDictionary *ImageDict = [ItemsDict objectForKeyNotNull:@"ImageInformation"];
    self.PaperdataArray = Items;
}
- (void)CanvasImageDataDictionary:(NSDictionary *)response
{
    NSDictionary *responseToUse = [response objectForKeyNotNull:@"d"];
    NSArray *Items = [responseToUse objectForKeyNotNull:@"Items"];
    //NSDictionary *ItemsDict = [responseToUse objectForKeyNotNull:@"Items"];
    //NSDictionary *ImageDict = [ItemsDict objectForKeyNotNull:@"ImageInformation"];
    self.CanvasdataArray = Items;
}

- (void)UpdatecatalogItemGetFrameRecommendationsData:(NSDictionary *)response
{
    NSDictionary *responseToUse = [response objectForKeyNotNull:@"d"];
    NSArray *Items = [responseToUse objectForKeyNotNull:@"Items"];
    //NSDictionary *ItemsDict = [responseToUse objectForKeyNotNull:@"Items"];
    //NSDictionary *ImageDict = [ItemsDict objectForKeyNotNull:@"ImageInformation"];
    self.CatalogFrameItemDataArray = Items;
}


@end
