//
//  Q8MapViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/7/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8MapViewController.h"
#import "Q8MerchantAnnotation.h"
#import "Q8TextField.h"

@interface Q8MapViewController ()

@end

@implementation Q8MapViewController {
    NSArray <Q8Merchant *> *allMerchants;
    
    Q8Merchant *selectedMerchant;
    Q8MerchantAnnotation *selectedAnnotation;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView.delegate = self;
    
    // Initial state
    [self setupImageAssessory];
    [self toggleMerchantDetailsHidden:YES animated:NO];
    [self reloadFilledFieldsRepresentation];

    // Load merchants
    [self loadMerchantsFromServer];
}

- (void)setupImageAssessory {
    UIImage* image = [UIImage imageNamed:NSLocalizedString(@"icon_arrow_right", nil)];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.arrowImageView setImage:image];
    [self.arrowImageView setTintColor:[UIColor blackColor]];
}

#pragma mark - Controller logic

- (void)reloadMapAnnotationsAndZoom:(BOOL)zoom {
    // Creates a marker in the center of the map.
    
    [self.mapView clear];
    for (Q8Merchant *merchant in [self merchants]) {
        Q8MerchantAnnotation *annotation = [[Q8MerchantAnnotation alloc] initWithMerchant:merchant];
        annotation.map = self.mapView;
    }
    if (zoom) {
        [self focusMapToShowAllMarkers];
    }
}

- (void)focusMapToShowAllMarkers {
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    
    for (Q8Merchant *merchant in [self merchants])
        bounds = [bounds includingCoordinate:merchant.currentLocation.locationCoordinate];
    
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:15.0f]];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)reloadFilledFieldsRepresentation {
    self.searchSeparatorView.hidden = !self.searchTextField.text.length;
}

- (NSArray <Q8Merchant *> *)merchants {
    return allMerchants;
}

#pragma mark - Merchant details

- (void)toggleMerchantDetailsHidden:(BOOL)hidden animated:(BOOL)animated {
    self.view.userInteractionEnabled = NO;
    if (!hidden) {
        self.merchantDetailsView.hidden = NO;
    }
    [UIView animateWithDuration:animated ? 0.2f : 0.0f
                     animations:^{
                         self.hideMerchantDetailsConstraint.priority = hidden ? 990 : 100;
                         [self.merchantDetailsView.superview layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.view.userInteractionEnabled = YES;
                     }];
}

- (void)populateMerchantDetails {
    [Q8ImageHelper setMerchantLogo:selectedMerchant intoImageView:self.merchantLogoImageView];
    self.merchantTitleLabel.text = selectedMerchant.title;
    self.categoryLabel.text = selectedMerchant.category.categoryName;
    self.distanceLabel.text = selectedMerchant.currentLocation.distanceString;
    self.offersCountLabel.text = selectedMerchant.offersCount> 100 ? NSLocalizedString(@"100+", nil) : [NSString stringWithFormat:@"%ld", (long)selectedMerchant.offersCount];
    self.offersTextLabel.text = selectedMerchant.offersCount==1 ? NSLocalizedString(@"offer", nil) : NSLocalizedString(@"offers", nil);
}

#pragma mark - Text field delegate

- (IBAction)textFieldDidChange:(id)sender {
    [self reloadFilledFieldsRepresentation];
    
    [self loadMerchantsFromServer];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hideKeyboard];
    return NO;
}

#pragma mark - Map delegate

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if (!(selectedAnnotation == marker)) {
        if (selectedAnnotation) {
            [selectedAnnotation setSelected:NO];            
        }
        
        if ([marker isKindOfClass:[Q8MerchantAnnotation class]]) {
            Q8MerchantAnnotation *annotationMarker = (Q8MerchantAnnotation *)marker;
            [annotationMarker setSelected:YES];
            selectedMerchant = annotationMarker.merchant;
            selectedAnnotation = annotationMarker;
            
            [self loadOffersFromServer];
            [self toggleMerchantDetailsHidden:NO animated:YES];
        }
    }
    
    return YES;
}

- (void)mapView:(GMSMapView *)amapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    if (selectedAnnotation) {
        [selectedAnnotation setSelected:NO];
        selectedMerchant = nil;
        selectedAnnotation = nil;
        [self toggleMerchantDetailsHidden:YES animated:YES];
    }
}

#pragma mark - Button actions

- (void)toMerchantButtonAction:(id)sender {
    // Open merchant page
    if (selectedMerchant) {
        [Q8NavigationManager moveToMerchant:selectedMerchant];
    } else {
        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:@[@""] bodyArguments:@[@""] delegate:nil];
    }
}

#pragma mark - Server requests

- (void)loadMerchantsFromServer {
    NSString *latitude = [[NSNumber numberWithDouble:[WLLocationHelper sharedHelper].currentUserLocationCoordinate.latitude] stringValue];
    NSString *longtitude = [[NSNumber numberWithDouble:[WLLocationHelper sharedHelper].currentUserLocationCoordinate.longitude] stringValue];
    weakify(self)
    [[Q8ServerAPIHelper sharedHelper] getMerchantsByLocation:latitude longtitude:longtitude searchtext:self.searchTextField.text onCompletion:^(BOOL success, NSArray<Q8Merchant *> *mershantsArray, NSString *searchText) {
        strongify(self);
        if ([searchText isEqualToString:self.searchTextField.text]) {
            self->allMerchants = mershantsArray;
            [self reloadMapAnnotationsAndZoom:mershantsArray.count ? YES : NO];
            if (!mershantsArray.count) {
                [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonSearchNoResults] titleArguments:nil bodyArguments:nil delegate:nil];
            }
        }
    } sender:self];
}

- (void)loadOffersFromServer {
    self.activityIndicator.hidden = NO;
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] getMerchantAndOffers:selectedMerchant.businessId onCompletion:^(BOOL success, Q8Merchant *merchant, NSArray<Q8Offer *> *offersArray) {
        strongify(self);
        if (success) {
            self.activityIndicator.hidden = YES;
            merchant.currentLocation = self->selectedMerchant.currentLocation;
            self->selectedMerchant = merchant;
            [self populateMerchantDetails];
        }
    } sender:self];
}


@end
