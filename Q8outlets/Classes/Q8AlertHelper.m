//
//  Q8AlertHelper.m
//  Q8outlets
//
//  Created by Alexander Bakuta on 17/08/2017.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8AlertHelper.h"

@implementation Q8AlertHelper

+ (NSInteger) convertToString:(AlertKeys)reason {
    NSInteger result = 0;
    
    switch(reason) {
        case  Q8ReasonServerFailure:
        {
            NSString* str = NSLocalizedString(@"1", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonNoInternet:
        {
            NSString* str = NSLocalizedString(@"2", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonSessionExpired:
        {
            NSString* str = NSLocalizedString(@"3", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonNameRequired:
        {
            NSString* str = NSLocalizedString(@"4", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonEmailRequired:
        {
            NSString* str = NSLocalizedString(@"5", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonPasswordRequired:
        {
            NSString* str = NSLocalizedString(@"6", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonPasswordConfirmationInvalid:
        {
            NSString* str = NSLocalizedString(@"7", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonInvalidCredentials:
        {
            NSString* str = NSLocalizedString(@"8", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonEmailTaken:
        {
            NSString* str = NSLocalizedString(@"9", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonEmailInvalid:
        {
            NSString* str = NSLocalizedString(@"10", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonAcceptTerms:
        {
            NSString* str = NSLocalizedString(@"11", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonCodeRequired:
        {
            NSString* str = NSLocalizedString(@"12", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonCodeInvalid:
        {
            NSString* str = NSLocalizedString(@"13", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonPasswordResetSuccess:
        {
            NSString* str = NSLocalizedString(@"14", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case Q8ReasonConfirmLogout:
        {
            NSString* str = NSLocalizedString(@"15", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonVIPSuccess:
        {
            NSString* str = NSLocalizedString(@"16", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonCameraAccessRequired:
        {
            NSString* str = NSLocalizedString(@"17", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonEmailNotFound:
        {
            NSString* str = NSLocalizedString(@"18", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonConfitmCouponDelete:
        {
            NSString* str = NSLocalizedString(@"19", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonVIPNeeded:
        {
            NSString* str = NSLocalizedString(@"20", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonPasswordTooShort:
        {
            NSString* str = NSLocalizedString(@"21", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonLoginRoleIsMerchant:
        {
            NSString* str = NSLocalizedString(@"22", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonLoginRoleIsClient:
        {
            NSString* str = NSLocalizedString(@"23", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonCantUnlinkNoEmail:
        {
            NSString* str = NSLocalizedString(@"24", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;        }
        case  Q8ReasonCantUnlinkNoPass:
        {
            NSString* str = NSLocalizedString(@"25", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonSocialNetworkEmailTaken:
        {
            NSString* str = NSLocalizedString(@"26", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonCouponExpired:
        {
            NSString* str = NSLocalizedString(@"27", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonReportSuccess:
        {
            NSString* str = NSLocalizedString(@"28", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonSearchNoResults:
        {
            NSString* str = NSLocalizedString(@"29", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonOfferReachedMaxAmountCoupons:
        {
            NSString* str = NSLocalizedString(@"30", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonSocialAccountUsed:
        {
            NSString* str = NSLocalizedString(@"31", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonShareOption:
        {
            NSString* str = NSLocalizedString(@"32", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
        case  Q8ReasonCouponInvalidCredentials:
        {
            NSString* str = NSLocalizedString(@"33", nil);
            result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
            break;
        }
		case Q8ReasonPasswordDidReset:
		{
			NSString* str = NSLocalizedString(@"34", nil);
			result = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
			break;
		}

        default:
            result = 999;
    }
    return result;
}

@end


