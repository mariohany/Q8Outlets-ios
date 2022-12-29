//
//  Q8ServerAPIHelper.h
//  Q8outlets
//
//  Created by Lesya Verbina on 1/31/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "Q8Coupon.h"
#import "Q8CouponsCount.h"
#import "Q8BusinessNotification.h"
#import "Q8EndUserSetting.h"

#define SERVER_MAIN_URL_BASE @"https://api.q8outlets.com/"
//#define SERVER_MAIN_URL_BASE @"http://api.q8outlets.wlab.tech/"

#define SERVER_MAIN_URL [NSString stringWithFormat:@"%@v1", SERVER_MAIN_URL_BASE]

#define WRONG_AUTHORIZATION_ERROR_CODE  401

#define PAGINATION_TOTAL_COUNT @"X-Pagination-Total-Count"

#define COUPON_ACTIVE_COUNT     @"Count-Active"
#define COUPON_ARCHIVED_COUNT   @"Count-Archived"
#define COUPON_EXPIRED_COUNT    @"Count-Expired"
#define COUPON_USED_COUNT       @"Count-Used"

#define REQUEST_REGISTRATION_EMAIL  @"login/signup"
#define REQUEST_LOGIN_EMAIL         @"login"
#define REQUEST_FORGOT_PASSWORD     @"login/reset-password-request"
#define REQUEST_FB_AUTHORIZE        @"login/login-social"
#define REQUEST_SEND_NEW_PASSWORD	@"login/set-new-password"

// **
// Client sections
#define REQUEST_ACTIVATE_VIP            @"users/vip-code"
#define REQUEST_UPDATE_USER             @"users/user-update"
#define REQUEST_DEVICE_TOKEN(userID)    [NSString stringWithFormat:@"users/%@/device",userID]
#define REQUEST_SETTINGS(userID)        [NSString stringWithFormat:@"users/%@/settings",userID]
#define REQUEST_SOCIAL(userID)          [NSString stringWithFormat:@"users/%@/social",userID]

// Offers
#define REQUEST_APPLY_TO_OFFER                  @"coupon"
#define REQUEST_GET_OFFER_BY_LOCATION           @"offer/by-location"
#define REQUEST_GET_ACTIVE_BUSINESS_OFFER       @"offer/self-business-offers"
#define REQUEST_GET_OFFER_STATISTICS            @"offer/statistics"
#define REQUEST_GET_OFFER_NOTIFICATIONS         @"offer/notifications"
#define REQUEST_UPDATE_OFFER_LIKE(offerID)      [NSString stringWithFormat:@"offer/%@/like",offerID]
#define REQUEST_UPDATE_OFFER_FOLLOW(offerID)    [NSString stringWithFormat:@"offer/%@/follow",offerID]
#define REQUEST_GET_OFFER(offerID)              [NSString stringWithFormat:@"offer/%@",offerID]
#define REQUEST_REPORT_OFFER(offerID)           [NSString stringWithFormat:@"offer/%@/report",offerID]
// Bussines
#define REQUEST_GET_BUSINESS  @"businesses"
#define REQUEST_GET_BUSINESS_OFFERS(merchantID)     [NSString stringWithFormat:@"businesses/%@",merchantID]
#define REQUEST_UPDATE_BUSINESS_FOLLOW(merchantID)  [NSString stringWithFormat:@"businesses/%@/follow",merchantID]
#define REQUEST_REPORT_BUSINESS(businessID)         [NSString stringWithFormat:@"businesses/%@/report",businessID]
// Coupons
#define REQUEST_GET_MY_COUPONS              @"coupon/self-coupons"
#define REQUEST_PATH_COUPON_ID(couponID)    [NSString stringWithFormat:@"coupon/%@",couponID]
#define REQUEST_APPLY_COUPON                @"coupon/apply"
#define REQUEST_GET_COUPON_BY_TOKEN         @"coupon/by-token"
// Location
#define REQUEST_GET_MERCHANTS_BY_LOCATION   @"location"

@interface Q8ServerAPIHelper :  AFHTTPSessionManager

+ (Q8ServerAPIHelper *)sharedHelper;

#pragma mark - Authorization

- (void)registerWithEmail:(NSString *)email
                     name:(NSString *)name
                 password:(NSString *)password
             onCompletion:(void (^)(BOOL success))completion
                   sender:(UIViewController *)sender;

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
                  role:(Q8UserRole)role
          onCompletion:(void (^)(BOOL success))completion
                sender:(UIViewController *)sender;

