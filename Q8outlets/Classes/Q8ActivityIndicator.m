//
//  Q8ActivityIndicator.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8ActivityIndicator.h"

@implementation Q8ActivityIndicator

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated {
    if ([self HUDForView:view]) {
        Q8ActivityIndicator *hud = (Q8ActivityIndicator *)[self HUDForView:view];
        return hud;
    }
    
    Q8ActivityIndicator *hud = [super showHUDAddedTo:view animated:animated];
    hud.bezelView.color = [UIColor clearColor];
    hud.backgroundColor = [UIColor clearColor];
    hud.tintColor = [UIColor grayColor];
    
    return hud;
}

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated {
    while ([self HUDForView:view]) {
        [super hideHUDForView:view animated:animated];
    }
    
    return YES;
}

@end
