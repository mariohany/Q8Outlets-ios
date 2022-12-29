//
//  Q8CouponTableViewCell.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/1/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8CouponTableViewCell.h"

@implementation Q8CouponTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setupForCoupon:(Q8Coupon *)coupon {
    [self layoutIfNeeded];
    
    self.qrCodeImageView.image = [coupon qrCodeImageOfSize:self.qrCodeImageView.bounds.size];
    self.titleLabel.text = coupon.offer.title;
    self.merchantTitleLabel.text = coupon.offer.merchant.title;
    self.addressLabel.text = coupon.offer.merchant.currentLocation.locationAddress ?: @"";
    NSString *locationAddress = [coupon.offer.merchant.currentLocation.locationAddress stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (locationAddress.length > 0) {
        self.distanceLabel.text = coupon.offer.merchant.currentLocation.distanceString ?: @"";
    }

    NSString *stampName = @"";
    NSString *statusText = @"";
    switch (coupon.status) {
            case Q8CouponStatusArchived: {
                stampName = @"stamp_archived";
                // fallthrough
            }
            case Q8CouponStatusActive: {
                statusText = NSLocalizedString(@"Expires in:", nil);
                break;
            }
            case Q8CouponStatusExpired: {
                statusText = NSLocalizedString(@"Expired:", nil);
                stampName = @"stamp_expired";
                break;
            }
            case Q8CouponStatusUsed: {
                statusText = NSLocalizedString(@"Used:", nil);
                stampName = @"stamp_used";
                break;
            }
        default:
            break;
    }
    self.statusLabel.text = statusText;
    self.statusImageView.image = [UIImage imageNamed:stampName];
    self.statusImageView.hidden = coupon.status == Q8CouponStatusActive;
    self.qrCodeImageView.alpha = (coupon.status == Q8CouponStatusActive) ? 1.0f : 0.1f;
    
    [self.archiveButton setImage:[UIImage imageNamed:coupon.isArchived ? @"icon_unarchive" : @"icon_archive"] forState:UIControlStateNormal];
    
    NSString *timeText = @"";
    switch (coupon.status) {
        case Q8CouponStatusArchived:
        case Q8CouponStatusActive:
            timeText = coupon.expirationCountdownString;
            break;
        case Q8CouponStatusExpired:
            timeText = [WLUtilityHelper formatDateToFullString:coupon.expirationDate preferredFormat:@"dd.MM.yyyy hh:mm"];
            break;
        case Q8CouponStatusUsed:
            timeText = [WLUtilityHelper formatDateToFullString:coupon.usedDate preferredFormat:@"dd.MM.yyyy hh:mm"];
            break;
        default:
            break;
    }
    self.statusDateLabel.text = timeText;
    self.statusDateLabel.textColor = ((coupon.status == Q8CouponStatusActive || coupon.status == Q8CouponStatusArchived) ?
                                      Q8OrangeColor : [UIColor lightGrayColor]);
    
    BOOL isStillActive = (coupon.status == Q8CouponStatusArchived ||
                          coupon.status == Q8CouponStatusActive);
    self.skipButtonsConstraint.priority = isStillActive ? 100 : 990;
    self.deleteButton.hidden = !isStillActive;
    self.archiveButton.hidden = !isStillActive;
    
    self.userInteractionEnabled = isStillActive;
    
    self.storedCoupon = coupon;
}

- (void)reloadCouponCountdown {
    if (self.storedCoupon.status == Q8CouponStatusActive ||
        self.storedCoupon.status == Q8CouponStatusArchived) {
        self.statusDateLabel.text = self.storedCoupon.expirationCountdownString;
    }
}

@end
