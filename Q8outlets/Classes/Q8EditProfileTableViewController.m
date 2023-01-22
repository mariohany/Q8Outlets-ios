//
//  Q8EditProfileTableViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/7/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8EditProfileTableViewController.h"
#import "Q8SocialLoginHelper.h"

@interface Q8EditProfileTableViewController ()
@end

enum {
    Q8SectionAccountsHeader,
    Q8SectionAddMore,
    Q8SectionConnectedAccount,
    Q8SectionAccountsFooter,
    
    Q8SectionProfileInfo,
    Q8SectionPassword
};

@implementation Q8EditProfileTableViewController {
    BOOL isEditing;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    [WLVisualHelper templatizeImageView:self.unlinkImageView withColor:Q8OrangeColor];
    [WLVisualHelper templatizeImageViews:self.socialNetworkImageViews withColor:Q8RedDefaultColor];
    [WLVisualHelper addBorderToViews:self.socialNetworkButtonViews color:Q8RedDefaultColor width:2.0f];
    [WLVisualHelper roundThisViews:self.socialNetworkButtonViews radius:Q8CornerRadius];
    for (UIView *networkView in self.socialNetworkButtonViews) {
        networkView.backgroundColor = [UIColor clearColor]; // remove gray from xib
    }
    
    // Populate current user profile info
    [self populateProfileRepresentation];
    isEditing = NO;
    [self reloadEditingRepresentation];
}

#pragma mark - Controller logic

- (void)populateProfileRepresentation {
    self.nameTextField.text = [Q8CurrentUser userName];
    self.emailTextField.text = [Q8CurrentUser userEmail];
    
    NSString *socialNetworkName = @"";
    switch ([Q8CurrentUser userSocialNetworkType]) {
        case Q8SocialNetworkTypeFacebook:
            socialNetworkName = NSLocalizedString(@"Facebook", nil);
            break;
        case Q8SocialNetworkTypeTwitter:
            socialNetworkName = NSLocalizedString(@"Twitter", nil);
            break;
        case Q8SocialNetworkTypeGoogle:
            socialNetworkName = NSLocalizedString(@"Google", nil);
            break;
        case Q8SocialNetworkTypeInstagram:
            socialNetworkName = NSLocalizedString(@"Instagram", nil);
            break;
        default:
            break;
    }
    
    self.linkedSocialNetworkTextLabel.text = socialNetworkName;
    self.linkedSocialNetworkAccountLabel.text = [Q8CurrentUser userSocialNetworkAccount];
    
    [self.tableView reloadData];
}

- (void)reloadEditingRepresentation {
    [self hideKeyboard];
    self.nameTextField.userInteractionEnabled = isEditing;
    self.emailTextField.userInteractionEnabled = isEditing;
    self.passwordTextField.userInteractionEnabled = isEditing;
    self.confirmTextField.userInteractionEnabled = isEditing;
    self.editBarButtonItem.image = [UIImage imageNamed:isEditing ? @"icon_check" : @"icon_edit"];
    [WLVisualHelper templatizeImageViews:self.fieldIconsImageViews withColor:isEditing ? Q8RedDefaultColor : Q8LightGrayColor];
    [self.tableView reloadData];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)isEnteredDataValid {
    if (!self.emailTextField.text.length || (self.emailTextField.text.length &&
        ![[Q8CurrentUser userEmail] isEqualToString:self.emailTextField.text] &&
        ![WLUtilityHelper isEmailValid:self.emailTextField.text])) {
        // Invalid email
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonEmailInvalid]];
        return NO;
    } else if (!self.nameTextField.text.length) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonNameRequired]];
        return NO;        
    } else if (self.passwordTextField.text.length < 6 && self.passwordTextField.text.length) {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonPasswordTooShort]];
        return NO;
    } else if (self.passwordTextField.text.length ||
               self.confirmTextField.text.length) {
        if (![self.passwordTextField.text isEqualToString:self.confirmTextField.text]) {
            // Wrong password confirmation
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonPasswordConfirmationInvalid]];
            return NO;
        }
    }
    
    return YES;
}

- (void)showActivityIndicator:(BOOL)isNeedShowActivity {
    if (isNeedShowActivity) {
        [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    } else {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
    }
    
    self.view.userInteractionEnabled = !isNeedShowActivity;
    self.editBarButtonItem.enabled = !isNeedShowActivity;
}

#pragma mark - Table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == Q8SectionAddMore && [Q8CurrentUser userSocialNetworkAccount].length) {
        // Can't add network if already added
        return 0;
    } else if (section == Q8SectionConnectedAccount && ![Q8CurrentUser userSocialNetworkAccount].length) {
        // No connected account
        return 0;
    } else if (section == Q8SectionPassword && !isEditing) {
        return 0;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Text field navigation Next - Next
    if (textField==self.nameTextField) {
        [self.emailTextField becomeFirstResponder];
    } else if (textField==self.emailTextField) {
        [self hideKeyboard];
    } else if (textField==self.passwordTextField) {
        [self.confirmTextField becomeFirstResponder];
    } else if (textField==self.confirmTextField) {
        [self hideKeyboard];
    }
    
    return NO;
}

