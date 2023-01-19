//
//  WLVisualHelper.m
//  WLHelpers
//
//  Created by Lesya Verbina on 6/1/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import "WLVisualHelper.h"

@implementation WLVisualHelper

#pragma mark - Views

// Gradients
+ (void)addVerticalGradientToView:(UIView *)view gradientColors:(NSArray<UIColor *> *)colors {
    [WLVisualHelper addLinearGradientToView:view vertical:YES gradientColors:colors];
}

+ (void)addHorizontalGradientToView:(UIView *)view gradientColors:(NSArray<UIColor *> *)colors {
    [WLVisualHelper addLinearGradientToView:view vertical:NO gradientColors:colors];
}

+ (void)addLinearGradientToView:(UIView *)view vertical:(BOOL)vertical gradientColors:(NSArray<UIColor *> *)colors {
    if ([colors count] && [colors count]==1) {
        // If no gradient, then do not bother
        view.backgroundColor = [colors firstObject];
    } else if ([colors count]) {        
        // View will be colored in equal parts by specified colors
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = view.layer.bounds;
        
        NSMutableArray *cgGradientColors = [NSMutableArray new];
        for (UIColor *color in colors) {
            [cgGradientColors addObject:(id)color.CGColor];
        }
        gradientLayer.colors = cgGradientColors;
        
        // Separating view into equal parts, according to the number of colors
        float colorPart = 1.0f/(float)([colors count]-1); // -1 so gradient ends on 1, not on 0.75 or so
        NSMutableArray *colorLocations = [NSMutableArray new];
        for (int i=0; i<[colors count]; i++) {
            [colorLocations addObject:@(i*colorPart)];
        }
        
        gradientLayer.locations = colorLocations;
        
        [gradientLayer setStartPoint:CGPointMake(0.0f, 0.0f)];
        // Vertical and horizontal gradients have different coordinates
        [gradientLayer setEndPoint:vertical ? CGPointMake(0.0f, 1.0f) : CGPointMake(1.0f, 0.0f)];
        
        gradientLayer.cornerRadius = view.layer.cornerRadius;
        gradientLayer.masksToBounds = view.layer.masksToBounds;
        
        // Remove old gradient before adding new
        NSMutableArray *layersToRemove = [NSMutableArray new];
        for (CALayer *sublayer in view.layer.sublayers) {
            if ([sublayer isKindOfClass:[CAGradientLayer class]]) {
                [layersToRemove addObject:sublayer];
            }
        }
        for (CALayer *sublayer in layersToRemove) {
            [sublayer removeFromSuperlayer];
        }
        [view.layer insertSublayer:gradientLayer atIndex:0];
    }
}

