//
//  Q8SearchNavbarPopupView.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/9/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8SearchNavbarPopupView.h"

@implementation Q8SearchNavbarPopupView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [WLVisualHelper roundThisView:self.containerView radius:10.0f];
    [WLVisualHelper transformViewtoTriange:self.triangleView facingDirection:WLDirectionUp triangleColor:[UIColor whiteColor]];
    [WLVisualHelper addDropShadowToView:self hardShadow:NO shouldRasterize:YES];
    [WLVisualHelper templatizeImageView:self.checkboxImageView withColor:Q8RedDefaultColor];
}

+ (Q8SearchNavbarPopupView *)viewFromXib {
    Q8SearchNavbarPopupView *view;
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:Q8SearchNavbarPopupXibName owner:nil options:nil];
    for (id currentView in nibViews) {
        if ([currentView isKindOfClass:[UIView class]]) {
            view = (Q8SearchNavbarPopupView *)currentView;
            break;
        }
    }
    return view;
}
@end
