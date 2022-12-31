//
//  Q8TourSlideCollectionViewCell.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8TourSlideCollectionViewCell.h"

@implementation Q8TourSlideCollectionViewCell

- (void)setupForSlide:(Q8Slide *)slide {
    self.slideTitleLabel.text = slide.slideTitle;
    self.slideTextLabel.text = slide.slideText;
    self.slideImageView.image = [UIImage imageNamed:slide.slideImageName];
    
    // If this is "register/login" slide, show buttons
    self.slideImageView.hidden = slide.isAutorizationPrompt;
    self.logoImageView.hidden = !slide.isAutorizationPrompt;
    self.registerButton.hidden = !slide.isAutorizationPrompt;
    self.loginLabel.hidden = !slide.isAutorizationPrompt;
    self.loginButton.hidden = !slide.isAutorizationPrompt;
}

@end
