//
//  Q8TourViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8TourViewController.h"
#import "Q8TourSlideCollectionViewCell.h"
#import "Q8Slide.h"
#import "Q8AuthorizationTableViewController.h"

@interface Q8TourViewController ()

@end

@implementation Q8TourViewController {
    NSArray <Q8Slide *> *slides;
    NSInteger currentPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Populate slides
    Q8Slide *slide1 = [Q8Slide new];
    slide1.slideTitle = NSLocalizedString(@"DISCOVER", nil);
    slide1.slideText= NSLocalizedString(@"Find outlets near you.\nUse quick search by merchant or offer name.", nil);
    slide1.slideImageName = @"tour_1";
    
    Q8Slide *slide2 = [Q8Slide new];
    slide2.slideTitle = NSLocalizedString(@"EXPLORE", nil);
    slide2.slideText= NSLocalizedString(@"Browse and choose from many special offers available to you.", nil);
    slide2.slideImageName = @"tour_2";
    
    Q8Slide *slide3 = [Q8Slide new];
    slide3.slideTitle = NSLocalizedString(@"FOLLOW", nil);
    slide3.slideText= NSLocalizedString(@"Follow merchants and offers and you will never miss available coupons.", nil);
    slide3.slideImageName = @"tour_3";
    
    Q8Slide *slide4 = [Q8Slide new];
    slide4.slideTitle = NSLocalizedString(@"APPLY", nil);
    slide4.slideText= NSLocalizedString(@"Apply for an offer and get your coupon code.\nHurry up and use it before it expires!", nil);
    slide4.slideImageName = @"tour_4";
    
    Q8Slide *slide5 = [Q8Slide new];
    slide5.slideTitle = NSLocalizedString(@"REDEEM", nil);
    slide5.slideText= NSLocalizedString(@"To redeem your offer show your coupon code to a merchant and get your gift.", nil);
    slide5.slideImageName = @"tour_5";
    
    Q8Slide *slide6 = [Q8Slide new];
    slide6.slideTitle = NSLocalizedString(@"GET STARTED", nil);
    slide6.isAutorizationPrompt = YES;
    
    slides = @[slide1, slide2, slide3, slide4, slide5, slide6];
    
    // Reload data after preparation
    [self.collectionView reloadData];
    [self reloadCurrentPageRepresentationScroll:NO];
}

#pragma mark - Collection view datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [slides count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Q8TourSlideCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Q8TourSlideCellIdentifier forIndexPath:indexPath];
    [cell layoutIfNeeded];
    
    Q8Slide *slide = [slides objectAtIndex:indexPath.item];
    [cell setupForSlide:slide];
    
    // Observe buttons
    [cell.registerButton addTarget:self action:@selector(registerCellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.loginButton addTarget:self action:@selector(loginCellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - Collection view delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Fullsize slides
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = collectionView.bounds.size.height;
    
    return CGSizeMake(width, height);
}

#pragma mark - Pagination logic

- (void)reloadCurrentPageRepresentationScroll:(BOOL)scroll {
    self.pageControl.currentPage = currentPage;
    // Last/first pages are special
    self.previousButton.hidden = !currentPage;
    self.nextButton.hidden = (currentPage == [slides count]-1);
    
    if (scroll) {
        @try {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentPage inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        } @catch (NSException *exception) {
            WLErrLog(@"%@",exception);
        } @finally {
        }
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        CGFloat pageWidth = self.collectionView.frame.size.width;
        float currentPageFloat = self.collectionView.contentOffset.x / pageWidth;
        
        if (fmodf(currentPageFloat, 1.0f) != 0.0f) {
            currentPage = currentPageFloat++;
        } else {
            currentPage = currentPageFloat;
        }
        
        // Reload next/prev buttons and page control
        [self reloadCurrentPageRepresentationScroll:NO];
    }
}

#pragma mark - Cell button actions

- (void)registerCellButtonAction:(id)sender {
    // Move to registration
    [self moveToClientAuthorizationRegister:YES];
}

- (void)loginCellButtonAction:(id)sender {
    // Move to login
    [self moveToClientAuthorizationRegister:NO];
}

#pragma mark - Button actions

- (IBAction)previousButtonAction:(id)sender {
    if (currentPage) {
        currentPage--;
        [self reloadCurrentPageRepresentationScroll:YES];
    }
}

- (IBAction)nextButtonAction:(id)sender {
    if (currentPage<[slides count]) {
        currentPage++;
        [self reloadCurrentPageRepresentationScroll:YES];
    }
}

- (IBAction)pageChangeAction:(id)sender {
    currentPage = self.pageControl.currentPage;
    [self reloadCurrentPageRepresentationScroll:YES];
}

#pragma mark - Navigation

- (void)moveToClientAuthorizationRegister:(BOOL)registration {
    Q8AuthorizationTableViewController *authorizationController = (Q8AuthorizationTableViewController *)[WLUtilityHelper viewControllerFromSBWithIdentifier:Q8AuthorizationControllerIdentifier];
    authorizationController.isRegistration = registration;
    authorizationController.authorizationRole = Q8UserRoleClient;
    
    UINavigationController *navigationController = self.navigationController;
    NSMutableArray *viewControllers = [navigationController.viewControllers mutableCopy];
    [viewControllers removeAllObjects];
    [viewControllers addObject:[navigationController.viewControllers firstObject]];
    [viewControllers addObject:authorizationController];
    
    navigationController.navigationBarHidden = NO;
    [navigationController setViewControllers:viewControllers animated:YES];
}

@end
