//
//  Q8BusinessNotification.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Q8BusinessNotification : NSObject

@property (nonatomic, strong) NSString *notificationText;
@property (nonatomic, strong) NSDate *notificationDate;
@property (nonatomic, strong) Q8Offer *offer;

+ (Q8BusinessNotification *)notificationFromDictionary:(NSDictionary *)notificationDictionary;

@end
