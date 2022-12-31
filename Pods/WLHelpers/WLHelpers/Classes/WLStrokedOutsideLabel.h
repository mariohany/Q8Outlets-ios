//
//  WLStrokedOutsideLabel.h
//  Social
//
//  Created by Lesya Verbina on 2/29/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Label that has a colored border of specified width and color.
 */
@interface WLStrokedOutsideLabel : UILabel

@property (assign, nonatomic) NSInteger strokeWidth;
@property (strong, nonatomic) UIColor *strokeColor;

@end
