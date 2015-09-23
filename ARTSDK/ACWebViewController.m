//
//  ACWebViewController.m
//  ArtAPI
//
//  Created by Doug Diego on 5/9/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ACWebViewController.h"
#import "NICommonMetrics.h"
#import "NIDeviceOrientation.h"
#import "NIFoundationMethods.h"
#import "ArtAPI.h"

@interface ACWebViewController ()
@property (nonatomic, readwrite, strong) UIView* background;
@property (nonatomic, readwrite, strong) UIWebView* webView;
@property (nonatomic, readwrite, strong) UIToolbar* toolbar;
@property (nonatomic, readwrite, strong) UIActionSheet* actionSheet;

@property (nonatomic, readwrite, strong) UIBarButtonItem* backButton;
@property (nonatomic, readwrite, strong) UIBarButtonItem* forwardButton;
@property (nonatomic, readwrite, strong) UIBarButtonItem* refreshButton;
@property (nonatomic, readwrite, strong) UIBarButtonItem* stopButton;
@property (nonatomic, readwrite, strong) UIBarButtonItem* actionButton;
@property (nonatomic, readwrite, strong) UIBarButtonItem* activityItem;
@property (nonatomic, readwrite, strong) UIActivityIndicatorView* activitySpinner;

@property (nonatomic, readwrite, strong) NSURL* loadingURL;
@property (nonatomic, readwrite, strong) NSURLRequest* loadRequest;

//@property(nonatomic, strong) UIButton * closeButton;
@end

@implementation ACWebViewController

@synthesize webViewTitle = _webViewTitle;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Life Cycle

- (void)dealloc {
    _actionSheet.delegate = nil;
    _webView.delegate = nil;
}


- (id)initWithRequest:(NSURLRequest *)request {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.hidesBottomBarWhenPushed = YES;
        [self openRequest:request];
    }
    return self;
}


