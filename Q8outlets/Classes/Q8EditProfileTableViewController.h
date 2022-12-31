//
//  Q8EditProfileTableViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/7/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8EditProfileControllerIdentifier = @"Q8EditProfile";

@interface Q8EditProfileTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *editBarButtonItem;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *socialNetworkImageViews;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *socialNetworkButtonViews;
@property (nonatomic, weak) IBOutlet UIView *facebookView;
@property (nonatomic, weak) IBOutlet UIView *twitterView;
@property (nonatomic, weak) IBOutlet UIView *googleView;
@property (nonatomic, weak) IBOutlet UIView *instagramView;

@property (nonatomic, weak) IBOutlet UILabel *linkedSocialNetworkTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *linkedSocialNetworkAccountLabel;
@property (nonatomic, weak) IBOutlet UIImageView *unlinkImageView;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *fieldIconsImageViews;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UIImageView *nameImageView;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UIImageView *emailImageView;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIImageView *passwordImageView;
@property (nonatomic, weak) IBOutlet UITextField *confirmTextField;
@property (nonatomic, weak) IBOutlet UIImageView *confirmImageView;

- (IBAction)editButtonAction:(id)sender;

- (IBAction)linkFacebookButtonAction:(id)sender;
- (IBAction)linkTwitterButtonAction:(id)sender;
- (IBAction)linkGoogleButtonAction:(id)sender;
- (IBAction)linkInstagramButtonAction:(id)sender;

- (IBAction)unlinkButtonAction:(id)sender;

@end
