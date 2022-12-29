//
//  Q8BusinessNotificationTableViewCell.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Q8BusinessNotification.h"

static NSString * const Q8BusinessNotificationCellIdentifier = @"Q8BusinessNotificationCell";

@interface Q8BusinessNotificationTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *notificationLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *offerTitleLabel;

- (void)setupForNotification:(Q8BusinessNotification *)notification;

@end
