//
//  Q8TabBarController.m
//  Q8outlets
//
//  Created by GlebGamaun on 19.02.17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8TabBarController.h"

@interface Q8TabBarController ()

@end

@implementation Q8TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Request location
    [[WLLocationHelper sharedHelper] requestAlwaysAuthorization];
}

@end
