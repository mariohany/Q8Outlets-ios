//
//  Q8SettingsTableViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8SettingsControllerIdentifier = @"Q8Settings";

@interface Q8SettingsTableViewController : UITableViewController

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *iconImageViews;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrowImageViews;

- (IBAction)logoutButtonAction:(id)sender;

@end