// Image from gradient
+ (UIImage *)imageWithGradientColors:(NSArray<UIColor *> *)colors gradientIsVertical:(BOOL)vertical imageSize:(CGSize)size {
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    // Generating proper gradient
    [WLVisualHelper addLinearGradientToView:gradientView vertical:vertical gradientColors:colors];
    
    // Render gradient to image
    UIGraphicsBeginImageContext(gradientView.layer.bounds.size);
    [gradientView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *gradientAsImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return gradientAsImage;
}


// For round views
+ (void)fullRoundThisViews:(NSArray *)views {
    for (UIView *view in views) {
        [WLVisualHelper fullRoundThisView:view];
    }
}

+ (void)fullRoundThisView:(UIView *)view {
    [view layoutIfNeeded];
    [WLVisualHelper roundThisView:view radius:view.frame.size.height/2];
}

// For not fully circular round views
+ (void)roundThisView:(UIView *)view radius:(float)radius {
    [view layoutIfNeeded];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = radius;
}
+ (void)roundThisViews:(NSArray *)views radius:(float)radius {
    for (UIView *view in views) {
        [WLVisualHelper roundThisView:view radius:radius];
    }
}


// For rounding only specific side
// For full rounding

+ (void)roundLeftOfView:(UIView *)view {
    float cornerRadius = view.frame.size.height/2;
    [WLVisualHelper roundLeftOfView:view cornerRadius:cornerRadius];
}

+ (void)roundRightOfView:(UIView *)view {
    float cornerRadius = view.frame.size.height/2;
    [WLVisualHelper roundRightOfView:view cornerRadius:cornerRadius];
}

+ (void)roundTopOfView:(UIView *)view {
    float cornerRadius = view.frame.size.height/2;
    [WLVisualHelper roundTopOfView:view cornerRadius:cornerRadius];
}

+ (void)roundBottomOfView:(UIView *)view {
    float cornerRadius = view.frame.size.height/2;
    [WLVisualHelper roundBottomOfView:view cornerRadius:cornerRadius];
}

// For rounding only specific side
// For partial rounding

+ (void)roundLeftOfView:(UIView *)view cornerRadius:(float)cornerRadius {
    UIRectCorner side = UIRectCornerTopLeft | UIRectCornerBottomLeft;
    [WLVisualHelper roundSideOfView:view side:side cornerRadius:cornerRadius];
}

+ (void)roundRightOfView:(UIView *)view cornerRadius:(float)cornerRadius {
    UIRectCorner side = UIRectCornerTopRight | UIRectCornerBottomRight;
    [WLVisualHelper roundSideOfView:view side:side cornerRadius:cornerRadius];
}

+ (void)roundTopOfView:(UIView *)view cornerRadius:(float)cornerRadius {
    UIRectCorner side = UIRectCornerTopRight | UIRectCornerTopLeft;
    [WLVisualHelper roundSideOfView:view side:side cornerRadius:cornerRadius];
}

+ (void)roundBottomOfView:(UIView *)view cornerRadius:(float)cornerRadius {
    UIRectCorner side = UIRectCornerBottomRight | UIRectCornerBottomLeft;
    [WLVisualHelper roundSideOfView:view side:side cornerRadius:cornerRadius];
}

+ (void)roundSideOfView:(UIView *)view side:(UIRectCorner)side cornerRadius:(float)cornerRadius {
    [view layoutIfNeeded];
    
    // Recalculate view size before making a path
    CGSize realExpandedSize = UILayoutFittingCompressedSize;
    realExpandedSize.width = [UIScreen mainScreen].bounds.size.width;
    CGSize realSize = [view systemLayoutSizeFittingSize:realExpandedSize];
    
    // If resulting height or width is lower, than the one we started with, double-check
    if (realSize.height < view.bounds.size.height) {
        realSize.height = view.bounds.size.height;
    }
    if (realSize.width < view.bounds.size.width) {
        realSize.width = view.bounds.size.width;
    }
    
    CGRect realBounds = CGRectMake(0, 0, realSize.width, realSize.height);
    

    
    // Mask with selected corners rounded
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:realBounds
                                           byRoundingCorners:side
                                                 cornerRadii:(CGSize){cornerRadius, cornerRadius}].CGPath;
    view.layer.mask = maskLayer;
    
    
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = realBounds;
    shape.path = maskLayer.path;
    shape.lineWidth = 2.0f;
    shape.strokeColor = [UIColor clearColor].CGColor;
    shape.fillColor = [UIColor clearColor].CGColor;
    [view.layer addSublayer:shape];
}

// For corner radius AND shadow
+ (void)addDropShadowAndRoundThisView:(UIView *)view
                         cornerRadius:(float)radius
                           hardShadow:(BOOL)hardShadow
                      shouldRasterize:(BOOL)shouldRasterize {
    [view layoutIfNeeded];
    [view.layer setCornerRadius:radius];
    [WLVisualHelper addDropShadowToView:view hardShadow:hardShadow shouldRasterize:shouldRasterize];
}

+ (void)addDropShadowAndRoundThisViews:(NSArray <UIView *> *)views
                          cornerRadius:(float)radius
                            hardShadow:(BOOL)hardShadow
                       shouldRasterize:(BOOL)shouldRasterize {
    for (UIView *view in views) {
         [WLVisualHelper addDropShadowAndRoundThisView:view cornerRadius:radius hardShadow:hardShadow shouldRasterize:shouldRasterize];
    }
}

// Add shadow
+ (void)addDropShadowToView:(UIView *)view
                 hardShadow:(BOOL)hardShadow
            shouldRasterize:(BOOL)shouldRasterize {
    [view layoutIfNeeded];
    if (shouldRasterize) {
        view.layer.shouldRasterize = YES;
        view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    } else {
        view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.layer.cornerRadius].CGPath;
    }
    [view.layer setShadowRadius:hardShadow ? 1.5f : 7.0f];
    [view.layer setShadowOpacity:hardShadow ? 1.0f : 0.2f];
    [view.layer setShadowOffset:hardShadow ? CGSizeMake(0, 3) : CGSizeMake(0, 5)];
}

