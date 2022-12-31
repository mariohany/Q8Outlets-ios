//
//  Q8BusinessStatsTableViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/14/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8BusinessStatsControllerIdentifier = @"Q8BusinessStats";

@interface Q8BusinessStatsTableViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UIImageView *appliedImageView;
@property (nonatomic, weak) IBOutlet UILabel *appliedLabel;
@property (nonatomic, weak) IBOutlet UIImageView *usedImageView;
@property (nonatomic, weak) IBOutlet UILabel *usedLabel;
@property (nonatomic, weak) IBOutlet UIImageView *expiredImageView;
@property (nonatomic, weak) IBOutlet UILabel *expiredLabel;

@end
