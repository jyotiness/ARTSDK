//
//  ACFavoritesRemoveActivity.h
//  ArtAPI
//
//  Created by Doug Diego on 2/13/14.
//  Copyright (c) 2014 Doug Diego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACFavoritesActivity.h"

@protocol ACShareDelegate;

@interface ACFavoritesRemoveActivity : UIActivity

@property(readwrite,nonatomic) FavoritesType type;
@property (nonatomic, weak) id <ACShareDelegate> delegate;

- (instancetype)initWithType:(FavoritesType)type;
- (instancetype)initWithType:(FavoritesType)type andDelegate:(id)delegate;


@end

@protocol ACShareDelegate<NSObject>
@optional
-(void)updateSlideshowForRemovedItem:(ACFavoritesRemoveActivity *)removeActivity;

@end