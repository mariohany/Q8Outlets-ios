//
//  Q8BusinessOfferTableViewCell.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/14/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8BusinessOfferCellIdentifier = @"Q8BusinessOfferCell";

@interface Q8BusinessOfferTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *offerTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *moreLocationsLabel;

@property (weak, nonatomic) IBOutlet UIImageView *availableImageView;
@property (weak, nonatomic) IBOutlet UILabel *availableLabel;
@property (weak, nonatomic) IBOutlet UILabel *appliedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *usedImageView;
@property (weak, nonatomic) IBOutlet UILabel *usedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *expiredImageView;
@property (weak, nonatomic) IBOutlet UILabel *expiredLabel;

- (void)setupForOffer:(Q8Offer *)offer;

@end
