//
//  Q8NotificationSettingsTableViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/7/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8NotificationSettingsControllerIdentifier = @"Q8NotificationSettings";

@interface Q8NotificationSettingsTableViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UIImageView     *offerEmailImageView;
@property (nonatomic, weak) IBOutlet UIImageView     *offerPushImageView;
@property (nonatomic, weak) IBOutlet UIImageView     *merchantEmailImageView;
@property (nonatomic, weak) IBOutlet UIImageView     *merchantPushImageView;
@property (nonatomic, weak) IBOutlet UIImageView     *couponsEmailImageView;
@property (nonatomic, weak) IBOutlet UIImageView     *couponsPushImageView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *backBarButton;

- (IBAction)offerEmailButtonAction:(id)sender;
- (IBAction)offerPushButtonAction:(id)sender;
- (IBAction)merchantEmailButtonAction:(id)sender;
- (IBAction)merchantPushButtonAction:(id)sender;
- (IBAction)couponsEmailButtonAction:(id)sender;
- (IBAction)couponsPushButtonAction:(id)sender;

- (IBAction)backButtonAction:(id)sender;

@end