+ (void)addDropShadowToViews:(NSArray<UIView *> *)views
                  hardShadow:(BOOL)hardShadow
             shouldRasterize:(BOOL)shouldRasterize {
    for (UIView *view in views) {
        [WLVisualHelper addDropShadowToView:view hardShadow:hardShadow shouldRasterize:shouldRasterize];
    }
}

// Shadow and full round
+ (void)addDropShadowAndFullyRoundThisView:(UIView *)view
                                hardShadow:(BOOL)hardShadow
                           shouldRasterize:(BOOL)shouldRasterize {
    [view layoutIfNeeded];
    [WLVisualHelper addDropShadowAndRoundThisView:view
                                     cornerRadius:view.bounds.size.height/2.0f
                                       hardShadow:hardShadow
                                  shouldRasterize:shouldRasterize];
}

// Shadow and full round
+ (void)addDropShadowAndFullyRoundThisViews:(NSArray <UIView *> *)views
                                 hardShadow:(BOOL)hardShadow
                            shouldRasterize:(BOOL)shouldRasterize {
    for (UIView *view in views) {
        [WLVisualHelper addDropShadowAndFullyRoundThisView:view hardShadow:hardShadow shouldRasterize:shouldRasterize];
    }
}

+ (void)removeShadowFromView:(UIView *)view {
    [view.layer setShadowOpacity:0.0f];
}

// For adding borders
+ (void)addBorderToViews:(NSArray *)views color:(UIColor *)color width:(CGFloat)width {
    for (UIView *view in views) {
        [WLVisualHelper addBorderToView:view color:color width:width];
    }
}

+ (void)addBorderToView:(UIView *)view color:(UIColor *)color width:(CGFloat)width {
    view.layer.borderWidth = width * [WLVisualHelper real1Px];
    view.layer.borderColor = color.CGColor;
}

#pragma mark - Text

// For text field placeholder color
+ (void)changePlaceholderColorOfTextFields:(NSArray *)textFields color:(UIColor *)color {
    for (UITextField *textField in textFields) {
        [WLVisualHelper changePlaceholderColorOfTextField:textField color:color];
    }
}

+ (void)changePlaceholderColorOfTextField:(UITextField *)textField color:(UIColor *)color {
    if (textField.placeholder) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    }
}

// For label character spacing
+ (void)setCharacterSpacingToLabel:(UILabel *)label spacing:(float)spacing {
    NSAttributedString *attributedString = [[NSAttributedString alloc]
                                            initWithString:label.text
                                            attributes:
                                            @{
                                              NSFontAttributeName : label.font,
                                              NSForegroundColorAttributeName : label.textColor,
                                              NSKernAttributeName : @(spacing)
                                              }];
    
    label.attributedText = attributedString;
}

// Padding for text fields, so "plain" text fields can simulate "bordered" appearence
+ (void)addLeftPadding:(float)padding toTextFields:(NSArray *)textFields {
    for (UITextField *textField in textFields) {
        [WLVisualHelper addLeftPadding:padding toTextField:textField];
    }
}
+ (void)addLeftPadding:(float)padding toTextField:(UITextField *)textField {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, padding, 20.0f)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

+ (void)addIconWithName:(NSString *)name templatize:(BOOL)templatize toTextField:(UITextField *)textField toLeftView:(BOOL)toTheLeft {
    UIImage *iconImage = templatize ? [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : [UIImage imageNamed:name];
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    iconImageView.contentMode = UIViewContentModeCenter;
    CGRect leftViewFrame = iconImageView.frame;
    
    // Adding some padding to image
    leftViewFrame.size.width += 15.0f;
    
    // Icon will take place of left view or right view
    iconImageView.frame = leftViewFrame;
    if (toTheLeft) {
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.leftView = iconImageView;
    } else {
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.rightView = iconImageView;
    }
}

#pragma mark - Labels

+ (void)makeTextBold:(NSString *)textToFind inLabel:(UILabel *)label {
    //  Make part of attributed title bold insibe of a label.
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:label.text];
    NSRange range = [attributedTitle.mutableString rangeOfString:textToFind options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        [attributedTitle addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:label.font.pointSize] range:range];
    }
    label.text = @"";
    label.attributedText = attributedTitle;
}

