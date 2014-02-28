//
//  PGTableViewWithEmptyView.m
//  iDJ-Remix
//
//  Created by Pete Goodliffe on 8/31/10.
//  Copyright 2010 Pete Goodliffe. All rights reserved.
//

#import "PGTableViewWithEmptyView.h"

#import <QuartzCore/QuartzCore.h>

@implementation PGTableViewWithEmptyView

@synthesize emptyView;


- (bool)tableViewHasRows {
    // TODO: This only supports the first section so far

    // Note: If numberOfSections is 0 you get a bogas number when requesting numberOfRowsInSection:0
    // That was the bug from the oringanl code set... I've set the changes back to the correct values 
    // in updateEmptyPage... R.S.
    NSUInteger numSections = [self numberOfSections];
    NSUInteger numRows = [self numberOfRowsInSection:0];


    if (numSections > 0) if (numRows > 0)
        return true;

    return false;
}

- (void)updateEmptyPage {
    const CGRect rect = (CGRect) {CGPointZero, self.frame.size};
    emptyView.frame = rect;

    //If table view does not have rows you should show the empty view... R.S.
    const bool shouldShowEmptyView = !self.tableViewHasRows;
    const bool emptyViewShown = emptyView.superview != nil;

    if (shouldShowEmptyView == emptyViewShown) return;

    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[self layer] addAnimation:animation forKey:kCATransitionReveal];

    if (shouldShowEmptyView)
        [self addSubview:emptyView];
    else
        [emptyView removeFromSuperview];
}

- (void)setEmptyView:(UIView *)newView {
    if (newView == emptyView) return;

    UIView *oldView = emptyView;
    emptyView = newView;

    [oldView removeFromSuperview];

    [self updateEmptyPage];
}

#pragma mark UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateEmptyPage];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // Prevent any interaction when the empty view is shown
    const bool emptyViewShown = emptyView.superview != nil;
    return emptyViewShown ? nil : [super hitTest:point withEvent:event];
}

#pragma mark UITableView

- (void)reloadData {
    [super reloadData];
    [self updateEmptyPage];
}

@end
