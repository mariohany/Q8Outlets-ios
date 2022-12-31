//
//  Q8OfferViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/6/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8OfferControllerIdentifier = @"Q8Offer";

@interface Q8OfferViewController : UIViewController <Q8OfferNotificationObserver, WLAlertControllerDelegate>

@property (nonatomic, strong) Q8Offer *offer;

// Offer header
@property (nonatomic, weak) IBOutlet UIImageView *promoImageView;
@property (nonatomic, weak) IBOutlet UIView *couponsContainerView;
@property (nonatomic, weak) IBOutlet UILabel *couponsCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *couponsTextLabel;

// Address panel
@property (nonatomic, weak) IBOutlet UILabel *merchantTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;

// Heart/share/star panel
@property (nonatomic, weak) IBOutlet UIImageView *likeImageView;
@property (nonatomic, weak) IBOutlet UILabel *likesLabel;
@property (nonatomic, weak) IBOutlet UIImageView *followImageView;

// Offer details
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *detailsIconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *skipDescriptionConstraint;
@property (nonatomic, weak) IBOutlet UIButton *applyButton;
@property (nonatomic, weak) IBOutlet UIView *noCouponsView;

// Coupon for applied offer
@property (nonatomic, weak) IBOutlet UIView *codeContainerView;
@property (nonatomic, weak) IBOutlet UILabel *expirationCoundownLabel;
@property (nonatomic, weak) IBOutlet UIImageView *qrCodeImageView;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;

- (IBAction)likeButtonAction:(id)sender;
- (IBAction)shareButtonAction:(id)sender;
- (IBAction)followButtonAction:(id)sender;

- (IBAction)detailsButtonAction:(id)sender;
- (IBAction)applyButtonAction:(id)sender;
- (IBAction)saveButtonAction:(id)sender;
- (IBAction)flagButtonAction:(id)sender;

@end
