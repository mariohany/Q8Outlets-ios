//
//  Q8Coupon.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/1/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Q8Offer.h"

typedef enum {
    Q8CouponStatusActive,
    Q8CouponStatusArchived,
    Q8CouponStatusExpired,
    Q8CouponStatusUsed,
    Q8CouponStatusWrongLocation,
    Q8CouponStatusError
} Q8CouponStatus;

@interface Q8Coupon : NSObject

@property (nonatomic, strong) NSString *couponToken;
@property (nonatomic, assign) NSInteger couponID;
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, strong, readonly) NSString *expirationCountdownString;
@property (nonatomic, strong) NSDate *usedDate;
@property (nonatomic, assign) BOOL isUsed;
@property (nonatomic, assign) BOOL isArchived;
@property (nonatomic, assign, readonly) BOOL isExpired;
@property (nonatomic, assign, readonly) Q8CouponStatus status;
@property (nonatomic, assign, readonly) NSString *statusString;

@property (nonatomic, strong) Q8Offer *offer;

- (UIImage *)qrCodeImageOfSize:(CGSize)size;

+ (NSString *)stringFromStatus:(Q8CouponStatus)status;

// **
// Generation from dictionary
+ (Q8Coupon *)couponFromDictionary:(NSDictionary *)couponDictionary;

@end
