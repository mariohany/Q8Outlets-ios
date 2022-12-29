//
//  Q8MapViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/7/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@class Q8TextField;

@interface Q8MapViewController : UIViewController <GMSMapViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet Q8TextField *searchTextField;
@property (nonatomic, weak) IBOutlet UIView *searchSeparatorView;

@property (nonatomic, weak) IBOutlet UIView *merchantDetailsView;
@property (nonatomic, weak) IBOutlet UIImageView *merchantLogoImageView;
@property (nonatomic, weak) IBOutlet UILabel *merchantTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *offersCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *offersTextLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *hideMerchantDetailsConstraint;
@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;

@property (nonatomic, weak) IBOutlet GMSMapView *mapView;

- (IBAction)textFieldDidChange:(id)sender;
- (IBAction)toMerchantButtonAction:(id)sender;

@end
