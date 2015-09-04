//
//  BundleManager.m
//  SwitchArt
//
//  Created by Mike Larson on 10/23/14.
//  Copyright (c) 2014 Art.com, Inc. All rights reserved.
//

#import "BundleManager.h"
#import "ArtAPI.h"
#import "AccountManager.h"

#define DEFAULT_PPI 53

@implementation BundleManager

@synthesize bundleDictionary;
@synthesize bundleIndex;
@synthesize didViewHelp;
@synthesize bundleIndexByBundleID;
@synthesize frameIndexByAPNum;
@synthesize pixelsPerInchMinimum;

+ (BundleManager*) sharedInstance {
    static BundleManager* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) {
            _one = [[ BundleManager alloc ] init ];
            
            _one.pixelsPerInchMinimum = DEFAULT_PPI;
        }
    }
    
    return _one;
}


-(void)setBundleConfigurations:(NSDictionary *)contentBlock{
    

     NSDictionary *tempBundlesDict = nil;

     if(contentBlock){
         NSArray *bannersArray = [contentBlock objectForKeyNotNull:@"Banners"];
         if(bannersArray){
             if([bannersArray count] > 0){
                 NSDictionary *bannerDict = (NSDictionary *)bannersArray[0];
                 
                 if(bannerDict){
                     NSString *largeTextBlockString = [bannerDict objectForKeyNotNull:@"LargeTextBlock"];
                     
                     @try{
                         NSData *data = [largeTextBlockString dataUsingEncoding:NSUTF8StringEncoding];
                         id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                         
                         NSDictionary *largeTextBlockDict = json;
                         
                         if(largeTextBlockDict){
                             tempBundlesDict = largeTextBlockDict;
                             
                             NSLog(@"Successfully loaded the bundles with BundleManager");
                             
                         }
                     }@catch(id exception){
                         //do nothing - the dict will remain set to nil
                     }
                 }
             }
             
             if([bannersArray count] > 1){
                 NSDictionary *bannerDict = (NSDictionary *)bannersArray[1];
                 
                 if(bannerDict){
                     NSString *largeTextBlockString = [bannerDict objectForKeyNotNull:@"LargeTextBlock"];
                     
                     @try{

                         self.pixelsPerInchMinimum = [largeTextBlockString integerValue];
                         NSLog(@"Successfully loaded the PixelsPerInch: %i in BundleManager", (int)self.pixelsPerInchMinimum);

                     }@catch(id exception){
                         
                         self.pixelsPerInchMinimum = DEFAULT_PPI;
                     }
                 }
             }
             
         }
         
         self.bundleDictionary = [NSMutableDictionary dictionaryWithDictionary:tempBundlesDict];
         
         [self indexBundles];
     }
}

-(NSDictionary *)getFrameDictFromAPNum:(NSString *)frameAPNum{
    
    if(!frameAPNum) return nil;
    
    return [self.frameIndexByAPNum objectForKey:frameAPNum];
}

-(NSDictionary *)getBundleDictFromGenericBundleID:(NSString *)bundleID{
    
    if(!bundleID) return nil;
    
    return [self.bundleIndexByBundleID objectForKey:bundleID];
}

-(NSString *)getFrameColorStringFromItemNumber:(NSString *)itemNumber{
    
    NSString *colorString = @"";
    
    NSDictionary *frameDict = [self getFrameDictFromAPNum:itemNumber];
    
    if(frameDict){
        
        colorString = [frameDict objectForKey:@"frameText"];
        
    }
    
    return colorString;
}



-(int)getBundleCountStringFromDict:(NSDictionary *)bundleDict{
    
    NSString *countString = @"";
    int retInt = 0;
    
    if(!bundleDict) return 0;
    
    NSDictionary *termsDict = [bundleDict objectForKey:@"terms"];
    
    if(termsDict){
        
        countString = [termsDict objectForKey:@"count"];
        if(!countString){
            countString = @"";
        }
        
        if([countString isEqualToString:@""]){
            countString = @"0";
        }
        
    }
    
    @try{
        retInt = [countString intValue];
    }@catch(id exception){
        retInt = 0;
    }
    
    return retInt;
}

