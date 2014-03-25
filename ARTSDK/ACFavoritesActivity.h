//
//  ACFavoritesActivity.h
//  ArtAPI
//
//  Created by Doug Diego on 2/10/14.
//  Copyright (c) 2014 Doug Diego. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    FavoritesTypeGallery,
    FavoritesTypeItem,
    FavoritesTypeOther
} FavoritesType;

@interface ACFavoritesActivity : UIActivity

@property(readwrite,nonatomic) FavoritesType type;

- (instancetype)initWithType:(FavoritesType)type;

@end
