//
//  PAAShippingOptionsTableViewCellCell.m
//  PhotosArt
//
//  Created by Sreedeep on 09/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACShipOptionsTableViewCell.h"

@implementation ACShipOptionsTableViewCell
@synthesize shippingDescriptionLabel;
@synthesize shippingPriceLabel;
@synthesize checkMarkButton;
@synthesize shippingType = _shippingType;
@synthesize shippingCost = _shippingCost;

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
}
@end
