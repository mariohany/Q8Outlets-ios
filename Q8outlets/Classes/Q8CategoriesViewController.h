//
//  Q8CategoriesViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8CategoriesControllerIdentifier = @"Q8Categories";

@interface Q8CategoriesViewController : UIViewController

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *categoryImageViews;

- (IBAction)searchButtonAction:(id)sender;

// **
// Categories
- (IBAction)foodButtonAction:(id)sender;
- (IBAction)fashionButtonAction:(id)sender;
- (IBAction)retailButtonAction:(id)sender;
- (IBAction)beautyButtonAction:(id)sender;
- (IBAction)leisureButtonAction:(id)sender;
- (IBAction)otherButtonAction:(id)sender;

@end
