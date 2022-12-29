//
//  Q8BusinessOfferViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8BusinessOfferViewController.h"
#import "Q8OfferLocationTableViewCell.h"

@interface Q8BusinessOfferViewController ()

@end

@implementation Q8BusinessOfferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    [WLVisualHelper templatizeImageView:self.availableImageView withColor:[UIColor darkGrayColor]];
    [WLVisualHelper templatizeImageView:self.usedImageView withColor:Q8RedDefaultColor];
    [WLVisualHelper templatizeImageView:self.expiredImageView withColor:Q8OrangeColor];
    
    // Populate offer data
    [self populateOfferRepresentation];
}

#pragma mark - Controller logic

- (void)populateOfferRepresentation {    
    [Q8ImageHelper setOfferPromoImage:self.offer intoImageView:self.promoImageView];
    self.titleLabel.text = self.offer.title;
    [self.addressesTableView reloadData];
    
    self.totalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.offer.totalCoupons];
    self.availableCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.offer.availableCoupons];
    self.appliedCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.offer.appliedCoupons];
    self.pendingCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.offer.pendingCoupons];
    self.usedCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.offer.usedCoupons];
    self.expiredCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.offer.expiredCoupons];
    
    self.addressesHeightConstraint.constant = self.addressesTableView.contentSize.height;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.offer.locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Q8OfferLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8OfferLocationCellIdentifier];
    Q8MerchantLocation *location = [self.offer.locations objectAtIndex:indexPath.row];
    [cell setupForLocation:location forMerchant:self.offer.merchant];
    return cell;
}

#pragma mark - Server requests

@end
