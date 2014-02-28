//
//  PAAOrderConfirmationViewController.m
//  PhotosArt
//
//  Created by Jobin on 03/10/12.
//
//

#import "ACOrderConfirmationViewController.h"
#import "ACWebViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ArtAPI.h"
#import "Analytics.h"
//#import "Helpshift.h"

@interface ACOrderConfirmationViewController ()

@end

@implementation ACOrderConfirmationViewController
@synthesize orderNumber;
@synthesize orderNumberLabel;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)rateTheApp{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RATE_THE_APP" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //mkl adding delay for Rate the App
    
    [self performSelector:@selector(rateTheApp) withObject:nil afterDelay:RATE_APP_DELAY];
    
    [self.supportMailLabel setText:[ACConstants getLocalizedStringForKey:@"SUPPORT_EMAIL_&&" withDefaultValue:@"support@art.com"]];
    
    [self.phoneNumberLabel setText:[ACConstants getLocalizedStringForKey:@"SUPPORT_PHONE_&&" withDefaultValue:@"1-800-952-5592"]];
    
    [self.supportMailLabel sizeToFit];
    [self.phoneNumberLabel sizeToFit];
    
    CGRect phoneFrame = self.phoneNumberLabel.frame;
    phoneFrame.origin.x = 0;
    self.phoneNumberLabel.frame = phoneFrame;
    
    CGRect mailFrame = self.supportMailLabel.frame;
    mailFrame.origin.x = CGRectGetMaxX(phoneFrame) + 5;
    mailFrame.origin.y = mailFrame.origin.y - 1;
    self.supportMailLabel.frame = mailFrame;
    
    self.emailLabel.frame = self.supportMailLabel.frame;
    
    CGFloat supportFrameWidth = phoneFrame.size.width + 5 + mailFrame.size.width;
    
    CGFloat horizontalCentre = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?270:160;
    CGRect supportViewFrame = self.supportFrame.frame;
    supportViewFrame = CGRectMake(horizontalCentre - supportFrameWidth/2, supportViewFrame.origin.y + 5, supportFrameWidth, supportViewFrame.size.height);
    
    self.supportFrame.frame = supportViewFrame;
    
    // Listen for notification kACNotificationDismissModal
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissModal) name:kACNotificationDismissModal object:nil];
    
    self.orderNumberLabel.text = [NSString stringWithFormat:@"#%@",self.orderNumber];
    [self.thankLabel setFont:[ACConstants getStandardBoldFontWithSize:30.0f]];
    [self.confirmationLabel setFont:[ACConstants getStandardBoldFontWithSize:30.0f]];
    [self.doneButton.titleLabel setFont:[ACConstants getStandardBoldFontWithSize:23.0f]];
    // Do any additional setup after loading the view from its nib.
    
    AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
    if((currAppLoc == AppLocationFrench) || (currAppLoc == AppLocationGerman))
    {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"apc_checkout"]];
        [self.doneButton setBackgroundImage:[UIImage imageNamed:@"TOP_NAV_BUY_BUTTON_GREEN"] forState:UIControlStateNormal];
        [self.doneButton setBackgroundImage:[UIImage imageNamed:@"TOP_NAV_BUY_BUTTON_GREEN_SELECTED"] forState:UIControlStateHighlighted];
        
        CGRect frame = self.doneButton.frame;
        frame.origin.x -= 10;
        frame.size.width += 10;
        self.doneButton.frame = frame;
    }
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        //iphone5 - compatibility
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height*[UIScreen mainScreen].scale;
        
        if(screenHeight == 480){
            //iphone no retina
        }else if(screenHeight == 960){
            //iphone with retina
        }else{
            //iphone5 - need to re-layout
            if((currAppLoc == AppLocationFrench) || (currAppLoc == AppLocationGerman)){
                [self.backgroundImageView setImage:[UIImage imageNamed:@"apc_checkout_iPhone5"]];
            }else{
                [self.backgroundImageView setImage:[UIImage imageNamed:ARTImage(@"checkout_iPhone5")]];
            }
        }
    }
    
    self.confirmationLabel.text = [ACConstants getLocalizedStringForKey:@"CONFIRMATION" withDefaultValue:@"CONFIRMATION"];
    self.thankLabel.text = [ACConstants getLocalizedStringForKey:@"THANK_YOU_FOR_YOUR_ORDER" withDefaultValue:@"THANK YOU FOR YOUR ORDER"];
    self.receiptLabel.text = [ACConstants getLocalizedStringForKey:@"A_RECEIPT_HAS_BEEN_SENT_TO_YOUR_EMAIL" withDefaultValue:@"A receipt has been sent to your email address"];
    self.yourorderLabel.text = [ACConstants getLocalizedStringForKey:@"YOUR_ORDER_NUMBER_IS" withDefaultValue:@"Your order number is:"];
    self.customerSupportLabel.text = [ACConstants getLocalizedStringForKey:@"CUSTOMER_SUPPORT_TEAM" withDefaultValue:@"Customer Support Team"];
    [self addBarButtons];
