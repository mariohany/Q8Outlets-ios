//
//  Q8EndUserSetting.h
//  Q8outlets
//
//  Created by GlebGamaun on 02.03.17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Q8EndUserSetting : NSObject

@property (nonatomic, assign) BOOL isOfferEmailsEnabled;
@property (nonatomic, assign) BOOL isOfferPushesEnabled;
@property (nonatomic, assign) BOOL isMerchantEmailsEnabled;
@property (nonatomic, assign) BOOL isMerchantPushesEnabled;
@property (nonatomic, assign) BOOL isCouponsEmailsEnabled;
@property (nonatomic, assign) BOOL isCouponsPushesEnabled;

+ (Q8EndUserSetting *)endUserSettingFromDictionary:(NSDictionary *)settingDictionary;

@end
