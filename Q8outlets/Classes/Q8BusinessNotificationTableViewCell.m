//
//  Q8BusinessNotificationTableViewCell.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8BusinessNotificationTableViewCell.h"

@implementation Q8BusinessNotificationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setupForNotification:(Q8BusinessNotification *)notification {
    self.notificationLabel.text = notification.notificationText;
    self.offerTitleLabel.text = notification.offer.title;
    self.timeLabel.text = [WLUtilityHelper stringWithJustTime:notification.notificationDate];
    
    [self layoutIfNeeded];
}

@end
