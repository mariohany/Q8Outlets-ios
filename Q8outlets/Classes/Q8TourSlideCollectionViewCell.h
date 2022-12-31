//
//  Q8TourSlideCollectionViewCell.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Q8Slide.h"

static NSString * const Q8TourSlideCellIdentifier = @"Q8TourSlideCell";

@interface Q8TourSlideCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *slideTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *slideTextLabel;
@property (nonatomic, weak) IBOutlet UIImageView *slideImageView;

@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;
@property (nonatomic, weak) IBOutlet UILabel *loginLabel;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;

- (void)setupForSlide:(Q8Slide *)slide;

@end
