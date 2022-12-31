//
//  Q8MerchantMapViewController.m
//  Q8outlets
//
//  Created by ProCreationsMac on 08.05.2018.
//  Copyright © 2018 Lesya Verbina. All rights reserved.
//

#import "Q8MerchantMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Q8MerchantAnnotation.h"

@interface Q8MerchantMapViewController ()

@property (nonatomic, weak) IBOutlet GMSMapView *mapView;

@end

@implementation Q8MerchantMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	Q8MerchantAnnotation *annotation = [[Q8MerchantAnnotation alloc] initWithMerchant:self.merchant];
	annotation.map = self.mapView;
	
	[self focusMapToShowAllMarkers];
}

- (void)focusMapToShowAllMarkers {
	CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(self.merchant.currentLocation.locationCoordinate.latitude + 0.001, self.merchant.currentLocation.locationCoordinate.longitude + 0.001);
	CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(self.merchant.currentLocation.locationCoordinate.latitude - 0.001, self.merchant.currentLocation.locationCoordinate.longitude - 0.001);
	GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast coordinate:southWest];
	bounds = [bounds includingCoordinate:self.merchant.currentLocation.locationCoordinate];
	
	[self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:15.0f]];
}

- (IBAction)backButtonPressed:(UIButton*)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}


@end
