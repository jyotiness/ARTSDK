//
//  ACShoppingCartItemTableCell.h
//  Art Dot Com iPhone App
//

#import <UIKit/UIKit.h>
#import "NINetworkImageView.h"

@interface ACShoppingCartItemTableCell : UITableViewCell

@property(nonatomic, strong) IBOutlet NINetworkImageView *photo;
@property(nonatomic, strong) IBOutlet UILabel *name;
@property(nonatomic, strong) IBOutlet UILabel *price;
@property(nonatomic, strong) IBOutlet UILabel *dimensions;
@property(nonatomic, strong) IBOutlet UILabel *info;
@property(nonatomic, strong) IBOutlet UITextField *quantityTextField;

@end