-(int)getBundleCountStringFromBundle:(NSDictionary *)bundleDict{
    
    NSString *countString = @"";
    int retInt = 0;
    
    if(!bundleDict) return retInt;
    
    NSDictionary *termsDict = [bundleDict objectForKey:@"terms"];
    
    if(termsDict){
        
        countString = [termsDict objectForKey:@"count"];
        if(!countString){
            countString = @"";
        }
        
        if([countString isEqualToString:@""]){
            countString = @"0";
        }
        
    }
    
    @try{
        retInt = [countString intValue];
    }@catch(id exception){
        retInt = 0;
    }
    
    return retInt;
}

-(int)getBundleCountStringFromGenericBundleID:(NSString *)bundleID{
    
    NSString *countString = @"";
    int retInt = 0;
    
    NSDictionary *bundleDict = [self getBundleDictFromGenericBundleID:bundleID];
    
    NSDictionary *termsDict = [bundleDict objectForKey:@"terms"];
    
    if(termsDict){
        
        countString = [termsDict objectForKey:@"count"];
        if(!countString){
            countString = @"";
        }
        
        if([countString isEqualToString:@""]){
            countString = @"0";
        }
        
    }
    
    @try{
        retInt = [countString intValue];
    }@catch(id exception){
        retInt = 0;
    }
    
    return retInt;
}

-(NSString *)getBundleSizeStringFromGenericBundleID:(NSString *)bundleID{
    
    NSString *sizeString = @"";
    
    NSDictionary *bundleDict = [self getBundleDictFromGenericBundleID:bundleID];
    
    NSDictionary *termsDict = [bundleDict objectForKey:@"terms"];
    NSDictionary *sizeDict;
    
    if(termsDict){
        
        sizeDict = [termsDict objectForKey:@"size"];
        
        NSString *heightString = [sizeDict objectForKeyNotNull:@"height"];
        NSString *widthString = [sizeDict objectForKeyNotNull:@"width"];
        
        
        if(heightString && widthString){
            int height = [heightString intValue];
            int width = [widthString intValue];
            
            if(height > width){
                sizeString = [NSString stringWithFormat:@"%i x %i", width, height, nil];
            }else{
                sizeString = [NSString stringWithFormat:@"%i x %i", height, width, nil];
            }
        }
        
    }
    
    return sizeString;
}

-(NSDictionary *)getFirstBundleWithAPNum:(NSString *)apnum{
    
    NSString *tempBundleAPNum;
    
    for(NSDictionary *tempBundle in self.bundleIndexByBundleID.allValues){
        
        tempBundleAPNum = [tempBundle objectForKey:@"APNUM"];
        if(!tempBundleAPNum) tempBundleAPNum = @"";
        if([tempBundleAPNum isEqualToString:@""]) continue;
        
        if([tempBundleAPNum isEqualToString:apnum]) return tempBundle;
    }
    
    return nil;
    
}

-(NSMutableDictionary *)populateDefaultsOnLastConfiguredPack:(NSDictionary *)inputPackDict{
    
    NSMutableDictionary *retDict = [NSMutableDictionary dictionaryWithDictionary:inputPackDict];
    
    NSDictionary *termsDict = [inputPackDict objectForKey:@"terms"];
    NSString *countString = @"0";
    
    if(termsDict){
        countString = [termsDict objectForKey:@"count"];
        if(!countString) countString = @"0";
    }
    
    NSDictionary *orderInfoDict = [inputPackDict objectForKey:@"orderInfo"];
    NSMutableDictionary *newOrderInfoDict = [NSMutableDictionary dictionaryWithDictionary:orderInfoDict];
    NSMutableDictionary *newBalanceDict = [NSMutableDictionary dictionaryWithDictionary:[orderInfoDict objectForKey:@"balance"]];
    
    [newBalanceDict setObject:countString forKey:@"count"];
    [newOrderInfoDict setObject:newBalanceDict forKey:@"balance"];
    [retDict setObject:newOrderInfoDict forKey:@"orderInfo"];
    
    NSString *newName = [[AccountManager sharedInstance] getNewPackName];
    [retDict setObject:newName forKey:@"name"];
    
    return retDict;
    
}


