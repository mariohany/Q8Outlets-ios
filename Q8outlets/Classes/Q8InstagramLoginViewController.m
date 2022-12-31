//
//  Q8InstagramLoginViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/8/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8InstagramLoginViewController.h"
#import <InstagramKit/InstagramKit.h>
#import <InstagramKit/InstagramEngine.h>

@interface Q8InstagramLoginViewController ()

@end

@implementation Q8InstagramLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    self.navigationItem.title = NSLocalizedString(@"Instagram", nil);
    // Back button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:NSLocalizedString(@"icon_arrow_left", nil)] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonAction:)];
    
    // Load authorization page
    self.webView.delegate = self;
    NSURL *authURL = [[InstagramEngine sharedEngine] authorizationURL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:authURL]];
    
    WLDebLog(@"%@",authURL);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
}

#pragma mark - Web view controller

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSError *error;
    if ([[InstagramEngine sharedEngine] receivedValidAccessTokenFromURL:request.URL error:&error]) {
        self.webView.hidden = YES; // To hide "404" error
        if (!error) {
            WLDebLog(@"%@", [InstagramEngine sharedEngine].accessToken);
            [[NSNotificationCenter defaultCenter] postNotificationName:Q8NotificationInstagramLoginSuccess
                                                                object:nil
                                                              userInfo:@{@"token" : [InstagramEngine sharedEngine].accessToken ?: @""}];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            WLErrLog(@"%@",error);
            [[NSNotificationCenter defaultCenter] postNotificationName:Q8NotificationInstagramLoginFail object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }

    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
}

#pragma mark - Button actions

- (IBAction)backButtonAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:Q8NotificationInstagramLoginFail object:nil];
    [self.webView stopLoading];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