- (void)authorizeUserWithFBOnCompletion:(void (^)(BOOL success, BOOL isRegistration))completion
                                         sender:(UIViewController *)sender;

- (void)authorizeUserWithGoogleToken:(NSString *)googleToken
                        onCompletion:(void (^)(BOOL success, BOOL isRegistration))completion
                              sender:(UIViewController *)sender;

- (void)authorizeUserWithTwitterToken:(NSString *)twitterToken
                        twitterSecret:(NSString *)twitterSecret
                         onCompletion:(void (^)(BOOL success, BOOL isRegistration))completion
                               sender:(UIViewController *)sender;

- (void)authorizeUserWithInstagramToken:(NSString *)instagramToken
                          onCompletion:(void (^)(BOOL success, BOOL isRegistration))completion
                                sender:(UIViewController *)sender;

#pragma mark - User info

- (void)sendForgotPasswordToEmail:(NSString *)email
                     onCompletion:(void (^)(BOOL success))completion
                           sender:(UIViewController *)sender;

- (void)sendNewPassword:(NSString*)password
			  withToken:(NSString*)token
		   onCompletion:(void (^)(BOOL))completion
				 sender:(UIViewController*)sender;

- (void)activateVIPCode:(NSString *)code
           onCompletion:(void (^)(BOOL success, BOOL codeIsInvalid))completion
                 sender:(UIViewController *)sender;

- (void)getCurrentUserInfoOnCompletion:(void (^)(BOOL success))completion
                                sender:(UIViewController *)sender;

- (void)saveDeviceToken:(NSString *)deviceToken
           onCompletion:(void (^)(BOOL success))completion
                 sender:(UIViewController *)sender;

- (void)removeDeviceToken:(NSString *)deviceToken
             onCompletion:(void (^)(BOOL success))completion
                   sender:(UIViewController *)sender;

- (void)linkFBOnCompletion:(void (^)(BOOL success))completion
                    sender:(UIViewController *)sender;

- (void)linkGoogleToken:(NSString *)googleToken
           onCompletion:(void (^)(BOOL success))completion
                 sender:(UIViewController *)sender;

- (void)linkTwitterToken:(NSString *)twitterToken
           twitterSecret:(NSString *)twitterSecret
            onCompletion:(void (^)(BOOL success))completion
                  sender:(UIViewController *)sender;

- (void)linkInstagramToken:(NSString *)instagramToken
               onCompletion:(void (^)(BOOL success))completion
                     sender:(UIViewController *)sender;

- (void)disconnectUserSocialNetwork:(NSString *)userID
                       onCompletion:(void (^)(BOOL success))completion
                             sender:(UIViewController *)sender;

- (void)updateUserEmail:(NSString *)email name:(NSString *)name password:(NSString *)password
           onCompletion:(void (^)(BOOL success))completion
                 sender:(UIViewController *)sender;

- (void)getUserSettings:(NSString *)userID
           onCompletion:(void (^)(BOOL success, Q8EndUserSetting *userSetting))completion
                 sender:(UIViewController *)sender;

- (void)saveEndUserSettings:(NSString *)userID
                   settings:(Q8EndUserSetting *)userSetting
               onCompletion:(void (^)(BOOL success))completion
                     sender:(UIViewController *)sender;

#pragma mark - Offers

- (void)applyToOffer:(Q8Offer *)offer
       onCompletions:(void (^)(BOOL success, Q8Coupon *coupon))completion
              sender:(UIViewController *)sender;

- (void)getOffersByCategoryID:(NSString *)categoryID
                   businessID:(NSString *)businessID
                         text:(NSString *)text
                     latitude:(NSString *)latitude
                   longtitude:(NSString *)longtitude
                         page:(NSInteger)page
               searchByfollow:(BOOL)searchByfollow
                 onCompletion:(void (^)(BOOL success, NSArray <Q8Offer *> *offersArray, NSInteger offersCount, NSString *searchText))completion
                       sender:(UIViewController *)sender;

- (void)getActiveOffersForBusiness:(NSString *)businessID
                              page:(NSInteger)page
                     onCompletions:(void (^)(BOOL success, NSArray <Q8Offer *> *offersArray, NSInteger offersCount))completion
                            sender:(UIViewController *)sender;

