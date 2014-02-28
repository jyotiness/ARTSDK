//
//  ArtsterInfoViewController.m
//  Art
//
//  Created by xdchen on 5/6/11.


#import "ACArtInfoViewController.h"
#import "UIColor+Additions.h"
#import "ArtAPI.h"


@implementation ACArtInfoViewController


@synthesize itemType = _itemType;
@synthesize leftFrameDetailImage = _leftFrameDetailImage;
@synthesize rightFrameDetailImage = _rightFrameDetailImage;

@synthesize addToCartButton = _addToCartButton;
@synthesize scrollView = _scrollView;
@synthesize itemNumber = _itemNumber;
@synthesize activityIndicatorView = _activityIndicatorView;

//Frame Tab
@synthesize frameProfileLabel = _frameProfileLabel;
@synthesize frameSizeLabel = _frameSizeLabel;
@synthesize frameColorLabel = _frameColorLabel;
@synthesize frameMaterialLabel = _frameMaterialLabel;
@synthesize frameStyleLabel = _frameStyleLabel;
@synthesize frameFinishLabel = _frameFinishLabel;
@synthesize frameIDLabel = _frameIDLabel;
@synthesize framePriceLabel = _framePriceLabel;
@synthesize frameData = _frameData;
@synthesize initialPage = _initialPage;
@synthesize frameDescriptionLabel = _frameDescriptionLabel;
@synthesize name = _name;
@synthesize owner = _owner;
@synthesize skuLabel = itemId;
@synthesize size = _size;
@synthesize withoutBorderSize = withoutBorderSize;
@synthesize price = _price;
@synthesize time = _time;
@synthesize description = _description;
@synthesize imageView = _imageView;
@synthesize frameInfoView = _frameInfoView;

@synthesize networkRequests;


//- (IBAction)addToCartButtonPressed:(id)sender {
//  [self.viewerViewcontroller addToCartButtonPressed:sender]; 
//}

- (void)infoDoneButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
/*
- (void)dataDidFail:(ACJSONAPIRequest *)request {
    NSLog(@"PHAIL");
    self.activityIndicatorView.hidden = YES;
    self.description.textAlignment = UITextAlignmentCenter;
    self.description.text = @"Description not available";
    [self resizeToFit];
}
 */
/*
- (void)dataDidLoad:(ACJSONAPIRequest *)request {
    NSDictionary *response = [request APIResponse];
    NSArray *items = [response objectForKeyNotNull:@"Items"];
    NSDictionary *item = [items objectAtIndex:0];
//  NSDictionary *imageInformation = [item objectForKeyNotNull:@"ImageInformation"];

    NSDictionary *itemAttributes = [item objectForKeyNotNull:@"ItemAttributes"];
    NSString *desc = [itemAttributes objectForKeyNotNull:@"Description"];
    self.description.text = desc;
    self.activityIndicatorView.hidden = YES;
    [self resizeToFit];
}
*/

- (void)loadDataFromAPI {
    /*ACJSONAPIRequest *request;
    request = [[ACAPI sharedAPI] requestForCatalogItemGetWithDelegate:self itemId:self.itemNumber];
    [request setDidFinishSelector:@selector(dataDidLoad:)];
    [request setDidFailSelector:@selector(dataDidFail:)];
    [self startRequest:request];*/
    
    NSString *lookupType = @"ItemNumber";
    [ArtAPI
     requestForCatalogItemGetForItemId:self.itemNumber lookupType:lookupType success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSLog(@"SUCCESS url: %@ %@ json: %@", request.HTTPMethod, request.URL, JSON);

         NSArray *items = [JSON objectForKeyNotNull:@"Items"];
         NSDictionary *item = [items objectAtIndex:0];
         //  NSDictionary *imageInformation = [item objectForKeyNotNull:@"ImageInformation"];
         
         NSDictionary *itemAttributes = [item objectForKeyNotNull:@"ItemAttributes"];
         NSString *desc = [itemAttributes objectForKeyNotNull:@"Description"];
         self.description.text = desc;
         if(!NIIsStringWithAnyText(desc)){
             self.aboutLabel.hidden = YES;
         }
         
         self.activityIndicatorView.hidden = YES;
         [self resizeToFit];

         
     }  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
         NSLog(@"FAILURE url: %@ %@ json: %@ error: %@", request.HTTPMethod, request.URL, JSON, error);
         self.activityIndicatorView.hidden = YES;
         self.description.textAlignment = NSTextAlignmentCenter;
         self.description.text = @"Description not available";
         [self resizeToFit];
     }];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = NO;
    //self.view.backgroundColor = [UIColor artDotComLightGray_Light_Color_iPad];

    [self resizeToFit];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    //[AppDel clearImageCache];
}

- (void)viewDidUnload {
    [self setFrameProfileLabel:nil];
    [self setFrameSizeLabel:nil];
    [self setFrameColorLabel:nil];
    [self setFrameMaterialLabel:nil];
    [self setFrameStyleLabel:nil];
    [self setFrameFinishLabel:nil];
    [self setFrameIDLabel:nil];
    [self setFramePriceLabel:nil];
    [super viewDidUnload];
}



