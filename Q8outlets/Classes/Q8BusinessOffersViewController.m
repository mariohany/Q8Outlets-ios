//
//  Q8BusinessOffersViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8BusinessOffersViewController.h"
#import "Q8BusinessOfferTableViewCell.h"
#import "Q8LoadingTableViewCell.h"

@interface Q8BusinessOffersViewController ()

@end

@implementation Q8BusinessOffersViewController {
    NSMutableArray <Q8Offer *> *offers;
    NSInteger currentOfferPage;
    NSInteger offersTotalCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell
    UINib *loadingNib = [UINib nibWithNibName:Q8LoadingCellXibName bundle:nil];
    [self.tableView registerNib:loadingNib forCellReuseIdentifier:Q8LoadingCellIdentifier];
    // Dynamic table view height
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    offers = [NSMutableArray array];
    currentOfferPage = 1;
    
    // Load offers
    [self loadOffersFromServer];
}

#pragma mark - Controller logic

- (void)reloadTableView {
    self.noOffersView.hidden = [offers count];
    self.tableView.hidden = !self.noOffersView.hidden;
    [self.tableView reloadData];
}

- (void)showActivityIndicator:(BOOL)isNeedShowActivity {
    if (isNeedShowActivity) {
        self.noOffersView.hidden = YES;
        self.tableView.hidden = YES;
        [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    } else {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
    }
    
    self.view.userInteractionEnabled = !isNeedShowActivity;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [offers count] < offersTotalCount ? [offers count] + 1 : [offers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isNeedShowLoadingCell = indexPath.row > [offers count] - 1 ? YES : NO;
    if (isNeedShowLoadingCell) {
        Q8LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8LoadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    Q8BusinessOfferTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8BusinessOfferCellIdentifier];
    Q8Offer *offer = [offers objectAtIndex:indexPath.row];
    [cell setupForOffer:offer];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell: (UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [offers count] - 1 && [offers count] < offersTotalCount) {
        currentOfferPage++;
        [self loadOffersFromServer];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Move to offer
    Q8Offer *offer = [offers objectAtIndex:indexPath.row];
    [Q8NavigationManager moveToBusinessOffer:offer];
}

#pragma mark - Server requests

- (void)loadOffersFromServer {
    [self showActivityIndicator:YES];
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] getActiveOffersForBusiness:@"" page:currentOfferPage onCompletions:^(BOOL success, NSArray<Q8Offer *> *offersArray, NSInteger offersCount) {
        [self->offers addObjectsFromArray:offersArray];
        self->offersTotalCount = offersCount;
        strongify(self);
        [self showActivityIndicator:NO];
        [self reloadTableView];
        
    } sender:self];
}

@end
