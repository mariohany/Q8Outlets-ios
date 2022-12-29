//
//  Q8ResetPasswordTableViewController.m
//  Q8outlets
//
//  Created by ProCreationsMac on 18.05.2018.
//  Copyright © 2018 Lesya Verbina. All rights reserved.
//

#import "Q8ResetPasswordTableViewController.h"
#import "Q8ServerAPIHelper.h"

@interface Q8ResetPasswordTableViewController ()

@end

@implementation Q8ResetPasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[WLVisualHelper addBorderToView:self.doneButton color:Q8RedDefaultColor width:2.0f];
	[WLVisualHelper roundThisView:self.doneButton radius:Q8CornerRadius];
	
	[self reloadFilledFieldsRepresentation];
}

#pragma mark - Controller logic

- (BOOL)isEnteredDataValid {
	if (!self.passwordTextField.text.length) {
		[WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonPasswordRequired]];
		return NO;
	} else if (self.passwordTextField.text.length < 6) {
		[WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonPasswordTooShort]];
		return NO;
	}
	return YES;
}

- (void)reloadFilledFieldsRepresentation {
	UIColor *passwordColor = self.passwordTextField.text.length >= 6 ? Q8GreenColor : Q8LightGrayColor;
	self.passwordSeparatorView.backgroundColor = passwordColor;
	[WLVisualHelper templatizeImageView:self.passwordImageView withColor:passwordColor];
}

#pragma mark - Text field delegate

- (IBAction)textFieldDidChange:(id)sender {
	[self reloadFilledFieldsRepresentation];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	// Text field navigation
	[self.view endEditing:YES];
	
	return NO;
}

#pragma mark - Button actions

- (IBAction)doneButtonAction:(id)sender {
	[self.view endEditing:YES];
	
	if ([self isEnteredDataValid]) {
		[self sendNewPasswordAndMove:[self encryptPassword]];
	}
}

#pragma mark - service functions

- (NSString*)encryptPassword {
	return self.passwordTextField.text;
}

#pragma mark - Server requests

- (void)sendNewPasswordAndMove:(NSString*)password {
	[Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
	self.view.userInteractionEnabled = NO;
	[[Q8ServerAPIHelper sharedHelper] sendNewPassword:self.passwordTextField.text withToken:self.passwordToken onCompletion:^(BOOL success) {
		[Q8ActivityIndicator hideHUDForView:self.view animated:YES];
		self.view.userInteractionEnabled = YES;
		
		if (success) {
			[WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonPasswordDidReset]];
			[self.navigationController popViewControllerAnimated:YES];
		}
	} sender:self];	
}

@end
