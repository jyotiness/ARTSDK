//
//  ACActivityViewController.h
//  ArtAPI
//
//  Created by Doug Diego on 1/27/14.
//  Copyright (c) 2014 Doug Diego. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ACActivityViewControllerCompletionHandler)(NSString *activityType, BOOL completed);

@interface ACActivityViewController : UIActivityViewController
@property (nonatomic, readwrite,copy) NSString *itemId;
@property(nonatomic,copy) ACActivityViewControllerCompletionHandler acCompletionHandler;  // set to nil after call
@end
