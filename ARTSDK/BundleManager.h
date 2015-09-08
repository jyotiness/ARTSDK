//
//  BundleManager.h
//  SwitchArt
//
//  Created by Mike Larson on 10/23/14.
//  Copyright (c) 2014 Art.com, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAUtilities.h"

#define DID_VIEW_HELP_KEY @"DIDVIEWHELP"

@interface BundleManager : NSObject

@property(nonatomic,strong) NSDictionary *bundleDictionary;
@property(nonatomic,strong) NSMutableDictionary *bundleIndex;
@property(nonatomic,strong) NSNumber *didViewHelp;
@property(nonatomic,strong) NSMutableDictionary *bundleIndexByBundleID;
@property(nonatomic,strong) NSMutableDictionary *frameIndexByAPNum;
@property(nonatomic,assign) NSInteger pixelsPerInchMinimum;

+ (BundleManager*) sharedInstance;
-(NSArray *)getBundlesForOrientation:(SAImageOrientation)orientation;
+(NSArray *)getOrderedSizeArrayFromBundles:(NSArray *)bundleArray;
+(NSArray *)getOrderedCountArrayFromBundles:(NSArray *)bundleArray;
-(NSDictionary *)getBundleForFrame:(NSString *)frameString forSize:(NSString *)sizeString forCount:(NSString *)countString;
+(NSNumber *)didViewHelp;
-(NSNumber *)didViewHelp;
+(void)setDidViewHelp:(NSNumber *)didViewHelpInput;
-(void)setDidViewHelp:(NSNumber *)didViewHelpInput;
-(void)setBundleConfigurations:(id)JSON;
-(NSDictionary *)getFrameDictFromAPNum:(NSString *)frameAPNum;
-(NSDictionary *)getBundleDictFromGenericBundleID:(NSString *)bundleID;
-(NSDictionary *)getFirstBundleWithAPNum:(NSString *)apnum;
-(SACartItemType)getItemTypeFromItemNumber:(NSString *)itemNumber withCompositeSku:(NSString *)compositeSku;
-(NSString *)getBundleSizeStringFromGenericBundleID:(NSString *)itemNumber;
-(NSString *)getBundleSizeStringFromBundle:(NSDictionary *)bundleDict;
-(int)getBundleCountStringFromGenericBundleID:(NSString *)itemNumber;
-(int)getBundleCountStringFromBundle:(NSDictionary *)bundleDict;
-(int)getBundleCountStringFromDict:(NSDictionary *)bundleDict;
-(NSString *)getFrameColorStringFromItemNumber:(NSString *)itemNumber;
-(NSMutableDictionary *)populateDefaultsOnLastConfiguredPack:(NSDictionary *)inputPackDict;

@end
