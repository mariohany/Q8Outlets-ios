//
//  Q8DateHeaderTableViewCell.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8DateHeaderTableViewCell.h"

@implementation Q8DateHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setupForDate:(NSDate *)date {
    // If today or yesterday
    if ([WLUtilityHelper checkIfSameDate:date date2:[NSDate date]]) {
        self.dateLabel.text = NSLocalizedString(@"TODAY", nil);
    } else if ([WLUtilityHelper daysBetweenDate:date andDate:[NSDate date]] == 1) {
        self.dateLabel.text = NSLocalizedString(@"YESTERDAY", nil);
    } else {
        self.dateLabel.text = [WLUtilityHelper formatDateToFullString:date preferredFormat:NSLocalizedString(@"dd.MM.YYYY", nil)];
    }
    
    [self layoutIfNeeded];
}

@end
