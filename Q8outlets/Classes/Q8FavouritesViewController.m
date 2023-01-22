//
//  Q8FavouritesViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/9/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8FavouritesViewController.h"
#import "Q8MerchantTableViewCell.h"
#import "Q8ClientOfferTableViewCell.h"
#import "Q8LoadingTableViewCell.h"
#import "Q8ShareHelper.h"

@interface Q8FavouritesViewController ()
@end

typedef enum {
    Q8FavTabMerchants,
    Q8FavTabOffers
}  Q8FavTab;

@implementation Q8FavouritesViewController {
    NSMutableArray <Q8Merchant *> *favMerchants;
    NSMutableArray <Q8Offer *> *favOffers;
    
    Q8Offer *offerToShare;
    
    NSInteger merchantCurrentPage;
    NSInteger merchantsTotalCount;
    
    NSInteger offerCurrentPage;
    NSInteger offersTotalCount;
    
    Q8FavTab currentTab;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cells
    UINib *offerNib = [UINib nibWithNibName:Q8ClientOfferCellXibName bundle:nil];
    [self.tableView registerNib:offerNib forCellReuseIdentifier:Q8ClientOfferCellIdentifier];
    UINib *merchantNib = [UINib nibWithNibName:Q8MerchantCellXibName bundle:nil];
    [self.tableView registerNib:merchantNib forCellReuseIdentifier:Q8MerchantCellIdentifier];
    UINib *loadingNib = [UINib nibWithNibName:Q8LoadingCellXibName bundle:nil];
    [self.tableView registerNib:loadingNib forCellReuseIdentifier:Q8LoadingCellIdentifier];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Merchants is default tab
    currentTab = Q8FavTabMerchants;
    [self reloadCurrentSearchTabRepresentation];
    
    // Register for offer/merchant follow/like changes
    [Q8NotificationHelper addObserverToAnyOfferChange:self];
    [Q8NotificationHelper addObserverToAnyMerchantChange:self];
    
    favMerchants = [NSMutableArray array];
    favOffers = [NSMutableArray array];
    
    merchantCurrentPage = 1;
    offerCurrentPage = 1;
    
    // Load favs
    [self loadFavsFromServerAndUpdateList:YES];
}

#pragma mark - Controller logic

