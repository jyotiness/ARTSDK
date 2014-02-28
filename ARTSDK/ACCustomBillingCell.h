//
//  PAACustomBillingCell.h
//  PhotosArt
//
//  Created by Sreedeep on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACCheckoutTextField.h"
@interface ACCustomBillingCell : UITableViewCell
@property (nonatomic,retain) IBOutlet UILabel *textLabel;
@property (retain, nonatomic) IBOutlet UIButton *contactPickerButton;
@property (retain, nonatomic) IBOutlet UIButton *scanCardButton;
@property (nonatomic,retain) IBOutlet ACCheckoutTextField *textField;
@property (nonatomic,retain) IBOutlet UIButton *pickerButton;
@property(nonatomic,retain) IBOutlet UISwitch *sameShippingAddress;
@property (strong, nonatomic) IBOutlet UIButton *cellTitleButton;
- (IBAction)cellTitleTapped:(UIButton *)sender;

@end