#pragma mark - Buttons

// Center button icon and text
+ (void)centerButtonIconOverText:(UIButton *)button spacing:(CGFloat)spacing {
    // The space between the image and text is spacing
    
    // Lower the text and push it left so it appears centered
    // below the image
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // Raise the image and push it right so it appears centered
    // above the text
    CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    button.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}

// Padding between button image and text
+ (void)addPaddingToImageInButtons:(NSArray<UIButton *> *)buttons spacing:(CGFloat)spacing {
    for (UIButton *button in buttons) {
        [WLVisualHelper addPaddingToImageInButton:button spacing:spacing];
    }
}
+ (void)addPaddingToImageInButton:(UIButton *)button spacing:(CGFloat)spacing {
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
}

+ (void)moveButtonIconToLeft:(UIButton *)button {
    button.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    button.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    button.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
}

// Make button's title shrink font size depending on width.
+ (void)makeButtonFontDynamicSize:(UIButton *)button
                  multilinedTitle:(BOOL)multilined {
    
    button.titleLabel.numberOfLines = multilined ? 0 : 1;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.lineBreakMode = NSLineBreakByClipping;
}
+ (void)makeButtonsFontDynamicSize:(NSArray<UIButton *> *)buttons {
    // Make button's title shrink font size depending on width. For many buttons
    for (UIButton *button in buttons) {
        [WLVisualHelper makeButtonFontDynamicSize:button multilinedTitle:NO];
    }
}

#pragma mark - Images

// For image views and buttons with template images
+ (void)templatizeImageView:(UIImageView *)imageView withColor:(UIColor *)color {
    UIImage *templateImage = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.image = templateImage;
    imageView.tintColor = color;
}
+ (void)templatizeImageViews:(NSArray *)imageViews withColor:(UIColor *)color {
    for (UIImageView *imageView in imageViews) {
        [WLVisualHelper templatizeImageView:imageView withColor:color];
    }
}

+ (void)templatizeImageViewWithAverageColor:(UIImageView *)imageView {
// For UIImageViews that have template images. Image inside UIImageView will be treated as a mask, and tint color will be applied to it.
// Tint color will be an average color of the image itself
    UIColor *averageColor = [WLVisualHelper averageColorOfImage:imageView.image];
    [WLVisualHelper templatizeImageView:imageView withColor:averageColor];
}

+ (void)templatizeImageViewsWithAverageColor:(NSArray<UIImageView *> *)imageViews {
    for (UIImageView *imageView in imageViews) {
        [WLVisualHelper templatizeImageViewWithAverageColor:imageView];
    }
}

+ (void)templatizeButton:(UIButton *)button withColor:(UIColor *)color {
    UIImage *templateImage = [button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    button.tintColor = color;
    [button setImage:templateImage forState:UIControlStateNormal];
}
+ (void)templatizeButtons:(NSArray *)buttons withColor:(UIColor *)color {
    for (UIButton *button in buttons) {
        [WLVisualHelper templatizeButton:button withColor:color];
    }
}

//Draw triangle with equal sides, facing in a specified way.
+ (void)transformViewtoTriange:(UIView *)view
               facingDirection:(WLDirection)triangleDirection
                 triangleColor:(UIColor *)color {
    
    // View's background color is triangle color
    view.backgroundColor = color;
    
    // Calculate triangle points based on view size and triangle direction
    
    // First point is triangle's head, and is in the middle of a side triangle is facing
    CGPoint headPoint;
    // Second point will be left leg of triangle, which is left and down from triangle head
    CGPoint leftLegPoint;
    // Last point will be right leg of triangle, which is right and down from triangle head
    CGPoint rightLegPoint;
    
    switch (triangleDirection) {
        case WLDirectionUp: {
            headPoint = CGPointMake(0.5 * view.frame.size.width, 0);
            leftLegPoint = CGPointMake(0 * view.frame.size.width, view.frame.size.height);
            rightLegPoint = CGPointMake(view.frame.size.width, view.frame.size.height);
            break;
        }
        case WLDirectionDown: {
            headPoint = CGPointMake(0.5 * view.frame.size.width, view.frame.size.height);
            leftLegPoint = CGPointMake(view.frame.size.width, 0);
            rightLegPoint = CGPointMake(0, 0);
            break;
        }
        case WLDirectionLeft: {
            headPoint = CGPointMake(0, 0.5 * view.frame.size.height);
            leftLegPoint = CGPointMake(view.frame.size.width, view.frame.size.height);
            rightLegPoint = CGPointMake(view.frame.size.width, 0);
            break;
        }
        case WLDirectionRight: {
            headPoint = CGPointMake(view.frame.size.width, 0.5 * view.frame.size.height);
            leftLegPoint = CGPointMake(0, 0);
            rightLegPoint = CGPointMake(0, view.frame.size.height);
            break;
        }
    }
    
    // Draw triangle
    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:headPoint];
    [trianglePath addLineToPoint:leftLegPoint];
    [trianglePath addLineToPoint:rightLegPoint];
    [trianglePath closePath];
    
    CAShapeLayer *triangleMaskLayer = [CAShapeLayer layer];
    [triangleMaskLayer setPath:trianglePath.CGPath];
    
    // Applying triangle mask to view
    view.layer.mask = triangleMaskLayer;
}


