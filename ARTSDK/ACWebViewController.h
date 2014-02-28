//
//  ACWebViewController.h
//  ArtAPI
//
//  Created by Doug Diego on 5/9/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

/**
 * A view controller that displays a webpage in a UIWebView
 *
 * <h2>NSNotificationCenter</h2>
 *
 * Responds notification: NOTIFICATION_DISMISS_MODAL  This will close the modal
 *
 */

@interface ACWebViewController : GAITrackedViewController <UIWebViewDelegate, UIActionSheetDelegate>

// Designated initializer.
- (id)initWithRequest:(NSURLRequest *)request;
- (id)initWithURL:(NSURL *)URL;

- (NSURL *)URL;

- (void)openURL:(NSURL*)URL;
- (void)openRequest:(NSURLRequest*)request;
- (void)openHTMLString:(NSString*)htmlString baseURL:(NSURL*)baseUrl;

@property (nonatomic, readwrite, assign, getter = isToolbarHidden) BOOL toolbarHidden;
@property (nonatomic, readwrite, assign, getter = isTitleHidden) BOOL titleHidden;
@property (nonatomic, readwrite, weak) UIColor* toolbarTintColor;
@property (nonatomic, readonly, strong) UIWebView* webView;
@property (retain, nonatomic) NSString *webViewTitle;
@property (nonatomic, retain) UIBarButtonItem *leftButtonItem;

// Subclassing
- (BOOL)shouldPresentActionSheet:(UIActionSheet *)actionSheet;
@property (nonatomic, readwrite, strong) NSURL* actionSheetURL;


@end
