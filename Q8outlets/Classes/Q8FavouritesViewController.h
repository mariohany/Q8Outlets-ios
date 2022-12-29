//
//  Q8FavouritesViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/9/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8FavouritesControllerIdentifier = @"Q8Favourites";

@interface Q8FavouritesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, Q8AllOffersNotificationObserver, Q8AllMerchantsNotificationObserver, WLAlertControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *merchantsTabButton;
@property (nonatomic, weak) IBOutlet UIButton *offersTabButton;
@property (nonatomic, weak) IBOutlet UIView *activeTabBottomView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *centerActiveTabOnMerchantsConstraint;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *noResultsLabel;
@property (nonatomic, weak) IBOutlet UILabel *noResultsTipLabel;
@property (nonatomic, weak) IBOutlet UIView *noResultsView;

- (IBAction)merchantsTabButtonAction:(id)sender;
- (IBAction)offersTabButtonAction:(id)sender;

@end
