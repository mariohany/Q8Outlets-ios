//
//  Q8Offer.h
//  Q8outlets
//
//  Created by Lesya Verbina on 1/31/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Q8Merchant.h"

@interface Q8Offer : NSObject

@property (nonatomic, strong) NSString *offerId;
@property (nonatomic, strong) NSString *offerDescription;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *pictureAddress;
@property (nonatomic, strong) NSString *link;

@property (nonatomic, assign) NSInteger likesCount;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isApplied;
@property (nonatomic, assign) BOOL isCanLike;
@property (nonatomic, assign) BOOL isCanFollow;

@property (nonatomic, assign) NSInteger totalCoupons;
@property (nonatomic, assign) NSInteger availableCoupons;
@property (nonatomic, assign) NSInteger appliedCoupons;
@property (nonatomic, assign) NSInteger pendingCoupons;
@property (nonatomic, assign) NSInteger usedCoupons;
@property (nonatomic, assign) NSInteger expiredCoupons;

@property (nonatomic, strong) Q8Merchant *merchant;
@property (nonatomic, strong) NSArray <Q8MerchantLocation *> *locations; // offer can be available only in some locations

@property (nonatomic, assign) BOOL isNeedLoadOfferData;

// **
// Generation from dictionary
+ (Q8Offer *)offerFromDictionary:(NSDictionary *)offerDictionary;

@end
