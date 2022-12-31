//
//  Q8NavigationManager.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/7/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8NavigationManager.h"
#import "Q8VipCodeTableViewController.h"
#import "Q8MerchantViewController.h"
#import "Q8OfferViewController.h"
#import "Q8BusinessOfferViewController.h"
#import "Q8ShowCouponViewController.h"
#import "Q8ResetPasswordTableViewController.h"

@implementation Q8NavigationManager

#pragma mark - Login section

+ (void)moveToSignUp {
	UIViewController *unAuthorizedHome = [WLUtilityHelper viewControllerFromStoryboard:@"Main" controllerIdentifier:Q8RootUnauthorizedController];
	[WLUtilityHelper changeWindowRootControllerAnimated:YES toController:unAuthorizedHome loadView:YES];
}

#pragma mark - reset password section

+ (void)moveToResetPasswordWithToken:(NSString*)token {
	Q8ResetPasswordTableViewController *resetPassword = (Q8ResetPasswordTableViewController*)[WLUtilityHelper viewControllerFromStoryboard:@"Main" controllerIdentifier:Q8ResetPasswordController];
	resetPassword.passwordToken = token;
	UINavigationController *rootController = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
	if ([rootController isKindOfClass:[UINavigationController class]]) {
		[rootController pushViewController:resetPassword animated:YES];
	}
}

#pragma mark - Client user section

+ (void)moveToClientHome {
    UIViewController *authorizedHome = [WLUtilityHelper viewControllerFromStoryboard:@"Client" controllerIdentifier:Q8RootClientHomeController];
    [WLUtilityHelper changeWindowRootControllerAnimated:YES toController:authorizedHome loadView:YES];
}

+ (void)moveToVipCodeCanSkip:(BOOL)canSkip moveToHome:(BOOL)moveToHome {
    Q8VipCodeTableViewController *vipController = (Q8VipCodeTableViewController *)[WLUtilityHelper viewControllerFromSBWithIdentifier:Q8VipCodeControllerIdentifier];
    vipController.hideSkip = !canSkip;
    vipController.moveToHome = moveToHome;
    UITabBarController *rootTabbarController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    if ([rootTabbarController isKindOfClass:[UITabBarController class]] &&
        [rootTabbarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *rootNavigationController = (UINavigationController *)rootTabbarController.selectedViewController;
        [rootNavigationController pushViewController:vipController animated:YES];
    }
}

+ (void)moveToMerchant:(Q8Merchant *)merchant {
    Q8MerchantViewController *merchantController = (Q8MerchantViewController *)[WLUtilityHelper viewControllerFromStoryboard:@"Client" controllerIdentifier:Q8MerchantControllerIdentifier];
    merchantController.merchant = merchant;
    UITabBarController *rootTabbarController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    UINavigationController *rootNavigationController = (UINavigationController *)rootTabbarController.selectedViewController;
    [rootNavigationController pushViewController:merchantController animated:YES];
}

+ (void)moveToClientOffer:(Q8Offer *)offer {
    Q8OfferViewController *offerController = (Q8OfferViewController *)[WLUtilityHelper viewControllerFromStoryboard:@"Client" controllerIdentifier:Q8OfferControllerIdentifier];
    offerController.offer = offer;
    UITabBarController *rootTabbarController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    if ([rootTabbarController isKindOfClass:[UITabBarController class]] &&
        [rootTabbarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *rootNavigationController = (UINavigationController *)rootTabbarController.selectedViewController;
        [rootNavigationController pushViewController:offerController animated:YES];
    }
}

+ (void)moveToClientCoupon:(Q8Coupon *)coupon {
    Q8ShowCouponViewController *couponController = (Q8ShowCouponViewController *)[WLUtilityHelper viewControllerFromStoryboard:@"Client" controllerIdentifier:Q8ShowCouponControllerIdentifier];
    couponController.coupon = coupon;
    UITabBarController *rootTabbarController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    if ([rootTabbarController isKindOfClass:[UITabBarController class]] &&
        [rootTabbarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *rootNavigationController = (UINavigationController *)rootTabbarController.selectedViewController;
        [rootNavigationController pushViewController:couponController animated:YES];
    }
}

#pragma mark - Business user section

+ (void)moveToBusinessHome {
    UIViewController *authorizedHome = [WLUtilityHelper viewControllerFromStoryboard:@"Business" controllerIdentifier:Q8RootBusinnessHomeController];
    [WLUtilityHelper changeWindowRootControllerAnimated:YES toController:authorizedHome loadView:YES];
}

+ (void)moveToBusinessOffer:(Q8Offer *)offer {
    Q8BusinessOfferViewController *offerController = (Q8BusinessOfferViewController *)[WLUtilityHelper viewControllerFromStoryboard:@"Business" controllerIdentifier:Q8BusinessOfferControllerIdentifier];
    offerController.offer = offer;
    UINavigationController *rootNavigationController = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    if ([rootNavigationController isKindOfClass:[UINavigationController class]]) {
        [rootNavigationController pushViewController:offerController animated:YES];
    }
}

@end
