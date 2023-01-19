//
//  Q8AuthorizationTableViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8AuthorizationTableViewController.h"
#import "Q8ForgotPasswordTableViewController.h"
#import "Q8VipCodeTableViewController.h"
#import "Q8SocialLoginHelper.h"

@interface Q8AuthorizationTableViewController ()
@end

enum {
    Q8SectionTabs,
    
    Q8SectionNetworksHeader,
    Q8SectionNetworks,
    
    Q8SectionEmailHeader,
    Q8SectionName,
    Q8SectionEmail,
    Q8SectionPassword,
    Q8SectionConfirm,
    Q8SectionTerms,
    
    Q8SectionDoneButton,
    Q8SectionForgotButton,
    Q8SectionMercantTip,
};

@implementation Q8AuthorizationTableViewController {
    BOOL acceptsTerms;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    [WLVisualHelper addBorderToViews:[self.socialNetworkButtonViews arrayByAddingObject:self.doneButton] color:Q8RedDefaultColor width:2.0f];
    [WLVisualHelper roundThisViews:[self.socialNetworkButtonViews arrayByAddingObject:self.doneButton] radius:Q8CornerRadius];
    for (UIView *networkView in self.socialNetworkButtonViews) {
        networkView.backgroundColor = [UIColor clearColor]; // remove gray from xib
    }
    [WLVisualHelper templatizeImageView:self.termsImageView withColor:Q8RedDefaultColor];
    [WLVisualHelper templatizeImageViews:self.socialNetworkImageViews withColor:Q8RedDefaultColor];
    
    self.facebookLabel.text     = NSLocalizedString(@"Autorize with Facebook", nil);
    self.googleLabel.text       = NSLocalizedString(@"Autorize with Google", nil);
    self.instagramLabel.text    = NSLocalizedString(@"Autorize with Instagram", nil);

    [WLVisualHelper makeTextBold:NSLocalizedString(@"Facebook", nil) inLabel:self.facebookLabel];
    [WLVisualHelper makeTextBold:NSLocalizedString(@"Google", nil) inLabel:self.googleLabel];
    [WLVisualHelper makeTextBold:NSLocalizedString(@"Instagram", nil) inLabel:self.instagramLabel];
    [WLVisualHelper makeTextBold:NSLocalizedString(@"End User License Agreement", nil) inLabel:self.termsLabel];
    
    // Change link color
    NSMutableAttributedString *attributtedTip = [[NSMutableAttributedString alloc] initWithString:self.merchantTipLabel.text];
    [attributtedTip setColorForText:NSLocalizedString(@"q8outlets.com", nil) withColor:Q8OrangeColor];
     self.merchantTipLabel.attributedText = attributtedTip;
    
    // Doesn't accept by default
    acceptsTerms = NO;
    [self reloadTermsRepresentation];
    
    [self reloadRegistrationModeRepresentation];
}

#pragma mark - Controller logic