-(NSString *)getBundleSizeStringFromBundle:(NSDictionary *)bundleDict{
    
    NSString *sizeString = @"";
    
    if(!bundleDict) return sizeString;
    
    NSDictionary *termsDict = [bundleDict objectForKey:@"terms"];
    NSDictionary *sizeDict;
    
    if(termsDict){
        
        sizeDict = [termsDict objectForKey:@"size"];
        
        NSString *heightString = [sizeDict objectForKeyNotNull:@"height"];
        NSString *widthString = [sizeDict objectForKeyNotNull:@"width"];
        
        
        if(heightString && widthString){
            int height = [heightString intValue];
            int width = [widthString intValue];
            
            if(height > width){
                sizeString = [NSString stringWithFormat:@"%i x %i", width, height, nil];
            }else{
                sizeString = [NSString stringWithFormat:@"%i x %i", height, width, nil];
            }
        }
        
    }
    
    return sizeString;
}

-(BOOL)isBundleAPNum:(NSString *)itemNumber{
    
    NSString *tempBundleAPNum;
    
    for(NSDictionary *tempBundle in self.bundleIndexByBundleID.allValues){
        
        tempBundleAPNum = [tempBundle objectForKey:@"APNUM"];
        if(!tempBundleAPNum) tempBundleAPNum = @"";
        if([tempBundleAPNum isEqualToString:@""]) continue;
        
        if([tempBundleAPNum isEqualToString:itemNumber]) return YES;
    }

    return NO;
}

-(SACartItemType)getItemTypeFromItemNumber:(NSString *)itemNumber withCompositeSku:(NSString *)compositeSku{
    
    //check if it is a bundle
    if([self isBundleAPNum:itemNumber]) return CartItemTypeBundle;
    
    //not a bundle - check for frame
    NSDictionary *theDict = [self getFrameDictFromAPNum:itemNumber];
    if(theDict) return CartItemTypeFrame;
    
    //not a frame - return print type
    return CartItemTypePrint;
    
}

