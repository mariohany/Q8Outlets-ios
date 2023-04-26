//
//  Q8AuthorizationTableViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AuthenticationServices/AuthenticationServices.h>

static NSString * const Q8AuthorizationControllerIdentifier = @"Q8Authorization";

@interface Q8AuthorizationTableViewController : UITableViewController <UITextFieldDelegate,ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>

@property (nonatomic, assign) BOOL isRegistration;
@property (nonatomic, assign) Q8UserRole authorizationRole; // For b-user or client

// **
// Login/register tabs on top
@property (nonatomic, weak) IBOutlet UIButton *registrationTabButton;
@property (nonatomic, weak) IBOutlet UIButton *loginTabButton;
@property (nonatomic, weak) IBOutlet UIView *activeTabBottomView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *centerActiveTabOnRegistrationConstraint; // For sliding bottom border on register/login "tab" buttons

- (IBAction)registrationTabButtonAction:(id)sender;
- (IBAction)loginTabButtonAction:(id)sender;

// **
// Social network buttons
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *socialNetworkButtonViews;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *socialNetworkImageViews;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterLabel;
@property (weak, nonatomic) IBOutlet UILabel *googleLabel;
@property (weak, nonatomic) IBOutlet UILabel *instagramLabel;

- (IBAction)facebookButtonAction:(id)sender;
- (IBAction)twitterButtonAction:(id)sender;
- (IBAction)googleButtonAction:(id)sender;
- (IBAction)instagramButtonAction:(id)sender;

// **
// Authorization form
@property (nonatomic, weak) IBOutlet UILabel *formHeaderLabel;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UIImageView *nameImageView;
@property (nonatomic, weak) IBOutlet UIView *nameSeparatorView;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UIImageView *emailImageView;
@property (nonatomic, weak) IBOutlet UIView *emailSeparatorView;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIImageView *passImageView;
@property (nonatomic, weak) IBOutlet UIView *passSeparatorView;
@property (nonatomic, weak) IBOutlet UITextField *confirmTextField;
@property (nonatomic, weak) IBOutlet UIImageView *confirmImageView;
@property (nonatomic, weak) IBOutlet UIView *confirmSeparatorView;

- (IBAction)textFieldDidChange:(id)sender;

// **
// "I accept terms and conditions"
@property (nonatomic, weak) IBOutlet UIButton *termsButton;
@property (nonatomic, weak) IBOutlet UIImageView *termsImageView;
@property (nonatomic, weak) IBOutlet UILabel *termsLabel;

- (IBAction)termsButtonAction:(id)sender;

// **
// Login/register button
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

- (IBAction)doneButtonAction:(id)sender;
- (IBAction)forgotPasswordButtonAction:(id)sender;

// **
// Tip for obtaining merchant account
@property (nonatomic, weak) IBOutlet UILabel *merchantTipLabel;

@end
