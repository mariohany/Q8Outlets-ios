//
//  Q8CouponsNavbarPopupView.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/9/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8CouponsNavbarPopupView.h"

@implementation Q8CouponsNavbarPopupView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [WLVisualHelper roundThisView:self.containerView radius:10.0f];
    [WLVisualHelper transformViewtoTriange:self.triangleView facingDirection:WLDirectionUp triangleColor:[UIColor whiteColor]];
    [WLVisualHelper addDropShadowToView:self hardShadow:NO shouldRasterize:YES];
    [WLVisualHelper templatizeImageViews:@[self.activeCheckboxImageView, self.archivedCheckboxImageView, self.usedCheckboxImageView, self.expiredCheckboxImageView] withColor:Q8RedDefaultColor];
}

+ (Q8CouponsNavbarPopupView *)viewFromXib {
    Q8CouponsNavbarPopupView *view;
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:Q8CouponsNavbarPopupXibName owner:nil options:nil];
    for (id currentView in nibViews) {
        if ([currentView isKindOfClass:[UIView class]]) {
            view = (Q8CouponsNavbarPopupView *)currentView;
            break;
        }
    }
    return view;
}

@end
