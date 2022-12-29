//
//  Q8CouponsViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/3/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8CouponsViewController.h"
#import "Q8CouponTableViewCell.h"
#import "Q8ShowCouponViewController.h"
#import "Q8CouponsNavbarPopupView.h"
#import "Q8LoadingTableViewCell.h"

@interface Q8CouponsViewController () <WLAlertControllerDelegate>
@end

@implementation Q8CouponsViewController {
    NSMutableArray <Q8Coupon *> *allCoupons;
    
    Q8Coupon *couponToDelete;
    Q8CouponsCount *couponsCount;
    // Filters
    Q8CouponStatus selectedFilter;
    Q8CouponsNavbarPopupView *navbarPopup;
    BOOL navbarPopupOpened;
    
    // Timer to count down
    NSTimer *oneSecondTimer;
    
    NSInteger currentCouponPage;
    NSInteger couponsTotalCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Addd "filters" popup
    navbarPopup = [Q8CouponsNavbarPopupView viewFromXib];
    CGRect popupFrame = navbarPopup.frame;
    popupFrame.origin.x = [UIScreen mainScreen].bounds.size.width - popupFrame.size.width - 4.0f;
    navbarPopup.frame = popupFrame;
    // Targets for checkbox buttons
    [navbarPopup.activeCheckboxButton addTarget:self action:@selector(activePopupButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navbarPopup.archivedCheckboxButton addTarget:self action:@selector(archivedPopupButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navbarPopup.usedCheckboxButton addTarget:self action:@selector(usedPopupButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navbarPopup.expiredCheckboxButton addTarget:self action:@selector(expiredPopupButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navbarPopup];
    
    // Register cells
    UINib *cellNib = [UINib nibWithNibName:Q8CouponCellXibName bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:Q8CouponCellIdentifier];
    UINib *loadingNib = [UINib nibWithNibName:Q8LoadingCellXibName bundle:nil];
    [self.tableView registerNib:loadingNib forCellReuseIdentifier:Q8LoadingCellIdentifier];
    self.tableView.estimatedRowHeight = 300.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Init allCoupons Array
    allCoupons = [NSMutableArray array];
    currentCouponPage = 1;
    
    // Default selected filter is "active"
    selectedFilter = Q8CouponStatusActive;
    navbarPopupOpened = NO;
    [self toggleFiltersPopupHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadFilterRepresentation];
    [self startCountdown];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopCountdown];
}

#pragma mark - Controller logic

- (void)reloadTableView {
    self.noResultsView.hidden = [[self coupons] count];
    NSString *statusString = [Q8Coupon stringFromStatus:selectedFilter];
    self.noResultsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"You don't have any %@ coupons", nil), [statusString lowercaseString]];
    
    [self reloadPopupCounts];
    
    [self.tableView reloadData];
}

- (void)reloadPopupCounts {
    navbarPopup.activeCountLabel.text = [@(couponsCount.activeCount) stringValue];
    navbarPopup.archivedCountLabel.text = [@(couponsCount.archivedCount) stringValue];
    navbarPopup.usedCountLabel.text = [@(couponsCount.usedCount) stringValue];
    navbarPopup.expiredCountLabel.text = [@(couponsCount.expiredCount) stringValue];
}

- (NSArray <Q8Coupon *> *)coupons {
    return allCoupons;
}

- (void)showActivityIndicator:(BOOL)isNeedShowActivity {
    if (isNeedShowActivity) {
        [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    } else {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
    }
    
    self.view.userInteractionEnabled = !isNeedShowActivity;
}

#pragma mark - Countdown logic

- (void)startCountdown {
    // Start one second timer to count down
    __weak typeof(self) weakSelf = self;
    oneSecondTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:weakSelf selector:@selector(reloadCouponsCountdown) userInfo:nil repeats:YES];
    oneSecondTimer.tolerance = 0.1f;
}

- (void)stopCountdown {
    [oneSecondTimer invalidate];
}

- (void)reloadCouponsCountdown {
    for (Q8CouponTableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell respondsToSelector:@selector(reloadCouponCountdown)] &&
            (selectedFilter == Q8CouponStatusActive ||
             selectedFilter == Q8CouponStatusArchived)) {
                
                if (cell.storedCoupon.isExpired) {
                    [self reloadTableView];
                    break;
                }
                [cell reloadCouponCountdown];
            }
    }
    [self reloadPopupCounts];
}

