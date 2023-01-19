//
//  WLLocationHelper.m
//  WLHelpers
//
//  Created by Lesya Verbina on 6/1/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import "WLLocationHelper.h"
#import "WLLogHelper.h"

@implementation WLLocationHelper {
    CLLocationCoordinate2D lastLocationCoordinate; // Tracking last meaningfull location manually
}

+ (WLLocationHelper *)sharedHelper {
    static dispatch_once_t onceToken;
    static WLLocationHelper *sharedHelper = nil;
    
    dispatch_once(&onceToken, ^{
        sharedHelper = [[WLLocationHelper alloc] init];
        sharedHelper.locationManager = [[CLLocationManager alloc] init];
        sharedHelper.locationManager.delegate = sharedHelper;
        // Set a movement threshold for new events.
        sharedHelper.locationManager.distanceFilter = 100.f; // meters
        sharedHelper.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    });
    return sharedHelper;
}

- (CLLocationCoordinate2D)currentUserLocationCoordinate {
    return self.locationManager.location.coordinate;
}

- (CLLocation *)currentUserCLLocation {
    return self.locationManager.location;
}

#pragma mark - Authorization

- (void)requestAlwaysAuthorization {
    [self.locationManager requestAlwaysAuthorization];
}

- (void)requestInUseAuthorization {
    [self.locationManager requestWhenInUseAuthorization];
}


+ (BOOL)isLocationAvailable {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        // Successfully gained authorization
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    WLErrLog(@"locationManager didFailWithError:%@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = locations.lastObject;
    
    // Needed to filter cached and too old locations
    // If location is older than 5 seconds, not using it
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    
    if (newLocation.horizontalAccuracy < 0) return;
    
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:lastLocationCoordinate.latitude longitude:lastLocationCoordinate.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    double distance = [loc1 distanceFromLocation:loc2];
    
    if(distance > 20) {
        //significant location update
        lastLocationCoordinate = newLocation.coordinate;
        
        if (self.notificationName.length) {
            // If provided notification to post on location update, posting notification
            [[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:nil];
        }
    }
}

@end
