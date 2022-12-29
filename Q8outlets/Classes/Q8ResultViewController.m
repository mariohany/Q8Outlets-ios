//
//  Q8ResultViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8ResultViewController.h"

@interface Q8ResultViewController ()

@end

@implementation Q8ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    self.resultImageView.hidden = YES;
    self.resultLabel.hidden = YES;
    self.offerContainerView.hidden = YES;
    
    // Try to redeem
    [self redeemCouponOnServer];
}

#pragma mark - Controller logic

- (void)populateScanResultWithOffer:(Q8Offer *)offer couponStatus:(Q8CouponStatus)status {
    self.resultImageView.hidden = NO;
    self.resultLabel.hidden = NO;
    
    if (!offer && status == Q8CouponStatusWrongLocation) {
        // Offer was not found - coupon is invalid
        self.resultImageView.image = [UIImage imageNamed:@"icon_cross_big"];
        [WLVisualHelper templatizeImageView:self.resultImageView withColor:Q8OrangeColor];
        
        self.resultLabel.text = NSLocalizedString(@"Wrong location", nil);
        self.resultLabel.textColor = Q8OrangeColor;
    } else if (!offer && status == Q8CouponStatusError) {
        // Offer was not found - coupon is invalid
        self.resultImageView.image = [UIImage imageNamed:@"icon_cross_big"];
        [WLVisualHelper templatizeImageView:self.resultImageView withColor:Q8OrangeColor];
        
        self.resultLabel.text = NSLocalizedString(@"Invalid code", nil);
        self.resultLabel.textColor = Q8OrangeColor;
    } else if (status == Q8CouponStatusActive ||
               status == Q8CouponStatusArchived) {
        // Valid coupon, can redeem
        self.resultImageView.image = [UIImage imageNamed:@"icon_check_big"];
        [WLVisualHelper templatizeImageView:self.resultImageView withColor:[UIColor blackColor]];
        
        self.resultLabel.text = NSLocalizedString(@"Valid code", nil);
        self.resultLabel.textColor = [UIColor blackColor];
    } else if (status == Q8CouponStatusExpired) {
        // Coupon expired
        self.resultImageView.image = [UIImage imageNamed:@"icon_cross_big"];
        [WLVisualHelper templatizeImageView:self.resultImageView withColor:Q8OrangeColor];
        
        self.resultLabel.text = NSLocalizedString(@"Expired code", nil);
        self.resultLabel.textColor = Q8OrangeColor;
    } else if (status == Q8CouponStatusUsed) {
        // Already used
        self.resultImageView.image = [UIImage imageNamed:@"icon_cross_big"];
        [WLVisualHelper templatizeImageView:self.resultImageView withColor:Q8OrangeColor];
        
        self.resultLabel.text = NSLocalizedString(@"Used code", nil);
        self.resultLabel.textColor = Q8OrangeColor;
    }
    
    [self populateOfferRepresentation:offer];
}

- (void)populateOfferRepresentation:(Q8Offer *)offer {
    self.offerContainerView.hidden = offer ? NO : YES;
    self.offerTitleLabel.text = offer.title;
    self.offerDescriptionTextView.text = offer.offerDescription;
}

#pragma mark - Server requests

- (void)redeemCouponOnServer {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    weakify(self)
    [[Q8ServerAPIHelper sharedHelper] applyCouponToken:self.couponQrToken onCompletion:^(BOOL success, NSString *offerID, Q8CouponStatus couponStatus) {
        strongify(self);
        if (!success) {
            [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
            self.view.userInteractionEnabled = YES;
            [self populateScanResultWithOffer:nil couponStatus:couponStatus];
        } else {
            [[Q8ServerAPIHelper sharedHelper] getOfferByOfferID:offerID onCompletions:^(BOOL success, Q8Offer *offer) {
                [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
                self.view.userInteractionEnabled = YES;
                [self populateScanResultWithOffer:offer couponStatus:Q8CouponStatusActive];
                
            } sender:nil];
        }
    } sender:self];
}

@end
