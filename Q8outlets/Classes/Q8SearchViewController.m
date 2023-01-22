//
//  Q8SearchViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8SearchViewController.h"
#import "Q8MerchantTableViewCell.h"
#import "Q8ClientOfferTableViewCell.h"
#import "Q8SearchNavbarPopupView.h"
#import "Q8TextField.h"
#import "Q8LoadingTableViewCell.h"
#import "Q8ShareHelper.h"

@interface Q8SearchViewController ()
@end

typedef enum {
    Q8SearchTabMerchants,
    Q8SearchTabOffers
}  Q8SearchTab;

@implementation Q8SearchViewController {
    NSMutableArray <Q8Merchant *> *allMerchants;
    NSMutableArray <Q8Offer *> *allOffers;
    
    Q8SearchTab currentTab;
    Q8Offer *offerToShare;
    
    BOOL nearMe;
    Q8SearchNavbarPopupView *navbarPopup; // popup with "near me"
    BOOL navbarPopupOpened;
    
    NSInteger merchantCurrentPage;
    NSInteger merchantsTotalCount;
    
    NSInteger offerCurrentPage;
    NSInteger offersTotalCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Visual setup
    // Category name will be title, if present
    if (self.category) {
        self.navigationItem.title = self.category.categoryName;
    }
    
    // Register cells
    UINib *offerNib = [UINib nibWithNibName:Q8ClientOfferCellXibName bundle:nil];
    [self.tableView registerNib:offerNib forCellReuseIdentifier:Q8ClientOfferCellIdentifier];
    UINib *merchantNib = [UINib nibWithNibName:Q8MerchantCellXibName bundle:nil];
    [self.tableView registerNib:merchantNib forCellReuseIdentifier:Q8MerchantCellIdentifier];
    UINib *loadingNib = [UINib nibWithNibName:Q8LoadingCellXibName bundle:nil];
    [self.tableView registerNib:loadingNib forCellReuseIdentifier:Q8LoadingCellIdentifier];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Keyboard notifs
    [self registerForKeyboardNotifications];
    
    // Addd "near me" popup
    navbarPopup = [Q8SearchNavbarPopupView viewFromXib];
    CGRect popupFrame = navbarPopup.frame;
    popupFrame.origin.x = [UIScreen mainScreen].bounds.size.width - popupFrame.size.width - 4.0f;
    navbarPopup.frame = popupFrame;
    // Target for checkbox
    [navbarPopup.checkboxButton addTarget:self action:@selector(nearMePopupButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navbarPopup];
    
    // Register for offer follow/like changes
    [Q8NotificationHelper addObserverToAnyOfferChange:self];
    
    // "Near me" is on by default and popup is closed
    nearMe = YES;
    [self reloadNearMeRepresentation];
    navbarPopupOpened = NO;
    [self toggleFiltersPopupHidden:YES animated:NO];
    
    // Merchants is default tab
    currentTab = Q8SearchTabMerchants;
    [self reloadCurrentSearchTabRepresentation];
    
    // If not category - if moved by search, start search
    if (!self.category) {
        [self.searchTextField becomeFirstResponder];
    }
    
    // Set current merchant search page
    merchantCurrentPage = 1;
    allMerchants = [NSMutableArray array];
    
    // Set current offers search page
    offerCurrentPage = 1;
    allOffers = [NSMutableArray array];
    
    // Load all merchants and items near me
    [self searchOnServer:NO AndUpdateList:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    [self reloadTableView];
}

#pragma mark - Controller logic

- (void)reloadTableView {
    BOOL shouldShowNoResults = NO;
    if (currentTab == Q8SearchTabMerchants) {
        shouldShowNoResults = ![[self merchants] count];
    } else {
        shouldShowNoResults = ![[self offers] count];
    }
    
    self.noResultsView.hidden = !shouldShowNoResults;
    self.tableView.hidden = shouldShowNoResults;
    [self.tableView reloadData];
}

- (NSArray <Q8Merchant *> *)merchants {
    // All results or search results
    return allMerchants;
}

- (NSArray <Q8Offer *> *)offers {
    // All results or search results
    return allOffers;
}

- (void)showActivityIndicator:(BOOL)isNeedShowActivity {
    if (isNeedShowActivity) {
        self.noResultsView.hidden = YES;
        self.tableView.hidden = YES;
        [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    } else {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
    }
    
    self.view.userInteractionEnabled = !isNeedShowActivity;
}

#pragma mark - Search logic

- (void)commitSearch {
    // Either send search to server, or display all items if search stopped
    [self searchOnServer:YES AndUpdateList:YES];
}

- (void)reloadSearchSeparatorRepresentation {
    // Green line under search, if filled
    self.searchSeparatorView.hidden = !self.searchTextField.text.length;
}


#pragma mark - Filters popup logic

- (void)reloadNearMeRepresentation {
    // Checkbox icon
    navbarPopup.checkboxImageView.image = [[UIImage imageNamed: nearMe ? @"icon_checkmark_checked" : @"icon_checkmark_empty"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)toggleFiltersPopupHidden:(BOOL)hidden animated:(BOOL)animated {
    [navbarPopup popupHidden:hidden animated:animated];
}

#pragma mark - Tabs logic

- (void)reloadCurrentSearchTabRepresentation {
    // Move "selected tab" green view under correct tab, change tab color
    [self.merchantsTabButton setTitleColor:((currentTab == Q8SearchTabMerchants) ?
                                            Q8RedDefaultColor :
                                            [UIColor grayColor])
                                  forState:UIControlStateNormal];
    [self.offersTabButton setTitleColor:((currentTab == Q8SearchTabOffers) ?
                                            Q8RedDefaultColor :
                                            [UIColor grayColor])
                                  forState:UIControlStateNormal];
    
    self.merchantsTabButton.userInteractionEnabled = (currentTab != Q8SearchTabMerchants);
    self.offersTabButton.userInteractionEnabled = (currentTab != Q8SearchTabOffers);
    
    [UIView animateWithDuration:0.2f animations:^{
        self.centerActiveTabOnMerchantsConstraint.priority = self->currentTab == Q8SearchTabMerchants ? 990 : 100;
        [self.activeTabBottomView.superview layoutIfNeeded];
    }];
    
    // Estimated row height is different
    self.tableView.estimatedRowHeight = ((currentTab == Q8SearchTabMerchants) ?
                                         [WLVisualHelper customCellHeightFromNibName:Q8MerchantCellXibName] :
                                         [WLVisualHelper customCellHeightFromNibName:Q8ClientOfferCellXibName]);
}

#pragma mark - Keyboard

- (void)registerForKeyboardNotifications {
    // Keyboard notifications for table view insets
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)keyboardWillBeShown:(NSNotification*)notification {
    // Called when the UIKeyboardWillShowNotification is sent
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat tabbarHeight = self.tabBarController.tabBar.frame.size.height;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, kbSize.height - tabbarHeight, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    // Called when the UIKeyboardWillHideNotification is sent
    [self.tableView reloadData];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 0.0, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Alert controller delegate

- (void)didUseActionAtIndex:(NSInteger)actionIndex ofAlertController:(UIAlertController *)alertController withReason:(NSInteger)alertControllerReason {
    if ((alertControllerReason == Q8ReasonShareOption) || (alertControllerReason == Q8ReasonShareOption_ar)){
        if (actionIndex == 0) {
            [Q8ShareHelper shareOfferToFacebook:offerToShare];
        } else if (actionIndex == 1) {
            [Q8ShareHelper shareOfferToOther:offerToShare];
        }
    }
}

#pragma mark - Text field delegate

- (IBAction)textFieldDidChange:(id)sender {
    [self commitSearch];
    [self reloadSearchSeparatorRepresentation];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Text field navigation
    [self hideKeyboard];
    
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsCount;
    // Either offers or merchants depending on the tab
    if (currentTab == Q8SearchTabMerchants) {
        rowsCount = [[self merchants] count] < merchantsTotalCount ? [[self merchants] count] + 1 : [[self merchants] count];
    } else {
        rowsCount = [[self offers] count] < offersTotalCount ? [[self offers] count] + 1 : [[self offers] count];
    }
    
    return  rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isNeedShowLoadingCellONMerchantsTab = indexPath.row > [[self merchants] count] - 1 ? YES : NO;
    BOOL isNeedShowLoadingCellONOffersTab = indexPath.row > [[self offers] count] - 1 ? YES : NO;
    if (currentTab == Q8SearchTabMerchants && isNeedShowLoadingCellONMerchantsTab) {
        Q8LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8LoadingCellIdentifier forIndexPath:indexPath];
        return cell;
    } else if (currentTab == Q8SearchTabOffers && isNeedShowLoadingCellONOffersTab) {
        Q8LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8LoadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    // Either offers or merchants depending on the tab
    
    if (currentTab == Q8SearchTabMerchants) {
        Q8MerchantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8MerchantCellIdentifier forIndexPath:indexPath];
        Q8Merchant *merchant = [[self merchants] objectAtIndex:indexPath.row];
        merchant.category = self.category ?: merchant.category;
        [cell setupForMerchant:merchant];
        return cell;
    } else {
        Q8ClientOfferTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8ClientOfferCellIdentifier forIndexPath:indexPath];
        Q8Offer *offer = [[self offers] objectAtIndex:indexPath.row];
        [cell setupForOffer:offer];
        
        // Add button targets
        [cell.likeButton addTarget:self action:@selector(cellLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.followButton addTarget:self action:@selector(cellFollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.shareButton addTarget:self action:@selector(cellShareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (currentTab == Q8SearchTabMerchants) {
        if (indexPath.row == [allMerchants count] - 1 && [allMerchants count] < merchantsTotalCount) {
            merchantCurrentPage++;
            [self searchOnServer:NO AndUpdateList:NO];
        }
    } else {
        if (indexPath.row == [allOffers count] - 1 && [allOffers count] < offersTotalCount) {
            offerCurrentPage++;
            [self searchOnServer:NO AndUpdateList:NO];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Move to merchant/offer
    if (currentTab == Q8SearchTabMerchants) {
        Q8Merchant *merchant = [[self merchants] objectAtIndex:indexPath.row];
        [Q8NavigationManager moveToMerchant:merchant];
    } else {
        Q8Offer *offer = [[self offers] objectAtIndex:indexPath.row];
        [Q8NavigationManager moveToClientOffer:offer];
    }
}

#pragma mark - Offer change notification observer

- (void)offerLikeStatusChanged:(Q8Offer *)changedOffer likeStatus:(BOOL)likeStatus {
    // Search for affected offer and change
    for (Q8Offer *offer in allOffers) {
        if ([offer.offerId isEqualToString:changedOffer.offerId]) {
            if (offer.isLiked != likeStatus) {
                offer.isLiked = likeStatus;
                if (offer.isLiked) {
                    offer.likesCount++;
                } else {
                    offer.likesCount--;
                }
            }
            
            if (currentTab == Q8SearchTabOffers &&
                [[self offers] containsObject:offer]) {
                [self reloadTableView];
            }
            
            return;
        }
    }
}

- (void)offerFollowStatusChanged:(Q8Offer *)changedOffer followStatus:(BOOL)followStatus {
    // Search for affected offer and change
    for (Q8Offer *offer in allOffers) {
        if ([offer.offerId isEqualToString:changedOffer.offerId]) {
            offer.isFollowed = followStatus;
            
            if (currentTab == Q8SearchTabOffers &&
                [[self offers] containsObject:offer]) {
                [self reloadTableView];
            }
            
            return;
        }
    }
}

- (void)offerCouponCountChanged:(Q8Offer *)changedOffer couponApplied:(BOOL)isApplied {
    for (Q8Offer *offer in allOffers) {
        if ([offer.offerId isEqualToString:changedOffer.offerId]) {
            if (offer.isApplied != isApplied) {
                offer.isApplied = isApplied;
                offer.availableCoupons--;
            }
            if (currentTab == Q8SearchTabOffers) {
                [self reloadTableView];
            }
            
            return;
        }
    }
}

#pragma mark - Offer change property success server request

- (void)offer:(Q8Offer *)offer likeSuccess:(BOOL)success {
    offer.isCanLike = YES;
    if (success) {
        if (currentTab == Q8SearchTabOffers &&
            [[self offers] containsObject:offer]) {
            [self reloadTableView];
        }
    } else {
        [Q8NotificationHelper postOfferLikeChangeNotification:offer likeStatus:!offer.isLiked];
    }
}

- (void)offer:(Q8Offer *)offer followSuccess:(BOOL)success {
    offer.isCanFollow = YES;
    if (success) {
        if (currentTab == Q8SearchTabOffers &&
            [[self offers] containsObject:offer]) {
            [self reloadTableView];
        }
    } else {
        [Q8NotificationHelper postOfferFollowChangeNotification:offer followStatus:!offer.isFollowed];
    }
}

#pragma mark - Merchant change notification observer

- (void)merchantFollowStatusChanged:(Q8Merchant *)changedMerchant followStatus:(BOOL)followStatus {
    for (Q8Merchant *merchant in allMerchants) {
        if ([merchant.merchantId isEqualToString:changedMerchant.merchantId]) {
            merchant.isFollowed = followStatus;
            return;
        }
    }
}

#pragma mark - Cell button actions

- (void)cellLikeButtonAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Q8Offer *offer = [[self offers] objectAtIndex:indexPath.row];
    
    [self likeOfferOnServer:offer];
}

- (void)cellFollowButtonAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Q8Offer *offer = [[self offers] objectAtIndex:indexPath.row];
    
    [self followOfferOnServer:offer];
}

- (void)cellShareButtonAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Q8Offer *offer = [[self offers] objectAtIndex:indexPath.row];
    offerToShare = offer;
    [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonShareOption] delegate:self];
}

#pragma mark - Popup button actions

- (void)nearMePopupButtonAction {
    nearMe = !nearMe;
    [self searchOnServer:NO AndUpdateList:YES]; // redo search with new filter
    [self reloadNearMeRepresentation];
}

#pragma mark - Button actions

- (IBAction)merchantsTabButtonAction:(id)sender {
    if (currentTab != Q8SearchTabMerchants) {
        currentTab = Q8SearchTabMerchants;
        [self reloadCurrentSearchTabRepresentation];
        [self searchOnServer:NO AndUpdateList:YES];
    }
}
- (IBAction)offersTabButtonAction:(id)sender {
    if (currentTab != Q8SearchTabOffers) {
        currentTab = Q8SearchTabOffers;
        [self reloadCurrentSearchTabRepresentation];
        [self searchOnServer:NO AndUpdateList:YES];
    }
}
- (IBAction)filtersButtonAction:(id)sender {
    navbarPopupOpened = !navbarPopupOpened;
    [self toggleFiltersPopupHidden:!navbarPopupOpened animated:YES];
}

#pragma mark - Server requests

- (void)searchOnServer:(BOOL)isSearch AndUpdateList:(BOOL)isNeedUpdateList {
    NSString *categoryID = self.category ? [@(self.category.categoryId) stringValue] : @"";
    NSString *latitude = @"";
    NSString *longtitude = @"";
    if (nearMe) {
        latitude = [[NSNumber numberWithDouble:[WLLocationHelper sharedHelper].currentUserLocationCoordinate.latitude] stringValue];
        longtitude = [[NSNumber numberWithDouble:[WLLocationHelper sharedHelper].currentUserLocationCoordinate.longitude] stringValue];
    }
    if (isNeedUpdateList && !isSearch) {
        [self.tableView setContentOffset:CGPointZero animated:YES];
        [self showActivityIndicator:YES];
    }
    weakify(self);
    if (currentTab == Q8SearchTabMerchants) {
        merchantCurrentPage = isNeedUpdateList ? 1 : merchantCurrentPage;
        
        [[Q8ServerAPIHelper sharedHelper] getMerchantsByCategoryID:categoryID text:self.searchTextField.text latitude:latitude longtitude:longtitude page:merchantCurrentPage searchByfollow:NO onCompletion:^(BOOL success, NSArray <Q8Merchant *> *merchantsArray, NSInteger merchantCount, NSString *searchText) {
            if ([searchText isEqualToString:self.searchTextField.text]) {
                if (isNeedUpdateList) {
                    [self->allMerchants removeAllObjects];
                }
                [self->allMerchants addObjectsFromArray:merchantsArray];
                self->merchantsTotalCount = merchantCount;
                strongify(self);
                [self showActivityIndicator:NO];
                [self reloadTableView];
            }
        } sender:self];
    } else {
        offerCurrentPage =  isNeedUpdateList ? 1 : offerCurrentPage;
        
        [[Q8ServerAPIHelper sharedHelper] getOffersByCategoryID:categoryID businessID:@"" text:self.searchTextField.text latitude:latitude longtitude:longtitude page:offerCurrentPage searchByfollow:NO onCompletion:^(BOOL success, NSArray <Q8Offer *> *offersArray, NSInteger offersCount, NSString *searchText) {
            if ([searchText isEqualToString:self.searchTextField.text]) {
                if (isNeedUpdateList) {
                    [self->allOffers removeAllObjects];
                }
                [self->allOffers addObjectsFromArray:offersArray];
                self->offersTotalCount = offersCount;
                strongify(self);
                [self showActivityIndicator:NO];
                [self reloadTableView];
            }
        } sender:self];
    }    
}

- (void)likeOfferOnServer:(Q8Offer *)offer {
    offer.isCanLike = NO;
    weakify(self);
    if (offer.isLiked) {
        [[Q8ServerAPIHelper sharedHelper] removeLikeFromOffer:offer.offerId onCompletion:^(BOOL success) {
            strongify(self);
            [self offer:offer likeSuccess:success];
        } sender:self];
    } else {
        [[Q8ServerAPIHelper sharedHelper] addLikeToOffer:offer.offerId onCompletion:^(BOOL success) {
            strongify(self);
            [self offer:offer likeSuccess:success];
        } sender:self];
    }
    [Q8NotificationHelper postOfferLikeChangeNotification:offer likeStatus:!offer.isLiked];
}

- (void)followOfferOnServer:(Q8Offer *)offer {
    offer.isCanFollow = NO;
    weakify(self);
    if (offer.isFollowed) {
        [[Q8ServerAPIHelper sharedHelper] removeFollowFromOffer:offer.offerId onCompletion:^(BOOL success) {
            strongify(self);
            [self offer:offer followSuccess:success];
        } sender:self];
    } else {
        [[Q8ServerAPIHelper sharedHelper] followOffer:offer.offerId onCompletion:^(BOOL success) {
            strongify(self);
            [self offer:offer followSuccess:success];
        } sender:self];
    }
    [Q8NotificationHelper postOfferFollowChangeNotification:offer followStatus:!offer.isFollowed];
}

@end