- (void)resizeToFit {
    CGSize textSize = [self.description.text sizeWithFont:self.description.font constrainedToSize:CGSizeMake(300, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    self.description.frame = CGRectMake(self.description.frame.origin.x, self.description.frame.origin.y, 300, textSize.height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.description.frame.origin.y + self.description.frame.size.height + 20);
}

- (void)configureFrameInfo {
    if (!self.frameData) {
        return;
    }

    NSDictionary *service = [self.frameData objectForKeyNotNull:@"Service"];
    NSDictionary *frame = [service objectForKeyNotNull:@"Frame"];
    NSDictionary *moulding = [frame objectForKeyNotNull:@"Moulding"];

    NSDictionary *imageInformation = [self.frameData objectForKeyNotNull:@"ImageInformation"];
    NSDictionary *thumbnailImage = [imageInformation objectForKeyNotNull:@"ThumbnailImage"];
    //NSURL *frameThumbnailURL = [[ACAPI sharedAPI] URLWithRawFrameURLString:[thumbnailImage objectForKeyNotNull:@"HttpImageURL"] maxWidth:self.imageView.frame.size.width maxHeight:self.imageView.frame.size.height];
    //[self.imageView setImageURL:frameThumbnailURL];
    NSString * frameThumbnailURL = [ArtAPI cleanImageUrl:[thumbnailImage objectForKeyNotNull:@"HttpImageURL"] withSize:self.imageView.frame.size.width];
    [self.imageView setPathToNetworkImage:frameThumbnailURL];
    
    NSDictionary *mouldingCornerImage = [moulding objectForKeyNotNull:@"CornerImage"];
    NSDictionary *mouldingProfileImage = [moulding objectForKeyNotNull:@"ProfileImage"];


    NSString *mouldingCornerImageURLString = [mouldingCornerImage objectForKeyNotNull:@"HttpImageURL"];
    NSString *mouldingProfileImageURLString = [mouldingProfileImage objectForKeyNotNull:@"HttpImageURL"];


    NSString *profile = [moulding objectForKeyNotNull:@"Profile"];
    NSDictionary *dimensions = [moulding objectForKeyNotNull:@"Dimensions"];
    NSString *top = [dimensions objectForKeyNotNull:@"Top"];
    NSString *left = [dimensions objectForKeyNotNull:@"Left"];
    //NSString *frameID = [moulding objectForKeyNotNull:@"ItemNumber"];
    NSString *frameSKU = [self.frameData objectForKeyNotNull:@"Sku"];

    NSString *color = [moulding objectForKeyNotNull:@"Color"];
    NSString *frameDescription = [moulding objectForKeyNotNull:@"Description"];
    NSString *finish = [moulding objectForKeyNotNull:@"Finish"];
    NSString *material = [moulding objectForKeyNotNull:@"Material"];
    NSString *style = [moulding objectForKeyNotNull:@"Style"];

    NSDictionary *frameItemPrice = [self.frameData objectForKeyNotNull:@"ItemPrice"];
    NSNumber *framePrice = [frameItemPrice objectForKeyNotNull:@"Price"];


    if (mouldingCornerImageURLString) {
        self.leftFrameDetailImage.image = nil;
        //[self.leftFrameDetailImage setImageURL:[NSURL URLWithString:mouldingCornerImageURLString]];
        [self.leftFrameDetailImage setPathToNetworkImage:mouldingCornerImageURLString];
    }

    if (mouldingProfileImageURLString) {
        self.rightFrameDetailImage.image = nil;
        //[self.rightFrameDetailImage setImageURL:[NSURL URLWithString:mouldingProfileImageURLString]];
        [self.rightFrameDetailImage setPathToNetworkImage:mouldingProfileImageURLString];
    }

    // [self.rightFrameDetailImage setImageURL:[NSURL URLWithString:mouldingCornerImageURLString]];

    if (framePrice) {
        NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        self.price.text = [currencyFormatter stringFromNumber:framePrice];
    }
    else {
        self.framePriceLabel.text = @"";
    }
    NSString *dimensionsText = nil;
    if (top && left) {
        dimensionsText = [NSString stringWithFormat:@"%@\" x %@\"", top, left];
    }

    if (frameDescription) {
        self.frameDescriptionLabel.text = frameDescription;
        CGSize textSize = [self.frameDescriptionLabel.text sizeWithFont:self.frameDescriptionLabel.font constrainedToSize:CGSizeMake(280, MAXFLOAT) lineBreakMode:self.frameDescriptionLabel.lineBreakMode];
        self.frameDescriptionLabel.frame = CGRectMake(self.frameDescriptionLabel.frame.origin.x, self.frameDescriptionLabel.frame.origin.y, 280, textSize.height);
        self.frameInfoView.contentSize = CGSizeMake(self.frameInfoView.frame.size.width, self.frameDescriptionLabel.frame.origin.y + self.frameDescriptionLabel.frame.size.height + 20);
    }
    else {
        self.frameDescriptionLabel.text = @"";
    }


    self.frameProfileLabel.text = profile ? profile : @"";
    self.size.text = dimensionsText ? dimensionsText : @"";
    self.frameColorLabel.text = color ? color : @"";
    self.frameMaterialLabel.text = material ? material : @"";
    self.frameStyleLabel.text = style ? style : @"";
    self.frameFinishLabel.text = finish ? finish : @"";
    if (frameSKU) {
        self.frameIDLabel.text = frameSKU;
    }
    else {
        self.frameIDLabel.text = @"";
    }

}


- (void)segmentedControlDidChange:(UIButton *)sender {
    if (sender.tag == 1) {
        [self.view addSubview:self.scrollView];
        [self.frameInfoView removeFromSuperview];
        [(UIButton *) [sender.superview viewWithTag:1] setBackgroundImage:[UIImage imageNamed:@"btn_segment_l_n"] forState:UIControlStateNormal];
        [(UIButton *) [sender.superview viewWithTag:2] setBackgroundImage:[UIImage imageNamed:@"btn_segment_r_h"] forState:UIControlStateNormal];
    }
    else if (sender.tag == 2) {
        [self.view addSubview:self.frameInfoView];
        [self.scrollView removeFromSuperview];
        [self configureFrameInfo];
        [(UIButton *) [sender.superview viewWithTag:1] setBackgroundImage:[UIImage imageNamed:@"btn_segment_l_h"] forState:UIControlStateNormal];
        [(UIButton *) [sender.superview viewWithTag:2] setBackgroundImage:[UIImage imageNamed:@"btn_segment_r_n"] forState:UIControlStateNormal];
    }
}


- (void)showSegmentedControlIfNeeded {
    if (!self.frameData) {
        //self.viewerViewcontroller.navigationItem.titleView = nil;
        return;
    }
    UIFont *font = [UIFont fontWithName:@"AvenirNextLTPro-Demi" size:12];
    UIView *segmentedControl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 151, 30)];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    [left addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventTouchUpInside];
    //[left setFont:font];
    left.titleLabel.font = font;
    left.adjustsImageWhenHighlighted = NO;
    [left setTitle:NSLocalizedString(@"Item Info", nil) forState:UIControlStateNormal];
    [left setTag:1];
    [left setTitleColor:[UIColor artDotComLightGray_Light_Color_iPad] forState:UIControlStateNormal];
    [left setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.33] forState:UIControlStateNormal];
    [left.titleLabel setShadowOffset:CGSizeMake(0, -1)];

    UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
    [right addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventTouchUpInside];
    right.adjustsImageWhenHighlighted = NO;
    //[right setFont:font];
     right.titleLabel.font = font;
    [right setTitle:NSLocalizedString(@"Frame Info", nil) forState:UIControlStateNormal];
    [right setTag:2];
    [right sizeToFit];
    [right setTitleColor:[UIColor artDotComLightGray_Light_Color_iPad] forState:UIControlStateNormal];
    [right setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.33] forState:UIControlStateNormal];
    [right.titleLabel setShadowOffset:CGSizeMake(0, -1)];

    left.frame = CGRectMake(0, 0, 151 / 2, 30);
    right.frame = CGRectMake(151, 0, 151 / 2, 30);
    [segmentedControl addSubview:left];
    [segmentedControl addSubview:right];
    segmentedControl.autoresizingMask = UIViewAutoresizingNone;

    [left setBackgroundImage:[UIImage imageNamed:@"btn_segment_l_n"] forState:UIControlStateNormal];
    [right setBackgroundImage:[UIImage imageNamed:@"btn_segment_r_h"] forState:UIControlStateNormal];

    left.frame = CGRectMake(0, 0, 151 / 2, 30);
    right.frame = CGRectMake(151 / 2, 0, 151 / 2, 30);

    //UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Item Info", @"Frame Info",nil]];
    //segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    //segmentedControl.selectedSegmentIndex = 0;
    //segmentedControl.tintColor = [UIColor colorWithRed:82.0/255 green:54.0/255 blue:43.0/255 alpha:1];
    //[segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];

    //self.viewerViewcontroller.navigationItem.titleView = segmentedControl;
}


- (void)setFrameData:(NSDictionary *)frameData
{
    _frameData = frameData;
}

/*
- (void)startRequest:(ACJSONAPIRequest *)request {
    
    Reachability *internetReachabilityTest = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachabilityTest currentReachabilityStatus];
    if (networkStatus == NotReachable) // NETWORK Reachability
    {
        
        [ AppDel showReachabilityAlert];
        return;
    }
    
    if (!request) {
        NSLog(@"Error: request is nil.");
        return;
    }
    [self.networkRequests addObject:request];
    [request startAsynchronous];
}

*/
@end