- (id)initWithURL:(NSURL *)URL {
    return [self initWithRequest:[NSURLRequest requestWithURL:URL]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithRequest:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private

- (void)didTapBackButton {
    [self.webView goBack];
}


- (void)didTapForwardButton {
    [self.webView goForward];
}


- (void)didTapRefreshButton {
    [self.webView reload];
}


- (void)didTapStopButton {
    [self.webView stopLoading];
}


- (void)didTapShareButton {
    // Dismiss the action menu if the user taps the action button again on the iPad.
    if ([self.actionSheet isVisible]) {
        // It shouldn't be possible to tap the share action button again on anything but the iPad.
        //NIDASSERT(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad );
        
        [self.actionSheet dismissWithClickedButtonIndex:[self.actionSheet cancelButtonIndex] animated:YES];
        
        // We remove the action sheet here just in case the delegate isn't properly implemented.
        self.actionSheet.delegate = nil;
        self.actionSheet = nil;
        self.actionSheetURL = nil;
        
        // Don't show the menu again.
        return;
    }
    
    // Remember the URL at this point
    self.actionSheetURL = [self.URL copy];
    
    if (nil == self.actionSheet) {
        self.actionSheet =
        [[UIActionSheet alloc] initWithTitle:[self.actionSheetURL absoluteString]
                                    delegate:self
                           cancelButtonTitle:nil
                      destructiveButtonTitle:nil
                           otherButtonTitles:nil];
        
        // Let -shouldPresentActionSheet: setup the action sheet
        if (![self shouldPresentActionSheet:self.actionSheet]) {
            // A subclass decided to handle the action in another way
            self.actionSheet = nil;
            self.actionSheetURL = nil;
            return;
        }
        // Add "Cancel" button except for iPads
        if (!UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            [self.actionSheet setCancelButtonIndex:[self.actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")]];
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        [self.actionSheet showFromBarButtonItem:self.actionButton animated:YES];
    } else {
        [self.actionSheet showInView:self.view];
    }
}

- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!self.toolbarHidden) {
        CGRect toolbarFrame = self.toolbar.frame;
        toolbarFrame.size.height = NIToolbarHeightForOrientation(interfaceOrientation);
        toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
        self.toolbar.frame = toolbarFrame;
        
        CGRect webViewFrame = self.webView.frame;
        webViewFrame.size.height = self.view.bounds.size.height - toolbarFrame.size.height;
        self.webView.frame = webViewFrame;
        
    } else {
        self.webView.frame = CGRectMake(0,64,self.view.bounds.size.width, self.view.bounds.size.height-64); //self.view.bounds;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Actions

- (void) closeButtonAction: (id) sender {
    
    //set the
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


- (void)updateWebViewFrame {
    if (self.toolbarHidden) {
        self.webView.frame = self.view.bounds;
        
    } else {
        self.webView.frame = NIRectContract(self.view.bounds, 0, self.toolbar.frame.size.height);
    }
}

- (void)viewDidLoad {
    // Listen for notification kACNotificationDismissModal
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissModal) name:kACNotificationDismissModal object:nil];
    
    self.screenName = @"Web View Screen";
    
    if (nil != self.loadRequest) {
        [self.webView loadRequest:self.loadRequest];
    }
    
    NSString *versionStr = [NSString stringWithFormat:@"v%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    UIBarButtonItem *versionBtn = [[UIBarButtonItem alloc] initWithTitle:versionStr style:UIBarButtonItemStyleBordered target:nil action:nil];
    versionBtn.tintColor = [UIColor blueColor];//UIColorFromRGB(0x4a4a4a);
    versionBtn.enabled = NO;
    self.navigationItem.leftBarButtonItem = versionBtn;
    
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    doneButton.frame = CGRectMake(0, 0, 38, 40);
    [doneButton setTitle:[ACConstants getLocalizedStringForKey:@"DONE" withDefaultValue:@"Done"] forState:UIControlStateNormal];
    [doneButton setTitleColor:[ACConstants getPrimaryLinkColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* doneBarButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    doneBarButton.tintColor = [ACConstants getPrimaryLinkColor];
    self.navigationItem.rightBarButtonItem = doneBarButton;
    
    if( _leftButtonItem ){
        self.navigationItem.leftBarButtonItem = _leftButtonItem;
    }
    
    self.navigationItem.titleView = [ACConstants getNavBarLogo];
    [[UINavigationBar appearance] setTintColor:UIColorFromRGB(0x32ccff)];
}


- (void)dismissModal {
    [[NSNotificationCenter defaultCenter] removeObserver:nil name:kACNotificationDismissModal object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadView {
    [super loadView];
    
    CGRect bounds = self.view.bounds;
    
    self.background =  [[UIView alloc] initWithFrame:CGRectZero];
    self.background.backgroundColor = UIColor.whiteColor;
     //[self.background setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.background];
    
    CGFloat toolbarHeight = NIToolbarHeightForOrientation(NIInterfaceOrientation());
    CGRect toolbarFrame = CGRectMake(0, bounds.size.height - toolbarHeight,
                                     bounds.size.width, toolbarHeight);
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    self.toolbar.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                                     | UIViewAutoresizingFlexibleWidth);
    self.toolbar.tintColor = self.toolbarTintColor;
    self.toolbar.hidden = self.toolbarHidden;
    
    UIActivityIndicatorView* spinner =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
     UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    
    self.activitySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     //[self.activitySpinner setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.activitySpinner];
    [self.activitySpinner startAnimating];
    
    
    UIImage* backIcon = [UIImage imageNamed:ARTImage(@"backIcon.png")];
    
    self.backButton =
    [[UIBarButtonItem alloc] initWithImage:backIcon
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didTapBackButton)];
    self.backButton.tag = 2;
    self.backButton.enabled = NO;
    
    UIImage* forwardIcon = [UIImage imageNamed:ARTImage(@"forwardIcon.png")];

    
    self.forwardButton =
    [[UIBarButtonItem alloc] initWithImage:forwardIcon
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didTapForwardButton)];
    self.forwardButton.tag = 1;
    self.forwardButton.enabled = NO;
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                          UIBarButtonSystemItemRefresh target:self action:@selector(didTapRefreshButton)];
    self.refreshButton.tag = 3;
    self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                       UIBarButtonSystemItemStop target:self action:@selector(didTapStopButton)];
    self.stopButton.tag = 3;
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                         UIBarButtonSystemItemAction target:self action:@selector(didTapShareButton)];
    
    UIBarItem* flexibleSpace =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                                  target: nil
                                                  action: nil];
    
    self.toolbar.items = [NSArray arrayWithObjects:
                          self.backButton,
                          flexibleSpace,
                          self.forwardButton,
                          flexibleSpace,
                          self.refreshButton,
                          flexibleSpace,
                          self.actionButton,
                          nil];
     //[self.toolbar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.toolbar];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [self updateWebViewFrame];
    self.webView.delegate = self;
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                     | UIViewAutoresizingFlexibleHeight);
    self.webView.scalesPageToFit = YES;
    
    if ([UIColor respondsToSelector:@selector(underPageBackgroundColor)]) {
        self.webView.backgroundColor = [UIColor underPageBackgroundColor];
    }
    //[self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.webView];
    

    
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:nil name:kACNotificationDismissModal object:nil];

    self.actionSheet.delegate = nil;
    self.webView.delegate = nil;
    
    self.actionSheet = nil;
    self.webView = nil;
    self.toolbar = nil;
    self.backButton = nil;
    self.forwardButton = nil;
    self.refreshButton = nil;
    self.stopButton = nil;
    self.actionButton = nil;
    self.activityItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect bounds = self.view.bounds;
    
    self.background.frame = bounds;
    
    // Position Close Button
    //self.closeButton.frame = CGRectMake(bounds.size.width - (BUTTON_CLOSE_WIDTH+BUTTON_CLOSE_PADDING), BUTTON_CLOSE_PADDING,BUTTON_CLOSE_WIDTH, BUTTON_CLOSE_HEIGHT);
    
    [self updateToolbarWithOrientation:self.interfaceOrientation];
}