//    [self.emailLabel setTitle:[ACConstants getLocalizedStringForKey:@"SUPPORT_EMAIL" withDefaultValue:@"support@art.com"] forState:UIControlStateNormal];
//    [self.doneButton setTitle:[ACConstants getLocalizedStringForKey:@"DONE" withDefaultValue:@"DONE"] forState:UIControlStateNormal];
//    [self.doneButton setTitle:[ACConstants getLocalizedStringForKey:@"DONE" withDefaultValue:@"DONE"] forState:UIControlStateHighlighted];
    
    self.screenName = @"Order Confirmation Screen";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:nil name:kACNotificationDismissModal object:nil];
    [self setOrderNumberLabel:nil];
    [self setThankLabel:nil];
    [self setConfirmationLabel:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}

-(void)addBarButtons
{
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:[ACConstants getLocalizedStringForKey:@"DONE" withDefaultValue:@"Done"] style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithShopping:)];
    doneBarButton.tintColor = [ACConstants getPrimaryLinkColor];

    self.navigationItem.rightBarButtonItem = doneBarButton;
    self.navigationItem.hidesBackButton = YES;
    
    self.navigationItem.titleView = [ACConstants getNavBarLogo];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoButton setFrame:CGRectMake(4.0, 4.0f, 24.0f, 24.0f)];
    [infoButton setImage:[UIImage imageNamed:ARTImage(@"InfoButton23")] forState:UIControlStateNormal];
    [infoButton addTarget:self action:@selector(confirmIButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //[_headerView addSubview:infoButton];
    //mkl info button in nav bar now
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.navigationItem.leftBarButtonItem = infoBarButton;
    
}

- (void)dismissModal {
    [[NSNotificationCenter defaultCenter] removeObserver:nil name:kACNotificationDismissModal object:nil];
    [self dismissModalViewControllerAnimated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return NO;
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return YES;
    }
    return NO;
}
  

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Action Methods

-(IBAction)doneWithShopping:(id)sender
{
    [ArtAPI setCountries:nil];
    [ArtAPI setStates:nil];
    
    // TODO: add back
    
     //PAAHomeScreenViewController *homeScreenController = (PAAHomeScreenViewController *)[[AppDel rootNavigationControllerr].viewControllers objectAtIndex:0];
     //homeScreenController.pickerMode = ImagePickerModeNone;
     //[self.navigationController dismissModalViewControllerAnimated:YES];
     //[self.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ORDERCOMPLETED" object:nil];
    
    if( self.navigationController.modalPresentationStyle ==  UIModalPresentationFullScreen){
        //NSLog(@"modalPresentationStyle: UIModalPresentationFullScreen");
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else if(self.navigationController.modalPresentationStyle ==  UIModalPresentationFormSheet){
        //NSLog(@"modalPresentationStyle: UIModalPresentationFormSheet");
         [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        //NSLog(@"modalPresentationStyle: other");
    }
}

- (IBAction)goBack:(id)sender
{
    [ self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(0 == buttonIndex)
    {
        //[Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_INFO_BUTTON_PRESSED];
        
        [self showAbout];
        
    }
    else if(1 == buttonIndex)
    {
        //[[Helpshift sharedInstance] showSupport:self];
    }
}

-(void)showAbout{
    ACWebViewController * webViewController = [[ACWebViewController alloc] initWithURL:[NSURL URLWithString:[ArtAPI sharedInstance].aboutURL]];
    webViewController.toolbarHidden = YES;
    webViewController.titleHidden = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)confirmIButtonTapped:(UIButton *)sender
{
    [Analytics logGAEvent:ANALYTICS_CATEGORY_UI_ACTION withAction:ANALYTICS_EVENT_NAME_INFO_BUTTON_PRESSED];
    
    [self showAbout];
    
    /* HELPSHIFT DISABLED
    NSString *aboutTitle = nil;
    AppLocation currAppLoc = [ACConstants getCurrentAppLocation];
    
    if(currAppLoc == AppLocationFrench){
        aboutTitle = NSLocalizedString(@"ABOUT_TITLE_MESPHOTOS", nil);
    }else if(currAppLoc == AppLocationGerman){
        aboutTitle = NSLocalizedString(@"ABOUT_TITLE_MYPHOTOS", nil);
    }else{
        aboutTitle = NSLocalizedString(@"ABOUT_TITLE_PHOTOSTOART", nil);
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:aboutTitle,NSLocalizedString(@"HELP", nil), nil];
    [actionSheet showInView:self.view];
  */
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if(result == MFMailComposeResultSent){
        
        NSString *msg = [ACConstants getLocalizedStringForKey:@"YOUR_MESSAGE_HAS_BEEN_SENT_&&" withDefaultValue:@"Your message has been sent to Art.com. Thank you."];
        
        UIAlertView *mailSentAlert = [[UIAlertView alloc] initWithTitle:[ACConstants getLocalizedStringForKey:@"EMAIL_SENT" withDefaultValue:@"Email Sent"]
                                                                message:msg
                                                               delegate:nil
                                                      cancelButtonTitle:[ACConstants getLocalizedStringForKey:@"OK" withDefaultValue:@"OK"]
                                                      otherButtonTitles:nil, nil];
        [mailSentAlert show];
    }
}

-(void)displayMail
{
    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    [emailController setSubject:[ACConstants getLocalizedStringForKey:@"&&_SUPPORT" withDefaultValue:@"Art.com Support"]];
    NSArray *recepeints = [NSArray arrayWithObject:[ACConstants getLocalizedStringForKey:@"SUPPORT_EMAIL_&&" withDefaultValue:@"support@art.com"]];
    [emailController setToRecipients:recepeints];
    [self.navigationController presentViewController:emailController animated:YES completion:nil];
}

-(void)configureEmail
{
    UIAlertView *configureMailAlert = [[UIAlertView alloc] initWithTitle:[ACConstants getLocalizedStringForKey:@"EMAIL" withDefaultValue:@"Email"]
                                                                 message:[ACConstants getLocalizedStringForKey:@"PLEASE_CONFIGURE_MAIL_ON_DEVICE" withDefaultValue:@"Please configure Mail on your device."]
                                                                delegate:nil
                                                       cancelButtonTitle:[ACConstants getLocalizedStringForKey:@"OK" withDefaultValue:@"OK"]
                                                       otherButtonTitles:nil, nil];
    [configureMailAlert show];
}

- (IBAction)emailButtonTapped:(UIButton *)sender
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        if ([mailClass canSendMail])
        {
            [self displayMail];
        }
        else
        {
            [self configureEmail];
        }
    }
    else
    {
        [self configureEmail];
    }
}

@end
