//
//  Q8ShareHelper.m
//  Q8outlets
//
//  Created by GlebGamaun on 07.03.17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8ShareHelper.h"

#import <FBSDKShareKit/FBSDKShareKit.h>

#define SHARE_IMAGE_LINK    @"https://q8outlets.com/logo.png"
#define SHARE_LINK          @"https://q8outlets.com"

@implementation Q8ShareHelper

//+ (void)shareOfferToFacebook:(Q8Offer *)offer {
//    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//    content.contentURL = [NSURL URLWithString:offer.link.length ? offer.link : SHARE_LINK];
//    content.contentDescription = [Q8ShareHelper sharingTextByOffer:offer];
//    content.imageURL = [NSURL URLWithString:SHARE_IMAGE_LINK];
//    
//    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
//    
//    dialog.shareContent = content;
//    dialog.mode = FBSDKShareDialogModeNative; // if you don't set this before canShow call, canShow would always return YES
//    if (![dialog canShow]) {
//        // fallback presentation when there is no FB app
//        dialog.mode = FBSDKShareDialogModeFeedBrowser;
//    }
//    [dialog show];
//}

+ (void)shareOfferToOther:(Q8Offer *)offer {
    // Share offer title and description
    NSMutableArray *sharingItems = [NSMutableArray new];
    NSString *sharingText = [Q8ShareHelper sharingTextByOffer:offer];
    [sharingItems addObject:sharingText];
    
    [Q8ShareHelper shareItems:sharingItems];
}

+ (void)shareItems:(NSArray *)items {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootViewController presentViewController:activityController animated:YES completion:nil];
}

+ (NSString *)sharingLinkByOffer:(Q8Offer *)offer {
    return offer.link.length ? [NSString stringWithFormat:NSLocalizedString(@"Check it here. %@", nil), offer.link] : @"";
}

+ (NSString *)sharingTextByOffer:(Q8Offer *)offer {
    return [NSString stringWithFormat:@"%@. %@. %@", offer.merchant.title, offer.title, [Q8ShareHelper sharingLinkByOffer:offer]];
}

@end
