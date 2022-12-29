//
//  Q8VipCodeTableViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8VipCodeTableViewController.h"

@interface Q8VipCodeTableViewController ()

@end

@implementation Q8VipCodeTableViewController {
    BOOL invalidCode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    [WLVisualHelper addBorderToView:self.doneButton color:Q8RedDefaultColor width:2.0f];
    [WLVisualHelper roundThisView:self.doneButton radius:Q8CornerRadius];
    
    // If can't skip, hide button
    if (self.hideSkip) {
        [self.tableView reloadData];
    }
    
    [self reloadFilledFieldsRepresentation];
}

#pragma mark - Controller logic

- (BOOL)isEnteredDataValid {
    if (!self.codeTextField.text.length) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonCodeRequired]];
        return NO;
    } else if (invalidCode) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonCodeInvalid]];
        return NO;
    }
    return YES;
}

- (void)reloadFilledFieldsRepresentation {
    self.wrongCodeLabel.hidden = !invalidCode;
    UIColor *codeColor = self.codeTextField.text.length ? Q8OrangeColor : Q8LightGrayColor;
    self.codeSeparatorView.backgroundColor = invalidCode ? [UIColor redColor] : codeColor;
    [WLVisualHelper templatizeImageView:self.codeImageView withColor:invalidCode ? [UIColor redColor] :codeColor];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.hideSkip) {
        // If can't skip, hide button cell, so no scroll
        return [super tableView:tableView numberOfRowsInSection:section] - 1;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

#pragma mark - Text field delegate 

- (IBAction)textFieldDidChange:(id)sender {
    invalidCode = NO;
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
        [self sendVipCodeToServerAndMove];
    }
}
- (IBAction)skipButtonAction:(id)sender {
    [Q8NavigationManager moveToClientHome];
}

#pragma mark - Server requests

- (void)sendVipCodeToServerAndMove {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [[Q8ServerAPIHelper sharedHelper] activateVIPCode:self.codeTextField.text onCompletion:^(BOOL success, BOOL codeIsInvalid) {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
        self.view.userInteractionEnabled = YES;
        
        if (success) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonVIPSuccess]];
            if (self.moveToHome) {
                [Q8NavigationManager moveToClientHome];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else if (codeIsInvalid) {
            invalidCode = YES;
            [self reloadFilledFieldsRepresentation];
        }
    } sender:self];
}

@end
