//
//  WebViewController.m
//  MiniKeePass
//
//  Created by Jason Rush on 1/25/13.
//  Copyright (c) 2013 Self. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate> {
    UIWebView *_webView;
    UIBarButtonItem *_backButton;
    UIBarButtonItem *_forwardButton;
    UIBarButtonItem *_reloadButton;
    UIBarButtonItem *_openInButton;
    UIBarButtonItem *_autotypeUsernameButton;
    UIBarButtonItem *_autotypePasswordButton;
}
@end

@implementation WebViewController

- (void)viewDidLoad {
    self.title = @"Web";

    _webView = [[UIWebView alloc] init];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_webView.backgroundColor = [UIColor whiteColor];
	_webView.delegate = self;
    _webView.keyboardDisplayRequiresUserAction = NO;
	[self.view addSubview:_webView];

    _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(backPressed)];
    _backButton.enabled = NO;

    _forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward"]
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(forwardPressed)];
    _forwardButton.enabled = NO;

    _reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                  target:self
                                                                  action:@selector(reloadPressed)];

    _openInButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                  target:self
                                                                  action:@selector(openInPressed)];

    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 10.0f;

    UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil] autorelease];

    self.toolbarItems = @[
                          fixedSpace,
                          _backButton,
                          flexibleSpace,
                          _forwardButton,
                          flexibleSpace,
                          _reloadButton,
                          flexibleSpace,
                          _openInButton,
                          fixedSpace
                          ];

    UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:@[@"User", @"Pass"]] autorelease];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
    [segmentedControl addTarget:self
                         action:@selector(autotypePressed:)
               forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *autotypeButton = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease];
    self.navigationItem.rightBarButtonItem = autotypeButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSURL *url = [NSURL URLWithString:self.entry.url];
    if (url.scheme == nil) {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:self.entry.url]];
    }

    _webView.frame = self.view.bounds;
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)dealloc {
    [_entry release];
    [_webView release];
    [_backButton release];
    [_forwardButton release];
    [_reloadButton release];
    [_openInButton release];
    [super dealloc];
}

- (void)updateButtons {
    _backButton.enabled = _webView.canGoBack;
    _forwardButton.enabled = _webView.canGoForward;
    _openInButton.enabled = !_webView.isLoading;
}

- (void)backPressed {
    if (_webView.canGoBack) {
        [_webView goBack];
    }
}

- (void)forwardPressed {
    if (_webView.canGoForward) {
        [_webView goForward];
    }
}

- (void)reloadPressed {
    [_webView reload];
}

- (void)openInPressed {
    [[UIApplication sharedApplication] openURL:_webView.request.URL];
}

- (void)autotypeString:(NSString *)string {
    NSString *script = [NSString stringWithFormat:@"if (document.activeElement) { document.activeElement.value = '%@'; }", string];
    [_webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)autotypePressed:(UISegmentedControl *)segmentedControl {
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            [self autotypeString:self.entry.username];
            break;

        case 1:
            [self autotypeString:self.entry.password];
            break;

        default:
            break;
    }
}

#pragma mark - WebView delegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self updateButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self updateButtons];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self updateButtons];
}

@end
