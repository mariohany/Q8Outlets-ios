//
//  Q8Category.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8Category.h"

@implementation Q8Category

+ (NSArray <Q8Category *> *)availableCategories {
    // 6 static categories included with the app
    NSMutableArray *categories = [NSMutableArray new];
    for (int i=1; i<7; i++) {
        Q8Category *category = [[Q8Category alloc] initWithCategoryId:i];
        [categories addObject:category];
    }
    
    return categories;
}

- (instancetype)initWithCategoryId:(NSInteger)categoryId {
    self = [super init];
    self.categoryId = categoryId;
    return self;
}

- (NSString *)categoryName {
    switch (self.categoryId) {
        case Q8CategoryIdFood:
            return NSLocalizedString(@"Food & Drinks", nil);
            break;
        case Q8CategoryIdFashion:
            return NSLocalizedString(@"Fashion", nil);
            break;
        case Q8CategoryIdRetail:
            return NSLocalizedString(@"Retail", nil);
            break;
        case Q8CategoryIdBeauty:
            return NSLocalizedString(@"Beauty & Fitness", nil);
            break;
        case Q8CategoryIdLeisure:
            return NSLocalizedString(@"Leisure", nil);
            break;
        case Q8CategoryIdOther:
        default:
            return NSLocalizedString(@"Category", nil);
            break;
    }
}

- (UIImage *)categoryIcon {
    NSString *iconName;
    switch (self.categoryId) {
        case Q8CategoryIdFood:
            iconName = @"icon_food";
            break;
        case Q8CategoryIdFashion:
            iconName = @"icon_fashion";
            break;
        case Q8CategoryIdRetail:
            iconName = @"icon_retail";
            break;
        case Q8CategoryIdBeauty:
            iconName = @"icon_beauty";
            break;
        case Q8CategoryIdLeisure:
            iconName = @"icon_leisure";
            break;
        case Q8CategoryIdOther:
        default:
            iconName = @"icon_gift";
            break;
    }
    
    UIImage *iconImage = [UIImage imageNamed:iconName];
    return iconImage;
}

@end
