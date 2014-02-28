//
//  PAACustomCell.m
//  PhotosArt
//
//  Created by Sreedeep on 11/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACAddressBookCustomCell.h"

@implementation ACAddressBookCustomCell
@synthesize contactPickerButton;
@synthesize textField,textLabel,pickerButton,cellTitleButton;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cellTitleTapped:(UIButton *)sender {
    if(![self.textField isFirstResponder])
        [self.textField becomeFirstResponder];
}
@end
