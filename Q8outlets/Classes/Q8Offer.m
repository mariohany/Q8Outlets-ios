//
//  Q8Offer.m
//  Q8outlets
//
//  Created by Lesya Verbina on 1/31/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8Offer.h"

@implementation Q8Offer

- (instancetype)init {
    self = [super init];
    self.offerId = @"";
    self.isNeedLoadOfferData = YES;
    
    return self;
}


#pragma mark - Generation from dict

+ (Q8Offer *)offerFromDictionary:(NSDictionary *)offerDictionary {
    Q8Offer *offer = [Q8Offer new];
    offer.offerId = [offerDictionary[@"id"] stringValue];
    offer.offerDescription = offerDictionary[@"description"];
    offer.title = offerDictionary[@"title"];
    offer.pictureAddress = offerDictionary[@"logoFile"];
    offer.link = offerDictionary[@"link"];
    
    offer.pendingCoupons = [offerDictionary[@"active_coupons"] integerValue];
    offer.usedCoupons = [offerDictionary[@"used_coupons"] integerValue];
    offer.expiredCoupons = [offerDictionary[@"expired_coupons"] integerValue];
    offer.totalCoupons = [offerDictionary[@"max_members"] integerValue];
    offer.appliedCoupons = offer.pendingCoupons + offer.usedCoupons + offer.expiredCoupons;
    NSInteger avaibleCoupons = offer.totalCoupons - offer.appliedCoupons;
    offer.availableCoupons = avaibleCoupons < 0 ? 0 : avaibleCoupons;
    
    if (offerDictionary [@"countCoupons"]) {
        NSInteger maxMember = [offerDictionary[@"max_members"] integerValue];
        NSInteger countCoupons = [offerDictionary[@"countCoupons"] integerValue];
        NSInteger avaibleCoupons = maxMember - countCoupons;
        offer.availableCoupons = avaibleCoupons < 0 ? 0 : avaibleCoupons;
    }
    
    offer.likesCount = [offerDictionary [@"countLikes"] integerValue];

    offer.isLiked = [offerDictionary [@"myLike"] count];
    offer.isCanLike = YES;
    offer.isFollowed = [offerDictionary [@"myFollow"] count];
    offer.isCanFollow = YES;
    offer.locations = [Q8MerchantLocation locationsFromArray:offerDictionary[@"locations"]];
    offer.merchant = [Q8Merchant merchantFromDictionary:offerDictionary[@"business"]];
    
    offer.isApplied = [offerDictionary [@"myCoupon"] count];
    
    offer.isNeedLoadOfferData = NO;
    
    return offer;

}

@end
