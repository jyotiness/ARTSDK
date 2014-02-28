//
//  ACTableViewController.m
//  Art
//
//  Created by Brad Smith on 7/11/11.


#import "ACTableViewController.h"


@implementation ACTableViewController

@synthesize tableView = _tableView;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidUnload {
    self.tableView = nil;
}


@end
