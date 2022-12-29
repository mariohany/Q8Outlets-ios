//
//  Q8BusinessStatsTableViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/14/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8BusinessStatsTableViewController.h"

@interface Q8BusinessStatsTableViewController ()
@end

@implementation Q8BusinessStatsTableViewController {
    NSInteger appliedOfferCount;
    NSInteger usedCouponsCount;
    NSInteger expiredCouponsCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    [WLVisualHelper templatizeImageView:self.usedImageView withColor:Q8RedDefaultColor];
    [WLVisualHelper templatizeImageView:self.expiredImageView withColor:Q8OrangeColor];
    
    // Get fresh stats from server
    [self getStatsFromServer];
}

#pragma mark - Controller logic

- (void)populateStatsRepresentation {
    self.appliedLabel.text = [@(appliedOfferCount) stringValue];
    self.usedLabel.text = [@(usedCouponsCount) stringValue];
    self.expiredLabel.text = [@(expiredCouponsCount) stringValue];
}

#pragma mark - Server requests

- (void)getStatsFromServer {
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] getStatisticsByOfferID:@"" onCompletions:^(BOOL success, NSInteger appliedCount, NSInteger usedCount, NSInteger expiredCount) {
        strongify(self);
        expiredCouponsCount = expiredCount;
        appliedOfferCount = appliedCount;
        usedCouponsCount = usedCount;
        [self populateStatsRepresentation];
    } sender:self];    
}

@end