- (void)reloadTermsRepresentation {
    // Either checkmark or empty
    UIImage *checkboxImage = [[UIImage imageNamed:(acceptsTerms ?
                                                   @"icon_checkmark_checked" : @"icon_checkmark_empty")]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.termsImageView.image = checkboxImage;
}

- (void)reloadRegistrationModeRepresentation {
    // Move "selected tab" green view under correct tab, change tab color
    [self.registrationTabButton setTitleColor:self.isRegistration ? Q8RedDefaultColor : [UIColor grayColor] forState:UIControlStateNormal];
    [self.loginTabButton setTitleColor:!self.isRegistration ? Q8RedDefaultColor : [UIColor grayColor] forState:UIControlStateNormal];
    [UIView animateWithDuration:0.2f animations:^{
        self.centerActiveTabOnRegistrationConstraint.priority = self.isRegistration ? 990 : 100;
        [self.activeTabBottomView.superview layoutIfNeeded];
    }];
    
    // Done button title changes
    [self.doneButton setTitle:self.isRegistration ? NSLocalizedString(@"REGISTER", nil) : NSLocalizedString(@"SIGN IN", nil) forState:UIControlStateNormal];
    self.formHeaderLabel.text = self.isRegistration ? NSLocalizedString(@"REGISTER WITH EMAIL", nil) : NSLocalizedString(@"LOGIN WITH EMAIL", nil);
    
    [self.tableView reloadData];
    [self reloadFilledFieldsRepresentation];
}

- (void)reloadFilledFieldsRepresentation {
    UIColor *nameColor = self.nameTextField.text.length ? Q8OrangeColor : Q8LightGrayColor;
    self.nameSeparatorView.backgroundColor = nameColor;
    [WLVisualHelper templatizeImageView:self.nameImageView withColor:nameColor];
    
    UIColor *emailColor = self.emailTextField.text.length ? Q8OrangeColor : Q8LightGrayColor;
    self.emailSeparatorView.backgroundColor = emailColor;
    [WLVisualHelper templatizeImageView:self.emailImageView withColor:emailColor];
    
    UIColor *passColor = self.passwordTextField.text.length ? Q8OrangeColor : Q8LightGrayColor;
    self.passSeparatorView.backgroundColor = passColor;
    [WLVisualHelper templatizeImageView:self.passImageView withColor:passColor];
    
    UIColor *confirmColor = self.confirmTextField.text.length ? Q8OrangeColor : Q8LightGrayColor;
    self.confirmSeparatorView.backgroundColor = confirmColor;
    [WLVisualHelper templatizeImageView:self.confirmImageView withColor:confirmColor];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)isEnteredDataValid {
    if (self.isRegistration && !self.nameTextField.text.length) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonNameRequired]];
        return NO;
    } else if (!self.emailTextField.text.length) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonEmailRequired]];
        return NO;
    } else if (![WLUtilityHelper isEmailValid:self.emailTextField.text]) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonEmailInvalid]];
        return NO;
    } else if (!self.passwordTextField.text.length) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonPasswordRequired]];
        return NO;
    } else if (self.isRegistration &&
              self.passwordTextField.text.length < 6) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonPasswordTooShort]];
        return NO;
    } else if (self.isRegistration &&
               ![self.passwordTextField.text isEqualToString:self.confirmTextField.text]) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonPasswordConfirmationInvalid]];
        return NO;
    } else if (self.isRegistration && !acceptsTerms) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonAcceptTerms]];
        return NO;
    }
    return YES;
}

#pragma mark - Text field delegate

- (IBAction)textFieldDidChange:(id)sender {
    [self reloadFilledFieldsRepresentation];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Text field navigation
    // Name - email - password - confirm
    if (textField == self.nameTextField) {
        [self.emailTextField becomeFirstResponder];
    } else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField && self.isRegistration) {
        [self.confirmTextField becomeFirstResponder];
    } else {
        [self hideKeyboard];
    }
    return NO;
}

#pragma mark - Table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case Q8SectionTabs:
            // No registration/login choice for business
            if (self.authorizationRole == Q8UserRoleBusiness) return 0;
            break;
            
        case Q8SectionNetworks:
            // No networks except "Facebook" for business
            if (self.authorizationRole == Q8UserRoleBusiness) return 1;
            break;
            
        case Q8SectionName:
        case Q8SectionConfirm:
        case Q8SectionTerms:
            // No registration fields on login
            if (!self.isRegistration) return 0;
            break;
            
        case Q8SectionForgotButton:
            // No "forgot" on registration
            if (self.isRegistration) return 0;
            break;
            
        case Q8SectionMercantTip:
            // No merchant tip for clients
            if (self.authorizationRole == Q8UserRoleClient) return 0;
            break;
            
        default:
            break;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

#pragma mark - Button actions

- (IBAction)registrationTabButtonAction:(id)sender {
    self.isRegistration = YES;
    [self reloadRegistrationModeRepresentation];
}

- (IBAction)loginTabButtonAction:(id)sender {
    self.isRegistration = NO;
    [self reloadRegistrationModeRepresentation];
}