+ (UIColor *)averageColorOfImage:(UIImage *)image {
    if (!image) {
        return [UIColor blackColor];
    }
    
    // Average color of all pixels in an image
    CGImageRef rawImageRef = [image CGImage];
    
    // This function returns the raw pixel values
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(rawImageRef));
    const UInt8 *rawPixelData = CFDataGetBytePtr(data);
    
    NSUInteger imageHeight = CGImageGetHeight(rawImageRef);
    NSUInteger imageWidth  = CGImageGetWidth(rawImageRef);
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(rawImageRef);
    NSUInteger stride = CGImageGetBitsPerPixel(rawImageRef) / 8;
    
    // If some of the pixels are transparent, not counting them
    NSUInteger realPixels = imageHeight * imageWidth;
    
    // Here I sort the R,G,B, values and get the average over the whole image
    unsigned int red   = 0;
    unsigned int green = 0;
    unsigned int blue  = 0;
    
    for (int row = 0; row < imageHeight; row++) {
        const UInt8 *rowPtr = rawPixelData + bytesPerRow * row;
        for (int column = 0; column < imageWidth; column++) {
            if (rowPtr[3]<1.0f) {
                // If some of the pixels are transparent, not counting them
                realPixels --;
            } else {
                red    += rowPtr[0];
                green  += rowPtr[1];
                blue   += rowPtr[2];
            }
            rowPtr += stride;
        }
    }
    CFRelease(data);
    
    CGFloat f = 1.0f / (255.0f * realPixels);
    return [UIColor colorWithRed:f * red  green:f * green blue:f * blue alpha:1];
}


