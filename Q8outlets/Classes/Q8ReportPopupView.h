//
//  Q8ReportPopupView.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/14/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8PopupView.h"

typedef enum {
    Q8ReportModeMerchant,
    Q8ReportModeOffer
} Q8ReportMode;

static NSString * const Q8ReportPopupXibName = @"Q8ReportPopupView";

@interface Q8ReportPopupView : Q8PopupView

@property (nonatomic, assign) Q8ReportMode reportMode;

@property (weak, nonatomic) IBOutlet UIView *triangleView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *reportHeaderLabel;

@property (weak, nonatomic) IBOutlet UIButton *offensiveButton;
@property (weak, nonatomic) IBOutlet UIButton *spamButton;
@property (weak, nonatomic) IBOutlet UIButton *cheatingButton;

- (void)setupForMode:(Q8ReportMode)reportMode;
+ (Q8ReportPopupView *)viewFromXib;

@end
