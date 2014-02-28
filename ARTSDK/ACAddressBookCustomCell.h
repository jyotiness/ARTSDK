//
//  PAACustomCell.h
//  PhotosArt
//
//  Created by Sreedeep on 11/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACCheckoutTextField.h"

@interface ACAddressBookCustomCell : UITableViewCell

@property (nonatomic,retain) IBOutlet UILabel *textLabel;
@property (nonatomic,retain) IBOutlet UIButton *contactPickerButton;
@property (nonatomic,retain) IBOutlet ACCheckoutTextField *textField;
@property (nonatomic,retain) IBOutlet UIButton *pickerButton;
- (IBAction)cellTitleTapped:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *cellTitleButton;

@end