#pragma mark - Filters popup logic

- (void)reloadFilterRepresentation {
    // Checkbox on the active filter
    UIImage *selectedImage = [[UIImage imageNamed:@"icon_checkmark_checked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *emptyImage = [[UIImage imageNamed:@"icon_checkmark_empty"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    navbarPopup.activeCheckboxImageView.image = (selectedFilter == Q8CouponStatusActive) ? selectedImage : emptyImage;
    navbarPopup.archivedCheckboxImageView.image = (selectedFilter == Q8CouponStatusArchived) ? selectedImage : emptyImage;
    navbarPopup.usedCheckboxImageView.image = (selectedFilter == Q8CouponStatusUsed) ? selectedImage : emptyImage;
    navbarPopup.expiredCheckboxImageView.image = (selectedFilter == Q8CouponStatusExpired) ? selectedImage : emptyImage;
    
    // Load coupons
    [self getCouponsFromServerNewCouponList:YES];
}

- (void)toggleFiltersPopupHidden:(BOOL)hidden animated:(BOOL)animated {
    [navbarPopup popupHidden:hidden animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self coupons] count] < couponsTotalCount ? [[self coupons] count] + 1 : [[self coupons] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isNeedShowLoadingCell = indexPath.row > [[self coupons] count] - 1 ? YES : NO;
    if (isNeedShowLoadingCell) {
        Q8LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8LoadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    Q8CouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8CouponCellIdentifier forIndexPath:indexPath];
    Q8Coupon *coupon = [[self coupons] objectAtIndex:indexPath.row];
    [cell setupForCoupon:coupon];
    
    // Add button targets
    [cell.archiveButton addTarget:self action:@selector(cellArchiveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteButton addTarget:self action:@selector(cellDeleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell: (UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [allCoupons count] - 1 && [allCoupons count] < couponsTotalCount) {
        currentCouponPage++;
        [self getCouponsFromServerNewCouponList:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Move to coupon if it is still active
    Q8Coupon *coupon = [[self coupons] objectAtIndex:indexPath.row];
    if (coupon.status == Q8CouponStatusArchived || coupon.status == Q8CouponStatusActive) {
        [self moveToCoupon:coupon];
    }
}

#pragma mark - Alert controller delegate

- (void)didUseActionAtIndex:(NSInteger)actionIndex ofAlertController:(UIAlertController *)alertController withReason:(NSInteger)alertControllerReason {
}

- (void)didUseDestructiveActionOfAlertController:(NSInteger)alertControllerReason {
    if ((alertControllerReason == Q8ReasonConfitmCouponDelete) || (alertControllerReason == Q8ReasonConfitmCouponDelete_ar)) {
        // Delete coupon
        [self deleteCouponOnServer:couponToDelete];
    }
}

#pragma mark - Cell button actions

- (void)cellDeleteButtonAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    // Alert "are you sure?"
    couponToDelete = [[self coupons] objectAtIndex:indexPath.row];
    [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonConfitmCouponDelete] delegate:self];
}

- (void)cellArchiveButtonAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Q8Coupon *coupon = [[self coupons] objectAtIndex:indexPath.row];
    
    // Archive coupon
    if (coupon.isArchived) {
        [self unarchiveCouponOnServer:coupon];
    } else {
        [self archiveCouponOnServer:coupon];
    }
}

#pragma mark - Popup button actions 

- (void)activePopupButtonAction {
    selectedFilter = Q8CouponStatusActive;
    [self reloadFilterRepresentation];
    navbarPopupOpened = NO;
    [self toggleFiltersPopupHidden:!navbarPopupOpened animated:YES];
}

- (void)archivedPopupButtonAction {
    selectedFilter = Q8CouponStatusArchived;
    [self reloadFilterRepresentation];
    navbarPopupOpened = NO;
    [self toggleFiltersPopupHidden:!navbarPopupOpened animated:YES];
}

- (void)usedPopupButtonAction {
    selectedFilter = Q8CouponStatusUsed;
    [self reloadFilterRepresentation];
    navbarPopupOpened = NO;
    [self toggleFiltersPopupHidden:!navbarPopupOpened animated:YES];
}

- (void)expiredPopupButtonAction {
    selectedFilter = Q8CouponStatusExpired;
    [self reloadFilterRepresentation];
    navbarPopupOpened = NO;
    [self toggleFiltersPopupHidden:!navbarPopupOpened animated:YES];
}

#pragma mark - Button actions

- (IBAction)filtersButtonAction:(id)sender {
    navbarPopupOpened = !navbarPopupOpened;
    [self toggleFiltersPopupHidden:!navbarPopupOpened animated:YES];
}

#pragma mark - Navigation

- (void)moveToCoupon:(Q8Coupon *)coupon {
    Q8ShowCouponViewController *couponController = (Q8ShowCouponViewController *)[WLUtilityHelper viewControllerFromStoryboard:@"Client" controllerIdentifier:Q8ShowCouponControllerIdentifier];
    couponController.coupon = coupon;
    [self.navigationController pushViewController:couponController animated:YES];
}

#pragma mark - Server requests

- (void)getCouponsFromServerNewCouponList:(BOOL)newCouponList {
    [self showActivityIndicator:YES];
    self.noResultsView.hidden = YES;
    if (newCouponList) {
        currentCouponPage = 1;
    }
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] getCouponsByCategory:[[Q8Coupon stringFromStatus:selectedFilter] lowercaseString] page:currentCouponPage onCompletion:^(BOOL success, NSArray<Q8Coupon *> *couponArray, Q8CouponsCount *couponCounts, NSInteger couponsByCategoryCount) {
        if (success) {
            strongify(self)
            [self showActivityIndicator:NO];
            if (newCouponList) {
                [allCoupons removeAllObjects];
            }
            [allCoupons addObjectsFromArray:couponArray];
            couponsTotalCount = couponsByCategoryCount;
            couponsCount = couponCounts;
            [self reloadTableView];
        }        
    } sender:self];
}


- (void)deleteCouponOnServer:(Q8Coupon *)coupon {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] deleteCoupon:coupon.couponID onCompletion:^(BOOL success) {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
        if (success) {
            strongify(self);
            [allCoupons removeObject:coupon];
            couponsTotalCount--;
            selectedFilter == Q8CouponStatusActive ? couponsCount.activeCount-- : couponsCount.archivedCount--;
            [self reloadTableView];
        }
    } sender:self];
}


- (void)archiveCouponOnServer:(Q8Coupon *)coupon {
     [self updateCouponOnServer:coupon archive:YES];
}

- (void)unarchiveCouponOnServer:(Q8Coupon *)coupon {
    [self updateCouponOnServer:coupon archive:NO];
}

- (void)updateCouponOnServer:(Q8Coupon *)coupon archive:(BOOL)archive {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] updateCoupon:coupon.couponID archive:archive onCompletion:^(BOOL success) {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
        if (success) {
            strongify(self);
            [allCoupons removeObject:coupon];
            couponsTotalCount--;
            couponsCount.archivedCount = archive ? couponsCount.archivedCount + 1 : couponsCount.archivedCount - 1;
            couponsCount.activeCount = archive ? couponsCount.activeCount - 1 : couponsCount.activeCount + 1;
            [self reloadTableView];
        }
    } sender:self];
}

@end
