//
//  Q8MerchantTableViewCell.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/1/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Q8Merchant.h"

static NSString * const Q8MerchantCellIdentifier = @"Q8MerchantCell";
static NSString * const Q8MerchantCellXibName = @"Q8MerchantTableViewCell";

@interface Q8MerchantTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *merchantLogoImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *categoryNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *offersCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *offersTextLabel;
@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;

- (void)setupForMerchant:(Q8Merchant *)merchant;

@end
