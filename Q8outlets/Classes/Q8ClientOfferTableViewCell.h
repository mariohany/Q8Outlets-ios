//
//  Q8ClientOfferTableViewCell.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/1/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Q8Offer.h"

static NSString * const Q8ClientOfferCellIdentifier = @"Q8ClientOfferCell";
static NSString * const Q8ClientOfferCellXibName = @"Q8ClientOfferTableViewCell";

@interface Q8ClientOfferTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *likeImageView;
@property (nonatomic, weak) IBOutlet UILabel *likesLabel;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;

@property (weak, nonatomic) IBOutlet UIView *promoContainerView;
@property (nonatomic, weak) IBOutlet UIImageView *promoImageView;
@property (nonatomic, weak) IBOutlet UIView *couponsContainerView;
@property (nonatomic, weak) IBOutlet UILabel *couponsCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *couponsTextLabel;

@property (nonatomic, weak) IBOutlet UILabel *merchantTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIImageView *followImageView;
@property (nonatomic, weak) IBOutlet UIButton *followButton;

- (void)setupForOffer:(Q8Offer *)offer;

@end
