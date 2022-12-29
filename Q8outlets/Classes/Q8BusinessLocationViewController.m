//
//  Q8BusinessLocationViewController.m
//  Q8outlets
//
//  Created by GlebGamaun on 23.03.17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8BusinessLocationViewController.h"
#import "Q8MerchantLocationTableViewCell.h"
#import "Q8LoadingTableViewCell.h"

@interface Q8BusinessLocationViewController ()

@end

@implementation Q8BusinessLocationViewController {
    NSMutableArray <Q8MerchantLocation *> *allLocations;
    
    NSInteger currentPage;
    NSInteger locationsTotalCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cells
    UINib *loadingNib = [UINib nibWithNibName:Q8LoadingCellXibName bundle:nil];
    [self.tableView registerNib:loadingNib forCellReuseIdentifier:Q8LoadingCellIdentifier];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    allLocations = [NSMutableArray array];
    
    // Request location
    [[WLLocationHelper sharedHelper] requestInUseAuthorization];
    
    [self loadLocationsFromServer];
}

#pragma mark - Controller logic

- (void)reloadTableView {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, self.tableView.frame.size.width, 44.0)];

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor whiteColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = Q8DarkGrayColor;
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont fontWithName:@"Raleway-Regular" size:17];
    headerLabel.frame = CGRectMake(10.0, 0.0, self.tableView.frame.size.width, 44.0);
    headerLabel.text = NSLocalizedString(@"Please, select your location", nil);
    [customView addSubview:headerLabel];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, customView.frame.size.height, customView.frame.size.width, 1.0)];
    separatorView.backgroundColor = Q8LightGrayColor;
    [customView addSubview:separatorView];
    
    return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return allLocations.count < locationsTotalCount ? allLocations.count + 1 : allLocations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isNeedShowLoadingCell = indexPath.row > allLocations.count - 1 ? YES : NO;
    if (isNeedShowLoadingCell) {
        Q8LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8LoadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    Q8MerchantLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8MerchantLocationCellIdentifier forIndexPath:indexPath];
    [cell setupForMerchantLocation:allLocations[indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell: (UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == allLocations.count - 1 && allLocations.count < locationsTotalCount) {
        currentPage++;
        [self loadLocationsFromServer];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    Q8MerchantLocation *location = [allLocations objectAtIndex:indexPath.row];
    [Q8CurrentUser saveUserLocationID:location.locationId];
    [Q8CurrentUser saveUserLocation:location.locationAddress];
    
    self.navigationItem.hidesBackButton = NO;
    
    [self reloadTableView];
}

#pragma mark - Server requests

- (void)loadLocationsFromServer {
    if (!allLocations.count) {
        [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    }
    
    NSString *latitude = [[NSNumber numberWithDouble:[WLLocationHelper sharedHelper].currentUserLocationCoordinate.latitude] stringValue];
    NSString *longtitude = [[NSNumber numberWithDouble:[WLLocationHelper sharedHelper].currentUserLocationCoordinate.longitude] stringValue];
    weakify(self)
    [[Q8ServerAPIHelper sharedHelper] getMerchantLocationsByLatitude:latitude longtitude:longtitude page:currentPage onCompletion:^(BOOL success, NSArray<Q8MerchantLocation *> *locations, NSInteger locationsCount)
     {
         [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
         
         strongify(self);
         [allLocations addObjectsFromArray:locations];
         locationsTotalCount = locationsCount;
         [self reloadTableView];
        
    } sender:self];
}

@end
