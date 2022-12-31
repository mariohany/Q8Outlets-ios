//
//  Q8Constants.h
//  Q8outlets
//
//  Created by Lesya Verbina on 1/31/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#ifndef Q8Constants_h
#define Q8Constants_h

#define weakify(var) __weak typeof(var) WLWeak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = WLWeak_##var; \
_Pragma("clang diagnostic pop")

#pragma mark -
#pragma mark - App related

#define APPSTORE_ITUNESCONNECT_ID @""

#pragma mark -
#pragma mark - General

// Report reasons
typedef enum {
    Q8ReportReasonOffensive = 1,
    Q8ReportReasonSpam,
    Q8ReportReasonCheating
} Q8ReportReason;

#pragma mark -
#pragma mark - Alert reasons

//#if [[[NSLocale preferredLanguages] objectAtIndex:0]  rangeOfString:@"ar"].location == NSNotFound)

// Keys to alerts in Alerts.json
typedef enum {
    Q8ReasonServerFailure = 1,
    Q8ReasonNoInternet,
    Q8ReasonSessionExpired,
    Q8ReasonNameRequired,
    Q8ReasonEmailRequired,
    Q8ReasonPasswordRequired,
    Q8ReasonPasswordConfirmationInvalid,
    Q8ReasonInvalidCredentials,
    Q8ReasonEmailTaken,
    Q8ReasonEmailInvalid,
    Q8ReasonAcceptTerms,
    Q8ReasonCodeRequired,
    Q8ReasonCodeInvalid,
    Q8ReasonPasswordResetSuccess,
    Q8ReasonConfirmLogout,
    Q8ReasonVIPSuccess,
    Q8ReasonCameraAccessRequired,
    Q8ReasonEmailNotFound,
    Q8ReasonConfitmCouponDelete,
    Q8ReasonVIPNeeded,
    Q8ReasonPasswordTooShort,
    Q8ReasonLoginRoleIsMerchant,
    Q8ReasonLoginRoleIsClient,
    Q8ReasonCantUnlinkNoEmail,
    Q8ReasonCantUnlinkNoPass,
    Q8ReasonSocialNetworkEmailTaken,
    Q8ReasonCouponExpired,
    Q8ReasonReportSuccess,
    Q8ReasonSearchNoResults,
    Q8ReasonOfferReachedMaxAmountCoupons,
    Q8ReasonSocialAccountUsed,
    Q8ReasonShareOption,
    Q8ReasonCouponInvalidCredentials,
	Q8ReasonPasswordDidReset,
    
    Q8ReasonConfirmLogout_ar = 115,
    Q8ReasonCameraAccessRequired_ar = 117,
    Q8ReasonConfitmCouponDelete_ar = 119,
    Q8ReasonVIPNeeded_ar = 120,
    Q8ReasonShareOption_ar = 132
} AlertKeys;

#pragma mark -
#pragma mark - Visual constants

#define Q8CornerRadius 2.0f

#define Q8RedDefaultColor   [UIColor colorWithRed:185.f/255.f green:0.f/255.f blue:10.f/255.f alpha:1.f]
#define Q8OrangeColor       [UIColor colorWithRed:249.f/255.f green:149.f/255.f blue:10.f/255.f alpha:1.f]
#define Q8DarkOrangeColor   [UIColor colorWithRed:240.f/255.f green:140.f/255.f blue:1.f/255.f alpha:1.f]
#define Q8LightGrayColor    [UIColor colorWithRed:210.f/255.f green:210.f/255.f blue:210.f/255.f alpha:1.f]
#define Q8DarkGrayColor     [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:50.f/255.f alpha:1.f]
#define Q8GreenColor		[UIColor colorWithRed:138.f/255.f green:179.f/255.f blue:110.f/255.f alpha:1.f]

#pragma mark -
#pragma mark - Local notifications

#define Q8NotificationInstagramLoginSuccess @"Q8NotificationInstagramLoginSuccess"
#define Q8NotificationInstagramLoginFail    @"Q8NotificationInstagramLoginFail"

#define Q8NotificationLogout    @"Q8NotificationLogout"

#pragma mark -
#pragma mark - Navigation constants

// Login controller for unauthorized users
#define Q8RootUnauthorizedController    @"Q8RootUnauthorized"
// Reset password controller
#define Q8ResetPasswordController    @"Q8ResetPassword"
// Home controller for authorized
#define Q8RootClientHomeController      @"Q8RootClientHome"
#define Q8RootBusinnessHomeController   @"Q8RootBusinnessHome"

#endif /* Q8Constants_h */
