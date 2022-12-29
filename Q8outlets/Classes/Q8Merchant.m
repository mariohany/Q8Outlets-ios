//
//  Q8Merchant.m
//  Q8outlets
//
//  Created by Lesya Verbina on 1/31/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8Merchant.h"

@implementation Q8Merchant

- (instancetype)init {
    self = [super init];
    self.merchantId = @"";
    self.businessId = @"";
    self.isNeedLoadMerchantData = YES;
    
    return self;
}

#pragma mark - Local search

- (BOOL)matchesQuery:(NSString *)query {
    query = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    query = [query lowercaseString];
    
    if (!query.length) {
        return YES;
    }
    
    NSString *cleanTitle = [self.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cleanTitle = [cleanTitle lowercaseString];
    
    NSString *cleanDescription = [self.merchantDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cleanDescription = [cleanDescription lowercaseString];
    if ((cleanTitle.length &&
         ([cleanTitle containsString:query] || [query containsString:cleanTitle])) ||
        (cleanDescription.length &&
         ([cleanDescription containsString:query] || [query containsString:cleanDescription]))) {
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Generation from dict

+ (Q8Merchant *)merchantFromDictionary:(NSDictionary *)merchantDictionary {
    merchantDictionary = [WLUtilityHelper dictionaryCleanedFromNulls:merchantDictionary];
    
    Q8Merchant *merchant = [Q8Merchant new];
    merchant.merchantId = [merchantDictionary[@"id"] stringValue];
    merchant.businessId = [merchantDictionary[@"business_id"] stringValue];
    merchant.merchantDescription = merchantDictionary[@"description"];
    merchant.title = merchantDictionary[@"title"];
    merchant.logoAddress = merchantDictionary[@"logoFile"];
    merchant.phone = merchantDictionary[@"phone"];
    merchant.email = merchantDictionary[@"email"];
	double latitude = merchantDictionary[@"lat"] ? [merchantDictionary[@"lat"] doubleValue] : [merchantDictionary[@"latitude"] doubleValue];
	double longitude = merchantDictionary[@"lng"] ? [merchantDictionary[@"lng"] doubleValue] : [merchantDictionary[@"longitude"] doubleValue];
    merchant.currentLocation = [Q8MerchantLocation locationByLatitude:latitude Longitude:longitude];
    merchant.allLocations = [Q8MerchantLocation locationsFromArray:merchantDictionary[@"businessLocations"]];
    
    NSDictionary *photoDictionary = [WLUtilityHelper chooseRandomFromItems:merchantDictionary[@"photos"]];    
    merchant.backgroundPictureAddress = photoDictionary[@"photo_file"];
    
    NSArray *categoryArray = merchantDictionary[@"category"];
    NSDictionary *categoryDict = [categoryArray firstObject];
    NSInteger categoryID = categoryDict ? [categoryDict[@"id"] integerValue] : [merchantDictionary[@"category_id"] integerValue];
    merchant.category = [[Q8Category alloc] initWithCategoryId:categoryID];

    merchant.offersCount = [merchantDictionary[@"countActiveOffers"] integerValue];    
    
    merchant.isCanFollow = YES;
    merchant.isFollowed = [merchantDictionary [@"myFollow"] count];
    
    merchant.isNeedLoadMerchantData = NO;
    
    return merchant;
}

@end
