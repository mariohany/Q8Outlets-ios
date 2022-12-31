//
//  Q8ResetPasswordTableViewController.h
//  Q8outlets
//
//  Created by ProCreationsMac on 18.05.2018.
//  Copyright © 2018 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8ResetPasswordControllerIdentifier = @"Q8ResetPassword";

@interface Q8ResetPasswordTableViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *passwordImageView;
@property (weak, nonatomic) IBOutlet UIView *passwordSeparatorView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic, copy) NSString *passwordToken;

@end
