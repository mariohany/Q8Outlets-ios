//
//  Q8MerchantAnnotation.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/7/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8MerchantAnnotation.h"
#import "Q8MerchantAnnotationView.h"

@implementation Q8MerchantAnnotation  {
    UIImageView *pinBackingImageView;
    UIImageView *categoryIconImageView;
    
    BOOL isSelected;
}

- (id)initWithMerchant:(Q8Merchant *)merchant {
    if (self = [super init]) {
        self.coordinate = merchant.currentLocation.locationCoordinate;
        self.merchant = merchant;
        self.position = self.coordinate;
        self.iconView = [self annotationView];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected {
    isSelected = selected;
    
    pinBackingImageView.tintColor = isSelected ? Q8OrangeColor : Q8RedDefaultColor;
    categoryIconImageView.backgroundColor = isSelected ? Q8OrangeColor : Q8RedDefaultColor;
}

- (Q8MerchantAnnotationView *)annotationView {
    Q8MerchantAnnotationView *annotationView = [[Q8MerchantAnnotationView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    annotationView.bounds = CGRectMake(0, 0, 50.0f, 50.0f);
    annotationView.backgroundColor = [UIColor clearColor];
    CGPoint annotationViewCenter = CGPointMake(annotationView.bounds.size.width/2.0f, annotationView.bounds.size.height/2.0f);
    
    // Making subviews sort of reuseable
    if (!pinBackingImageView) {
        pinBackingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        pinBackingImageView.contentMode = UIViewContentModeScaleAspectFit;
        pinBackingImageView.backgroundColor = [UIColor clearColor];
        pinBackingImageView.image = [[UIImage imageNamed:@"icon_map_pin"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    pinBackingImageView.tintColor = isSelected ? Q8OrangeColor : Q8RedDefaultColor;
    [pinBackingImageView removeFromSuperview];
    [annotationView addSubview:pinBackingImageView];
    pinBackingImageView.center = annotationViewCenter;
    annotationView.pinImageView = pinBackingImageView;
    
    // Making subviews sort of reuseable
    if (!categoryIconImageView) {
        categoryIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        categoryIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        categoryIconImageView.tintColor = [UIColor whiteColor];
    }
    categoryIconImageView.backgroundColor = isSelected ? Q8OrangeColor : Q8RedDefaultColor;
    CGPoint categoryIconCenter = pinBackingImageView.center;
    categoryIconCenter.y -= 4.0f;
    [categoryIconImageView removeFromSuperview];
    [annotationView addSubview:categoryIconImageView];
    categoryIconImageView.center = categoryIconCenter;
    categoryIconImageView.image = [self.merchant.category.categoryIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    annotationView.categoryIconImageView = categoryIconImageView;
    
    return annotationView;
}

@end
