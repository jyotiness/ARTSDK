//
//  ACLoginCustomCell.h
//  ArtAPI
//
//  Created by Doug Diego on 5/2/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACCheckoutTextField.h"

@interface ACLoginCustomCell : UITableViewCell

@property (nonatomic,retain) IBOutlet UILabel *textLabel;
@property (nonatomic,retain) IBOutlet ACCheckoutTextField *textField;

@end
