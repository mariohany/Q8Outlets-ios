//
//  Q8MerchantLocationTableViewCell.h
//  Q8outlets
//
//  Created by GlebGamaun on 23.03.17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8MerchantLocationCellIdentifier = @"Q8MerchantLocationTableViewCell";

@interface Q8MerchantLocationTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel        *merchantTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel        *merchantLocationLabel;
@property (nonatomic, weak) IBOutlet UIImageView    *selectedLocationImageView;

- (void)setupForMerchantLocation:(Q8MerchantLocation *)location;

@end
