//
//  Q8CategoriesViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8CategoriesViewController.h"
#import "Q8SearchViewController.h"
#import "Q8Category.h"

@interface Q8CategoriesViewController ()

@end

@implementation Q8CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    [WLVisualHelper templatizeImageViews:self.categoryImageViews withColor:Q8RedDefaultColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Button actions

- (IBAction)searchButtonAction:(id)sender {
    [self moveToSearch];
}

- (IBAction)foodButtonAction:(id)sender {
    [self moveToCategoryWitId:Q8CategoryIdFood];
}
- (IBAction)fashionButtonAction:(id)sender {
    [self moveToCategoryWitId:Q8CategoryIdFashion];
}
- (IBAction)retailButtonAction:(id)sender {
    [self moveToCategoryWitId:Q8CategoryIdRetail];
}
- (IBAction)beautyButtonAction:(id)sender {
    [self moveToCategoryWitId:Q8CategoryIdBeauty];
}
- (IBAction)leisureButtonAction:(id)sender {
    [self moveToCategoryWitId:Q8CategoryIdLeisure];
}
- (IBAction)otherButtonAction:(id)sender {
    [self moveToCategoryWitId:Q8CategoryIdOther];
}

#pragma mark - Navigation

- (void)moveToSearch {
    Q8SearchViewController *searchController = (Q8SearchViewController *)[WLUtilityHelper viewControllerFromStoryboard:@"Client" controllerIdentifier:Q8SearchControllerIdentifier];
    [self.navigationController pushViewController:searchController animated:YES];
}

- (void)moveToCategoryWitId:(NSInteger)categoryId {
    // Move to search/browse in category
    Q8Category *category = [[Q8Category alloc] initWithCategoryId:categoryId];
    
    Q8SearchViewController *searchController = (Q8SearchViewController *)[WLUtilityHelper viewControllerFromStoryboard:@"Client" controllerIdentifier:Q8SearchControllerIdentifier];
    searchController.category = category;
    [self.navigationController pushViewController:searchController animated:YES];
}

@end