- (void)reloadTableView {
    BOOL shouldShowNoResults = NO;
    NSString *noResultsText = @"";
    NSString *noResultsTip = @"";
    if (currentTab == Q8FavTabMerchants) {
        shouldShowNoResults = ![favMerchants count];
        noResultsText = NSLocalizedString(@"You are not following any merchants yet", nil);
        noResultsTip = NSLocalizedString(@"If you follow a merchant we will notify you about their new offers", nil);
    } else {
        shouldShowNoResults = ![favOffers count];
        noResultsText = NSLocalizedString(@"You are not following any offers yet", nil);
        noResultsTip = NSLocalizedString(@"If you follow an offer, we will notify you about available coupons", nil);
    }
    
    self.noResultsLabel.text = noResultsText;
    self.noResultsTipLabel.text = noResultsTip;
    self.noResultsView.hidden = !shouldShowNoResults;
    self.tableView.hidden = shouldShowNoResults;
    [self.tableView reloadData];
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

#pragma mark - Tabs logic

- (void)reloadCurrentSearchTabRepresentation {
    // Move "selected tab" green view under correct tab, change tab color
    [self.merchantsTabButton setTitleColor:((currentTab == Q8FavTabMerchants) ?
                                            Q8RedDefaultColor :
                                            [UIColor grayColor])
                                  forState:UIControlStateNormal];
    [self.offersTabButton setTitleColor:((currentTab == Q8FavTabOffers) ?
                                         Q8RedDefaultColor :
                                         [UIColor grayColor])
                               forState:UIControlStateNormal];
    
    self.merchantsTabButton.userInteractionEnabled = (currentTab != Q8FavTabMerchants);
    self.offersTabButton.userInteractionEnabled = (currentTab != Q8FavTabOffers);
    
    [UIView animateWithDuration:0.2f animations:^{
        self.centerActiveTabOnMerchantsConstraint.priority = self->currentTab == Q8FavTabMerchants ? 990 : 100;
        [self.activeTabBottomView.superview layoutIfNeeded];
    }];
    
    // Estimated row height is different
    self.tableView.estimatedRowHeight = ((currentTab == Q8FavTabMerchants) ?
                                         [WLVisualHelper customCellHeightFromNibName:Q8MerchantCellXibName] :
                                         [WLVisualHelper customCellHeightFromNibName:Q8ClientOfferCellXibName]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsCount;
    // Either offers or merchants depending on the tab
    if (currentTab == Q8FavTabMerchants) {
        rowsCount = [favMerchants count] < merchantsTotalCount ? [favMerchants count] + 1 : [favMerchants count];
    } else {
        rowsCount = [favOffers count] < offersTotalCount ? [favOffers count] + 1 : [favOffers count];
    }
    
    return  rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isNeedShowLoadingCellONMerchantsTab = indexPath.row > [favMerchants count] - 1 ? YES : NO;
    BOOL isNeedShowLoadingCellONOffersTab = indexPath.row > [favOffers count] - 1 ? YES : NO;
    if (currentTab == Q8FavTabMerchants && isNeedShowLoadingCellONMerchantsTab) {
        Q8LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8LoadingCellIdentifier forIndexPath:indexPath];
        return cell;
    } else if (currentTab == Q8FavTabOffers && isNeedShowLoadingCellONOffersTab) {
        Q8LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8LoadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    // Either offers or merchants depending on the tab
    if (currentTab == Q8FavTabMerchants) {
        Q8MerchantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8MerchantCellIdentifier forIndexPath:indexPath];
        Q8Merchant *merchant = [favMerchants objectAtIndex:indexPath.row];
        [cell setupForMerchant:merchant];
        return cell;
    } else {
        Q8ClientOfferTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8ClientOfferCellIdentifier forIndexPath:indexPath];
        Q8Offer *offer = [favOffers objectAtIndex:indexPath.row];
        [cell setupForOffer:offer];
        
        // Add button targets
        [cell.likeButton addTarget:self action:@selector(cellLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.followButton addTarget:self action:@selector(cellFollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.shareButton addTarget:self action:@selector(cellShareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

#pragma mark - Table view swipe buttons

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Only merchants have unfav button on swipe
    if (currentTab == Q8FavTabMerchants) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Nothing gets called here if you invoke `tableView:editActionsForRowAtIndexPath:` according to Apple docs so just leave this method blank
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *deleteActionWidthModifier = @"            ";
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:deleteActionWidthModifier handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // Delete this merchant from favs
        Q8Merchant *merchant = [self->favMerchants objectAtIndex:indexPath.row];
        [self unfollowMerchantOnServer:merchant];
    }];
    
  
    // Image for swipable button background
    CGRect frame = CGRectMake(0, 0, 62, self.tableView.estimatedRowHeight);
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, Q8OrangeColor.CGColor);
    CGContextFillRect(context, frame);
    UIImage *image = [UIImage imageNamed:@"icon_star_crossed"];
    CGSize imageSize = CGSizeMake(25.0f, 25.0f);
    [image drawInRect:CGRectMake(frame.size.width/2.0, frame.size.height/2.0 - imageSize.height/2.0f, imageSize.width, imageSize.height)]; // Size of the image is reduced so there is padding
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    deleteAction.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];

    return @[deleteAction];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell: (UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [favMerchants count] - 1 && [favMerchants count] < merchantsTotalCount) {
        merchantCurrentPage++;
        [self loadFavsFromServerAndUpdateList:NO];
    } else if (indexPath.row == [favOffers count] - 1 && [favOffers count] < offersTotalCount) {
        offerCurrentPage++;
        [self loadFavsFromServerAndUpdateList:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Move to merchant/offer
    if (currentTab == Q8FavTabMerchants) {
        Q8Merchant *merchant = [favMerchants objectAtIndex:indexPath.row];
        [Q8NavigationManager moveToMerchant:merchant];
    } else {
        Q8Offer *offer = [favOffers objectAtIndex:indexPath.row];
        [Q8NavigationManager moveToClientOffer:offer];
    }
}

#pragma mark - Alert controller delegate

- (void)didUseActionAtIndex:(NSInteger)actionIndex ofAlertController:(UIAlertController *)alertController withReason:(NSInteger)alertControllerReason {
    if ((alertControllerReason == Q8ReasonShareOption) || (alertControllerReason == Q8ReasonShareOption_ar)) {
        if (actionIndex == 0) {
            [Q8ShareHelper shareOfferToFacebook:offerToShare];
        } else if (actionIndex == 1) {
            [Q8ShareHelper shareOfferToOther:offerToShare];
        }
    }
}

#pragma mark - Offer change property success server request

- (void)offer:(Q8Offer *)offer likeSuccess:(BOOL)success {
    offer.isCanLike = YES;
    if (success) {
        [self reloadTableView];
    } else {
        [Q8NotificationHelper postOfferLikeChangeNotification:offer likeStatus:!offer.isLiked];
    }
}

- (void)offer:(Q8Offer *)offer followSuccess:(BOOL)success {
    offer.isCanFollow = YES;
    if (success) {
        [self reloadTableView];
    } else {
        [Q8NotificationHelper postOfferFollowChangeNotification:offer followStatus:!offer.isFollowed];
    }
}

#pragma mark - Offer change notification observer

- (void)offerLikeStatusChanged:(Q8Offer *)changedOffer likeStatus:(BOOL)likeStatus {
    // Search for affected offer and change
    for (Q8Offer *offer in favOffers) {
        if ([offer.offerId isEqualToString:changedOffer.offerId]) {
            if (offer.isLiked != likeStatus) {
                offer.isLiked = likeStatus;
                if (offer.isLiked) {
                    offer.likesCount++;
                } else {
                    offer.likesCount--;
                }
            }            
            
            if (currentTab == Q8FavTabOffers) {
                [self reloadTableView];
            }
            
            return;
        }
    }
}

- (void)offerFollowStatusChanged:(Q8Offer *)changedOffer followStatus:(BOOL)followStatus {
    // Search for affected offer and change
    for (Q8Offer *offer in favOffers) {
        if ([offer.offerId isEqualToString:changedOffer.offerId]) {
            offer.isFollowed = followStatus;
            if (!offer.isFollowed) {
                [favOffers removeObject:offer];
                if (offersTotalCount > 0) {
                    offersTotalCount--;
                }                
            }
            
            if (currentTab == Q8FavTabOffers) {
                [self reloadTableView];
            }
            
            return;
        }
    }
    
    // If no offer affected, and follow added - add offer
    if (followStatus) {
        [favOffers insertObject:changedOffer atIndex:0];
        offersTotalCount++;
        if (currentTab == Q8FavTabOffers) {
            [self reloadTableView];
        }
    }
}

- (void)offerCouponCountChanged:(Q8Offer *)changedOffer couponApplied:(BOOL)isApplied {
    for (Q8Offer *offer in favOffers) {
        if ([offer.offerId isEqualToString:changedOffer.offerId]) {
            if (offer.isApplied != isApplied) {
                offer.isApplied = isApplied;
                offer.availableCoupons--;
            }
            
            if (currentTab == Q8FavTabOffers) {
                [self reloadTableView];
            }
            
            return;
        }
    }
}

#pragma mark - Merchant change notification observer 

- (void)merchantFollowStatusChanged:(Q8Merchant *)changedMerchant followStatus:(BOOL)followStatus {
    // Search for affected merchant and change
    for (Q8Merchant *merchant in favMerchants) {
        if ([merchant.merchantId isEqualToString:changedMerchant.merchantId]) {
            merchant.isFollowed = followStatus;
            if (!merchant.isFollowed) {
                [favMerchants removeObject:merchant];
                if (merchantsTotalCount > 0) {
                    merchantsTotalCount--;
                }
            }
            
            if (currentTab == Q8FavTabMerchants) {
                [self reloadTableView];
            }
            
            return;
        }
    }
   
    // If no offer affected, and follow added - add offer
    if (followStatus) {
        [favMerchants insertObject:changedMerchant atIndex:0];
        merchantsTotalCount++;
        if (currentTab == Q8FavTabMerchants) {
            [self reloadTableView];
        }
    }
}

#pragma mark - Cell button actions

- (void)cellLikeButtonAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Q8Offer *offer = [favOffers objectAtIndex:indexPath.row];
    
    [self likeOfferOnServer:offer];
}

- (void)cellFollowButtonAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Q8Offer *offer = [favOffers objectAtIndex:indexPath.row];
    
    [self toggleFollowOfferOnServer:offer];
}

- (void)cellShareButtonAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Q8Offer *offer = [favOffers objectAtIndex:indexPath.row];
    offerToShare = offer;
    
    [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonShareOption] delegate:self];
}

