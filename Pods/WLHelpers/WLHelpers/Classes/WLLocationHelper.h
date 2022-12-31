//
//  WLLocationHelper.h
//  WLHelpers
//
//  Created by Lesya Verbina on 6/1/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface WLLocationHelper : NSObject <CLLocationManagerDelegate>

/**
 *  CoreLocation manager to be used by helper.
 */
@property (strong, nonatomic) CLLocationManager *locationManager;

/**
 *  Notification name of location update notification. If set, notification with this name will be posted on location update events.
 */
@property (strong, nonatomic) NSString *notificationName;

/**
 *  Singleton of location helper, to access instance methods.
 *
 *  @return Location helper shared instance.
 */
+ (WLLocationHelper *)sharedHelper;

/**
 *  Current location coordinate of the device.
 *
 *  @return Current location coordinate of the device.
 */
- (CLLocationCoordinate2D)currentUserLocationCoordinate;

/**
 Current location of the device, as CLLocation object.

 @return Current location of the device, as CLLocation object.
 */
- (CLLocation *)currentUserCLLocation;

#pragma mark - Authorization

/**
 * Request "always" authorization from user, to access location even when user is not in the app.
 * 
 * @warning Provide NSLocationAlwaysUsageDescription key in your Info.plist or authorization prompt will not appear.
 */
- (void)requestAlwaysAuthorization;

/**
 * Request "in use" authorization from user, to access location when app is in the foreground.
 *
 * @warning Provide NSLocationWhenInUseUsageDescription key in your Info.plist or authorization prompt will not appear.
 */
- (void)requestInUseAuthorization;

/**
 *  Check if location is available and user has granted access to it.
 *
 *  @return Flag if location services can be used by app.
 */
+ (BOOL)isLocationAvailable;

@end