- (void)viewWillDisappear:(BOOL)animated {
    // If the browser launched the media player, it steals the key window and never gives it
    // back, so this is a way to try and fix that.
    [self.view.window makeKeyWindow];
    
    [super viewWillDisappear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NIIsSupportedOrientation(interfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateToolbarWithOrientation:toInterfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIWebViewDelegate


- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    self.loadingURL = [request.mainDocumentURL copy];
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
    return YES;
}


- (void)webViewDidStartLoad:(UIWebView*)webView {
    if( ACIsStringWithAnyText(_webViewTitle) && ![self isTitleHidden] ){
        self.title = _webViewTitle;
    } else if( ![self isTitleHidden] ) {
        self.title = NSLocalizedString(@"Loading...", @"");
    }
    if (!self.navigationItem.rightBarButtonItem) {
        [self.navigationItem setRightBarButtonItem:self.activityItem animated:YES];
    }
    
    CGRect activitySpinnerFrame  = self.activitySpinner.frame;
    activitySpinnerFrame.origin.x = self.view.bounds.size.width/2 - activitySpinnerFrame.size.width;
    activitySpinnerFrame.origin.y = self.view.bounds.size.height/2 - activitySpinnerFrame.size.height;
    self.activitySpinner.frame = activitySpinnerFrame;
    self.activitySpinner.hidden = NO;
    webView.hidden = YES;
    
    NSInteger buttonIndex = 0;
    for (UIBarButtonItem* button in self.toolbar.items) {
        if (button.tag == 3) {
            NSMutableArray* newItems = [NSMutableArray arrayWithArray:self.toolbar.items];
            [newItems replaceObjectAtIndex:buttonIndex withObject:self.stopButton];
            self.toolbar.items = newItems;
            break;
        }
        ++buttonIndex;
    }
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
}


- (void)webViewDidFinishLoad:(UIWebView*)webView {
    self.loadingURL = nil;
    if( ACIsStringWithAnyText(_webViewTitle) && ![self isTitleHidden] ){
        self.title = _webViewTitle;
    } else if( ![self isTitleHidden] ) {
        self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    if (self.navigationItem.rightBarButtonItem == self.activityItem) {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
    
    self.activitySpinner.hidden = YES;
    webView.hidden = NO;
    
    NSInteger buttonIndex = 0;
    for (UIBarButtonItem* button in self.toolbar.items) {
        if (button.tag == 3) {
            NSMutableArray* newItems = [NSMutableArray arrayWithArray:self.toolbar.items];
            [newItems replaceObjectAtIndex:buttonIndex withObject:self.refreshButton];
            self.toolbar.items = newItems;
            break;
        }
        ++buttonIndex;
    }
    
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
}


- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    self.loadingURL = nil;
    [self webViewDidFinishLoad:webView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.actionSheet) {
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:self.actionSheetURL];
        } else if (buttonIndex == 1) {
            [[UIPasteboard generalPasteboard] setURL:self.actionSheetURL];
        }
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.actionSheet) {
        self.actionSheet.delegate = nil;
        self.actionSheet = nil;
        self.actionSheetURL = nil;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public


- (NSURL *)URL {
    return self.loadingURL ? self.loadingURL : self.webView.request.mainDocumentURL;
}


- (void)openURL:(NSURL*)URL {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    [self openRequest:request];
}

- (void)openRequest:(NSURLRequest *)request {
    self.loadRequest = request;
    
    if ([self isViewLoaded]) {
        if (nil != request) {
            [self.webView loadRequest:request];
            
        } else {
            [self.webView stopLoading];
        }
    }
}


- (void)openHTMLString:(NSString*)htmlString baseURL:(NSURL*)baseUrl {
	//NIDASSERT([self isViewLoaded]);
	[_webView loadHTMLString:htmlString baseURL:baseUrl];
}


- (void)setToolbarHidden:(BOOL)hidden {
    _toolbarHidden = hidden;
    if ([self isViewLoaded]) {
        self.toolbar.hidden = hidden;
        [self updateWebViewFrame];
    }
}

- (void)setTitleHidden:(BOOL)hidden {
    _titleHidden = hidden;
    //if ([self isViewLoaded]) {
    //    self.toolbar.hidden = hidden;
    //    [self updateWebViewFrame];
    //}
}


- (void)setToolbarTintColor:(UIColor*)color {
    if (color != _toolbarTintColor) {
        _toolbarTintColor = color;
    }
    
    if ([self isViewLoaded]) {
        self.toolbar.tintColor = color;
    }
}

- (BOOL)shouldPresentActionSheet:(UIActionSheet *)actionSheet {
    if (actionSheet == self.actionSheet) {
        [self.actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", @"")];
        [self.actionSheet addButtonWithTitle:NSLocalizedString(@"Copy URL", @"")];
    }
    return YES;
}




@end