#pragma mark - Button actions

- (IBAction)merchantsTabButtonAction:(id)sender {
    if (currentTab != Q8FavTabMerchants) {
        currentTab = Q8FavTabMerchants;
        [self reloadCurrentSearchTabRepresentation];
        [self loadFavsFromServerAndUpdateList:YES];
    }
}
- (IBAction)offersTabButtonAction:(id)sender {
    if (currentTab != Q8FavTabOffers) {
        currentTab = Q8FavTabOffers;
        [self reloadCurrentSearchTabRepresentation];
        [self loadFavsFromServerAndUpdateList:YES];
    }
}

#pragma mark - Server requests

- (void)loadFavsFromServerAndUpdateList:(BOOL)isNeedUpdateList {
    if (isNeedUpdateList) {
        [self showActivityIndicator:YES];
    }
    weakify(self);
    if (currentTab == Q8FavTabMerchants) {
        if (isNeedUpdateList) {
            [favMerchants removeAllObjects];
            merchantCurrentPage = 1;
        }
        [[Q8ServerAPIHelper sharedHelper] getMerchantsByCategoryID:@"" text:@"" latitude:@"" longtitude:@"" page:merchantCurrentPage searchByfollow:YES onCompletion:^(BOOL success, NSArray <Q8Merchant *> *merchantsArray, NSInteger merchantCount, NSString *searchText) {
            [self->favMerchants addObjectsFromArray:merchantsArray];
            self->merchantsTotalCount = merchantCount;
            strongify(self);
            [self showActivityIndicator:NO];
            [self reloadTableView];
        } sender:self];
    } else {
        if (isNeedUpdateList) {
            [favOffers removeAllObjects];
            offerCurrentPage = 1;
        }
        [[Q8ServerAPIHelper sharedHelper] getOffersByCategoryID:@"" businessID:@"" text:@"" latitude:@"" longtitude:@"" page:offerCurrentPage searchByfollow:YES onCompletion:^(BOOL success, NSArray <Q8Offer *> *offersArray, NSInteger offersCount, NSString *searchText) {
            [self->favOffers addObjectsFromArray:offersArray];
            self->offersTotalCount = offersCount;
            strongify(self);
            [self showActivityIndicator:NO];
            [self reloadTableView];
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

- (void)toggleFollowOfferOnServer:(Q8Offer *)offer {
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

- (void)unfollowMerchantOnServer:(Q8Merchant *)merchant {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    [[Q8ServerAPIHelper sharedHelper] removeFollowFromMerchant:merchant.merchantId onCompletion:^(BOOL success) {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
        if (success) {
            [Q8NotificationHelper postMerchantFollowChangeNotification:merchant followStatus:NO];
        }
    } sender:self];
}

@end
