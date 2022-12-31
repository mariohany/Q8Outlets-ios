//
//  Q8Category.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    Q8CategoryIdFood = 1,
    Q8CategoryIdFashion,
    Q8CategoryIdRetail,
    Q8CategoryIdBeauty,
    Q8CategoryIdLeisure,
    Q8CategoryIdOther
};

@interface Q8Category : NSObject

@property (nonatomic, assign) NSInteger categoryId;
@property (nonatomic, strong, readonly) NSString *categoryName;
@property (nonatomic, strong, readonly) UIImage *categoryIcon;

// Static categories included with the app
+ (NSArray <Q8Category *> *)availableCategories;
- (instancetype)initWithCategoryId:(NSInteger)categoryId;

@end
