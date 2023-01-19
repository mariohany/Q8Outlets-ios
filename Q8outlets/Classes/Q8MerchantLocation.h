//
//  Q8MerchantLocation.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/3/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Q8MerchantLocation : NSObject

@property (nonatomic, strong) NSString *locationId; // id within the system on backend
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;
@property (nonatomic, strong) NSString *locationAddress;
@property (nonatomic, strong) NSString *locationTitle;
@property (nonatomic, strong, readonly) NSString *distanceString;

+ (Q8MerchantLocation *)locationByLatitude:(CLLocationDegrees)latitude Longitude:(CLLocationDegrees)longitude;
+ (Q8MerchantLocation *)locationFromDictionary:(NSDictionary *)locationDictionary;
+ (NSArray<Q8MerchantLocation *> *)locationsFromArray:(NSArray *)locationsArray;

@end
