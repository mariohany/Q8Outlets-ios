//
//  Q8ShowCouponViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/6/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8ShowCouponViewController.h"

@interface Q8ShowCouponViewController ()
@end

@implementation Q8ShowCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    [WLVisualHelper addPaddingToImageInButton:self.archiveButton spacing:12.0f];
    
    // Populate coupon data
    [self populateCouponRepresentation];
    
    // Schedule action to close coupon if expired
    weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self.coupon.expirationDate timeIntervalSinceNow] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        strongify(self);
        [self couponExpired];
    });
}

#pragma mark - Controller logic

- (void)populateCouponRepresentation {
    self.titleLabel.text = self.coupon.offer.title;
    self.qrCodeImageView.image = [self.coupon qrCodeImageOfSize:self.qrCodeImageView.bounds.size];
    [self.archiveButton setTitle:self.coupon.isArchived ? NSLocalizedString(@"RESTORE", nil) : NSLocalizedString(@"ARCHIVE", nil) forState:UIControlStateNormal];
    [self.archiveButton setImage:[UIImage imageNamed:self.coupon.isArchived ? @"icon_unarchive" : @"icon_archive"] forState:UIControlStateNormal];
    self.archiveButton.hidden = self.coupon.isUsed || self.coupon.isExpired;
    self.couponTokenLabel.text = self.coupon.couponToken;
}

- (void)couponExpired {
    // Move back and alert that coupon expired
    [self.navigationController popViewControllerAnimated:YES];
    [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonCouponExpired]];
}

#pragma mark - Button actions

- (IBAction)archiveButtonAction:(id)sender {
    // Move this coupon from/to archive
    self.coupon.isArchived ? [self sendArchiveCouponOnServer:NO] : [self sendArchiveCouponOnServer:YES];
}

#pragma mark - Server requests

- (void)sendArchiveCouponOnServer:(BOOL)archive {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    [[Q8ServerAPIHelper sharedHelper] updateCoupon:self.coupon.couponID archive:archive onCompletion:^(BOOL success) {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
        self.coupon.isArchived = archive;
        [self populateCouponRepresentation];
    } sender:self];
}

@end
