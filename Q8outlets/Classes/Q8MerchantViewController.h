//
//  Q8MerchantViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/6/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Q8Merchant.h"

static NSString * const Q8MerchantControllerIdentifier = @"Q8Merchant";

@interface Q8MerchantViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, Q8MerchantNotificationObserver, Q8AllOffersNotificationObserver, WLAlertControllerDelegate>

@property (nonatomic, strong) Q8Merchant *merchant;

// Merchant header
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;

// Address panel
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;

// Details
@property (nonatomic, weak) IBOutlet UIButton *phoneButton;
@property (nonatomic, weak) IBOutlet UIButton *emailButton;
@property (nonatomic, weak) IBOutlet UIButton *smsButton;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIButton *followButton;
@property (nonatomic, weak) IBOutlet UIImageView *followImageView;

// Offers
@property (nonatomic, weak) IBOutlet UILabel *offersTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *offersCountLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *noOffersView;

//Activity indicator
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)flagButtonAction:(id)sender;
- (IBAction)mapButtonAction:(id)sender;
- (IBAction)phoneButtonAction:(id)sender;
- (IBAction)emailButtonAction:(id)sender;
- (IBAction)smsButtonAction:(id)sender;
- (IBAction)followButtonAction:(id)sender;

@end
