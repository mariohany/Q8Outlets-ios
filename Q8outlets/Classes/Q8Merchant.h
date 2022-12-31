//
//  Q8Merchant.h
//  Q8outlets
//
//  Created by Lesya Verbina on 1/31/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Q8MerchantLocation.h"
#import "Q8Category.h"

@class Q8Offer;

@interface Q8Merchant : NSObject

@property (nonatomic, strong) NSString *merchantId;
@property (nonatomic, strong) NSString *businessId;
@property (nonatomic, strong) NSString *merchantDescription;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *logoAddress;
@property (nonatomic, strong) NSString *backgroundPictureAddress;
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isCanFollow;
@property (nonatomic, assign) NSInteger offersCount;

@property (nonatomic, strong) Q8Category *category;

@property (nonatomic, strong) NSString *phone; // contact info
@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) Q8MerchantLocation *currentLocation;
@property (nonatomic, strong) NSArray <Q8MerchantLocation *> *allLocations;

@property (nonatomic, strong) NSArray <Q8Offer *> *allOffers;

@property (nonatomic, assign) BOOL isNeedLoadMerchantData;

// **
// Convenience for local search
- (BOOL)matchesQuery:(NSString *)query;

// **
// Generation from dictionary
+ (Q8Merchant *)merchantFromDictionary:(NSDictionary *)merchantDictionary;

@end
