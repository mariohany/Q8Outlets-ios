//
//  Q8DynamicLinkHelper.m
//  Q8outlets
//
//  Created by GlebGamaun on 28.03.17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8DynamicLinkHelper.h"

#define COUPON_TOKEN_KEY @"couponToken"
#define RESET_PASSWORD_TOKEN_KEY @"token"

@implementation Q8DynamicLinkHelper

+ (void)handleDynamicLinkQuery:(NSString *)query {
    if (!query) {
        return;
    }
	NSArray *parameters = [[NSArray alloc] init];
	if ([query containsString:@"&"])
    	parameters = [query componentsSeparatedByString:@"&"];
	else
		parameters = [query componentsSeparatedByString:@"?"];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    [parameters enumerateObjectsUsingBlock:^(NSString *parameter, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *keyValue = [parameter componentsSeparatedByString:@"="];
        if ([keyValue count]>1) {
            [dictionary addEntriesFromDictionary:@{keyValue[0] : keyValue[1]}];
        }
    }];
	
    [Q8DynamicLinkHelper handleValueFromDynamicLinkDictionary:dictionary];
}

+ (void)handleValueFromDynamicLinkDictionary:(NSDictionary *)dict {
    if (dict[COUPON_TOKEN_KEY]) {
        NSString *couponToken = dict[COUPON_TOKEN_KEY];
        [[Q8ServerAPIHelper sharedHelper] getCouponByCouponToken:couponToken onCompletion:^(BOOL success, Q8Coupon *coupon) {
            if (success) {
                 [Q8NavigationManager moveToClientCoupon:coupon];
            }           
        } sender:nil];
    }
	else if (dict[RESET_PASSWORD_TOKEN_KEY]) {
		[Q8NavigationManager moveToResetPasswordWithToken:dict[RESET_PASSWORD_TOKEN_KEY]];
	}
}

@end
