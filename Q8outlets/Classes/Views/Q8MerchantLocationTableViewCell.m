//
//  Q8MerchantLocationTableViewCell.m
//  Q8outlets
//
//  Created by GlebGamaun on 23.03.17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8MerchantLocationTableViewCell.h"

@implementation Q8MerchantLocationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setupForMerchantLocation:(Q8MerchantLocation *)location {
    self.merchantTitleLabel.text = location.locationTitle;
    self.merchantLocationLabel.text = location.locationAddress;
    
    self.selectedLocationImageView.hidden = [[Q8CurrentUser userLocationID] isEqualToString:location.locationId] ? NO : YES;
}

@end
