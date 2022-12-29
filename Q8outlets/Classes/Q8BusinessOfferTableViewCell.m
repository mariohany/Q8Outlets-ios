//
//  Q8BusinessOfferTableViewCell.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/14/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8BusinessOfferTableViewCell.h"

@implementation Q8BusinessOfferTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Visual setup
    [WLVisualHelper templatizeImageView:self.availableImageView withColor:[UIColor darkGrayColor]];
    [WLVisualHelper templatizeImageView:self.usedImageView withColor:Q8RedDefaultColor];
    [WLVisualHelper templatizeImageView:self.expiredImageView withColor:Q8OrangeColor];
}

- (void)setupForOffer:(Q8Offer *)offer {
    self.offerTitleLabel.text = offer.title;
    self.addressLabel.text = [offer.locations count] ? [offer.locations firstObject].locationAddress : NSLocalizedString(@"No available locations", nil);
    self.moreLocationsLabel.text = [offer.locations count]>1 ? [NSString stringWithFormat:NSLocalizedString(@"%ld more locations", nil), (long)[offer.locations count]-1] : @"";
    
    self.availableLabel.text =  [@(offer.availableCoupons) stringValue];
    self.appliedLabel.text =    [@(offer.appliedCoupons) stringValue];
    self.usedLabel.text =       [@(offer.usedCoupons) stringValue];
    self.expiredLabel.text =    [@(offer.expiredCoupons) stringValue];
}

@end