- (IBAction)facebookButtonAction:(id)sender {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [Q8SocialLoginHelper loginFacebookOnCompletion:^(BOOL success) {
        if (!success) {
            [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
            self.view.userInteractionEnabled = YES;
        } else {
            [[Q8ServerAPIHelper sharedHelper] authorizeUserWithFBOnCompletion:^(BOOL success, BOOL isRegistration) {
                [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
                self.view.userInteractionEnabled = YES;
                if (success) {
                    [self moveToAuthorizedPart];
                }
            } sender:self];
        }
    } sender:self];
}

- (IBAction)googleButtonAction:(id)sender {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [[Q8SocialLoginHelper sharedHelper] loginGoogleOnCompletion:^(BOOL success, NSString *googleToken) {
        if (!success) {
            [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
            self.view.userInteractionEnabled = YES;
        } else {
            [[Q8ServerAPIHelper sharedHelper] authorizeUserWithGoogleToken:googleToken
                                                              onCompletion:^(BOOL success, BOOL isRegistration) {
                                                                  [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
                                                                  self.view.userInteractionEnabled = YES;
                                                                  if (success) {
                                                                      [self moveToAuthorizedPart];
                                                                  }
                                                              } sender:self];
        }
    } sender:self];
}

- (IBAction)instagramButtonAction:(id)sender {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [[Q8SocialLoginHelper sharedHelper] loginInstagramOnCompletion:^(BOOL success, NSString *instagramToken) {
        if (!success) {
            [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
            self.view.userInteractionEnabled = YES;
        } else {
            [[Q8ServerAPIHelper sharedHelper] authorizeUserWithInstagramToken:instagramToken onCompletion:^(BOOL success, BOOL isRegistration) {
                [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
                self.view.userInteractionEnabled = YES;
                if (success) {
                    [self moveToAuthorizedPart];
                }
            } sender:self];
        }
    } sender:self];
}

- (IBAction)termsButtonAction:(id)sender {
    acceptsTerms = !acceptsTerms;
    [self reloadTermsRepresentation];
}

- (IBAction)doneButtonAction:(id)sender {
    [self hideKeyboard];
    if ([self isEnteredDataValid]) {
        // If data is valid, authorize
        if (self.isRegistration) {
            [self registerWithEmailOnServerAndMove];
        } else {
            [self loginWithEmailOnServerAndMove];
        }
    }
}
- (IBAction)forgotPasswordButtonAction:(id)sender {
    [self moveToForgotPassword];
}

#pragma mark - Navigation

- (void)moveToForgotPassword {
    Q8ForgotPasswordTableViewController *forgotPassword = (Q8ForgotPasswordTableViewController *)[WLUtilityHelper viewControllerFromSBWithIdentifier:Q8ForgotPasswordControllerIdentifier];
    forgotPassword.sentEmail = self.emailTextField.text;
    [self.navigationController pushViewController:forgotPassword animated:YES];
}

- (void)moveToAuthorizedPart {
    if ([Q8CurrentUser userRole] == Q8UserRoleClient) {
        if (self.authorizationRole != Q8UserRoleClient) {
            // If role mismatch between account and selected role
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonLoginRoleIsClient]];
        }
        [Q8NavigationManager moveToClientHome];
    } else {
        if (self.authorizationRole != Q8UserRoleBusiness) {
            // If role mismatch between account and selected role
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonLoginRoleIsMerchant]];
        }
        [Q8NavigationManager moveToBusinessHome];
    }
}

#pragma mark - Server requests

- (void)loginWithEmailOnServerAndMove {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [[Q8ServerAPIHelper sharedHelper] loginWithEmail:self.emailTextField.text
                                            password:self.passwordTextField.text
                                                role:self.authorizationRole
                                        onCompletion:^(BOOL success) {
                                            [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
                                            self.view.userInteractionEnabled = YES;
                                            if (success) {
                                                // Move to home or VIP for non-vip clients
                                                [self moveToAuthorizedPart];
                                            }
                                        } sender:self];
}

- (void)registerWithEmailOnServerAndMove {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [[Q8ServerAPIHelper sharedHelper] registerWithEmail:self.emailTextField.text
                                                   name:self.nameTextField.text
                                               password:self.passwordTextField.text
                                           onCompletion:^(BOOL success) {
                                               [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
                                               self.view.userInteractionEnabled = YES;
                                               
                                               if (success) {
                                                   [self moveToAuthorizedPart];
                                               }
                                           } sender:self];
}

@end
