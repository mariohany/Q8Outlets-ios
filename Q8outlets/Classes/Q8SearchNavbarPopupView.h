//
//  Q8SearchNavbarPopupView.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/9/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8PopupView.h"

static NSString * const Q8SearchNavbarPopupXibName = @"Q8SearchNavbarPopupView";

@interface Q8SearchNavbarPopupView : Q8PopupView

@property (weak, nonatomic) IBOutlet UIView *triangleView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *checkboxImageView;
@property (weak, nonatomic) IBOutlet UIButton *checkboxButton;

+ (Q8SearchNavbarPopupView *)viewFromXib;

@end