+ (UIImage *)rotateImageToDefaultOrientation:(UIImage *)image {
    // Strip image from EXIF flags and rotate the pixels
    // to the correct orientation instead.
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            break;
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

+ (UIBezierPath *)pathFromPoints:(NSArray<NSValue *> *)arrayOfPoints {
    // Complile path from array of points
    CGMutablePathRef path = CGPathCreateMutable();
    if (arrayOfPoints && arrayOfPoints.count > 0) {
        CGPoint p = [(NSValue *)[arrayOfPoints objectAtIndex:0] CGPointValue];
        CGPathMoveToPoint(path, nil, p.x, p.y);
        for (int i = 1; i < arrayOfPoints.count; i++) {
            p = [(NSValue *)[arrayOfPoints objectAtIndex:i] CGPointValue];
            CGPathAddLineToPoint(path, nil, p.x, p.y);
        }
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:path];
    CGPathRelease(path);
    
    return bezierPath;
}

+ (UIImage *)strokePath:(UIBezierPath *)path
            strokeColor:(UIColor *)color
        backgroundImage:(UIImage *)inputImage {
    
    // Flipping drawing image back up in case it was flipped
    inputImage = [UIImage imageWithCGImage:inputImage.CGImage
                                     scale:inputImage.scale
                               orientation:UIImageOrientationUp];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    // Create a view to draw the path in
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    
    // Begin graphics context for drawing
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    // Configure the view to render in the graphics context
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Set color
    [color set];
    
    // Draw previous image so new one is on top
    if (inputImage) {
        [inputImage drawInRect:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    }
    
    // Draw the stroke
    path.lineWidth = 3.0f;
    [path stroke];
    
    // Get an image of the graphics context
    UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    return overlayImage;
}

#pragma mark - Scroll views

+ (void)sizeImageView:(UIImageView *)imageView
      toFitScrollView:(UIScrollView *)scrollView {
    
    CGSize originalSize = imageView.image.size;
    CGSize sizeToFit = scrollView.bounds.size;
    CGFloat scaleDownFactor = MIN(sizeToFit.width / originalSize.width,
                                  sizeToFit.height / originalSize.height);
    scrollView.zoomScale = scaleDownFactor;
    
    [WLVisualHelper centerImageView:imageView inScrollView:scrollView];
}

+ (void)centerImageView:(UIImageView *)imageView
           inScrollView:(UIScrollView *)scrollView {
    CGSize imgViewSize = imageView.frame.size;
    CGSize imageSize = imageView.image.size;
    
    CGSize realImgSize;
    if (imageSize.width / imageSize.height > imgViewSize.width / imgViewSize.height) {
        realImgSize = CGSizeMake(imgViewSize.width, imgViewSize.width / imageSize.width * imageSize.height);
    }
    else {
        realImgSize = CGSizeMake(imgViewSize.height / imageSize.height * imageSize.width, imgViewSize.height);
    }
    
    CGRect fr = CGRectMake(0, 0, 0, 0);
    fr.size = realImgSize;
    imageView.frame = fr;
    
    CGSize scrSize = scrollView.frame.size;
    float offx = (scrSize.width > realImgSize.width ? (scrSize.width - realImgSize.width) / 2 : 0);
    float offy = (scrSize.height > realImgSize.height ? (scrSize.height - realImgSize.height) / 2 : 0);
    
    // don't animate the change.
    scrollView.contentInset = UIEdgeInsetsMake(offy, offx, offy, offx);
}

#pragma mark - Table views

// Height for custom cells
+ (float)customCellHeightFromNibName:(NSString *)nibName {
    float height = 0.0;
    
    // Custom UITableViewCell height
    NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    for (id currentObject in topLevelObjects) {
        if ([currentObject isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *)currentObject;
            height = cell.contentView.frame.size.height;
            break;
        }
    }
    
    // Custom UICollectionViewCell height
    if (!height) {
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UICollectionViewCell class]]) {
                UICollectionViewCell *cell = (UICollectionViewCell *)currentObject;
                height = cell.contentView.frame.size.height;
                break;
            }
        }
    }
    return height;
}

// For cells with zero separator inset (thanks Apple :|)
+ (void)makeCellZeroInset:(UITableViewCell *)cell {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


// Refresh controller for tableviews
+ (void)addRefreshControll:(UIRefreshControl *)refreshControl toTableView:(UITableView *)tableView {
    // Controller init for smooth refresh
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = tableView;
    tableViewController.refreshControl = refreshControl;
}

#pragma mark - Misc

// Animated tabbar toggle
+ (void)setTabBarVisible:(BOOL)visible
            onController:(UIViewController *)controller
                animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    NSInteger visibleTag = 10;
    NSInteger hiddenTag = 20;
    // Storing if tabbar is hidden. If first time, will be 0
    if (!controller.tabBarController.tabBar.tag) {
        controller.tabBarController.tabBar.tag = visibleTag;
    }
    
    // If tabbar already visible/hidden, do nothing
    if ((visible && controller.tabBarController.tabBar.tag==visibleTag) ||
        (!visible && controller.tabBarController.tabBar.tag==hiddenTag)) {
        if (completion) {
            completion (YES);
        }
        return;
    } else {
        if (visible) {
            controller.tabBarController.tabBar.tag = visibleTag;
        } else {
            controller.tabBarController.tabBar.tag = hiddenTag;
        }
    }
    
    // Get a frame calculation ready
    CGFloat height = controller.tabBarController.tabBar.frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // Zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        controller.tabBarController.tabBar.frame = CGRectOffset(controller.tabBarController.tabBar.frame, 0, offsetY);
    } completion:completion];
}

// Real 1 pixel for retinas
+ (CGFloat)real1Px {
    UIScreen* mainScreen = [UIScreen mainScreen];
    CGFloat onePixel = 1.0 / mainScreen.scale;
    if ([mainScreen respondsToSelector:@selector(nativeScale)])
        onePixel = 1.0 / mainScreen.nativeScale;
    return onePixel;
}

// Color object from hex string
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0]; // no '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
