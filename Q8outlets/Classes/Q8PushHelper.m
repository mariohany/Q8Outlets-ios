//
//  Q8PushHelper.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/9/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8PushHelper.h"
@import UserNotifications;

#define DISTANCE_TO_FIRE_NEW_OFFER ((double) 2000)

typedef NS_ENUM(NSUInteger, Q8PushNotificationEvent) {
    Q8LocalNotificationEventNewOffer = 10,
    Q8PushNotificationEventNewOffer = 100,
    Q8PushNotificationEventCouponAvailable,
    Q8PushNotificationEventNewFollowedOffer
};

@interface Q8PushHelper () <UNUserNotificationCenterDelegate>
@end

@implementation Q8PushHelper

+ (Q8PushHelper *)sharedHelper {
    static dispatch_once_t onceToken;
    static Q8PushHelper *sharedHelper = nil;
    
    dispatch_once(&onceToken, ^{
        sharedHelper = [[Q8PushHelper alloc] init];
    });
    
    return sharedHelper;
}

+ (void)setupRemoteNotificaitons {
    // Setting up necessary permissions for using APNS
    [Q8PushHelper registerForRemoteNotificaitons];
    [Q8PushHelper registerForNotificaionCategories];
}

+ (void)registerForRemoteNotificaitons {
    UIApplication *application = [UIApplication sharedApplication];
    
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
        // New format for iOS 10 pushes
        [UNUserNotificationCenter currentNotificationCenter].delegate = [Q8PushHelper sharedHelper];
        
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
				[self performSelectorOnMainThread:@selector(registerForRemoteNotificaitons) withObject:application waitUntilDone:NO];
//                [application registerForRemoteNotifications];
            }
        }];
    } else {
        // Push notifications setup, receive permissions
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                           categories:nil]];
        [application registerForRemoteNotifications];
    }
}

+ (void)registerForNotificaionCategories {
    // Init buttons for actions
}

+ (void)receivedDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    WLDebLog(@"Registered for remote notifs %@",deviceTokenString);
    
    // Removing old token from server and adding new one, if token chenged
    if (![[Q8CurrentUser deviceToken] isEqualToString:deviceTokenString]) {
        [[Q8ServerAPIHelper sharedHelper] removeDeviceToken:deviceTokenString onCompletion:^(BOOL success) {} sender:nil];
    }
    
    // Saving new token
    if ([Q8CurrentUser userId]) {
        [[Q8ServerAPIHelper sharedHelper] saveDeviceToken:deviceTokenString onCompletion:^(BOOL success) {} sender:nil];
    }
    
    [Q8CurrentUser saveDeviceToken:deviceTokenString];
}

+ (void)receivedRemoteNotification:(NSDictionary *)userInfo {
    WLDebLog(@"Received notification %@", userInfo);
    Q8PushNotificationEvent notificationEvent = [userInfo[@"event"] integerValue];
    if (notificationEvent == Q8PushNotificationEventNewOffer) {
        [Q8PushHelper checkRemoteNotificationToNewOfferNearMe:userInfo];
    } else if (!(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max)) {
        [Q8PushHelper handleAppBeingOpenedByPushWithUserInfo:userInfo];
    }
}

+ (void)handleActionWithIdentifier:(NSString *)identifier
             forRemoteNotification:(NSDictionary *)userInfo
                 completionHandler:(void (^)())completionHandler {
    // Handle remote notifications with actions
}

+ (void)handleAppBeingOpenedByPushWithUserInfo:(NSDictionary *)userInfo {
    WLDebLog(@"App opened by push %@",userInfo);
    Q8PushNotificationEvent notificationEvent = [userInfo[@"event"] integerValue];
    [Q8PushHelper handleRemoteNotificationEvent:notificationEvent userInfo:userInfo];
}

+ (void)handleRemoteNotificationEvent:(Q8PushNotificationEvent)notificationEvent  userInfo:(NSDictionary *)userInfo {
    if ([Q8CurrentUser isAuthorized] && [Q8CurrentUser userId] && [Q8CurrentUser userRole] == Q8UserRoleClient) {
        NSDictionary *notificationParams = userInfo[@"result"];
        [Q8PushHelper openOfferControllerByOfferID:[notificationParams[@"offer_id"] stringValue]];    }
}

+ (void)checkRemoteNotificationToNewOfferNearMe:(NSDictionary *)userInfo {
    if (![WLLocationHelper isLocationAvailable]) {
        return;
    }
    
    NSDictionary *notificationParams = userInfo[@"result"];
    notificationParams = [WLUtilityHelper JSONcleanedFromNulls:notificationParams];
    if (!notificationParams [@"latitude"] || !notificationParams [@"longitude"]) {
        return;
    }
    double offerLatitude = [notificationParams [@"latitude"] doubleValue];
    double offerLongitude = [notificationParams [@"longitude"] doubleValue];
    double distance = [WLUtilityHelper distanceBetweenCoordinate:[WLLocationHelper sharedHelper].currentUserLocationCoordinate andCoordinate:CLLocationCoordinate2DMake(offerLatitude, offerLongitude)];
    if (distance < DISTANCE_TO_FIRE_NEW_OFFER) {
        [Q8PushHelper fireOfferNearMeNotification:userInfo];
    }
}

#pragma mark - Local notification

+ (void)fireOfferNearMeNotification:(NSDictionary *)userInfo {
    NSMutableDictionary *mutableUserInfo = [userInfo mutableCopy];
    mutableUserInfo[@"event"] = @(Q8LocalNotificationEventNewOffer);
    NSDictionary *notificationParams = userInfo[@"result"];
    NSString *alertBodyMessage = notificationParams[@"message"];
    [mutableUserInfo removeObjectForKey:@"aps"];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.body = alertBodyMessage;
        content.sound = [UNNotificationSound defaultSound];
        content.userInfo = mutableUserInfo;
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1
                                                                                                        repeats:NO];
        NSDictionary *notificationParams = userInfo[@"result"];
        NSString *identifier = [NSString stringWithFormat:@"%@%@",notificationParams[@"business_id"], notificationParams[@"offer_id"]];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                              content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {}];
    } else {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];;
        localNotification.alertBody = alertBodyMessage;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.userInfo = mutableUserInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

#pragma mark - Navigation from notification

+ (void)openOfferControllerByOfferID:(NSString *)offerID {
    Q8Offer *offer = [Q8Offer new];
    offer.offerId = offerID;
    [Q8NavigationManager moveToClientOffer:offer];
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // iOS 10 method that gets called instead of AppDelegate's "didReceiveNotification"
    WLDebLog(@"%@",notification);
    
    [Q8PushHelper receivedRemoteNotification:notification.request.content.userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    // App is being opened from push notification, but not from termination
    WLDebLog(@"%@",response);
    
    [Q8PushHelper handleAppBeingOpenedByPushWithUserInfo:response.notification.request.content.userInfo];
}
    
@end
