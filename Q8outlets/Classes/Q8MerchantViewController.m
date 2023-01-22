//
//  Q8MerchantViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/6/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8MerchantViewController.h"
#import "Q8ClientOfferTableViewCell.h"
#import "Q8OfferViewController.h"
#import "Q8ReportPopupView.h"
#import "Q8LoadingTableViewCell.h"
#import "Q8MerchantMapViewController.h"
#import "NSString+Q8URLEncoding.h"
#import "Q8ShareHelper.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface Q8MerchantViewController ()

@end

@implementation Q8MerchantViewController {
    NSMutableArray <Q8Offer *> *offers;
    Q8Offer *offerToShare;
    
    // Report popup
    Q8ReportPopupView *navbarPopup;
    BOOL navbarPopupOpened;
    
    NSInteger offerCurrentPage;
    NSInteger offersTotalCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Addd "report" popup
    navbarPopup = [Q8ReportPopupView viewFromXib];
    CGRect popupFrame = navbarPopup.frame;
    popupFrame.origin.x = [UIScreen mainScreen].bounds.size.width - popupFrame.size.width - 4.0f;
    navbarPopup.frame = popupFrame;
    [navbarPopup setupForMode:Q8ReportModeMerchant];
    // Targets for report buttons
    [navbarPopup.offensiveButton addTarget:self action:@selector(offensiveReportPopupButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navbarPopup.spamButton addTarget:self action:@selector(spamReportPopupButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navbarPopup.cheatingButton addTarget:self action:@selector(cheatingReportPopupButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navbarPopup];
    [self toggleReportPopupHidden:YES animated:NO];
    
    // Visual setup
    [WLVisualHelper addBorderToView:self.logoImageView color:[UIColor whiteColor] width:6.0f];
    [WLVisualHelper roundThisView:self.logoImageView radius:5.0f];
    [WLVisualHelper templatizeButtons:@[self.emailButton, self.phoneButton, self.smsButton] withColor:Q8RedDefaultColor];
    [self setupImageAssessory];
    
    // Register cells
    UINib *offerNib = [UINib nibWithNibName:Q8ClientOfferCellXibName bundle:nil];
    [self.tableView registerNib:offerNib forCellReuseIdentifier:Q8ClientOfferCellIdentifier];
    UINib *loadingNib = [UINib nibWithNibName:Q8LoadingCellXibName bundle:nil];
    [self.tableView registerNib:loadingNib forCellReuseIdentifier:Q8LoadingCellIdentifier];
    
    self.tableView.estimatedRowHeight = [WLVisualHelper customCellHeightFromNibName:Q8ClientOfferCellXibName];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    offers = [NSMutableArray array];
    
    offerCurrentPage = 1;
    
    [self setupContactButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.merchant.isNeedLoadMerchantData) {
        [self loadMerchantFromServer];
    } else if (!offers.count) {
        [self setupControllerAppearance];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.descriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.descriptionLabel.frame);
    [self sizeTableViewHeaderToFit];
}

- (void)setupImageAssessory {
    UIImage* image = [UIImage imageNamed:NSLocalizedString(@"icon_arrow_right", nil)];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.arrowImageView setImage:image];
    [self.arrowImageView setTintColor:[UIColor blackColor]];
}

#pragma mark - Controller logic 

- (void)setupContactButtons {
    BOOL isMerchantContainPhone = self.merchant.phone.length;
    self.phoneButton.alpha = isMerchantContainPhone ? 1.0 : 0.5;
    self.phoneButton.userInteractionEnabled = isMerchantContainPhone ? YES : NO;
    
    self.smsButton.alpha = isMerchantContainPhone ? 1.0 : 0.5;
    self.smsButton.userInteractionEnabled = isMerchantContainPhone ? YES : NO;
    
    BOOL isMerchantContainEmail = self.merchant.email.length;
    self.emailButton.alpha = isMerchantContainEmail ? 1.0 : 0.5;
    self.emailButton.userInteractionEnabled = isMerchantContainEmail ? YES : NO;
}

- (void)sizeTableViewHeaderToFit {
    // Calculate table view header height that contains all merchant info
    UIView *headerView = self.tableView.tableHeaderView;
    [headerView setNeedsLayout];
    [headerView layoutIfNeeded];
    
    CGFloat headerHeight = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect frame = headerView.frame;
    frame.size.height = headerHeight;
    headerView.frame = frame;
    self.tableView.tableHeaderView = headerView;
}

- (void)setupControllerAppearance {
    // Populate merchant data
    [self populateMerchantRepresentation];
    
    // Register for offer like/follow change and this merchant change
    [Q8NotificationHelper addObserver:self toMerchantChange:self.merchant];
    [Q8NotificationHelper addObserverToAnyOfferChange:self];
    // Load offers
    [self loadOffersFromServer];
}

- (void)populateMerchantRepresentation {
    self.navigationItem.title = self.merchant.title;
    [Q8ImageHelper setMerchantLogo:self.merchant intoImageView:self.logoImageView];
    [Q8ImageHelper setMerchantBackgroundImage:self.merchant intoImageView:self.backgroundImageView];
    self.categoryLabel.text = self.merchant.category.categoryName;
    self.addressLabel.text = [self.merchant.allLocations count] ? [self.merchant.allLocations firstObject].locationAddress : @"";
	NSString *distance = [self.merchant.allLocations count] ? [self.merchant.allLocations firstObject].distanceString : @"";
	self.distanceLabel.text = distance;
    self.descriptionLabel.text = self.merchant.merchantDescription;    
    self.offersTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Offers in %@", nil), self.merchant.title];
    
    [self populateMerchantFollowRepresentation];
}

- (void)populateMerchantFollowRepresentation {
    self.followImageView.image = [UIImage imageNamed:(self.merchant.isFollowed ?
                                                      @"icon_star_full" :
                                                      @"icon_star_empty")];
    self.followButton.userInteractionEnabled = self.merchant.isCanFollow;
}

- (void)reloadTableView {
    self.activityIndicator.hidden = YES;
    self.offersTextLabel.hidden = ![offers count];
    self.offersCountLabel.hidden = ![offers count];
    self.offersCountLabel.text = [NSString stringWithFormat:@"%ld", (long)[offers count]];
    self.noOffersView.hidden = [offers count];
    CGRect noOffersFooterFrame = self.tableView.tableFooterView.frame;
    noOffersFooterFrame.size.height = [offers count] ? 0.0f : 200.0f;
    
    self.tableView.tableFooterView.frame = noOffersFooterFrame;
    [self.tableView reloadData];
}

#pragma mark - Report popup logic

- (void)toggleReportPopupHidden:(BOOL)hidden animated:(BOOL)animated {
    navbarPopup.hidden = hidden;
}

#pragma mark - Table view datasource

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
    
    Q8ClientOfferTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8ClientOfferCellIdentifier forIndexPath:indexPath];
    Q8Offer *offer = [offers objectAtIndex:indexPath.row];
    [cell setupForOffer:offer];
    
    // Add button targets
    [cell.likeButton addTarget:self action:@selector(cellLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.followButton addTarget:self action:@selector(cellFollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareButton addTarget:self action:@selector(cellShareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell: (UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [offers count] - 1 && [offers count] < offersTotalCount) {
        offerCurrentPage++;
        [self loadOffersFromServer];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Move to offer
    Q8Offer *offer = [offers objectAtIndex:indexPath.row];
    [Q8NavigationManager moveToClientOffer:offer];
}

- (void)didUseActionAtIndex:(NSInteger)actionIndex ofAlertController:(UIAlertController *)alertController withReason:(NSInteger)alertControllerReason {
    if ((alertControllerReason == Q8ReasonShareOption) || (alertControllerReason == Q8ReasonShareOption_ar)) {
        if (actionIndex == 0) {
            [Q8ShareHelper shareOfferToFacebook:offerToShare];
        } else if (actionIndex == 1) {
            [Q8ShareHelper shareOfferToOther:offerToShare];
        }
    }
}

#pragma mark - Offer change notification observer

- (void)offerLikeStatusChanged:(Q8Offer *)changedOffer likeStatus:(BOOL)likeStatus {
    // Search for affected offer and change
    for (Q8Offer *offer in offers) {
        if ([offer.offerId isEqualToString:changedOffer.offerId]) {
            if (offer.isLiked != likeStatus) {
                offer.isLiked = likeStatus;
                if (offer.isLiked) {
                    offer.likesCount++;
                } else {
                    offer.likesCount--;
                }
            }
            
            [self reloadTableView];
            return;
        }
    }
}

- (void)offerFollowStatusChanged:(Q8Offer *)changedOffer followStatus:(BOOL)followStatus {
    // Search for affected offer and change
    for (Q8Offer *offer in offers) {
        if ([offer.offerId isEqualToString:changedOffer.offerId]) {
            offer.isFollowed = followStatus;
            
            [self reloadTableView];
            return;
        }
    }
}

- (void)offerCouponCountChanged:(Q8Offer *)changedOffer couponApplied:(BOOL)isApplied {
    for (Q8Offer *offer in offers) {
        if ([offer.offerId isEqualToString:changedOffer.offerId]) {
            if (offer.isApplied != isApplied) {
                offer.isApplied = isApplied;
                offer.availableCoupons--;
            }
            
            [self reloadTableView];
            return;
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

#pragma mark - Merchant change notification observer

- (void)myMerchantFollowStatusChanged:(BOOL)followStatus {
    self.merchant.isFollowed = followStatus;
    [self populateMerchantFollowRepresentation];
}

#pragma mark - Cell button actions

- (void)cellLikeButtonAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Q8Offer *offer = [offers objectAtIndex:indexPath.row];
    
    [self likeOfferOnServer:offer];
}

- (void)cellFollowButtonAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Q8Offer *offer = [offers objectAtIndex:indexPath.row];
    
    [self followOfferOnServer:offer];
}

- (void)cellShareButtonAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Q8Offer *offer = [offers objectAtIndex:indexPath.row];
    offerToShare = offer;
    
    [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonShareOption] delegate:self];
}

#pragma mark - Button actions

- (IBAction)flagButtonAction:(id)sender {
    navbarPopupOpened = !navbarPopupOpened;
    [self toggleReportPopupHidden:!navbarPopupOpened animated:YES];
}

- (IBAction)mapButtonAction:(id)sender {
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Client" bundle:nil];
	Q8MerchantMapViewController *vc = (Q8MerchantMapViewController*)[sb instantiateViewControllerWithIdentifier:@"Q8MerchantMapViewController"];
	vc.merchant = self.merchant;
	[self.navigationController presentViewController:vc animated:YES completion:nil];
	/*
	CLLocationCoordinate2D center = self.merchant.currentLocation.locationCoordinate;
	BOOL isGoogleMapInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];
	if (isGoogleMapInstalled) {
		NSString *place = [self.merchant.title urlEncodeUsingEncoding:NSUTF8StringEncoding];
		NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?q=%@&center=%f,%f&mapmode=standard&views&zoom=17",place,center.latitude,center.longitude];
		NSLog(@"open google maps url: %@", urlString);
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
	}
	else {
		NSLog(@"No google maps");
		// Create MKMapItem out of merchant location
		MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:center addressDictionary:nil];
		MKMapItem *mapItem =  [[MKMapItem alloc] initWithPlacemark:placemark];
		mapItem.name = self.merchant.title;
		[mapItem openInMapsWithLaunchOptions:nil];
	}
	 */
}

- (IBAction)phoneButtonAction:(id)sender {
    NSString *phoneNumber =  [NSString stringWithFormat:@"telprompt://%@",self.merchant.phone];
    NSURL *url = [NSURL URLWithString:phoneNumber];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
- (IBAction)emailButtonAction:(id)sender {
    NSString *email = [NSString stringWithFormat:@"mailto:%@",self.merchant.email];;
    NSURL *url = [NSURL URLWithString:email];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
- (IBAction)smsButtonAction:(id)sender {
    NSString *sms = [NSString stringWithFormat:@"sms:%@",self.merchant.phone];
    NSURL *url = [NSURL URLWithString:sms];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
- (IBAction)followButtonAction:(id)sender {
    [self followMerchantOnServer];
}

#pragma mark - Popup button actions

- (void)offensiveReportPopupButtonAction {
    navbarPopupOpened = NO;
    [self toggleReportPopupHidden:YES animated:YES];
    [self reportMerchantOnServer:Q8ReportReasonOffensive];
}

- (void)spamReportPopupButtonAction {
    navbarPopupOpened = NO;
    [self toggleReportPopupHidden:YES animated:YES];
    [self reportMerchantOnServer:Q8ReportReasonSpam];
}

- (void)cheatingReportPopupButtonAction {
    navbarPopupOpened = NO;
    [self toggleReportPopupHidden:YES animated:YES];
    [self reportMerchantOnServer:Q8ReportReasonCheating];
}

#pragma mark - Server requests

- (void)loadMerchantFromServer {
    [Q8ActivityIndicator showHUDAddedTo:self.view animated:YES];
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] getMerchantAndOffers:self.merchant.businessId onCompletion:^(BOOL success, Q8Merchant *merchant, NSArray<Q8Offer *> *offersArray) {
        [Q8ActivityIndicator hideHUDForView:self.view animated:YES];
        if (success) {
            strongify(self);
            self.merchant = merchant;
            [self setupControllerAppearance];
        }
    } sender:nil];
}

- (void)loadOffersFromServer {
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] getOffersByCategoryID:@"" businessID:self.merchant.merchantId text:@"" latitude:@"" longtitude:@"" page:offerCurrentPage searchByfollow:NO onCompletion:^(BOOL success, NSArray <Q8Offer *> *offersArray, NSInteger offersCount, NSString *searchText) {
        strongify(self);
        self->offersTotalCount = offersCount;
        [self->offers addObjectsFromArray:offersArray];
        [self reloadTableView];
    } sender:self];
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

- (void)followMerchantOnServer {
    self.merchant.isCanFollow = NO;
    weakify(self);
    if (self.merchant.isFollowed) {
        [[Q8ServerAPIHelper sharedHelper] removeFollowFromMerchant:self.merchant.merchantId onCompletion:^(BOOL success) {
            strongify(self);
            self.merchant.isCanFollow = YES;
            [Q8NotificationHelper postMerchantFollowChangeNotification:self.merchant followStatus:success ? NO : self.merchant.isFollowed];
        } sender:self];
    } else {
        [[Q8ServerAPIHelper sharedHelper] followMerchant:self.merchant.merchantId onCompletion:^(BOOL success) {
            strongify(self);
            self.merchant.isCanFollow = YES;
            [Q8NotificationHelper postMerchantFollowChangeNotification:self.merchant followStatus:success ? YES : !self.merchant.isFollowed];
        } sender:self];

    }
    [Q8NotificationHelper postMerchantFollowChangeNotification:self.merchant followStatus:!self.merchant.isFollowed];
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

- (void)reportMerchantOnServer:(Q8ReportReason)reportReason {
    [[Q8ServerAPIHelper sharedHelper] reportBusiness:self.merchant.merchantId reportCategory:reportReason onCompletion:^(BOOL success) {
        if (success) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonReportSuccess]];
        }
    } sender:self];
}

@end