#pragma mark - Button actions

- (IBAction)editButtonAction:(id)sender {
    // Switch between editing/not editing
    if (!isEditing) {
        isEditing = YES;
        [self reloadEditingRepresentation];
    } else if ([self isEnteredDataValid]) {
        [self editProfileInfoOnServer];
    }
}

- (IBAction)linkFacebookButtonAction:(id)sender {
    [self addFacebookOnServer];
}
- (IBAction)linkTwitterButtonAction:(id)sender {
    [self addTwitterOnServer];
}
- (IBAction)linkGoogleButtonAction:(id)sender {
    [self addGoogleOnServer];
}
- (IBAction)linkInstagramButtonAction:(id)sender {
    [self addInstagramOnServer];
}

- (IBAction)unlinkButtonAction:(id)sender {
    if (![Q8CurrentUser userEmail].length) {
        // If no login info - can't unlink
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonCantUnlinkNoEmail]];
    } else {
        [self unlinkNetworkOnServer];
    }
    
}

#pragma mark - Server requests 

- (void)editProfileInfoOnServer {
    [self showActivityIndicator:YES];
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] updateUserEmail:self.emailTextField.text name:self.nameTextField.text password:self.passwordTextField.text onCompletion:^(BOOL success) {
        strongify(self);
        [self showActivityIndicator:NO];
        if (success) {
            [Q8CurrentUser saveUserName:self.nameTextField.text];
            [Q8CurrentUser saveUserEmail:self.emailTextField.text];
            self->isEditing = NO;
            [self reloadEditingRepresentation];
        }
    } sender:self];
}

- (void)unlinkNetworkOnServer {
    [self showActivityIndicator:YES];
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] disconnectUserSocialNetwork:[Q8CurrentUser userId] onCompletion:^(BOOL success) {
        [self showActivityIndicator:NO];
        if (success) {
            strongify(self);
            [Q8CurrentUser saveUserSocialNetworkAccount:@""];            
            [self populateProfileRepresentation];
        }
    } sender:self];
}

- (void)addFacebookOnServer {
    [self showActivityIndicator:YES];
    
    weakify(self);
    [Q8SocialLoginHelper loginFacebookOnCompletion:^(BOOL success) {
        if (!success) {
            strongify(self);
            [self showActivityIndicator:NO];
        } else {
            [[Q8ServerAPIHelper sharedHelper] linkFBOnCompletion:^(BOOL success) {
                strongify(self);
                [self showActivityIndicator:NO];
                
                [self populateProfileRepresentation];
            } sender:self];
        }
    } sender:self];
}

- (void)addTwitterOnServer {
    [self showActivityIndicator:YES];
    
    weakify(self);
    [Q8SocialLoginHelper loginTwitterOnCompletion:^(BOOL success, NSString *twitterToken, NSString *twitterSecret) {
        if (!success) {
            strongify(self);
            [self showActivityIndicator:NO];
        } else {
            [[Q8ServerAPIHelper sharedHelper] linkTwitterToken:twitterToken twitterSecret:twitterSecret onCompletion:^(BOOL success) {
                strongify(self);
                [self showActivityIndicator:NO];
                
                [self populateProfileRepresentation];
            } sender:self];
        }
    } sender:self];
}

- (void)addGoogleOnServer {
    [self showActivityIndicator:YES];
    
    weakify(self);
    [[Q8SocialLoginHelper sharedHelper] loginGoogleOnCompletion:^(BOOL success, NSString *googleToken) {
        if (!success) {
            strongify(self);
            [self showActivityIndicator:NO];
        } else {
            [[Q8ServerAPIHelper sharedHelper] linkGoogleToken:googleToken onCompletion:^(BOOL success) {
                strongify(self);
                [self showActivityIndicator:NO];
                
                [self populateProfileRepresentation];
            } sender:self];
        }
    } sender:self];
}

- (void)addInstagramOnServer {
    [self showActivityIndicator:YES];
    
    weakify(self);
    [[Q8SocialLoginHelper sharedHelper] loginInstagramOnCompletion:^(BOOL success, NSString *instagramToken) {
        if (!success) {
            strongify(self);
            [self showActivityIndicator:NO];
        } else {
            [[Q8ServerAPIHelper sharedHelper] linkInstagramToken:instagramToken onCompletion:^(BOOL success) {
                strongify(self);
                [self showActivityIndicator:NO];
                
                [self populateProfileRepresentation];
            } sender:self];
        }
    } sender:self];    
}


@end
