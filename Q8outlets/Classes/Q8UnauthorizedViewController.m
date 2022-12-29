//
//  Q8UnauthorizedViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8UnauthorizedViewController.h"
#import "Q8TourViewController.h"
#import "Q8AuthorizationTableViewController.h"

@interface Q8UnauthorizedViewController ()

@end

@implementation Q8UnauthorizedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Disable back swipe
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBarHidden = YES;
    
    // Logout just in case
    [Q8CurrentUser logOutAndMoveToLoginScreen:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBarHidden = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Button actions

- (IBAction)tourButtonAction:(id)sender {
    [self moveToTour];
}
- (IBAction)registerButtonAction:(id)sender {
    [self moveToAuthorizationAs:Q8UserRoleClient registration:YES];
}
- (IBAction)clientLoginButtonAction:(id)sender {
    [self moveToAuthorizationAs:Q8UserRoleClient registration:NO];
}
- (IBAction)businessLoginButtonAction:(id)sender {
    [self moveToAuthorizationAs:Q8UserRoleBusiness registration:NO];
}

#pragma mark - Navigation

- (void)moveToTour {
    UIViewController *tourController = [WLUtilityHelper viewControllerFromSBWithIdentifier:Q8TourControllerIdentifier];
    [self.navigationController pushViewController:tourController animated:YES];
}

- (void)moveToAuthorizationAs:(Q8UserRole)userRole registration:(BOOL)registration {
    Q8AuthorizationTableViewController *authorizationController = (Q8AuthorizationTableViewController *)[WLUtilityHelper viewControllerFromSBWithIdentifier:Q8AuthorizationControllerIdentifier];
    authorizationController.isRegistration = registration;
    authorizationController.authorizationRole = userRole;
    
    [self.navigationController pushViewController:authorizationController animated:YES];
}

@end
