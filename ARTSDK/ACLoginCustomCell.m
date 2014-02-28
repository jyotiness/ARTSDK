//
//  ACLoginCustomCell.m
//  ArtAPI
//
//  Created by Doug Diego on 5/2/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ACLoginCustomCell.h"

@implementation ACLoginCustomCell

@synthesize textField,textLabel;

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

@end


