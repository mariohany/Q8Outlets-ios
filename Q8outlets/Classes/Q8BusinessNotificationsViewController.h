//
//  Q8BusinessNotificationsViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8BusinessNotificationsControllerIdentifier = @"Q8BusinessNotifications";

@interface Q8BusinessNotificationsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *noNotificationsView;

@end
