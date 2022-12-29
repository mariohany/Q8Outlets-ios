//
//  Q8SettingsTableViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8SettingsTableViewController.h"
#import "Q8VipCodeTableViewController.h"
#import "Q8EditProfileTableViewController.h"
#import "Q8NotificationSettingsTableViewController.h"

@interface Q8SettingsTableViewController () <WLAlertControllerDelegate>
@end

enum {
    Q8SectionProfile,
    Q8SectionNotifications
};

@implementation Q8SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    [WLVisualHelper templatizeImageViews:self.iconImageViews withColor:Q8RedDefaultColor];
    [self setupImageAssessory];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData]; // Reload number of rows so VIP can be hidden
}

- (void)setupImageAssessory {
    for (UIImageView *imageView in self.arrowImageViews) {
        UIImage* image = [UIImage imageNamed:NSLocalizedString(@"icon_arrow_right", nil)];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [imageView setImage:image];
        [imageView setTintColor:[UIColor blackColor]];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == Q8SectionProfile) {
        [self moveToProfile];
    } else if (indexPath.section == Q8SectionNotifications) {
        [self moveToNotifications];
    }
}

#pragma mark - Alert controller delegate

- (void)didUseActionAtIndex:(NSInteger)actionIndex ofAlertController:(UIAlertController *)alertController withReason:(NSInteger)alertControllerReason {
    if ((alertControllerReason == Q8ReasonConfirmLogout) || (alertControllerReason == Q8ReasonConfirmLogout_ar)) {
        // Logout
        [Q8CurrentUser logOutAndMoveToLoginScreen:YES];
    }
}

#pragma mark - Button actions

- (IBAction)logoutButtonAction:(id)sender {
    [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonConfirmLogout] delegate:self];
}

#pragma mark - Navigation

- (void)moveToProfile {
    UIViewController *editProfileController = [WLUtilityHelper viewControllerFromStoryboard:@"Client" controllerIdentifier:Q8EditProfileControllerIdentifier];
    [self.navigationController pushViewController:editProfileController animated:YES];
}

- (void)moveToNotifications {
    UIViewController *notificationSettingsController = [WLUtilityHelper viewControllerFromStoryboard:@"Client" controllerIdentifier:Q8NotificationSettingsControllerIdentifier];
    [self.navigationController pushViewController:notificationSettingsController animated:YES];
}

@end
