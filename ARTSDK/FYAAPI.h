//
//  FYAAPI.h
//  Pods
//
//  Created by Ness User on 10/19/15.
//
//

#import <Foundation/Foundation.h>
#import "ArtAPI.h"

@interface FYAAPI : NSObject

@property(nonatomic,copy) NSArray *PaperdataArray;
@property(nonatomic,copy) NSArray *CanvasdataArray;
@property(nonatomic,copy) NSArray *CatalogFrameItemDataArray;

+ (FYAAPI*) sharedInstance;
+(void) loadAPI;
//-(void) loadAPI;
+(NSArray *)GetPaperImageVariable;
+(NSArray*)GetCanvasImageVariable;

+(NSArray*)GetcatalogItemGetFrameRecommendationsDataArray;

+(void) GetcatalogItemGetFrameRecommendationsData;
//-(NSArray *)getMyVariable;

@end
