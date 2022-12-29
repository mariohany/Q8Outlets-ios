//
//  Q8TextField.m
//  Q8outlets
//
//  Created by GlebGamaun on 16.02.17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8TextField.h"

@implementation Q8TextField

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupClearButton];
}

- (void)setupClearButton {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_cross"]];
    [WLVisualHelper templatizeImageView:imageView withColor:Q8LightGrayColor];
    
    UIButton *clearBtn = [self valueForKey:@"_clearButton"];
    clearBtn.contentMode = UIViewContentModeScaleAspectFit;
    
    [clearBtn setImage:imageView.image forState:UIControlStateNormal];
    [clearBtn setImage:imageView.image forState:UIControlStateHighlighted];
}

@end
