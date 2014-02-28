//
//  ACShoppingCartItemTableCell.m
//  Art
//

#import "ACShoppingCartItemTableCell.h"
#import "UIColor+Additions.h"

@implementation ACShoppingCartItemTableCell
/*
@synthesize photo = _photo;
@synthesize name = _name;
@synthesize dimensions = _dimensions;
@synthesize price = _price;
@synthesize info = _info;
@synthesize quantityTextField = _quantityTextField;
*/

- (void)awakeFromNib {
    //self.backgroundView.backgroundColor = [UIColor artDotComLightGray_Light_Color_iPad];
    self.selectedBackgroundView.backgroundColor = [UIColor artDotComDarkGrayColor_iPad];
    self.quantityTextField.alpha = 0;
}


/*
#pragma mark
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        // [self.accessoryView removeFromSuperview];
        [(UIImageView *) self.accessoryView setImage:[UIImage imageNamed:ARTImage(@"icon_browseArrow_h"]];
    }
    else {
        [(UIImageView *) self.accessoryView setImage:[UIImage imageNamed:ARTImage(@"icon_browseArrow_n"]];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [UIView beginAnimations:@"" context:nil];
    //self.quantityTextField.alpha = !editing;
    [UIView commitAnimations];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
    if (state & UITableViewCellStateShowingDeleteConfirmationMask) {
        [UIView animateWithDuration:0.33 animations:^(void) {
            CGRect f = self.name.frame;
            f.size.width -= 65;
            self.name.frame = f;
            f = self.info.frame;
            f.size.width -= 65;
            self.info.frame = f;
        }];
    }
    else if (self.showingDeleteConfirmation) {
        [UIView animateWithDuration:0.33 animations:^(void) {
            CGRect f = self.name.frame;
            f.size.width += 65;
            self.name.frame = f;
            f = self.info.frame;
            f.size.width += 65;
            self.info.frame = f;
        }];
    }

}
*/
@end
