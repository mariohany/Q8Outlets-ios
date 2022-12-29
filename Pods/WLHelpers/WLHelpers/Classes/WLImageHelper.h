//
//  WLImageHelper.h
//  WLHelpers
//
//  Created by Lesya Verbina on 6/1/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WLImageHelper : NSObject

/**
 *  For generating placeholder profile pictures which are colored circles with initials.
 *
 *  @param text       Text to display on image. Usually initials.
 *  @param size       Size of resulting image.
 *  @param bgColor    Background color of image.
 *  @param textColor  Color of text.
 *  @param isCircular Flag to generate either rectangular or circle images.
 *
 *  @return Image object, created from text and background color.
 */
+ (UIImage *)imageSnapshotFromText:(NSString *)text
                              size:(CGSize)size
                   backgroundColor:(UIColor *)bgColor
                         textColor:(UIColor *)textColor
                          circular:(BOOL)isCircular;

@end
