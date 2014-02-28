//
//  UIBarButtonItem+ArtDotCom.m
//  Art
//
//  Created by Brad Smith on 6/21/11.


#import "UIBarButtonItem+ArtDotCom.h"

#import "UIColor+Additions.h"

@implementation UIBarButtonItem (ArtDotCom)

+ (UIButton *)customButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 36, 36);
    UIFont *font = [UIFont fontWithName:@"AvenirNextLTPro-Demi" size:12];
    //[button setFont:font];
    button.titleLabel.font = font;
    [button setTitleColor:[UIColor artDotComLightGray_MediumLight_Color_iPad] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.33] forState:UIControlStateNormal];
    [button.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    return button;
}

+ (UIBarButtonItem *)customButtonWithStyle:(ACBarButtonItemStyle)style target:(id)target action:(SEL)action {
    UIButton *button = [self customButton];

    NSString *baseImageName = nil;
    NSString *baseBackgroundName = nil;
    NSString *title = nil;
    if (style == ACBarButtonItemStyleAdd) baseImageName = @"btn_generalAddTo";
    if (style == ACBarButtonItemStyleAirPlay) baseImageName = @"btn_generalAirPlay";
    if (style == ACBarButtonItemStyleClose) baseImageName = @"btn_generalClose";
    if (style == ACBarButtonItemStyleGridView) baseImageName = @"btn_generalGridView";
    if (style == ACBarButtonItemStyleLeftArrow) {
        baseBackgroundName = @"btn_generalLeftArrow";
        button.frame = CGRectMake(5, 4, 57, 36);
        title = @"Back";
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    }
    if (style == ACBarButtonItemStyleListView) baseImageName = @"btn_generalListView";
    if (style == ACBarButtonItemStyleRightArrow) baseImageName = @"btn_generalRightArrow";
    if (style == ACBarButtonItemStyleSearch) baseImageName = @"btn_generalSearch";

    if (baseImageName) {
        NSString *normalName = [NSString stringWithFormat:@"%@_n", baseImageName];
        NSString *highlightesName = [NSString stringWithFormat:@"%@_h", baseImageName];
        [button setImage:[UIImage imageNamed:normalName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:highlightesName] forState:UIControlStateHighlighted];
    }

    if (baseBackgroundName) {
        NSString *normalName = [NSString stringWithFormat:@"%@_n", baseBackgroundName];
        NSString *highlightesName = [NSString stringWithFormat:@"%@_h", baseBackgroundName];
        [button setBackgroundImage:[UIImage imageNamed:normalName] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:highlightesName] forState:UIControlStateHighlighted];
    }

    [button setTitle:title forState:UIControlStateNormal];

    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (UIBarButtonItem *)customButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *button = [self customButton];
    button.frame = CGRectMake(0, 0, 75, 36);
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
//    UIImage *normalBackground = [[UIImage imageNamed:@"btn_generalNav_n"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
//    UIImage *selectedBackground = [[UIImage imageNamed:@"btn_generalNav_h"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
//    [button setBackgroundImage:normalBackground forState:UIControlStateNormal];
//    [button setBackgroundImage:selectedBackground forState:UIControlStateHighlighted];
    CGSize size = [title sizeWithFont:button.titleLabel.font];
    button.frame = CGRectMake(0, 0, size.width + 30, 36);

    [button setTitle:title forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}


/*
- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
  UIBarButtonItem *item = [UIBarButtonItem customButtonWithTitle:title target:target action:action];
  [item setTarget:target];
  [item setAction:action];
  return [item retain];
}
*/
@end
