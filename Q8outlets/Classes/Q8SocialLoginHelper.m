//
//  Q8SocialLoginHelper.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/8/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8SocialLoginHelper.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Q8InstagramLoginViewController.h"
#import <InstagramKit/InstagramKit.h>
#import <InstagramKit/InstagramEngine.h>

@implementation Q8SocialLoginHelper {
    void (^instagramAuthorizationCompletion)(BOOL success, NSString *instagramToken);
    BOOL instagramLoginOnServer;
    UIViewController *instagramSenderController;
}

+ (Q8SocialLoginHelper *)sharedHelper {
    static dispatch_once_t onceToken;
    static Q8SocialLoginHelper *sharedHelper = nil;
    
    dispatch_once(&onceToken, ^{
        sharedHelper = [Q8SocialLoginHelper new];
        [sharedHelper loadState];
    });
    
    return sharedHelper;
}

- (instancetype)init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successfullInstagramLoginNotification:) name:Q8NotificationInstagramLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedInstagramLoginNotification:) name:Q8NotificationInstagramLoginFail object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Facebook

+ (void)loginFacebookOnCompletion:(void (^)(BOOL success))completion
                           sender:(UIViewController *)sender {
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithPermissions:@[@"public_profile", @"email"]
                        fromViewController:nil
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                       if (error) {
                                           WLDebLog(@"%@",error);
                                           NSString *errorMessage = @"";
                                           if ([error.userInfo objectForKey:@"com.facebook.sdk:FBSDKErrorDeveloperMessageKey"]) {
                                               errorMessage = [error.userInfo objectForKey:@"com.facebook.sdk:FBSDKErrorDeveloperMessageKey"];
                                           }
                                           if (sender.isViewLoaded && sender.view.window) {
                                               [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[errorMessage] delegate:nil];
                                           }
                                           completion(NO);
                                       } else {
                                           completion(YES);
                                       }
                                   }];
}

+ (void)logoutFacebook {
    [FBSDKAccessToken setCurrentAccessToken:nil];
}

#pragma mark - Google

- (void)loginGoogleOnCompletion:(void (^)(BOOL, NSString *googleToken))completion
                         sender:(UIViewController *)sender {
    NSURL *issuer = [NSURL URLWithString:kIssuer];
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
    
    WLDebLog(@"Fetching configuration for issuer: %@", issuer);
    
    // discovers endpoints
    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
        
        if (!configuration) {
            WLErrLog(@"Error retrieving discovery document: %@", error);
            [self logoutGoogle];
            completion(NO, nil);
            return;
        }
        
        WLDebLog(@"Got configuration: %@", configuration);
        
        // builds authentication request
        OIDAuthorizationRequest *request =
        [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                      clientId:kClientID
                                                        scopes:@[OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail]
                                                   redirectURL:redirectURI
                                                  responseType:OIDResponseTypeCode
                                          additionalParameters:nil];
        // performs authentication request
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        WLDebLog(@"Initiating authorization request with scope: %@", request.scope);
        
        appDelegate.currentAuthorizationFlow =
        [OIDAuthState authStateByPresentingAuthorizationRequest :request
                                       presentingViewController:sender
                                                       callback:^(OIDAuthState *_Nullable authState,
                                                                  NSError *_Nullable error) {
                                                           if (authState) {
                                                               GTMAppAuthFetcherAuthorization *authorization =
                                                               [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                                                               
                                                               [self setGtmAuthorization:authorization];
                                                               WLDebLog(@"Got authorization tokens. Access token: %@",
                                                                        authState.lastTokenResponse.accessToken);
                                                               
                                                               completion(YES, authState.lastTokenResponse.accessToken);
                                                           } else {
                                                               [self logoutGoogle];
                                                               WLErrLog(@"Authorization error: %@", [error localizedDescription]);
                                                               if (sender.isViewLoaded && sender.view.window) {
                                                                   [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[[error localizedDescription]] delegate:nil];
                                                               }
                                                               completion(NO, nil);
                                                           }
                                                       }];
    }];
}

- (void)logoutGoogle {
    [self setGtmAuthorization:nil];
}


/*! @brief Saves the @c GTMAppAuthFetcherAuthorization to @c NSUSerDefaults.
 */
- (void)saveState {
    if (_authorization.canAuthorize) {
        [GTMAppAuthFetcherAuthorization saveAuthorization:_authorization
                                        toKeychainForName:kExampleAuthorizerKey];
    } else {
        [GTMAppAuthFetcherAuthorization removeAuthorizationFromKeychainForName:kExampleAuthorizerKey];
    }
}

/*! @brief Loads the @c GTMAppAuthFetcherAuthorization from @c NSUSerDefaults.
 */
- (void)loadState {
    GTMAppAuthFetcherAuthorization* authorization =
    [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:kExampleAuthorizerKey];
    [self setGtmAuthorization:authorization];
}

- (void)setGtmAuthorization:(GTMAppAuthFetcherAuthorization*)authorization {
    if ([_authorization isEqual:authorization]) {
        return;
    }
    _authorization = authorization;
    [self stateChanged];
}

- (void)stateChanged {
    [self saveState];
}

- (void)didChangeState:(OIDAuthState *)state {
    [self stateChanged];
}

- (void)authState:(OIDAuthState *)state didEncounterAuthorizationError:(NSError *)error {
    WLErrLog(@"%@", error);
}

- (BOOL)isAuthorized {
    [self loadState];
    WLDebLog(@"%ld",(long)_authorization.authState.isAuthorized);
    return _authorization.authState.isAuthorized;
}


#pragma mark - Twitter
//
//+ (void)loginTwitterOnCompletion:(void (^)(BOOL, NSString *twitterToken, NSString *twitterSecret))completion
//                          sender:(UIViewController *)sender {
//    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
//        if (session) {
//            WLDebLog(@"signed in as %@", session.userName);
//            completion(YES, session.authToken, session.authTokenSecret);
//        } else {
//            WLErrLog(@"Authorizaation error: %@ %ld", error, (long)error.code);
//            if (sender.isViewLoaded && sender.view.window && error.code!=1) {
//                [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[[error localizedDescription]] delegate:nil];
//            }
//            completion(NO, nil, nil);
//        }
//    }];
//}

+ (void)logoutTwitter {
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
//    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
//    NSString *userID = store.session.userID;
//    [[[Twitter sharedInstance] sessionStore] logOutUserID:userID];
}

#pragma mark - Instagram

- (void)loginInstagramOnCompletion:(void (^)(BOOL, NSString *))completion
                            sender:(UIViewController *)sender {
    instagramAuthorizationCompletion = completion;
    instagramSenderController = sender;
    Q8InstagramLoginViewController *instagramController = [[Q8InstagramLoginViewController alloc] initWithNibName:Q8InstagramLoginControllerXibName bundle:nil];
    [sender.navigationController pushViewController:instagramController animated:YES];
}

- (void)successfullInstagramLoginNotification:(NSNotification *)notification {
    // Successfull instagram login
    instagramAuthorizationCompletion(YES, [notification.userInfo objectForKey:@"token"]);
}

- (void)failedInstagramLoginNotification:(NSNotification *)notification {
    // Couldn't login with instagram
    instagramAuthorizationCompletion(NO, nil);
}

+ (void)logoutInstagram {
    [[InstagramEngine sharedEngine] logout];
}

@end
