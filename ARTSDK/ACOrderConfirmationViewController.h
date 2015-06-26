//
//  PAAOrderConfirmationViewController.h
//  PhotosArt
//
//  Created by Jobin on 03/10/12.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GAITrackedViewController.h"

/**
 * A view controller displays an order confirmation
 *
 * <h2>NSNotificationCenter</h2>
 *
 * Responds notification: NOTIFICATION_DISMISS_MODAL  This will close the modal
 *
 */

@interface ACOrderConfirmationViewController : GAITrackedViewController<MFMailComposeViewControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, retain) NSString *orderNumber;
@property (retain, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (retain, nonatomic) IBOutlet UILabel *thankLabel;
@property (retain, nonatomic) IBOutlet UILabel *confirmationLabel;
@property (retain, nonatomic) IBOutlet UIButton *doneButton;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *yourorderLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiptLabel;
@property (weak, nonatomic) IBOutlet UILabel *customerSupportLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *detailsHolderView;

- (IBAction)confirmIButtonTapped:(UIButton *)sender;
- (IBAction)emailButtonTapped:(UIButton *)sender;
- (IBAction)doneWithShopping:(id)sender;
- (IBAction)goBack:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *supportMailLabel;
@property (strong, nonatomic) IBOutlet UIView *supportFrame;

@end
