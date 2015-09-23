//
//  PAAMasterVariations.h
//  PhotosArt
//
//  Created by Jobin on 14/09/12.
//
//

#import <Foundation/Foundation.h>

@interface ACMasterVariations : NSObject
{
    NSString   *dimensions;
    NSString   *mPodConfigId;
    NSString   *mTimeToShipText;
    BOOL        warningValue;
    CGFloat size;
    CGFloat small;
}

@property (nonatomic,copy) NSString   *dimensions;
@property (nonatomic,copy) NSString   *podConfigId;
@property (nonatomic,copy) NSString   *timeToShipText;
@property (nonatomic, assign) BOOL     warningValue;
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, assign) CGFloat small;

@end
