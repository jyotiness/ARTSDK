//
//  ACActivityViewController.m
//  ArtAPI
//
//  Created by Doug Diego on 1/27/14.
//  Copyright (c) 2014 Doug Diego. All rights reserved.
//

#import "ACActivityViewController.h"
#import "Analytics.h"

@interface ACActivityViewController ()

@end

@implementation ACActivityViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //NSLog(@"ACActivityViewController.viewDidLoad");
    
    __weak typeof(self) weakSelf = self;
    
    [self setCompletionHandler:^(NSString *activityType, BOOL completed)
     {
         //NSLog(@"ACActivityViewController - activityType: %@ completed: %d itemId: %@", activityType, completed, weakSelf.itemId);
         
         if (completed) {
             [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION
                        withAction:[NSString stringWithFormat:@"Item Shared %@", activityType]
                         withLabel:weakSelf.itemId];
             //NSLog(@"Item was shared to: %@", activityType);
         } else {
            // NSLog(@"Item was not shared to: %@", activityType);
             [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION
                        withAction:ANALYTICS_EVENT_NAME_ITEM_SHARE_CANCELED
                         withLabel:activityType];
         }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
