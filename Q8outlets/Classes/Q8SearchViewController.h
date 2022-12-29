//
//  Q8SearchViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Q8Category.h"

@class Q8TextField;

static NSString * const Q8SearchControllerIdentifier = @"Q8Search";

@interface Q8SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, Q8AllOffersNotificationObserver, Q8AllMerchantsNotificationObserver, WLAlertControllerDelegate>

@property (nonatomic, strong) Q8Category *category; // Can search and browse inside category

@property (nonatomic, weak) IBOutlet Q8TextField *searchTextField;
@property (nonatomic, weak) IBOutlet UIView *searchSeparatorView;

@property (nonatomic, weak) IBOutlet UIButton *merchantsTabButton;
@property (nonatomic, weak) IBOutlet UIButton *offersTabButton;
@property (nonatomic, weak) IBOutlet UIView *activeTabBottomView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *centerActiveTabOnMerchantsConstraint;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *noResultsView;

- (IBAction)textFieldDidChange:(id)sender;
- (IBAction)merchantsTabButtonAction:(id)sender;
- (IBAction)offersTabButtonAction:(id)sender;
- (IBAction)filtersButtonAction:(id)sender;

@end
