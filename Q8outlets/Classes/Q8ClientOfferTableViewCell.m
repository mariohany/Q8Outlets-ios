//
//  Q8ClientOfferTableViewCell.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/1/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8ClientOfferTableViewCell.h"

@implementation Q8ClientOfferTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Visual setup
    [WLVisualHelper fullRoundThisView:self.couponsContainerView];
    
    self.layoutMargins = UIEdgeInsetsZero;
    self.contentView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 10);
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)setupForOffer:(Q8Offer *)offer {
    
    // Populate cell with data for an offer
    self.titleLabel.text = offer.title;
    self.descriptionLabel.text = offer.offerDescription;
    self.likesLabel.text = [NSString stringWithFormat:@"%ld", (long)offer.likesCount];
    self.likeButton.userInteractionEnabled = offer.isCanLike;
    self.followButton.userInteractionEnabled = offer.isCanFollow;
    self.likeImageView.image = [UIImage imageNamed:(offer.isLiked ?
                                                    @"icon_heart_full" :
                                                    @"icon_heart_empty")];
    self.followImageView.image = [UIImage imageNamed:(offer.isFollowed ?
                                                      @"icon_star_full" :
                                                      @"icon_star_empty")];
    self.merchantTitleLabel.text = offer.merchant.title;
    self.couponsCountLabel.text = offer.availableCoupons > 100 ? NSLocalizedString(@"100+", nil) : [NSString stringWithFormat:@"%ld", (long)offer.availableCoupons];
    self.couponsTextLabel.text = (offer.availableCoupons == 1) ? NSLocalizedString(@"coupon", nil) : NSLocalizedString(@"coupons", nil);
    UIColor *couponsColor = offer.availableCoupons ? Q8RedDefaultColor : [UIColor grayColor];
    if (offer.availableCoupons == 1) {
        couponsColor = Q8OrangeColor;
    }
    self.couponsCountLabel.textColor = couponsColor;
    
    // Load image from the server
    [Q8ImageHelper setOfferPromoImage:offer intoImageView:self.promoImageView];

    self.distanceLabel.text = [offer.locations count] ? [offer.locations firstObject].distanceString : @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    
    self.couponsContainerView.backgroundColor = [UIColor whiteColor];
    self.promoContainerView.backgroundColor = [UIColor blackColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    self.couponsContainerView.backgroundColor = [UIColor whiteColor];
    self.promoContainerView.backgroundColor = [UIColor blackColor];
}

@end
