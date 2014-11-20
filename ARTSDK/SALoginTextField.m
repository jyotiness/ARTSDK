//
//  SALoginTextField.m
//  Pods
//
//  Created by Jobin on 11/20/14.
//
//

#import "SALoginTextField.h"

@implementation SALoginTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 30, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 30, 0);
}


@end