-(void)indexBundles{
    
    self.bundleIndex = [[NSMutableDictionary alloc] init];
    self.bundleIndexByBundleID = [[NSMutableDictionary alloc] init];
    self.frameIndexByAPNum = [[NSMutableDictionary alloc] init];
    
    NSArray *bundleArray = [self.bundleDictionary objectForKey:@"Bundles"];
    
    NSDictionary *frameDict;
    NSDictionary *termsDict;
    NSDictionary *sizeDict;
    NSString *bundleID;
    NSString *frameAPNum;
    NSString *frameString;
    NSString *heightString;
    NSString *widthString;
    NSString *sizeString;
    NSString *countString;
    int height = 0;
    int width = 0;
    
    NSString *bundleKey;
    
    if(bundleArray){
        for(NSDictionary *bundleDict in bundleArray){
    
            bundleID = [bundleDict objectForKey:@"bundleId"];
            
            if(![self.bundleIndexByBundleID objectForKey:bundleID]){
                if(![bundleID isEqualToString:@""]){
                    [self.bundleIndexByBundleID setObject:bundleDict forKey:bundleID];
                    //NSLog(@"Indexed Bundle by ID: %@", bundleID);
                }
            }else{
                //NSLog(@"Bundle ID Exists in Index: %@", bundleID);
            }
            
            termsDict = [bundleDict objectForKey:@"terms"];
            
            if(termsDict){
                
                frameDict = [termsDict objectForKey:@"frame"];
                
                if(frameDict){
                    frameString = [frameDict objectForKey:@"frameText"];
                    frameAPNum = [frameDict objectForKey:@"frameAPNUM"];
                    
                    if(frameAPNum){
                        if(![frameAPNum isEqualToString:@""]){
                            if(![self.frameIndexByAPNum objectForKey:frameAPNum]){
                                [self.frameIndexByAPNum setObject:frameDict forKey:frameAPNum];
                                //NSLog(@"Indexed Frame APNum: %@", frameAPNum);
                            }else{
                                //NSLog(@"Frame APNum Exists in Index: %@", frameAPNum);
                            }
                        }
                    }
                }
                
                if(!frameString){
                    frameString = @"";
                }
                
                if([frameString isEqualToString:@""]){
                    frameString = @"NOFRAME";
                }
                
                sizeDict = [termsDict objectForKey:@"size"];
                
                heightString = [sizeDict objectForKeyNotNull:@"height"];
                widthString = [sizeDict objectForKeyNotNull:@"width"];
                
                if(heightString && widthString){
                    height = [heightString intValue];
                    width = [widthString intValue];
                    
                    if(height > width){
                        sizeString = [NSString stringWithFormat:@"%ix%i", width, height, nil];
                    }else{
                        sizeString = [NSString stringWithFormat:@"%ix%i", height, width, nil];
                    }
                }
                
                countString = [termsDict objectForKey:@"count"];
                if(!countString){
                    countString = @"";
                }
                
                if([countString isEqualToString:@""]){
                    countString = @"0";
                }
            }
            

            
            bundleKey = [@"BUNDLE_KEY_" stringByAppendingString:[frameString uppercaseString]];
            bundleKey = [bundleKey stringByAppendingString:@"_"];
            bundleKey = [bundleKey stringByAppendingString:sizeString];
            bundleKey = [bundleKey stringByAppendingString:@"_"];
            bundleKey = [bundleKey stringByAppendingString:countString];
            
            if(![self.bundleIndex objectForKey:bundleKey]){
                [self.bundleIndex setObject:bundleDict forKey:bundleKey];
                //NSLog(@"Indexed bundle: %@", bundleKey);
            }
        }
    }
    
}

-(NSArray *)getBundlesForOrientation:(SAImageOrientation)orientation{

    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    
    NSArray *bundleArray = [self.bundleDictionary objectForKey:@"Bundles"];
    
    NSDictionary *termsDict;
    NSDictionary *sizeDict;
    NSString *heightString;
    NSString *widthString;
    int height = 0;
    int width = 0;
    
    if(bundleArray){
        for(NSDictionary *bundleDict in bundleArray){
            
            termsDict = [bundleDict objectForKey:@"terms"];
            
            if(termsDict){
                
                sizeDict = [termsDict objectForKey:@"size"];
                
                heightString = [sizeDict objectForKeyNotNull:@"height"];
                widthString = [sizeDict objectForKeyNotNull:@"width"];
                
                if(heightString && widthString){
                    height = [heightString intValue];
                    width = [widthString intValue];
                    
                    if(height == width){
                        //square
                        if(orientation == OrientationSquare){
                            [retArray addObject:bundleDict];
                        }
                    }else{
                        //landscape or portrait
                        if(orientation != OrientationSquare){
                            [retArray addObject:bundleDict];
                        }
                    }
                }
            }
        }
    }
    
    return retArray;
    
}

