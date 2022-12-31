//
//  Q8ScanCodeViewController.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const Q8ScanCodeControllerIdentifier = @"Q8ScanCode";

@interface Q8ScanCodeViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *previewView;

- (IBAction)backButtonAction:(id)sender;

@end
