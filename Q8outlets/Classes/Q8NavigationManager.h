//
//  Q8NavigationManager.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/7/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Manages commonly used paths of navigation - moving to home screen of
 a role, opening merchant or offer, sharing.
 */
@interface Q8NavigationManager : NSObject

// **
// Login section
+ (void)moveToSignUp;

// **
// Reset password section
+ (void)moveToResetPasswordWithToken:(NSString*)token;

// **
// Client user section
+ (void)moveToClientHome;
+ (void)moveToVipCodeCanSkip:(BOOL)canSkip moveToHome:(BOOL)moveToHome;

+ (void)moveToMerchant:(Q8Merchant *)merchant;
+ (void)moveToClientOffer:(Q8Offer *)offer;

+ (void)moveToClientCoupon:(Q8Coupon *)coupon;

// **
// Business user section
+ (void)moveToBusinessHome;

+ (void)moveToBusinessOffer:(Q8Offer *)offer;

@end
