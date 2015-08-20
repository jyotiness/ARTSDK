//
//  ACKeyboardToolbarView.h
//  ArtAPI
//
//  Created by Doug Diego on 10/16/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Additions.h"

@protocol ACKeyboardToolbarDelegate;

@interface ACKeyboardToolbarView : UIToolbar
@property (assign, nonatomic) id <ACKeyboardToolbarDelegate> toolbarDelegate;
@property (assign, nonatomic)BOOL isModalKeyboard;

//@property (nonatomic, assign) NSIndexPath *cellIndexPath;

- (id)initWithFrame:(CGRect)frame hideNextPrevButtons: (BOOL) hideNextPrevButtons;
- (void)layoutDoneButton;

@end

@protocol ACKeyboardToolbarDelegate<NSObject>
@optional
- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectNext: (id) next ;
- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectPrevious: (id) previous ;
- (void)keyboardToolbar: (ACKeyboardToolbarView*) keyboardToolbar didSelectDone: (id) done ;
@end
