//
//  WLImageHelper.m
//  WLHelpers
//
//  Created by Lesya Verbina on 6/1/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import "WLImageHelper.h"

@implementation WLImageHelper

// Placeholder profile pictures which are colored circles with initials
+ (UIImage *)imageSnapshotFromText:(NSString *)text
                              size:(CGSize)size
                   backgroundColor:(UIColor *)bgColor
                         textColor:(UIColor *)textColor
                          circular:(BOOL)isCircular {
    
    CGFloat scale = [UIScreen mainScreen].scale;
    size.width = floorf(size.width * scale) / scale;
    size.height = floorf(size.height * scale) / scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (isCircular) {
        //
        // Clip context to a circle
        CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, size.width, size.height), NULL);
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGPathRelease(path);
    }
    
    //
    // Fill background of context
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    //
    // Draw text in the context
    float fontSize = size.height/2.1;
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                                     NSForegroundColorAttributeName: textColor
                                     };
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    
    [text drawInRect:CGRectMake(bounds.size.width/2 - textSize.width/2,
                                bounds.size.height/2 - textSize.height/2,
                                textSize.width,
                                textSize.height)
      withAttributes:textAttributes];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}


@end
