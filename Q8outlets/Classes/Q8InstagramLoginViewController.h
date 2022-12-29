//
//  Q8InstagramLoginViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/8/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8InstagramLoginControllerXibName = @"Q8InstagramLoginViewController";

@interface Q8InstagramLoginViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

- (IBAction)backButtonAction:(id)sender;

@end
