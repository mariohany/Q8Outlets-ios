//
//  Q8TourViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8TourControllerIdentifier = @"Q8Tour";

@interface Q8TourViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView; // for tour slides
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (nonatomic, weak) IBOutlet UIButton *previousButton;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;

- (IBAction)previousButtonAction:(id)sender;
- (IBAction)nextButtonAction:(id)sender;
- (IBAction)pageChangeAction:(id)sender;

@end
