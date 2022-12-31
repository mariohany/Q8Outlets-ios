//
//  Q8VipCodeTableViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8VipCodeControllerIdentifier = @"Q8VipCode";

@interface Q8VipCodeTableViewController : UITableViewController

@property (nonatomic, assign) BOOL hideSkip;
@property (nonatomic, assign) BOOL moveToHome;

@property (nonatomic, weak) IBOutlet UITextField *codeTextField;
@property (nonatomic, weak) IBOutlet UIImageView *codeImageView;
@property (nonatomic, weak) IBOutlet UIView *codeSeparatorView;
@property (nonatomic, weak) IBOutlet UILabel *wrongCodeLabel;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@property (nonatomic, weak) IBOutlet UIButton *skipButton;

- (IBAction)doneButtonAction:(id)sender;
- (IBAction)skipButtonAction:(id)sender;


@end
