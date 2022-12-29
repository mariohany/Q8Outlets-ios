//
//  Q8OfferLocationTableViewCell.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8OfferLocationTableViewCell.h"

@implementation Q8OfferLocationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setupForLocation:(Q8MerchantLocation *)location forMerchant:(Q8Merchant *)merchant {
    self.merchantTitleLabel.text = merchant.title;
    self.addressLabel.text = location.locationAddress;
}

@end
