//
//  Q8MerchantLocation.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/3/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8MerchantLocation.h"

@implementation Q8MerchantLocation

- (NSString *)distanceString {
    // Showing distance to location, if we can
    BOOL distanceAvailable = ([WLLocationHelper sharedHelper].currentUserLocationCoordinate.latitude &&
                              [WLLocationHelper sharedHelper].currentUserLocationCoordinate.longitude);
    if (distanceAvailable) {
        float distance = [WLUtilityHelper distanceBetweenCoordinate:[WLLocationHelper sharedHelper].currentUserLocationCoordinate andCoordinate:self.locationCoordinate];
        return [NSString stringWithFormat:@"%.1f km", distance/1000.0f];
    } else {
        return @"";
    }
}

+ (Q8MerchantLocation *)locationByLatitude:(CLLocationDegrees)latitude Longitude:(CLLocationDegrees)longitude {
    Q8MerchantLocation *location = [Q8MerchantLocation new];
    location.locationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    return location;
}

+ (Q8MerchantLocation *)locationFromDictionary:(NSDictionary *)locationDictionary {
    Q8MerchantLocation *location = [Q8MerchantLocation new];
    CLLocationDegrees latitude = [locationDictionary[@"latitude"] doubleValue];
    CLLocationDegrees longitude = [locationDictionary[@"longitude"] doubleValue];
    location.locationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    location.locationId =  [locationDictionary[@"id"] stringValue];
    location.locationAddress = [NSString stringWithFormat:@"%@ %@ %@ %@", locationDictionary[@"street_number"]? :@"", locationDictionary[@"route"]? :@"", locationDictionary[@"locality"]? :@"", locationDictionary[@"country"]? :@""];
    location.locationTitle = locationDictionary[@"title"];
    
    return location;
}

+ (NSArray<Q8MerchantLocation *> *)locationsFromArray:(NSArray *)locationsArray {
    NSMutableArray *locationArray = [NSMutableArray array];
    for (NSDictionary *locationDictionary in locationsArray) {
        [locationArray addObject:[Q8MerchantLocation locationFromDictionary:[WLUtilityHelper dictionaryCleanedFromNulls:locationDictionary]]];
    }
    
    return locationArray;
}

@end
