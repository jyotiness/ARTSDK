//
//  ArtsterInfoViewController.h
//  Art
//
//  Created by xdchen on 5/6/11.


#import <UIKit/UIKit.h>
#import "NINetworkImageView.h"


@interface ACArtInfoViewController : UIViewController {
    UIScrollView *scrollView;
    NSInteger initialPage;
}


@property(nonatomic, strong) IBOutlet NINetworkImageView *leftFrameDetailImage;
@property(nonatomic, strong) IBOutlet NINetworkImageView *rightFrameDetailImage;


@property(nonatomic, strong) IBOutlet UIButton *addToCartButton;


@property(nonatomic, strong) NSString *itemNumber;

@property(nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property(nonatomic, weak) NSDictionary *frameData;
@property(nonatomic, assign) NSInteger initialPage;

@property(nonatomic, strong) IBOutlet UILabel *itemType;
@property(nonatomic, strong) IBOutlet UILabel *name;
@property(nonatomic, strong) IBOutlet UILabel *owner;
@property(nonatomic, strong) IBOutlet UILabel *skuLabel;
@property(nonatomic, strong) IBOutlet UILabel *size;
@property(nonatomic, strong) IBOutlet UILabel *withoutBorderSize;
@property(nonatomic, strong) IBOutlet UILabel *price;
@property(nonatomic, strong) IBOutlet UILabel *time;
@property(nonatomic, strong) IBOutlet UILabel *description;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property(nonatomic, strong) IBOutlet NINetworkImageView *imageView;

@property(nonatomic, strong) IBOutlet UIScrollView *frameInfoView;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property(nonatomic, strong) IBOutlet UILabel *frameProfileLabel;
@property(nonatomic, strong) IBOutlet UILabel *frameSizeLabel;
@property(nonatomic, strong) IBOutlet UILabel *frameColorLabel;
@property(nonatomic, strong) IBOutlet UILabel *frameMaterialLabel;
@property(nonatomic, strong) IBOutlet UILabel *frameStyleLabel;
@property(nonatomic, strong) IBOutlet UILabel *frameFinishLabel;
@property(nonatomic, strong) IBOutlet UILabel *frameIDLabel;
@property(nonatomic, strong) IBOutlet UILabel *framePriceLabel;
@property(nonatomic, strong) IBOutlet UILabel *frameDescriptionLabel;

@property(nonatomic, strong) NSMutableArray *networkRequests;


- (void)resizeToFit;

- (void)loadDataFromAPI;

- (void)showSegmentedControlIfNeeded;

- (void)configureFrameInfo;

//- (void)startRequest:(ACJSONAPIRequest *)request;

@end
