//
//  Q8BusinessHomeViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8BusinessHomeControllerIdentifier = @"Q8BusinessHome";

@interface Q8BusinessHomeViewController : UIViewController

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *buttonViews;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *iconImageViews;

@property (nonatomic, weak) IBOutlet UILabel *merchantLocationLabel;
@property (nonatomic, weak) IBOutlet UIImageView *merchantLocationArrowImageView;
@property (nonatomic, weak) IBOutlet UIImageView *scanImageView;
@property (weak, nonatomic) IBOutlet UIView *emptyLocationView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLocationLabel;

- (IBAction)scanButtonAction:(id)sender;

- (IBAction)logoutButtonAction:(id)sender;
- (IBAction)notificationsButtonAction:(id)sender;

- (IBAction)offersButtonAction:(id)sender;
- (IBAction)statsButtonAction:(id)sender;

- (IBAction)locationButtonAction:(id)sender;

@end
