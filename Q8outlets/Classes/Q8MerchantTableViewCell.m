//
//  Q8MerchantTableViewCell.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/1/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8MerchantTableViewCell.h"

@implementation Q8MerchantTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.layoutMargins = UIEdgeInsetsZero;
    self.contentView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 10);
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self setupImageAssessory];
}

- (void)setupImageAssessory {
    UIImage* image = [UIImage imageNamed:NSLocalizedString(@"icon_arrow_right", nil)];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.arrowImageView setImage:image];
    [self.arrowImageView setTintColor:[UIColor blackColor]];
}

- (void)setupForMerchant:(Q8Merchant *)merchant {
    [Q8ImageHelper setMerchantLogo:merchant intoImageView:self.merchantLogoImageView];
    self.titleLabel.text = merchant.title;
    self.categoryNameLabel.text = merchant.category.categoryName;
    self.offersCountLabel.text = merchant.offersCount>100 ? NSLocalizedString(@"100+", nil) : [NSString stringWithFormat:@"%ld", (long)merchant.offersCount];
    self.offersTextLabel.textColor = [UIColor grayColor];
    self.offersTextLabel.text = (merchant.offersCount == 1) ? NSLocalizedString(@"offer", nil) : NSLocalizedString(@"offers", nil);
    self.distanceLabel.text = [merchant.allLocations count] ? [merchant.allLocations firstObject].distanceString : @"";
}

@end
