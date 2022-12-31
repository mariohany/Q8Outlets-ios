//
//  Q8PushHelper.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/9/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Q8PushHelper : NSObject

+ (void)setupRemoteNotificaitons;

+ (void)receivedDeviceToken:(NSData *)deviceToken;

+ (void)receivedRemoteNotification:(NSDictionary *)userInfo;

+ (void)handleActionWithIdentifier:(NSString *)identifier
             forRemoteNotification:(NSDictionary *)userInfo
                 completionHandler:(void (^)())completionHandler;

+ (void)handleAppBeingOpenedByPushWithUserInfo:(NSDictionary *)userInfo;

@end
