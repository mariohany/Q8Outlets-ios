//
//  Q8CurrentUser.h
//  Q8outlets
//
//  Created by Lesya Verbina on 1/31/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Q8UserRoleClient,
    Q8UserRoleBusiness,
    Q8UserRoleModerator
} Q8UserRole;

typedef enum {
    Q8SocialNetworkTypeFacebook,
    Q8SocialNetworkTypeTwitter,
    Q8SocialNetworkTypeGoogle,
    Q8SocialNetworkTypeInstagram
} Q8SocialNetworkType;

@interface Q8CurrentUser : NSObject

+ (NSString *)deviceToken;
+ (void)saveDeviceToken:(NSString *)deviceToken;

+ (BOOL)isAuthorized;

+ (NSString *)accessToken;
+ (void)saveAccessToken:(NSString *)accessToken;

+ (Q8UserRole)userRole;
+ (void)saveUserRole:(Q8UserRole)userRole;

+ (BOOL)isVIP;
+ (void)saveVIP:(BOOL)vip;

+ (NSString *)userId;
+ (void)saveUserId:(NSString *)userId;

+ (NSString *)userName;
+ (void)saveUserName:(NSString *)name;

+ (NSString *)userEmail;
+ (void)saveUserEmail:(NSString *)email;

+ (NSString *)userSessionUDID;
+ (void)saveUserSessionUDID:(NSString *)sessionUdid;

+ (NSString *)userSocialNetworkAccount;
+ (void)saveUserSocialNetworkAccount:(NSString *)socialNetworkAccount;

+ (Q8SocialNetworkType)userSocialNetworkType;
+ (void)saveUserSocialNetworkType:(Q8SocialNetworkType)socialNetworkType;

+ (NSString *)userLocationID;
+ (void)saveUserLocationID:(NSString *)userLocationID;

+ (NSString *)userLocation;
+ (void)saveUserLocation:(NSString *)userLocation;

// Notification settings
+ (BOOL)offerEmails;
+ (void)saveOfferEmails:(BOOL)offerEmails;
+ (BOOL)offerPushes;
+ (void)saveOfferPushes:(BOOL)offerPushes;
+ (BOOL)merchantEmails;
+ (void)saveMerchantEmails:(BOOL)merchantEmails;
+ (BOOL)merchantPushes;
+ (void)saveMerchantPushes:(BOOL)merchantPushes;
+ (BOOL)couponsEmails;
+ (void)saveCouponsEmails:(BOOL)couponsEmails;
+ (BOOL)couponsPushes;
+ (void)saveCouponsPushes:(BOOL)couponsPushes;

#pragma mark - Logout

/**
 Move to unauthorized controller and clean current user's session info.
 
 @param move Flag describing is should move to login controller.
 */
+ (void)logOutAndMoveToLoginScreen:(BOOL)move;


@end
