//
//  Q8NotificationHelper.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/10/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Will be notified on change of a particular offer's like or follow status.
 */
@protocol Q8OfferNotificationObserver <NSObject>
- (void)myOfferLikeStatusChanged:(BOOL)likeStatus;
- (void)myOfferFollowStatusChanged:(BOOL)followStatus;
- (void)myOfferCouponApplied:(BOOL)isApplied;
@end

/**
 Will be notified on change of a particular merchant's follow status.
 */
@protocol Q8MerchantNotificationObserver <NSObject>
- (void)myMerchantFollowStatusChanged:(BOOL)followStatus;
@end

/**
 Will be notified on change of any offer's like or follow status.
 */
@protocol Q8AllOffersNotificationObserver <NSObject>
- (void)offerLikeStatusChanged:(Q8Offer *)offer likeStatus:(BOOL)likeStatus;
- (void)offerFollowStatusChanged:(Q8Offer *)offer followStatus:(BOOL)followStatus;
- (void)offerCouponCountChanged:(Q8Offer *)offer couponApplied:(BOOL)isApplied;
@end

/**
 Will be notified on change of any merchant's follow status.
 */
@protocol Q8AllMerchantsNotificationObserver <NSObject>
- (void)merchantFollowStatusChanged:(Q8Merchant *)merchant followStatus:(BOOL)followStatus;
@end

@interface Q8NotificationHelper : NSObject

// **
// Offers
+ (void)postOfferLikeChangeNotification:(Q8Offer *)offer likeStatus:(BOOL)likeStatus;
+ (void)postOfferFollowChangeNotification:(Q8Offer *)offer followStatus:(BOOL)followStatus;
+ (void)postOfferCouponCountChangeNotification:(Q8Offer *)offer couponApplied:(BOOL)isApplied;

+ (void)addObserver:(id <Q8OfferNotificationObserver>)observer toOfferChange:(Q8Offer *)offer;
+ (void)addObserverToAnyOfferChange:(id <Q8AllOffersNotificationObserver>)observer;

// **
// Merchants
+ (void)postMerchantFollowChangeNotification:(Q8Merchant *)merchant followStatus:(BOOL)followStatus;

+ (void)addObserver:(id <Q8MerchantNotificationObserver>)observer toMerchantChange:(Q8Merchant *)offer;
+ (void)addObserverToAnyMerchantChange:(id <Q8AllMerchantsNotificationObserver>)observer;


@end
