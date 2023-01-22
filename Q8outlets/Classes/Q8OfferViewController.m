//
//  Q8OfferViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/6/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8OfferViewController.h"
#import "Q8Coupon.h"
#import "Q8VipCodeTableViewController.h"
#import "Q8ReportPopupView.h"
#import "Q8ShareHelper.h"

@interface Q8OfferViewController () <WLAlertControllerDelegate>
@end

@implementation Q8OfferViewController {
    Q8Coupon *appliedCoupon;
    
    BOOL descriptionExpanded;
    
    // Timer to count down
    NSTimer *oneSecondTimer;
    
    // Report popup
    Q8ReportPopupView *navbarPopup;
    BOOL navbarPopupOpened;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Addd "report" popup
    navbarPopup = [Q8ReportPopupView viewFromXib];
    CGRect popupFrame = navbarPopup.frame;
    popupFrame.origin.x = [UIScreen mainScreen].bounds.size.width - popupFrame.size.width - 4.0f;
    navbarPopup.frame = popupFrame;
    [navbarPopup setupForMode:Q8ReportModeOffer];
    // Targets for report buttons
    [navbarPopup.offensiveButton addTarget:self action:@selector(offensiveReportPopupButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navbarPopup.spamButton addTarget:self action:@selector(spamReportPopupButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navbarPopup.cheatingButton addTarget:self action:@selector(cheatingReportPopupButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navbarPopup];
    [self toggleReportPopupHidden:YES animated:NO];
    
    // Visual setup
    [WLVisualHelper fullRoundThisView:self.couponsContainerView];
    [WLVisualHelper roundThisView:self.applyButton radius:Q8CornerRadius];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = Q8DarkOrangeColor.CGColor;
    bottomBorder.borderWidth = 2;
    bottomBorder.frame = CGRectMake(-bottomBorder.borderWidth,
                                    -bottomBorder.borderWidth,
                                    CGRectGetWidth(self.applyButton.frame)+2*bottomBorder.borderWidth,
                                    CGRectGetHeight(self.applyButton.frame)+bottomBorder.borderWidth);
    [self.applyButton.layer addSublayer:bottomBorder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.offer.isNeedLoadOfferData) {
        [self loadOfferFromServer];
    } else {
        [self setupControllerAppearance];
    }
    
    [self startCountdown];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopCountdown];
}

#pragma mark - Controller logic

- (void)setupControllerAppearance {
    // Register for "follow" and "like" notifications
    [Q8NotificationHelper addObserver:self toOfferChange:self.offer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Populate offer data
        [self populateOfferRepresentation];
    });
    // Expanded by default
    descriptionExpanded = YES;
    [self reloadDescriptionRepresentation];
}

- (void)populateOfferRepresentation {
    [Q8ImageHelper setOfferPromoImage:self.offer intoImageView:self.promoImageView];
    self.couponsCountLabel.text = self.offer.availableCoupons > 100 ?  NSLocalizedString(@"100+", nil) : [NSString stringWithFormat:@"%ld", (long)self.offer.availableCoupons];
    self.couponsTextLabel.text = self.offer.availableCoupons == 1 ? NSLocalizedString(@"coupon", nil) : NSLocalizedString(@"coupons", nil);
    UIColor *couponsColor = self.offer.availableCoupons ? Q8RedDefaultColor : [UIColor grayColor];
    if (self.offer.availableCoupons == 1) {
        couponsColor = Q8OrangeColor;
    }
    self.couponsCountLabel.textColor = couponsColor;
    
    self.merchantTitleLabel.text = self.offer.merchant.title;
    self.addressLabel.text = [self.offer.locations count] ? [self.offer.locations firstObject].locationAddress : @"";
    self.distanceLabel.text = [self.offer.locations count] ? [self.offer.locations firstObject].distanceString : @"";
    
    self.likesLabel.text = [NSString stringWithFormat:@"%ld", (long)self.offer.likesCount];
    self.likeImageView.image = [UIImage imageNamed:(self.offer.isLiked ?
                                                    @"icon_heart_full" :
                                                    @"icon_heart_empty")];
    self.followImageView.image = [UIImage imageNamed:(self.offer.isFollowed ?
                                                      @"icon_star_full" :
                                                      @"icon_star_empty")];
    
    self.titleLabel.text = self.offer.title;
    self.descriptionLabel.text = self.offer.offerDescription;
    
    self.noCouponsView.hidden = self.offer.availableCoupons || self.offer.isApplied;
    self.codeContainerView.hidden = !self.offer.isApplied || !appliedCoupon;
    self.applyButton.alpha = self.offer.isApplied ? 0.5f : 1.0f;
    self.applyButton.userInteractionEnabled = !self.offer.isApplied;
    [self.applyButton setTitle:self.offer.isApplied ? NSLocalizedString(@"ALREADY APPLIED", nil) : NSLocalizedString(@"APPLY FOR THIS OFFER", nil) forState:UIControlStateNormal];
    
    self.qrCodeImageView.image = [appliedCoupon qrCodeImageOfSize:self.qrCodeImageView.bounds.size];
    self.expirationCoundownLabel.text = appliedCoupon.expirationCountdownString;
}

#pragma mark - Report popup logic

- (void)toggleReportPopupHidden:(BOOL)hidden animated:(BOOL)animated {
    [navbarPopup popupHidden:hidden animated:animated];
}

#pragma mark - Countdown logic

- (void)startCountdown {
    // Start one second timer to count down
    __weak typeof(self) weakSelf = self;
    oneSecondTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:weakSelf selector:@selector(reloadCouponsCountdown) userInfo:nil repeats:YES];
    oneSecondTimer.tolerance = 0.1f;
}

