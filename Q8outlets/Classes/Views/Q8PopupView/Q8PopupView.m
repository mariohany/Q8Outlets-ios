//
//  Q8PopupView.m
//  Q8outlets
//
//  Created by GlebGamaun on 16.02.17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8PopupView.h"

@implementation Q8PopupView

- (void)popupHidden:(BOOL)hidden animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self popupHidden:hidden];
        } completion:nil];
    } else {
        [self popupHidden:hidden];
    }    
}

- (void)popupHidden:(BOOL)hidden {
    self.alpha = hidden ? 0.0 : 1.0;
}

@end
