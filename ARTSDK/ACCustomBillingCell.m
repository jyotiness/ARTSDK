//
//  PAACustomBillingCell.m
//  PhotosArt
//
//  Created by Sreedeep on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AcCustomBillingCell.h"

@implementation ACCustomBillingCell
@synthesize textField,textLabel,contactPickerButton,pickerButton,sameShippingAddress,cellTitleButton;
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

    NSLog(@"cellTitleTapped");
    //Anuj - getting this error here:
    //[ACCustomBillingCell _didChangeToFirstResponder:]: message sent to deallocated instance 0x1aaf6110
    
    if(self.textField){
        if(![self.textField isFirstResponder]){
            [self.textField becomeFirstResponder];
        }
    }
    
}

@end
