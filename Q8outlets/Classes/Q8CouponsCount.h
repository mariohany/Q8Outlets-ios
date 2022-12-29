//
//  Q8CouponsCount.h
//  Q8outlets
//
//  Created by GlebGamaun on 20.02.17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Q8CouponsCount : NSObject

@property (nonatomic, assign) NSInteger activeCount;
@property (nonatomic, assign) NSInteger archivedCount;
@property (nonatomic, assign) NSInteger usedCount;
@property (nonatomic, assign) NSInteger expiredCount;

@end