- (void)stopCountdown {
    [oneSecondTimer invalidate];
}

- (void)reloadCouponsCountdown {
    self.expirationCoundownLabel.text = appliedCoupon.expirationCountdownString;
}

#pragma mark - Collapsable desctiption

- (void)reloadDescriptionRepresentation {
    if (self.offer.offerDescription.length > 0) {
        self.detailsIconImageView.image = [UIImage imageNamed:descriptionExpanded ? @"icon_arrow_down" : @"icon_arrow_right"];
        
        self.descriptionLabel.alpha = descriptionExpanded ? 0.0f : 1.0f;
        if (descriptionExpanded) {
            self.descriptionLabel.hidden = NO;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.descriptionLabel.alpha = self->descriptionExpanded ? 1.0f : 0.0f;
            self.skipDescriptionConstraint.priority = self->descriptionExpanded ? 100 : 990;
            [self.descriptionLabel.superview.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (!self->descriptionExpanded) {
                self.descriptionLabel.hidden = YES;
            }
        }];
    } else {
        self.detailsLabel.hidden = YES;
        self.detailsIconImageView.hidden = YES;
    }
}

#pragma mark - Offer change notification observer

- (void)myOfferLikeStatusChanged:(BOOL)likeStatus {
    self.offer.isLiked = likeStatus;
    if (self.offer.isLiked) {
        self.offer.likesCount++;
    } else {
        self.offer.likesCount--;
    }
    [self populateOfferRepresentation];
}

- (void)myOfferFollowStatusChanged:(BOOL)followStatus {
    self.offer.isFollowed = followStatus;
    [self populateOfferRepresentation];
}

- (void)myOfferCouponApplied:(BOOL)isApplied {
    self.offer.isApplied = YES;
    self.offer.availableCoupons--;
    [self populateOfferRepresentation];
}

#pragma mark - Alert controller delegate

- (void)didUseActionAtIndex:(NSInteger)actionIndex ofAlertController:(UIAlertController *)alertController withReason:(NSInteger)alertControllerReason {
    if ((alertControllerReason==Q8ReasonVIPNeeded) || (alertControllerReason==Q8ReasonVIPNeeded_ar)) {
        // "Enter VIP code" tapped
        [Q8NavigationManager moveToVipCodeCanSkip:NO moveToHome:NO];
    } else if ((alertControllerReason == Q8ReasonShareOption) || (alertControllerReason == Q8ReasonShareOption_ar)) {
        if (actionIndex == 0) {
            [Q8ShareHelper shareOfferToFacebook:self.offer];
        } else if (actionIndex == 1) {
            [Q8ShareHelper shareOfferToOther:self.offer];
        }
    }
}

#pragma mark - Button actions

- (IBAction)likeButtonAction:(id)sender {
    [self likeOfferOnServer];
}
- (IBAction)shareButtonAction:(id)sender {
    [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonShareOption] delegate:self];
}
- (IBAction)followButtonAction:(id)sender {
    [self followOfferOnServer];
}

