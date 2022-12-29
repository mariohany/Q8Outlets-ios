//
//  Q8ImageHelper.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/3/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8ImageHelper.h"
#import <AFNetworking/UIKit+AFNetworking.h>

static NSString * const placeholderImageName = @"placeholder";

@implementation Q8ImageHelper


+ (void)setMerchantLogo:(Q8Merchant *)merchant
          intoImageView:(UIImageView *)imageView {
    
    NSURL *imageURL = [NSURL URLWithString:merchant.logoAddress];
    [Q8ImageHelper setImageWithURL:imageURL
                     intoImageView:imageView
                  placeholderImage:[UIImage imageNamed:placeholderImageName]
                       fallbackURL:nil
                      onCompletion:^(BOOL success) {}];
}

+ (void)setMerchantBackgroundImage:(Q8Merchant *)merchant
                     intoImageView:(UIImageView *)imageView {
    
    NSURL *imageURL = [NSURL URLWithString:merchant.backgroundPictureAddress];
    [Q8ImageHelper setImageWithURL:imageURL
                     intoImageView:imageView
                  placeholderImage:[UIImage imageNamed:placeholderImageName]
                       fallbackURL:nil
                      onCompletion:^(BOOL success) {}];
}

+ (void)setOfferPromoImage:(Q8Offer *)offer
             intoImageView:(UIImageView *)imageView {
    
    NSURL *imageURL = [NSURL URLWithString:offer.pictureAddress];
    [Q8ImageHelper setImageWithURL:imageURL
                     intoImageView:imageView
                  placeholderImage:[UIImage imageNamed:placeholderImageName]
                       fallbackURL:nil
                      onCompletion:^(BOOL success) {}];
}

+ (void)setImageWithURL:(NSURL *)imageURL
          intoImageView:(UIImageView *)imageView
       placeholderImage:(UIImage *)placeholderImage
            fallbackURL:(NSURL *)fallbackURL
           onCompletion:(void (^)(BOOL success))completion {
    
    // Reset old image
    imageView.image = placeholderImage ? placeholderImage : [UIImage new];
    
    // Removing old activity indicators, if any
    [Q8ImageHelper removeActivityIndicatorFromImageView:imageView];
    
    // Track instance of image view, so when it is used in reusable cells,
    // there are no image bugs with old images repopulating new cells
    __weak UIImageView *imageViewWeakCopy = imageView;
    imageView.tag = arc4random_uniform(10000);
    int imageViewTag = (int)imageView.tag;
    
    // If no image to load, end
    if (!imageURL) {
        completion(NO);
        return;
    }
    
    // Adding activity indicator while we wait
    [self addActivityIndicatorToImageView:imageView];
    
    // Make request for main image and fallback
    NSMutableURLRequest *request = [Q8ImageHelper imageRequestWithURL:imageURL];
    NSMutableURLRequest *fallbackRequest = [Q8ImageHelper imageRequestWithURL:fallbackURL];
    [imageView setImageWithURLRequest:request
                     placeholderImage:placeholderImage
                              success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                  
                                  // Removing activity indicator on operaiton end
                                  [Q8ImageHelper removeActivityIndicatorFromImageView:imageViewWeakCopy];
                                  
                                  // Set received image into image view
                                  if (imageViewWeakCopy.tag == imageViewTag) {
                                      imageViewWeakCopy.image = image ? image : [UIImage new];
                                  }
                                  
                                  completion(YES);
                              }
                              failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                  if (fallbackRequest) {
                                      [imageViewWeakCopy setImageWithURLRequest:fallbackRequest
                                                               placeholderImage:placeholderImage success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                                                   // Removing activity indicator on operaiton end
                                                                   [Q8ImageHelper removeActivityIndicatorFromImageView:imageViewWeakCopy];
                                                                   
                                                                   if (imageViewWeakCopy.tag == imageViewTag) {
                                                                       imageViewWeakCopy.image = image;
                                                                   }
                                                                   
                                                                   completion(YES);
                                                               } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                                                   // Removing activity indicator on operaiton end
                                                                   [Q8ImageHelper removeActivityIndicatorFromImageView:imageViewWeakCopy];
                                                                   completion(NO);
                                                                   
                                                                   if (imageViewWeakCopy.tag == imageViewTag) {
                                                                       imageViewWeakCopy.image = placeholderImage ? placeholderImage : [UIImage new];
                                                                   }
                                                               }];
                                  } else {
                                      // Removing activity indicator on operaiton end
                                      [Q8ImageHelper removeActivityIndicatorFromImageView:imageViewWeakCopy];
                                      completion(NO);
                                      
                                      if (imageViewWeakCopy.tag == imageViewTag) {
                                          imageViewWeakCopy.image = placeholderImage ? placeholderImage : [UIImage new];
                                      }
                                  }
                              }];
}

#pragma mark - Convinience

+ (NSMutableURLRequest *)imageRequestWithURL:(NSURL *)imageURL {
    if (imageURL) {
        // Accepted types spam, as there is a bug when "*" does not work for S3 buckets
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        [request addValue:@"image/jpg" forHTTPHeaderField:@"Accept"];
        [request addValue:@"image/png" forHTTPHeaderField:@"Accept"];
        
        return request;
    }
    return nil;
}

#pragma mark - Activity indicator

+ (void)addActivityIndicatorToImageView:(UIImageView *)imageView {
    // Adding activity indicator while we wait
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [imageView addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(imageView.bounds.size.width/2, imageView.bounds.size.height/2);
    [activityIndicator startAnimating];
}


+ (void)removeActivityIndicatorFromImageView:(UIView *)view {
    [WLUtilityHelper runOnMainThreadWithoutDeadlocking:^{
        // Removing every activity indicator from specified view
        NSMutableArray *indicators = [NSMutableArray new];
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:[UIActivityIndicatorView class]]) {
                [indicators addObject:subview];
            }
        }
        for (UIView *subview in indicators) {
            [subview removeFromSuperview];
        }
    }];
}

@end
