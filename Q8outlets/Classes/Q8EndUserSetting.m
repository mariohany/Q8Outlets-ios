//
//  Q8EndUserSetting.m
//  Q8outlets
//
//  Created by GlebGamaun on 02.03.17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8EndUserSetting.h"

@implementation Q8EndUserSetting

+ (Q8EndUserSetting *)endUserSettingFromDictionary:(NSDictionary *)settingDictionary; {
    Q8EndUserSetting *userSettings = [Q8EndUserSetting new];
    
    userSettings.isOfferEmailsEnabled = [settingDictionary[@"email_near_offer"] boolValue];
    userSettings.isOfferPushesEnabled = [settingDictionary[@"push_near_offer"] boolValue];
    userSettings.isMerchantEmailsEnabled = [settingDictionary[@"email_followed_offer"] boolValue];
    userSettings.isMerchantPushesEnabled = [settingDictionary[@"push_followed_offer"] boolValue];
    userSettings.isCouponsEmailsEnabled = [settingDictionary[@"email_coupon_available"] boolValue];
    userSettings.isCouponsPushesEnabled = [settingDictionary[@"push_coupon_available"] boolValue];
    
    return userSettings;
}

@end