- (void)getStatisticsByOfferID:(NSString *)offerID
                 onCompletions:(void (^)(BOOL success, NSInteger appliedCount, NSInteger usedCount, NSInteger expiredCount))completion
                        sender:(UIViewController *)sender;

- (void)getOfferNotification:(NSInteger)page
               onCompletions:(void (^)(BOOL success, NSArray <Q8BusinessNotification *> *notificationArray, NSInteger notificationCount))completion
                      sender:(UIViewController *)sender;

- (void)getOfferByOfferID:(NSString *)offerID
               onCompletions:(void (^)(BOOL success, Q8Offer *offer))completion
                      sender:(UIViewController *)sender;

- (void)addLikeToOffer:(NSString *)offerID
          onCompletion:(void (^)(BOOL success))completion
                sender:(UIViewController *)sender;

- (void)removeLikeFromOffer:(NSString *)offerID
          onCompletion:(void (^)(BOOL success))completion
                sender:(UIViewController *)sender;

- (void)followOffer:(NSString *)offerID
          onCompletion:(void (^)(BOOL success))completion
                sender:(UIViewController *)sender;

- (void)removeFollowFromOffer:(NSString *)offerID
       onCompletion:(void (^)(BOOL success))completion
             sender:(UIViewController *)sender;

- (void)reportOffer:(NSString *)offerID
     reportCategory:(NSInteger)categoryID
                 onCompletion:(void (^)(BOOL success))completion
                       sender:(UIViewController *)sender;

#pragma mark - Business

- (void)getMerchantsByCategoryID:(NSString *)categoryID
                 text:(NSString *)text
              latitude:(NSString *)latitude
            longtitude:(NSString *)longtitude
                  page:(NSInteger)page
        searchByfollow:(BOOL)searchByfollow
          onCompletion:(void (^)(BOOL success, NSArray <Q8Merchant *> *, NSInteger merchantTotalCount, NSString *searchText))completion
                sender:(UIViewController *)sender;

- (void)getMerchantAndOffers:(NSString *)merchantID
             onCompletion:(void (^)(BOOL success, Q8Merchant *merchant, NSArray <Q8Offer *> *))completion
                   sender:(UIViewController *)sender;

- (void)followMerchant:(NSString *)merchantID
          onCompletion:(void (^)(BOOL success))completion
                sender:(UIViewController *)sender;

- (void)removeFollowFromMerchant:(NSString *)merchantID
                    onCompletion:(void (^)(BOOL success))completion
                          sender:(UIViewController *)sender;

- (void)reportBusiness:(NSString *)businessID
        reportCategory:(NSInteger)categoryID
          onCompletion:(void (^)(BOOL success))completion
                sender:(UIViewController *)sender;

#pragma mark - Coupons

- (void)getCouponsByCategory:(NSString *)category
                        page:(NSInteger)page
                onCompletion:(void (^)(BOOL success, NSArray <Q8Coupon *> *, Q8CouponsCount *couponsCount, NSInteger couponsTotalCount))completion
                      sender:(UIViewController *)sender;

- (void)updateCoupon:(NSInteger)couponID
             archive:(BOOL)archive
        onCompletion:(void (^)(BOOL success))completion
              sender:(UIViewController *)sender;

- (void)deleteCoupon:(NSInteger)couponID
        onCompletion:(void (^)(BOOL success))completion
              sender:(UIViewController *)sender;

- (void)applyCouponToken:(NSString *)couponToken
        onCompletion:(void (^)(BOOL success, NSString *offerID, Q8CouponStatus couponStatus))completion
              sender:(UIViewController *)sender;

- (void)getCouponByCouponToken:(NSString *)couponToken
            onCompletion:(void (^)(BOOL success, Q8Coupon *coupon))completion
                  sender:(UIViewController *)sender;

#pragma mark - Location

- (void)getMerchantsByLocation:(NSString *)latitude
                    longtitude:(NSString *)longtitude
                    searchtext:(NSString *)text
                  onCompletion:(void (^)(BOOL success, NSArray <Q8Merchant *> *, NSString *searchText))completion
                        sender:(UIViewController *)sender;

- (void)getMerchantLocationsByLatitude:(NSString *)latitude
                  longtitude:(NSString *)longtitude
                        page:(NSInteger)page
                onCompletion:(void (^)(BOOL success, NSArray <Q8MerchantLocation *> *, NSInteger merchantTotalCount))completion
                      sender:(UIViewController *)sender;

@end
