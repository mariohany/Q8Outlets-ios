//
//  Q8SocialLoginHelper.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/8/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppAuth/AppAuth.h>
//#import "AppAuth.h"
#import <GTMAppAuth/GTMAppAuth.h>
#import "AppDelegate.h"
#import "GTMSessionFetcher.h"
#import "GTMSessionFetcherService.h"
//#import <TwitterCore/TwitterCore.h>
//#import <Twitter/Twitter.h>
@import Twitter;
//@import TwitterCore;
//@import TwitterKit;

static NSString *const kIssuer = @"https://accounts.google.com";
static NSString *const kExampleAuthorizerKey = @"authorization";

// Dev
//static NSString *const kClientID = @"666808612663-rcstou5mfesokiskn670gsqbhdinq5qg.apps.googleusercontent.com";
//static NSString *const kRedirectURI =
//@"com.googleusercontent.apps.666808612663-rcstou5mfesokiskn670gsqbhdinq5qg:/oauthredirect";

// Live
static NSString *const kClientID = @"627742393930-9cft6vt8ig8958uoo29dj1fuoro01fu8.apps.googleusercontent.com";
static NSString *const kRedirectURI =
@"com.googleusercontent.apps.627742393930-9cft6vt8ig8958uoo29dj1fuoro01fu8:/oauthredirect";
@interface Q8SocialLoginHelper : NSObject <OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate>


+ (Q8SocialLoginHelper *)sharedHelper;

// **
// Facebook
+ (void)loginFacebookOnCompletion:(void (^)(BOOL success))completion
                     sender:(UIViewController *)sender;
+ (void)logoutFacebook;

// **
// Google
@property(nonatomic) GTMAppAuthFetcherAuthorization *authorization;

- (void)loginGoogleOnCompletion:(void (^)(BOOL success, NSString *googleToken))completion
                             sender:(UIViewController *)sender;
- (void)logoutGoogle;

// **
// Twitter
+ (void)loginTwitterOnCompletion:(void (^)(BOOL success, NSString *twitterToken, NSString *twitterSecret))completion
                          sender:(UIViewController *)sender;
+ (void)logoutTwitter;

// **
// Instagram
- (void)loginInstagramOnCompletion:(void (^)(BOOL success, NSString *instagramToken))completion
                            sender:(UIViewController *)sender;
+ (void)logoutInstagram;


@end
