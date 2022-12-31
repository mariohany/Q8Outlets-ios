//
//  Q8BusinessNotification.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8BusinessNotification.h"

@implementation Q8BusinessNotification

+ (Q8BusinessNotification *)notificationFromDictionary:(NSDictionary *)notificationDictionary {
    Q8BusinessNotification *notification = [Q8BusinessNotification new];
    notification.notificationDate = [NSDate dateWithTimeIntervalSince1970:[notificationDictionary[@"created_at"] doubleValue]];
    notification.notificationText = [NSString stringWithFormat:NSLocalizedString(@"%ld users have applied for your offer", nil), (long)[notificationDictionary[@"amount"] integerValue]];
    notification.offer = [Q8Offer new];
    notification.offer.title = notificationDictionary[@"title"];
    
    return notification;
}

@end
