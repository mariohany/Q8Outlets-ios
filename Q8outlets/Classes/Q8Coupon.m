//
//  Q8Coupon.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/1/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8Coupon.h"

#define COUPON_STATUS_ARCHIVED  5

@implementation Q8Coupon

- (UIImage *)qrCodeImageOfSize:(CGSize)size {
    if (!self.couponToken.length) {
        return [UIImage imageNamed:@"placeholder"];
    }
    
    NSData *stringData = [self.couponToken dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = 2 * size.width / qrImage.extent.size.width;
    float scaleY = 2 * size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:qrImage
                               scale:[UIScreen mainScreen].scale
                         orientation:UIImageOrientationUp];
}

- (BOOL)isExpired {
    if ([self.expirationDate timeIntervalSinceNow] <= 0) {
        return YES;
    }
    return NO;
}

- (NSString *)expirationCountdownString {
    if ([self.expirationDate timeIntervalSinceNow]<0) {
        return @"expired";
    }
        
    NSTimeInterval expiresIn = [self.expirationDate timeIntervalSinceNow];
    int hours = expiresIn/(60*60);
    int minutes = (expiresIn - hours*60*60)/60;
    int seconds = (expiresIn - hours*60*60 - minutes*60);
    
    NSString *countDownString = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    return countDownString;
}

- (Q8CouponStatus)status {
    if (self.isUsed) {
        return Q8CouponStatusUsed;
    } else if (self.isExpired) {
        return Q8CouponStatusExpired;
    } else if (self.isArchived) {
        return Q8CouponStatusArchived;
    } else {
        return Q8CouponStatusActive;
    }
}

- (NSString *)statusString {
    return [Q8Coupon stringFromStatus:self.status];
}

+ (NSString *)stringFromStatus:(Q8CouponStatus)status {
    switch (status) {
        case Q8CouponStatusExpired:
            return NSLocalizedString(@"Expired", nil);
            break;
        case Q8CouponStatusUsed:
            return NSLocalizedString(@"Used", nil);
            break;
        case Q8CouponStatusArchived:
            return NSLocalizedString(@"Archived", nil);
            break;
        case Q8CouponStatusActive:
            return NSLocalizedString(@"Active", nil);
            break;
            
        default:
            return NSLocalizedString(@"Status unknown", nil);
            break;
    }
}

// Generation from dictionary
+ (Q8Coupon *)couponFromDictionary:(NSDictionary *)couponDictionary {
    Q8Coupon *coupon = [Q8Coupon new];
    coupon.couponToken = couponDictionary[@"token"];
    coupon.isUsed = [couponDictionary[@"isUsed"] boolValue];
    coupon.expirationDate = [NSDate dateWithTimeIntervalSince1970:[couponDictionary[@"expired_at"] doubleValue]];
    coupon.couponID = [couponDictionary[@"id"] integerValue];
    coupon.usedDate = [NSDate dateWithTimeIntervalSince1970:[couponDictionary[@"updated_at"] doubleValue]];
    coupon.isArchived = [couponDictionary[@"status"] integerValue] == COUPON_STATUS_ARCHIVED ? YES : NO;
    
    coupon.offer = [Q8Offer offerFromDictionary:couponDictionary[@"offer"]];    
    coupon.offer.merchant = [Q8Merchant new];
    NSArray *location = couponDictionary[@"locationsByOffer"];
    NSDictionary *locationsByOffer = [location firstObject];
    coupon.offer.merchant.currentLocation = [Q8MerchantLocation locationFromDictionary:[WLUtilityHelper dictionaryCleanedFromNulls:locationsByOffer]];
    
    return coupon;
}

@end