- (IBAction)detailsButtonAction:(id)sender {
    // Show/hide description
    descriptionExpanded = !descriptionExpanded;
    [self reloadDescriptionRepresentation];
}
- (IBAction)applyButtonAction:(id)sender {
    if ([Q8CurrentUser isVIP]) {
        [self applyToOfferOnServer];
    } else {
        // If not VIP user - can't apply, show popup
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonVIPNeeded] delegate:self];
    }
}
- (IBAction)saveButtonAction:(id)sender {
    // Button does nothing, customer asked to add it anyway
    self.saveButton.hidden = YES;
}

- (IBAction)flagButtonAction:(id)sender {
    navbarPopupOpened = !navbarPopupOpened;
    [self toggleReportPopupHidden:!navbarPopupOpened animated:YES];
}

#pragma mark - Popup button actions

- (void)offensiveReportPopupButtonAction {
    navbarPopupOpened = NO;
    [self toggleReportPopupHidden:YES animated:YES];
    [self reportOfferOnServer:Q8ReportReasonOffensive];
}

- (void)spamReportPopupButtonAction {
    navbarPopupOpened = NO;
    [self toggleReportPopupHidden:YES animated:YES];
    [self reportOfferOnServer:Q8ReportReasonSpam];
}

- (void)cheatingReportPopupButtonAction {
    navbarPopupOpened = NO;
    [self toggleReportPopupHidden:YES animated:YES];
    [self reportOfferOnServer:Q8ReportReasonCheating];
}

#pragma mark - Server requests

- (void)loadOfferFromServer {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] getOfferByOfferID:self.offer.offerId onCompletions:^(BOOL success, Q8Offer *offer) {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
        if (success) {
            strongify(self);
            self.offer = offer;
            [self setupControllerAppearance];
        }
        
    } sender:nil];
}


- (void)likeOfferOnServer {
    self.offer.isCanLike = NO;
    weakify(self);
    if (self.offer.isLiked) {
        [[Q8ServerAPIHelper sharedHelper] removeLikeFromOffer:self.offer.offerId onCompletion:^(BOOL success) {
            strongify(self);
            self.offer.isCanLike = YES;
            if (!success) {
                [Q8NotificationHelper postOfferLikeChangeNotification:self.offer likeStatus:!self.offer.isLiked];
            }
            
        } sender:self];
    } else {
        [[Q8ServerAPIHelper sharedHelper] addLikeToOffer:self.offer.offerId onCompletion:^(BOOL success) {
            strongify(self);
            self.offer.isCanLike = YES;
            if (!success) {
                [Q8NotificationHelper postOfferLikeChangeNotification:self.offer likeStatus:!self.offer.isLiked];
            }
        } sender:self];
    }
    [Q8NotificationHelper postOfferLikeChangeNotification:self.offer likeStatus:!self.offer.isLiked];
}

- (void)followOfferOnServer {
    self.offer.isCanFollow = NO;
    weakify(self);
    if (self.offer.isFollowed) {
        [[Q8ServerAPIHelper sharedHelper] removeFollowFromOffer:self.offer.offerId onCompletion:^(BOOL success) {
            strongify(self);
            self.offer.isCanFollow = YES;
            if (!success) {
                [Q8NotificationHelper postOfferFollowChangeNotification:self.offer followStatus:!self.offer.isFollowed];
            }
        } sender:self];
    } else {
        [[Q8ServerAPIHelper sharedHelper] followOffer:self.offer.offerId onCompletion:^(BOOL success) {
            strongify(self);
            self.offer.isCanFollow = YES;
            if (!success) {
                [Q8NotificationHelper postOfferFollowChangeNotification:self.offer followStatus:!self.offer.isFollowed];
            }
        } sender:self];
    }
    [Q8NotificationHelper postOfferFollowChangeNotification:self.offer followStatus:!self.offer.isFollowed];
}


- (void)applyToOfferOnServer {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] applyToOffer:self.offer onCompletions:^(BOOL success, Q8Coupon *coupon) {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
        if (success) {
            strongify(self);
            self->appliedCoupon = coupon;
            [Q8NotificationHelper postOfferCouponCountChangeNotification:self.offer couponApplied:YES];
            
            self->descriptionExpanded = NO;
            [self reloadDescriptionRepresentation];
        }
    } sender:self];
}

- (void)reportOfferOnServer:(Q8ReportReason)reportReason {
    [[Q8ServerAPIHelper sharedHelper] reportOffer:self.offer.offerId reportCategory:reportReason onCompletion:^(BOOL success) {
        if (success) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonReportSuccess]];
        }
    } sender:self];    
}

@end
