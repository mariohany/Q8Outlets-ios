//
//  Q8ReportPopupView.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/14/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8ReportPopupView.h"

@implementation Q8ReportPopupView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [WLVisualHelper roundThisView:self.containerView radius:10.0f];
    [WLVisualHelper transformViewtoTriange:self.triangleView facingDirection:WLDirectionUp triangleColor:[UIColor whiteColor]];
    [WLVisualHelper addDropShadowToView:self hardShadow:NO shouldRasterize:YES];
}

- (void)setupForMode:(Q8ReportMode)reportMode {
    self.reportMode = reportMode;
    self.reportHeaderLabel.text = reportMode==Q8ReportModeOffer ? NSLocalizedString(@"REPORT THIS OFFER", nil) : NSLocalizedString(@"REPORT THIS MERCHANT", nil);
}

+ (Q8ReportPopupView *)viewFromXib {
    Q8ReportPopupView *view;
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:Q8ReportPopupXibName owner:nil options:nil];
    for (id currentView in nibViews) {
        if ([currentView isKindOfClass:[UIView class]]) {
            view = (Q8ReportPopupView *)currentView;
            break;
        }
    }
    return view;
}


@end