+(NSArray *)getOrderedSizeArrayFromBundles:(NSArray *)bundleArray{
    
    NSMutableDictionary *dedupeDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *unsortedArray = [[NSMutableArray alloc] init];
    NSArray *sortedArray;
    NSMutableDictionary *sortableDict;
    
    
    NSDictionary *termsDict;
    NSDictionary *sizeDict;
    NSString *heightString;
    NSString *widthString;
    NSString *sizeString;
    int height = 0;
    int width = 0;
    int unitedInchesInt = 0;
    NSNumber *unitedInches;
    NSNumber *largeSideNumber;
    NSNumber *smallSideNumber;
    
    
    if(bundleArray){
        for(NSDictionary *bundleDict in bundleArray){
            
            termsDict = [bundleDict objectForKey:@"terms"];
            
            if(termsDict){
                
                sizeDict = [termsDict objectForKey:@"size"];
                
                heightString = [sizeDict objectForKeyNotNull:@"height"];
                widthString = [sizeDict objectForKeyNotNull:@"width"];
                
                if(heightString && widthString){
                    height = [heightString intValue];
                    width = [widthString intValue];
                    unitedInchesInt = height + width;
                    unitedInches = [NSNumber numberWithInt:unitedInchesInt];
                    
                    if(height > 0 && width > 0){
                        if(height > width){
                            sizeString = [NSString stringWithFormat:@"%ix%i", width, height, nil];
                            largeSideNumber = [NSNumber numberWithInt:height];
                            smallSideNumber = [NSNumber numberWithInt:width];
                        }else{
                            sizeString = [NSString stringWithFormat:@"%ix%i", height, width, nil];
                            largeSideNumber = [NSNumber numberWithInt:width];
                            smallSideNumber = [NSNumber numberWithInt:height];
                        }
                        
                        if(![dedupeDict objectForKey:sizeString]){
                            sortableDict = [[NSMutableDictionary alloc] init];
                            [sortableDict setObject:sizeString forKey:@"SizeString"];
                            [sortableDict setObject:unitedInches forKey:@"UnitedInches"];
                            [sortableDict setObject:largeSideNumber forKey:@"LargeSide"];
                            [sortableDict setObject:smallSideNumber forKey:@"SmallSide"];
                            [dedupeDict setObject:sizeString forKey:sizeString];
                            [unsortedArray addObject:sortableDict];
                        }
                    }
                }
            }
        }
    }
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"UnitedInches" ascending:YES];
    NSArray * descriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    sortedArray = [unsortedArray sortedArrayUsingDescriptors:descriptors];
    
    return sortedArray;
    
}

+(NSArray *)getOrderedCountArrayFromBundles:(NSArray *)bundleArray{
    
    NSMutableDictionary *dedupeDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *unsortedArray = [[NSMutableArray alloc] init];
    NSArray *sortedArray;
    NSMutableDictionary *sortableDict;
    
    
    NSDictionary *termsDict;
    NSString *countString;
    int countInt = 0;
    NSNumber *count;
    
    if(bundleArray){
        for(NSDictionary *bundleDict in bundleArray){
            
            termsDict = [bundleDict objectForKey:@"terms"];
            
            if(termsDict){
                
                countString = [termsDict objectForKeyNotNull:@"count"];
                
                if(countString){
                    countInt = [countString intValue];
                    count = [NSNumber numberWithInt:countInt];
                    
                    if(countInt > 0){
                        //do not add any 0 values
                        if(![dedupeDict objectForKey:countString]){
                            sortableDict = [[NSMutableDictionary alloc] init];
                            [sortableDict setObject:countString forKey:@"CountString"];
                            [sortableDict setObject:count forKey:@"CountNumber"];
                            [dedupeDict setObject:countString forKey:countString];
                            if(![countString isEqualToString:@"0"]){
                                [unsortedArray addObject:sortableDict];
                            }
                        }
                    }
                }
            }
        }
    }
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"CountNumber" ascending:YES];
    NSArray * descriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    sortedArray = [unsortedArray sortedArrayUsingDescriptors:descriptors];
    
    return sortedArray;
    
}

-(NSDictionary *)getBundleForFrame:(NSString *)frameString forSize:(NSString *)sizeString forCount:(NSString *)countString{
    
    NSString *bundleKey = [@"BUNDLE_KEY_" stringByAppendingString:[frameString uppercaseString]];
    bundleKey = [bundleKey stringByAppendingString:@"_"];
    bundleKey = [bundleKey stringByAppendingString:sizeString];
    bundleKey = [bundleKey stringByAppendingString:@"_"];
    bundleKey = [bundleKey stringByAppendingString:countString];
    
    NSLog(@"Looking up bundle: %@", bundleKey);
    
    NSDictionary *bundleDict = [self.bundleIndex objectForKey:bundleKey];
    
    return bundleDict;
    
}

@end
