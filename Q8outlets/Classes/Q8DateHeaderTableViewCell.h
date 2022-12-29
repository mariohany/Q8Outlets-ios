//
//  Q8DateHeaderTableViewCell.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8DateHeaderCellIdentifier = @"Q8DateHeaderCell";

@interface Q8DateHeaderTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

- (void)setupForDate:(NSDate *)date;

@end
