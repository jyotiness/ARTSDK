//
//  PAAShippingOptionsTableViewCellCell.h
//  PhotosArt
//
//  Created by Sreedeep on 09/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACShipOptionsTableViewCell : UITableViewCell{

}

@property (nonatomic,assign) int shippingType;
@property (nonatomic,retain) NSDecimalNumber *shippingCost;
@property (retain, nonatomic) IBOutlet UILabel *shippingDescriptionLabel;
@property (retain, nonatomic) IBOutlet UILabel *shippingPriceLabel;
@property (retain, nonatomic) IBOutlet UIButton *checkMarkButton;

@end
