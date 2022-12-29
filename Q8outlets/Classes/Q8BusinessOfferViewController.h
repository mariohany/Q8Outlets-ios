//
//  Q8BusinessOfferViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8BusinessOfferControllerIdentifier = @"Q8BusinessOffer";

@interface Q8BusinessOfferViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Q8Offer *offer;

// Offer header
@property (nonatomic, weak) IBOutlet UIImageView *promoImageView;
@property (nonatomic, weak) IBOutlet UITableView *addressesTableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *addressesHeightConstraint;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

// Stats for offer
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *availableImageView;
@property (weak, nonatomic) IBOutlet UILabel *availableCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *appliedCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *pendingCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *usedImageView;
@property (weak, nonatomic) IBOutlet UILabel *usedCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *expiredImageView;
@property (weak, nonatomic) IBOutlet UILabel *expiredCountLabel;

@end
