//
//  ACSharingActivityProvider.h
//  JudyTouch
//
//  Created by Doug Diego on 10/17/13.
//  Copyright (c) 2013 Art.com, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACSharingActivityProvider : UIActivityItemProvider
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *imageURL;
@property(nonatomic, strong) NSString *sourceURL;
@property(nonatomic, strong) NSString *iTunesURL;
@property(nonatomic, strong) NSString *appName;
@property(nonatomic, strong) NSString *itemId;
@property(nonatomic, strong) NSString *shareItemId;
@property(nonatomic, strong) NSString *galleryItemId;
@end
