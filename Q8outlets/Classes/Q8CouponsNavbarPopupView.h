//
//  Q8CouponsNavbarPopupView.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/9/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Q8PopupView.h"

static NSString * const Q8CouponsNavbarPopupXibName = @"Q8CouponsNavbarPopupView";

@interface Q8CouponsNavbarPopupView : Q8PopupView

@property (weak, nonatomic) IBOutlet UIView *triangleView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UILabel *activeCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activeCheckboxImageView;
@property (weak, nonatomic) IBOutlet UIButton *activeCheckboxButton;
@property (weak, nonatomic) IBOutlet UILabel *archivedCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *archivedCheckboxImageView;
@property (weak, nonatomic) IBOutlet UIButton *archivedCheckboxButton;
@property (weak, nonatomic) IBOutlet UILabel *usedCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *usedCheckboxImageView;
@property (weak, nonatomic) IBOutlet UIButton *usedCheckboxButton;
@property (weak, nonatomic) IBOutlet UILabel *expiredCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *expiredCheckboxImageView;
@property (weak, nonatomic) IBOutlet UIButton *expiredCheckboxButton;

+ (Q8CouponsNavbarPopupView *)viewFromXib;

@end
