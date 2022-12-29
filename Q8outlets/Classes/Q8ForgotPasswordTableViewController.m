//
//  Q8ForgotPasswordTableViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8ForgotPasswordTableViewController.h"

@interface Q8ForgotPasswordTableViewController ()

@end

@implementation Q8ForgotPasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    [WLVisualHelper addBorderToView:self.doneButton color:Q8RedDefaultColor width:2.0f];
    [WLVisualHelper roundThisView:self.doneButton radius:Q8CornerRadius];
    self.emailTextField.text = self.sentEmail ?: @"";
    
    [self reloadFilledFieldsRepresentation];
}

#pragma mark - Controller logic

- (BOOL)isEnteredDataValid {
    if (!self.emailTextField.text.length) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonEmailRequired]];
        return NO;
    } else if (![WLUtilityHelper isEmailValid:self.emailTextField.text]) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonEmailInvalid]];
        return NO;
    }
    return YES;
}

- (void)reloadFilledFieldsRepresentation {
    UIColor *emailColor = self.emailTextField.text.length ? Q8OrangeColor : Q8LightGrayColor;
    self.emailSeparatorView.backgroundColor = emailColor;
    [WLVisualHelper templatizeImageView:self.emailImageView withColor:emailColor];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Text field delegate

- (IBAction)textFieldDidChange:(id)sender {
    [self reloadFilledFieldsRepresentation];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Text field navigation
    [self hideKeyboard];
    
    return NO;
}

#pragma mark - Button actions

- (IBAction)doneButtonAction:(id)sender {
    [self hideKeyboard];
    
    if ([self isEnteredDataValid]) {
        [self sendResetPasswordToServerAndMove];
    }
}

#pragma mark - Server requests

- (void)sendResetPasswordToServerAndMove {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [[Q8ServerAPIHelper sharedHelper] sendForgotPasswordToEmail:self.emailTextField.text
                                                   onCompletion:^(BOOL success) {
                                                       [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
                                                       self.view.userInteractionEnabled = YES;
                                                       
                                                       if (success) {
                                                           [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonPasswordResetSuccess]];
                                                           [self.navigationController popToRootViewControllerAnimated:YES];
                                                       }
                                                   } sender:self];
}

@end
