//
//  Q8CurrentUser.m
//  Q8outlets
//
//  Created by Lesya Verbina on 1/31/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8CurrentUser.h"
#import "Q8SocialLoginHelper.h"
#import <WLHelpers/WLKeychainHelper.h>

#define Q8_USER_SESSION_UDID    @"Q8_USER_SESSION_UDID"
#define Q8_USER_DEVICE_TOKEN    @"Q8_USER_DEVICE_TOKEN"

#define Q8_USER_ROLE        @"Q8_USER_ROLE"
#define Q8_USER_VIP         @"Q8_USER_VIP"
#define Q8_USER_ID          @"Q8_USER_ID"
#define Q8_USER_NAME        @"Q8_USER_NAME"
#define Q8_USER_EMAIL       @"Q8_USER_EMAIL"
#define Q8_USER_LOCATION    @"Q8_USER_LOCATION"
#define Q8_USER_LOCATION_ID @"Q8_USER_LOCATION_ID"

#define Q8_USER_SOCIAL_NETWORK_TYPE     @"Q8_USER_SOCIAL_NETWORK_TYPE"
#define Q8_USER_SOCIAL_NETWORK_ACCOUNT  @"Q8_USER_SOCIAL_NETWORK_ACCOUNTL"

#define Q8_SETTING_OFFER_EMAILS         @"Q8_SETTING_OFFER_EMAILS"
#define Q8_SETTING_OFFER_PUSHES         @"Q8_SETTING_OFFER_PUSHES"
#define Q8_SETTING_MERCHANT_EMAILS      @"Q8_SETTING_MERCHANT_EMAILS"
#define Q8_SETTING_MERCHANT_PUSHES      @"Q8_SETTING_MERCHANT_PUSHES"
#define Q8_SETTING_COUPONS_EMAILS       @"Q8_SETTING_COUPONS_EMAILS"
#define Q8_SETTING_COUPONS_PUSHES       @"Q8_SETTING_COUPONS_PUSHES"

@implementation Q8CurrentUser

+ (NSString *)deviceToken {
    return [WLUtilityHelper dataFromDefaultsWithKey:Q8_USER_DEVICE_TOKEN];
}
+ (void)saveDeviceToken:(NSString *)deviceToken {
    [WLUtilityHelper writeDataToDefaults:deviceToken forKey:Q8_USER_DEVICE_TOKEN];
}

+ (BOOL)isAuthorized {
    return [Q8CurrentUser accessToken].length;
}

+ (NSString *)accessToken {
    return [WLKeychainHelper objectForKey:(__bridge id)kSecValueData];
}
+ (void)saveAccessToken:(NSString *)accessToken {
    [WLKeychainHelper setObject:accessToken forKey:(__bridge id)kSecValueData];
}

+ (Q8UserRole)userRole {
    return [[WLUtilityHelper dataFromDefaultsWithKey:Q8_USER_ROLE] intValue];
}
+ (void)saveUserRole:(Q8UserRole)userRole {
    [WLUtilityHelper writeDataToDefaults:@(userRole) forKey:Q8_USER_ROLE];
}

+ (BOOL)isVIP {
    return YES;
    return [[WLUtilityHelper dataFromDefaultsWithKey:Q8_USER_VIP] boolValue];
}
+ (void)saveVIP:(BOOL)vip {
    [WLUtilityHelper writeDataToDefaults:@(vip) forKey:Q8_USER_VIP];
}

+ (NSString *)userId {
    return [WLUtilityHelper dataFromDefaultsWithKey:Q8_USER_ID];
}
+ (void)saveUserId:(NSString *)userId {
    [WLUtilityHelper writeDataToDefaults:userId forKey:Q8_USER_ID];
}

+ (NSString *)userName {
    return [WLUtilityHelper dataFromDefaultsWithKey:Q8_USER_NAME];
    
}
+ (void)saveUserName:(NSString *)name {
    [WLUtilityHelper writeDataToDefaults:name forKey:Q8_USER_NAME];
}

+ (NSString *)userEmail {
    return [WLUtilityHelper dataFromDefaultsWithKey:Q8_USER_EMAIL];
}
+ (void)saveUserEmail:(NSString *)email {
    [WLUtilityHelper writeDataToDefaults:email forKey:Q8_USER_EMAIL];
}

+ (NSString *)userSessionUDID {
    NSString *sessionUDID = [WLUtilityHelper dataFromDefaultsWithKey:Q8_USER_SESSION_UDID];
    if (!sessionUDID.length) {
        sessionUDID = [WLUtilityHelper randomStringWithLength:20];
        [Q8CurrentUser saveUserSessionUDID:sessionUDID];
    }
    return sessionUDID;
}
+ (void)saveUserSessionUDID:(NSString *)sessionUdid {
    [WLUtilityHelper writeDataToDefaults:sessionUdid forKey:Q8_USER_SESSION_UDID];
}

+ (NSString *)userSocialNetworkAccount {
    return [WLUtilityHelper dataFromDefaultsWithKey:Q8_USER_SOCIAL_NETWORK_ACCOUNT];
}
+ (void)saveUserSocialNetworkAccount:(NSString *)socialNetworkAccount {
    [WLUtilityHelper writeDataToDefaults:socialNetworkAccount forKey:Q8_USER_SOCIAL_NETWORK_ACCOUNT];
}

