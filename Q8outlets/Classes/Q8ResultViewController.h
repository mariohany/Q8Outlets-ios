//
//  Q8ResultViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8ResultControllerIdentifier = @"Q8Result";

@interface Q8ResultViewController : UIViewController

@property (nonatomic, strong) NSString *couponQrToken; // code scanned in previous step

@property (nonatomic, weak) IBOutlet UIImageView *resultImageView;
@property (nonatomic, weak) IBOutlet UILabel *resultLabel;

@property (nonatomic, weak) IBOutlet UIView *offerContainerView;
@property (nonatomic, weak) IBOutlet UILabel *offerTitleLabel;
@property (nonatomic, weak) IBOutlet UITextView *offerDescriptionTextView;

@end
