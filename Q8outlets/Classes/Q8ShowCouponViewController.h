//
//  Q8ShowCouponViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/6/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Q8Coupon.h"

static NSString * const Q8ShowCouponControllerIdentifier = @"Q8ShowCoupon";

@interface Q8ShowCouponViewController : UIViewController

@property (nonatomic, strong) Q8Coupon *coupon;

@property (nonatomic, weak) IBOutlet UILabel        *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView    *qrCodeImageView;
@property (nonatomic, weak) IBOutlet UIButton       *archiveButton;
@property (nonatomic, weak) IBOutlet UILabel        *couponTokenLabel;

- (IBAction)archiveButtonAction:(id)sender;

@end