+ (Q8SocialNetworkType)userSocialNetworkType {
    return [[WLUtilityHelper dataFromDefaultsWithKey:Q8_USER_SOCIAL_NETWORK_TYPE] intValue];
    
}
+ (void)saveUserSocialNetworkType:(Q8SocialNetworkType)socialNetworkType {
    [WLUtilityHelper writeDataToDefaults:@(socialNetworkType) forKey:Q8_USER_SOCIAL_NETWORK_TYPE];
}

+ (NSString *)userLocationID {
     return [WLUtilityHelper dataFromDefaultsWithKey:Q8_USER_LOCATION_ID];
}

+ (void)saveUserLocationID:(NSString *)userLocationID {
    [WLUtilityHelper writeDataToDefaults:userLocationID forKey:Q8_USER_LOCATION_ID];
}

+ (NSString *)userLocation {
    return [WLUtilityHelper dataFromDefaultsWithKey:Q8_USER_LOCATION];
}

+ (void)saveUserLocation:(NSString *)userLocation {
     [WLUtilityHelper writeDataToDefaults:userLocation forKey:Q8_USER_LOCATION];
}

+ (BOOL)offerEmails {
    return [[WLUtilityHelper dataFromDefaultsWithKey:Q8_SETTING_OFFER_EMAILS] boolValue];
}
+ (void)saveOfferEmails:(BOOL)offerEmails {
    [WLUtilityHelper writeDataToDefaults:@(offerEmails) forKey:Q8_SETTING_OFFER_EMAILS];
}
+ (BOOL)offerPushes {
    return [[WLUtilityHelper dataFromDefaultsWithKey:Q8_SETTING_OFFER_PUSHES] boolValue];
}
+ (void)saveOfferPushes:(BOOL)offerPushes {
    [WLUtilityHelper writeDataToDefaults:@(offerPushes) forKey:Q8_SETTING_OFFER_PUSHES];
}
+ (BOOL)merchantEmails {
    return [[WLUtilityHelper dataFromDefaultsWithKey:Q8_SETTING_MERCHANT_EMAILS] boolValue];
}
+ (void)saveMerchantEmails:(BOOL)merchantEmails {
    [WLUtilityHelper writeDataToDefaults:@(merchantEmails) forKey:Q8_SETTING_MERCHANT_EMAILS];
}
+ (BOOL)merchantPushes {
    return [[WLUtilityHelper dataFromDefaultsWithKey:Q8_SETTING_MERCHANT_PUSHES] boolValue];
}
+ (void)saveMerchantPushes:(BOOL)merchantPushes {
    [WLUtilityHelper writeDataToDefaults:@(merchantPushes) forKey:Q8_SETTING_MERCHANT_PUSHES];
}
+ (BOOL)couponsEmails {
    return [[WLUtilityHelper dataFromDefaultsWithKey:Q8_SETTING_COUPONS_EMAILS] boolValue];
}
+ (void)saveCouponsEmails:(BOOL)couponsEmails {
    [WLUtilityHelper writeDataToDefaults:@(couponsEmails) forKey:Q8_SETTING_COUPONS_EMAILS];
}
+ (BOOL)couponsPushes {
    return [[WLUtilityHelper dataFromDefaultsWithKey:Q8_SETTING_COUPONS_PUSHES] boolValue];
}
+ (void)saveCouponsPushes:(BOOL)couponsPushes {
    [WLUtilityHelper writeDataToDefaults:@(couponsPushes) forKey:Q8_SETTING_COUPONS_PUSHES];
}

#pragma mark - Logout

+ (void)logOutAndMoveToLoginScreen:(BOOL)move {
    // Save "udid" for server session
    NSString *sessionUdid = [Q8CurrentUser userSessionUDID];
    // Save "device token"
    NSString *deviceToken = [Q8CurrentUser deviceToken];
    // Remove device token from server
    [[Q8ServerAPIHelper sharedHelper] removeDeviceToken:deviceToken onCompletion:^(BOOL success) {} sender:nil];
    // Clean up all user data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [defaults removePersistentDomainForName:appDomain];
    [WLKeychainHelper resetKeychain];
    
    // Log out of social networks
    [Q8SocialLoginHelper logoutFacebook];
    [[Q8SocialLoginHelper sharedHelper] logoutGoogle];
    [Q8SocialLoginHelper logoutTwitter];
    
    if (move) {
        // Move to unathorized home after logout
        UIViewController *rootLoginController = [WLUtilityHelper viewControllerFromSBWithIdentifier:Q8RootUnauthorizedController];
        [WLUtilityHelper changeWindowRootControllerAnimated:YES toController:rootLoginController loadView:YES];
    }
    
    // Post "logout" notification so other controllers have
    // opportunity to react by closing/stopping sound, etc
    [[NSNotificationCenter defaultCenter] postNotificationName:Q8NotificationLogout
                                                        object:nil];
    
    [Q8CurrentUser saveUserSessionUDID:sessionUdid];
    [Q8CurrentUser saveDeviceToken:deviceToken];
}

@end
