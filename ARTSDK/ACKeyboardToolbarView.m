//
//  ACKeyboardToolbarView.m
//  ArtAPI
//
//  Created by Doug Diego on 10/16/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ACKeyboardToolbarView.h"
#import "ACConstants.h"

@interface ACKeyboardToolbarView()
@property (nonatomic, readwrite, assign) BOOL hideNextPrevButtons;
@end

@implementation ACKeyboardToolbarView

- (id)initWithFrame:(CGRect)frame hideNextPrevButtons: (BOOL) hideNextPrevButtons {
    self = [super initWithFrame:frame];
    if (self) {
        self.hideNextPrevButtons = hideNextPrevButtons;
        [self setupUI];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hideNextPrevButtons = NO;
        [self setupUI];
    }
    return self;
}

-(void) setupUI {
    //[self setBackgroundColor:[UIColor whiteColor]];
    
    // Create SegmentedControl
    if( !self.hideNextPrevButtons ){
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[ACLocalizedString(@"PREVIOUS", @"PREVIOUS"), ACLocalizedString(@"NEXT", @"NEXT") ]];
        [segmentedControl setTintColor:APP_TINT_COLOR];
        segmentedControl.frame = CGRectMake(5, 5, 160, 30);
        segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
        [segmentedControl addTarget:self
                             action:@selector(nextPrevButtonPressed:)
                   forControlEvents:UIControlEventValueChanged];
        [self addSubview:segmentedControl];
    }
    
    // Create Done Button
    UIButton * btnDone = [UIButton buttonWithType:UIButtonTypeSystem];
    btnDone.tintColor = APP_TINT_COLOR;
    [btnDone setFrame:CGRectMake(self.bounds.size.width - 70, 0.0f, 70.0f, 40.0f)];
    [btnDone setTitle:ACLocalizedString(@"DONE", @"DONE") forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnDone];
}

-(void) nextPrevButtonPressed: (id) sender {
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    if(segmentedControl.selectedSegmentIndex == 1){
        // Call Delegate
        if (self.toolbarDelegate && [self.toolbarDelegate respondsToSelector:@selector(keyboardToolbar:didSelectNext:)]) {
            [self.toolbarDelegate keyboardToolbar:self didSelectNext:sender];
        }
    } else {
        // Call Delegate
        if (self.toolbarDelegate && [self.toolbarDelegate respondsToSelector:@selector(keyboardToolbar:didSelectPrevious:)]) {
            [self.toolbarDelegate keyboardToolbar:self didSelectPrevious:sender];
        }
    }
    
    // Deselected Segment Control
    segmentedControl.selectedSegmentIndex = -1;
}

-(void) doneButtonPressed: (id) sender {
    // Call Delegate
    if (self.toolbarDelegate && [self.toolbarDelegate respondsToSelector:@selector(keyboardToolbar:didSelectDone:)]) {
        [self.toolbarDelegate keyboardToolbar:self didSelectDone:sender];
    }
}


@end
