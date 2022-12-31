//
//  Q8CouponsViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/3/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8CouponsControllerIdentifier = @"Q8Coupons";

@interface Q8CouponsViewController : UIViewController <UITableViewDelegate, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *noResultsView;
@property (nonatomic, weak) IBOutlet UILabel *noResultsLabel;

- (IBAction)filtersButtonAction:(id)sender;

@end
