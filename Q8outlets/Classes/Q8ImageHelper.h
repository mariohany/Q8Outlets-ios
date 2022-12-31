//
//  Q8ImageHelper.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/3/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Q8Merchant.h"
#import "Q8Offer.h"

@interface Q8ImageHelper : NSObject

+ (void)setMerchantLogo:(Q8Merchant *)merchant
          intoImageView:(UIImageView *)imageView;

+ (void)setMerchantBackgroundImage:(Q8Merchant *)merchant
                     intoImageView:(UIImageView *)imageView;

+ (void)setOfferPromoImage:(Q8Offer *)offer
             intoImageView:(UIImageView *)imageView;
@end
