//
//  Q8NotificationSettingsTableViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/7/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8NotificationSettingsTableViewController.h"

@interface Q8NotificationSettingsTableViewController ()
@end

@implementation Q8NotificationSettingsTableViewController {
    // Track if values changed
    BOOL offerEmails;
    BOOL offerPushes;
    BOOL merchantEmails;
    BOOL merchantPushes;
    BOOL couponsEmails;
    BOOL couponsPushes;
    
    Q8EndUserSetting *userSettings;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    [WLVisualHelper templatizeImageViews:@[self.offerEmailImageView, self.offerPushImageView, self.merchantEmailImageView, self.merchantPushImageView, self.couponsEmailImageView, self.couponsPushImageView] withColor:Q8RedDefaultColor];
    [self.backBarButton setImage:[UIImage imageNamed:NSLocalizedString(@"icon_arrow_left", nil)]];
    
    // Populate checkboxes
    [self populateCurrentSettingsRepresentation];
    
    [self loadSettingsFromServer];
}

#pragma mark - Controller logic

- (void)populateCurrentSettingsRepresentation {
    UIImage *checkedImage = [[UIImage imageNamed:@"icon_checkmark_checked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *emptyImage = [[UIImage imageNamed:@"icon_checkmark_empty"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.offerEmailImageView.image = offerEmails ? checkedImage : emptyImage;
    self.offerPushImageView.image = offerPushes ? checkedImage : emptyImage;
    self.merchantEmailImageView.image = merchantEmails ? checkedImage : emptyImage;
    self.merchantPushImageView.image = merchantPushes ? checkedImage : emptyImage;
    self.couponsEmailImageView.image = couponsEmails ? checkedImage : emptyImage;
    self.couponsPushImageView.image = couponsPushes ? checkedImage : emptyImage;
}

#pragma mark - Button actions

- (IBAction)offerEmailButtonAction:(id)sender {
    offerEmails = !offerEmails;
    [self populateCurrentSettingsRepresentation];
}
- (IBAction)offerPushButtonAction:(id)sender {
    offerPushes = !offerPushes;
    [self populateCurrentSettingsRepresentation];
}
- (IBAction)merchantEmailButtonAction:(id)sender {
    merchantEmails = !merchantEmails;
    [self populateCurrentSettingsRepresentation];
}
- (IBAction)merchantPushButtonAction:(id)sender {
    merchantPushes = !merchantPushes;
    [self populateCurrentSettingsRepresentation];
}
- (IBAction)couponsEmailButtonAction:(id)sender {
    couponsEmails = !couponsEmails;
    [self populateCurrentSettingsRepresentation];
}
- (IBAction)couponsPushButtonAction:(id)sender {
    couponsPushes = !couponsPushes;
    [self populateCurrentSettingsRepresentation];
}

- (IBAction)backButtonAction:(id)sender {
    BOOL settingsChanged = (offerEmails != userSettings.isOfferEmailsEnabled ||
                            offerPushes != userSettings.isOfferPushesEnabled ||
                            merchantEmails != userSettings.isMerchantEmailsEnabled ||
                            merchantPushes != userSettings.isMerchantPushesEnabled ||
                            couponsEmails != userSettings.isCouponsEmailsEnabled ||
                            couponsPushes != userSettings.isCouponsPushesEnabled);
    if (settingsChanged) {
        [self saveNotificationSettingsOnServerAndMoveBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Server requests

- (void)loadSettingsFromServer {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    [[Q8ServerAPIHelper sharedHelper] getUserSettings:[Q8CurrentUser userId] onCompletion:^(BOOL success, Q8EndUserSetting *endUserSettings) {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
        self.view.userInteractionEnabled = YES;
        
        userSettings = endUserSettings;
        
        offerEmails = userSettings.isOfferEmailsEnabled;
        offerPushes = userSettings.isOfferPushesEnabled;
        merchantEmails = userSettings.isMerchantEmailsEnabled;
        merchantPushes = userSettings.isMerchantPushesEnabled;
        couponsEmails = userSettings.isCouponsEmailsEnabled;
        couponsPushes = userSettings.isCouponsPushesEnabled;
        
        // Populate checkboxes
        [self populateCurrentSettingsRepresentation];
    } sender:self];
}

- (void)saveNotificationSettingsOnServerAndMoveBack {
    userSettings.isOfferEmailsEnabled = offerEmails;
    userSettings.isOfferPushesEnabled = offerPushes;
    userSettings.isMerchantEmailsEnabled = merchantEmails;
    userSettings.isMerchantPushesEnabled = merchantPushes;
    userSettings.isCouponsEmailsEnabled = couponsEmails;
    userSettings.isCouponsPushesEnabled = couponsPushes;
    
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    [[Q8ServerAPIHelper sharedHelper] saveEndUserSettings:[Q8CurrentUser userId] settings:userSettings onCompletion:^(BOOL success) {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
        self.view.userInteractionEnabled = YES;
        
        [self.navigationController popViewControllerAnimated:YES];
    } sender:self];
}

@end
