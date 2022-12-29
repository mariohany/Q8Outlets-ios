//
//  Q8MerchantAnnotation.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/7/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GMSMarker.h>

@interface Q8MerchantAnnotation : GMSMarker

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) Q8Merchant *merchant;

// Selected pin is orange, deselected is green
- (void)setSelected:(BOOL)selected;
- (id)initWithMerchant:(Q8Merchant *)merchant;

@end
