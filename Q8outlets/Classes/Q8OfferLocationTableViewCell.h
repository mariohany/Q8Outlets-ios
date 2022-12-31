//
//  Q8OfferLocationTableViewCell.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8OfferLocationCellIdentifier = @"Q8OfferLocationCell";

@interface Q8OfferLocationTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *merchantTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;

- (void)setupForLocation:(Q8MerchantLocation *)location
             forMerchant:(Q8Merchant *)merchant;

@end
