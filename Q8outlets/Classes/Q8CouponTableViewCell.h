//
//  Q8CouponTableViewCell.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/1/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Q8Coupon.h"

static NSString * const Q8CouponCellIdentifier = @"Q8CouponCell";
static NSString * const Q8CouponCellXibName = @"Q8CouponTableViewCell";

@interface Q8CouponTableViewCell : UITableViewCell

@property (nonatomic, strong) Q8Coupon *storedCoupon;

@property (nonatomic, weak) IBOutlet UIImageView *qrCodeImageView;
@property (nonatomic, weak) IBOutlet UIImageView *statusImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *merchantTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;

@property (nonatomic, weak) IBOutlet UILabel *statusLabel; // "Expires in", "Used", "Expired", etc
@property (nonatomic, weak) IBOutlet UILabel *statusDateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *skipButtonsConstraint;

@property (nonatomic, weak) IBOutlet UIButton *archiveButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

- (void)setupForCoupon:(Q8Coupon *)coupon;
- (void)reloadCouponCountdown;

@end
