//
//  ACCartViewController.h
//  ArtAPI
//
//  Created by Doug Diego on 4/9/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ACShoppingCartItemTableCell.h"
#import "ACActivityIndicator.h"

@protocol ACShoppingCartViewDelegate;

@interface ACShoppingCartViewController : UIViewController  <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    IBOutlet UIView *tableViewFooter;
    IBOutlet UIView *subtotalBar;
    IBOutlet UILabel *subtotalLabel;
    NSMutableArray *_cartItems;
    UIToolbar *keyboardDoneButtonView;
    UIPickerView *pickerView;
    UITextField *textFieldBeingEdited;
    UIButton *activeQuantityButton;
    ACActivityIndicator *activityIndicator;
}

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSDictionary *data;
@property(nonatomic, strong) UINib *cellNib;
@property(nonatomic, strong) UITableViewCell *tmpCell;
@property (assign, nonatomic) id <ACShoppingCartViewDelegate> delegate;

- (void)editButtonPressed:(id)sender;

- (void)updateSubtotalLabel;

- (void)updateNavigationBarButtons;

- (void)loadDataFromAPI;

- (void)showActivityIndicator:(ACActivityIndicatorType)type;

- (void)hideActivityIndicator;

@end


@protocol ACShoppingCartViewDelegate <NSObject>
- (void)presentCheckout:(id)sender;
@end

