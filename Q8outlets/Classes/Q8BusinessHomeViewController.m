//
//  Q8BusinessHomeViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8BusinessHomeViewController.h"
#import "Q8ScanCodeViewController.h"
#import "Q8BusinessNotificationsViewController.h"
#import "Q8BusinessOffersViewController.h"
#import "Q8BusinessStatsTableViewController.h"
#import "Q8BusinessLocationViewController.h"

@interface Q8BusinessHomeViewController () <WLAlertControllerDelegate>

@end

@implementation Q8BusinessHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // hide statistic view if userRole == Q8UserRoleModerator
    if ([Q8CurrentUser userRole] == Q8UserRoleModerator) {
        UIView *statisticView = [self.buttonViews lastObject];
        statisticView.hidden = YES;
    }
    
    // Visual setup
    
//    self.emptyLocationView.hidden = NO;

    [WLVisualHelper roundThisViews:self.buttonViews radius:Q8CornerRadius];
    [WLVisualHelper addBorderToViews:self.buttonViews color:Q8RedDefaultColor width:2.0f];
    [WLVisualHelper templatizeImageViews:self.iconImageViews withColor:Q8RedDefaultColor];
    for (UIView *view in self.buttonViews) {
        view.backgroundColor = [UIColor clearColor]; // remove gray from storyboard
    }
    
    
    NSString *strText = NSLocalizedString(@"Please open q8outlets.com in your browser and add at least one business location", nil);
    NSRange rangeColor = [strText rangeOfString:@"q8outlets.com"];
    NSMutableAttributedString *mutAttrTextViewString = [[NSMutableAttributedString alloc] initWithString:strText];
    [mutAttrTextViewString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255/255.0 green:165/255.0 blue:0 alpha:1] range:rangeColor];
    [self.emptyLocationLabel setAttributedText:mutAttrTextViewString];
    
    [self.scanImageView setImage:[UIImage imageNamed:NSLocalizedString(@"picture_scan", nil)]];
    
    [WLVisualHelper templatizeImageView:self.merchantLocationArrowImageView withColor:Q8LightGrayColor];
    
    // If userLocation == nil need select location
    if (![Q8CurrentUser userLocation]) {
        self.navigationItem.leftBarButtonItem = nil;
        self.emptyLocationView.hidden = NO;
        [self moveToLocations];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([Q8CurrentUser userLocation]) {
        self.emptyLocationView.hidden = YES;
        if (self.navigationItem.leftBarButtonItem == nil) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_bell"] style:UIBarButtonItemStylePlain target:self action:@selector(notificationsButtonAction:)];
        }
    }
    //set user location text
    self.merchantLocationLabel.text = [Q8CurrentUser userLocation];
}

#pragma mark - Alert controller delegate

- (void)didUseActionAtIndex:(NSInteger)actionIndex ofAlertController:(UIAlertController *)alertController withReason:(NSInteger)alertControllerReason {
    if ((alertControllerReason == Q8ReasonConfirmLogout) || (alertControllerReason == Q8ReasonConfirmLogout_ar)) {
        // Logout
        [Q8CurrentUser logOutAndMoveToLoginScreen:YES];
    } else if ((alertControllerReason == Q8ReasonCameraAccessRequired) || (alertControllerReason == Q8ReasonCameraAccessRequired_ar)) {
        // Open settings as per camera access alert
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - Button actions

- (IBAction)scanButtonAction:(id)sender {
    [WLUtilityHelper getCameraPermissionOnCompletion:^(BOOL success) {
        if (!success) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonCameraAccessRequired] delegate:self];
        } else {
            [self moveToScan];
        }
    }];
}

- (IBAction)logoutButtonAction:(id)sender {
    [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonConfirmLogout] delegate:self];
}

- (IBAction)notificationsButtonAction:(id)sender {
    [self moveToNotifications];
}

- (IBAction)offersButtonAction:(id)sender {
    [self moveToOffers];
}

- (IBAction)statsButtonAction:(id)sender {
    [self moveToStats];
}

- (IBAction)locationButtonAction:(id)sender {
    [self moveToLocations];
}

#pragma mark - Navigation

- (void)moveToScan {
    UIViewController *scanController = [WLUtilityHelper viewControllerFromStoryboard:@"Business" controllerIdentifier:Q8ScanCodeControllerIdentifier];
    [self.navigationController pushViewController:scanController animated:YES];
}

- (void)moveToNotifications {
    UIViewController *notificationsController = [WLUtilityHelper viewControllerFromStoryboard:@"Business" controllerIdentifier:Q8BusinessNotificationsControllerIdentifier];
    [self.navigationController pushViewController:notificationsController animated:YES];
}

- (void)moveToOffers {
    UIViewController *offersController = [WLUtilityHelper viewControllerFromStoryboard:@"Business" controllerIdentifier:Q8BusinessOffersControllerIdentifier];
    [self.navigationController pushViewController:offersController animated:YES];
}

- (void)moveToStats {
    UIViewController *statsController = [WLUtilityHelper viewControllerFromStoryboard:@"Business" controllerIdentifier:Q8BusinessStatsControllerIdentifier];
    [self.navigationController pushViewController:statsController animated:YES];
}

- (void)moveToLocations {
    UIViewController *statsController = [WLUtilityHelper viewControllerFromStoryboard:@"Business" controllerIdentifier:Q8BusinessLocationControllerIdentifier];
    [self.navigationController pushViewController:statsController animated:YES];
}

@end
