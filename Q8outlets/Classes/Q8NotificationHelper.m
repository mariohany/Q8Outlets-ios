//
//  Q8NotificationHelper.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/10/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8NotificationHelper.h"

@implementation Q8NotificationHelper {
    NSMapTable *singleOfferObserversMap;
    NSHashTable *allOfferObservers;
    
    NSMapTable *singleMerchantObserversMap;
    NSHashTable *allMerchantObservers;
}

+ (Q8NotificationHelper *)sharedHelper {
    static dispatch_once_t onceToken;
    static Q8NotificationHelper *sharedHelper = nil;
    
    dispatch_once(&onceToken, ^{
        sharedHelper = [[Q8NotificationHelper alloc] init];
    });
    
    return sharedHelper;
}

- (instancetype)init {
    self = [super init];
    
    singleOfferObserversMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    allOfferObservers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    
    singleMerchantObserversMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    allMerchantObservers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    
    return self;
}

#pragma mark - Offers

+ (void)postOfferLikeChangeNotification:(Q8Offer *)offer likeStatus:(BOOL)likeStatus {
    [[Q8NotificationHelper sharedHelper] postOfferLikeChangeNotification:offer likeStatus:likeStatus];
}
- (void)postOfferLikeChangeNotification:(Q8Offer *)offer likeStatus:(BOOL)likeStatus {
    NSEnumerator *singleOffersEnumerator = [singleOfferObserversMap keyEnumerator];
    for (id <Q8OfferNotificationObserver> observer in [singleOffersEnumerator allObjects]) {
        Q8Offer *observingOffer = [singleOfferObserversMap objectForKey:observer];
        if (observingOffer == offer) {
            if ([observer respondsToSelector:@selector(myOfferLikeStatusChanged:)]) {
                [observer myOfferLikeStatusChanged:likeStatus];
            }
        }
    }
    for (id <Q8AllOffersNotificationObserver> observer in [allOfferObservers allObjects]) {
        if ([observer respondsToSelector:@selector(offerLikeStatusChanged:likeStatus:)]) {
            [observer offerLikeStatusChanged:offer likeStatus:likeStatus];
        }
    }
}
+ (void)postOfferFollowChangeNotification:(Q8Offer *)offer followStatus:(BOOL)followStatus {
    [[Q8NotificationHelper sharedHelper] postOfferFollowChangeNotification:offer followStatus:followStatus];
}
- (void)postOfferFollowChangeNotification:(Q8Offer *)offer followStatus:(BOOL)followStatus {
    NSEnumerator *singleOffersEnumerator = [singleOfferObserversMap keyEnumerator];
    for (id <Q8OfferNotificationObserver> observer in [singleOffersEnumerator allObjects]) {
        Q8Offer *observingOffer = [singleOfferObserversMap objectForKey:observer];
        if ([observingOffer.offerId isEqualToString:offer.offerId]) {
            if ([observer respondsToSelector:@selector(myOfferFollowStatusChanged:)]) {
                [observer myOfferFollowStatusChanged:followStatus];
            }
        }        
    }
    for (id <Q8AllOffersNotificationObserver> observer in [allOfferObservers allObjects]) {
        if ([observer respondsToSelector:@selector(offerFollowStatusChanged:followStatus:)]) {
            [observer offerFollowStatusChanged:offer followStatus:followStatus];
        }
    }
}

+ (void)postOfferCouponCountChangeNotification:(Q8Offer *)offer couponApplied:(BOOL)isApplied {
    [[Q8NotificationHelper sharedHelper] postOfferCouponCountChangeNotification:offer couponApplied:isApplied];
}

- (void)postOfferCouponCountChangeNotification:(Q8Offer *)offer couponApplied:(BOOL)isApplied {
    NSEnumerator *singleOffersEnumerator = [singleOfferObserversMap keyEnumerator];
    for (id <Q8OfferNotificationObserver> observer in [singleOffersEnumerator allObjects]) {
        Q8Offer *observingOffer = [singleOfferObserversMap objectForKey:observer];
        if ([observingOffer.offerId isEqualToString:offer.offerId]) {
            if ([observer respondsToSelector:@selector(myOfferCouponApplied:)]) {
                [observer myOfferCouponApplied:isApplied];
            }
        }
    }
    for (id <Q8AllOffersNotificationObserver> observer in [allOfferObservers allObjects]) {
        if ([observer respondsToSelector:@selector(offerCouponCountChanged:couponApplied:)]) {
            [observer offerCouponCountChanged:offer couponApplied:isApplied];
        }
    }
}

+ (void)addObserver:(id <Q8OfferNotificationObserver>)observer toOfferChange:(Q8Offer *)offer {
    [[Q8NotificationHelper sharedHelper] addObserver:observer toOfferChange:offer];
}
- (void)addObserver:(id <Q8OfferNotificationObserver>)observer toOfferChange:(Q8Offer *)offer {
    __weak typeof(observer) weakObserver = observer;
    [singleOfferObserversMap setObject:offer forKey:weakObserver];
}

+ (void)addObserverToAnyOfferChange:(id <Q8AllOffersNotificationObserver>)observer {
    [[Q8NotificationHelper sharedHelper] addObserverToAnyOfferChange:observer];
}
- (void)addObserverToAnyOfferChange:(id <Q8AllOffersNotificationObserver>)observer {
    __weak typeof(observer) weakObserver = observer;
    [allOfferObservers addObject:weakObserver];
}


#pragma mark - Merchants

+ (void)postMerchantFollowChangeNotification:(Q8Merchant *)merchant followStatus:(BOOL)followStatus {
    [[Q8NotificationHelper sharedHelper] postMerchantFollowChangeNotification:merchant followStatus:followStatus];
}

- (void)postMerchantFollowChangeNotification:(Q8Merchant *)merchant followStatus:(BOOL)followStatus {
    NSEnumerator *singleMerchantsEnumerator = [singleMerchantObserversMap keyEnumerator];
    for (id <Q8MerchantNotificationObserver> observer in [singleMerchantsEnumerator allObjects]) {
        Q8Merchant *observingMerchant = [singleMerchantObserversMap objectForKey:observer];
        if ([observingMerchant.merchantId isEqualToString:merchant.merchantId]) {
            if ([observer respondsToSelector:@selector(myMerchantFollowStatusChanged:)]) {
                [observer myMerchantFollowStatusChanged:followStatus];
            }
        }
    }    
    for (id <Q8AllMerchantsNotificationObserver> observer in [allOfferObservers allObjects]) {
        if ([observer respondsToSelector:@selector(merchantFollowStatusChanged:followStatus:)]) {
            [observer merchantFollowStatusChanged:merchant followStatus:followStatus];
        }
    }    
}

+ (void)addObserver:(id <Q8MerchantNotificationObserver>)observer toMerchantChange:(Q8Merchant *)merchant {
    [[Q8NotificationHelper sharedHelper] addObserver:observer toMerchantChange:merchant];
}
- (void)addObserver:(id <Q8MerchantNotificationObserver>)observer toMerchantChange:(Q8Merchant *)merchant {
    __weak typeof(observer) weakObserver = observer;
    [singleMerchantObserversMap setObject:merchant forKey:weakObserver];
}

+ (void)addObserverToAnyMerchantChange:(id <Q8AllMerchantsNotificationObserver>)observer {
    [[Q8NotificationHelper sharedHelper] addObserverToAnyMerchantChange:observer];
}

- (void)addObserverToAnyMerchantChange:(id <Q8AllMerchantsNotificationObserver>)observer {
    __weak typeof(observer) weakObserver = observer;
    [allMerchantObservers addObject:weakObserver];
}

@end
