//
//  Q8ShareHelper.h
//  Q8outlets
//
//  Created by GlebGamaun on 07.03.17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Q8ShareHelper : NSObject

+ (void)shareOfferToFacebook:(Q8Offer *)offer;
+ (void)shareOfferToOther:(Q8Offer *)offer;

@end
