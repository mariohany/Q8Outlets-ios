//
//  AppDelegate.m
//  Q8outlets
//
//  Created by Lesya Verbina on 1/31/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>
//#import <TwitterKit/TWTRKit.h>
#import "Q8PushHelper.h"
#import <Firebase/Firebase.h>
#import "Q8DynamicLinkHelper.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Branch.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
// Dev
//#define GOOLE_API_KEY   @"AIzaSyD09kX5yCUkgbeuqQaOCVyQ4oFt2s427Dg"

// Live
#define GOOLE_API_KEY   @"AIzaSyBQ9aSCCmHOLvuJYScDF0S7uDLzTGFXZso"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
	return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Setup Fabric
//    [Fabric with:@[[Crashlytics class], [Twitter class]]];
    // Setup Facebook
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
	
    // Setup Firebase
    [FIROptions defaultOptions].deepLinkURLScheme = [[NSBundle mainBundle] bundleIdentifier];
    [FIRApp configure];
    
    // Setup Google maps
    [GMSServices provideAPIKey:GOOLE_API_KEY];
    
    // Visual setup
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName: Q8RedDefaultColor,
                                                           NSFontAttributeName: [UIFont fontWithName:@"Raleway-Regular" size:17.0f]}];
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"navbar_shadow"]];
    [[UINavigationBar appearance] setTintColor:Q8RedDefaultColor];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UITabBar appearance] setTintColor:Q8RedDefaultColor];
    
    // Setup pushes
    [Q8PushHelper setupRemoteNotificaitons];
    
    // Setup alert controller tint
    [WLAlertHelper setAlertControllerButtonsTintColor:Q8RedDefaultColor];
    
    // Open authorized/unauthorized section
    if ([Q8CurrentUser isAuthorized] && [Q8CurrentUser userId]) {
        UIViewController *authorizedController;
        if ([Q8CurrentUser userRole]==Q8UserRoleClient) {
            authorizedController = [WLUtilityHelper viewControllerFromStoryboard:@"Client" controllerIdentifier:Q8RootClientHomeController];
        } else {
           authorizedController = [WLUtilityHelper viewControllerFromStoryboard:@"Business" controllerIdentifier:Q8RootBusinnessHomeController];
        }
        self.window.rootViewController = authorizedController;
    } else {
        // Remove device token from server if user is not logged in
        [[Q8ServerAPIHelper sharedHelper] removeDeviceToken:[Q8CurrentUser deviceToken] onCompletion:^(BOOL success) {} sender:nil];
        
        UIViewController *unauthorizedController = [WLUtilityHelper viewControllerFromSBWithIdentifier:Q8RootUnauthorizedController];
        self.window.rootViewController = unauthorizedController;
    }
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        // Handling remote pushes opening app
        [Q8PushHelper handleAppBeingOpenedByPushWithUserInfo:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    } else if (!(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max)) {
        // Handling local pushes opening app
        UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (notification) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Q8PushHelper handleAppBeingOpenedByPushWithUserInfo:notification.userInfo];
            });
        }
    }
	
	Branch *branch = [Branch getInstance];
	[branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
		if (!error && params) {
			// params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
			// params will be empty if no data found
			// ... insert custom logic here ...
			NSLog(@"params: %@", params.description);
		}
	}];
	
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Q8PushHelper receivedDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    WLErrLog(@"%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // Handling remote pushes    
    if (application.applicationState != UIApplicationStateActive) {
        [Q8PushHelper receivedRemoteNotification:userInfo];        
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Handling remote pushes
    if (application.applicationState != UIApplicationStateActive) {
        [Q8PushHelper receivedRemoteNotification:userInfo];
    }
}

- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)notification
  completionHandler:(void (^)())completionHandler {
    
    // Handling custom actions in pushes
    [Q8PushHelper handleActionWithIdentifier:identifier forRemoteNotification:notification completionHandler:completionHandler];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [Q8PushHelper handleAppBeingOpenedByPushWithUserInfo:notification.userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    // Sends the URL to the current authorization flow (if any) which will process it if it relates to
    // an authorization response.
    if ([_currentAuthorizationFlow resumeExternalUserAgentFlowWithURL :url]) {
        _currentAuthorizationFlow = nil;
        return YES;
    }
	// handle deep links
	else if ([[url absoluteString] containsString:@"frontend.q8outlets.com/site/reset-password?"]) {
		NSRange range = [[url absoluteString] rangeOfString:@"frontend.q8outlets.com/site/reset-password?"];
		NSString *tokenString = [[url absoluteString] substringFromIndex:(range.location + range.length)].stringByRemovingPercentEncoding;
		[Q8DynamicLinkHelper handleDynamicLinkQuery:tokenString];
		return YES;
	}

    [[FBSDKApplicationDelegate sharedInstance] application:app
                                                   openURL:url
                                                   options:options];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	[[Branch getInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
	
    [Q8DynamicLinkHelper handleDynamicLinkQuery:[url absoluteString]];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation];
    
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    if (dynamicLink) {
        return YES;
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
		BOOL handled = [[FIRDynamicLinks dynamicLinks]
						handleUniversalLink:userActivity.webpageURL
						completion:^(FIRDynamicLink * _Nullable dynamicLink,
									 NSError * _Nullable error) {
							[Q8DynamicLinkHelper handleDynamicLinkQuery:dynamicLink.url.query];
						}];
		return handled;
}

@end
