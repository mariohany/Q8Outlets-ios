//
//  Q8ForgotPasswordTableViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8ForgotPasswordControllerIdentifier = @"Q8ForgotPassword";

@interface Q8ForgotPasswordTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSString *sentEmail; // From previous screen

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UIImageView *emailImageView;
@property (nonatomic, weak) IBOutlet UIView *emailSeparatorView;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

- (IBAction)doneButtonAction:(id)sender;

@end
