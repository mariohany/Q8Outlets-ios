//
//  Q8ServerAPIHelper.m
//  Q8outlets
//
//  Created by Lesya Verbina on 1/31/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8ServerAPIHelper.h"
#import <Reachability/Reachability.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

typedef NS_ENUM(NSUInteger, Q8HTTPRequestMethod) {
    Q8HTTPRequestMethodGET = 0,
    Q8HTTPRequestMethodPOST,
    Q8HTTPRequestMethodPATCH,
    Q8HTTPRequestMethodPUT,
    Q8HTTPRequestMethodDELETE
};

@implementation Q8ServerAPIHelper   {
    BOOL silenceNoInternerAlert; // Way to know if helper should alert about internet loss
}

+ (Q8ServerAPIHelper *)sharedHelper {
    static dispatch_once_t onceToken;
    static Q8ServerAPIHelper *sharedHelper = nil;
    
    dispatch_once(&onceToken, ^{
        sharedHelper = [[Q8ServerAPIHelper alloc] init];
        sharedHelper.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    
    return sharedHelper;
}

- (instancetype)init {
    self = [super initWithBaseURL:[NSURL URLWithString:SERVER_MAIN_URL]];
    
    // Initialize Reachability
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    // Start Monitoring
    [reachability startNotifier];
    
    // JSON request and response serializers
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return self;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler {
    if (![Q8ServerAPIHelper isNetworkReachable]) {
        // Displaying "no internet" alert
        if (!silenceNoInternerAlert) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonNoInternet]];
        }
    }
    return [super dataTaskWithRequest:request uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:^(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) {
        
        // Cleaning response object from NSNull objects so it does not crash
        responseObject = [WLUtilityHelper JSONcleanedFromNulls:responseObject];
        
        if (error) {
            NSHTTPURLResponse *httpResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            NSInteger statusCode = httpResponse.statusCode;
            
            // If access token is wrong, user has to be logged out
            if (statusCode==WRONG_AUTHORIZATION_ERROR_CODE && [Q8CurrentUser isAuthorized]) {
                // Alerting user why they are redirected to the login screen
                WLErrLog(@"Wrong token : %@",[error localizedDescription]);
                [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonSessionExpired]];
                [Q8CurrentUser logOutAndMoveToLoginScreen:YES];
            }
        }
        
        completionHandler(response, responseObject, error);
    }];
}

- (void)sendRequestWithMethod:(Q8HTTPRequestMethod)method
                             path:(NSString *)path
                 checkAccessToken:(BOOL)isNeedCheckAccessToken
                       authorized:(BOOL)authorized
                       parameters:(NSDictionary *)parameters
                          success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                          failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    if (isNeedCheckAccessToken) {
        if (![Q8CurrentUser accessToken].length || ![Q8CurrentUser userSessionUDID].length) {
            [Q8CurrentUser logOutAndMoveToLoginScreen:YES];
            return;
        }
    }
    
    [self needAuthorize:authorized];
    switch (method) {
        case Q8HTTPRequestMethodGET:
            [self GET:path parameters:parameters progress:nil success:success failure:failure];
            break;
        case Q8HTTPRequestMethodPOST:
            [self POST:path parameters:parameters progress:nil success:success failure:failure];
            break;
        case Q8HTTPRequestMethodPATCH:
            [self PATCH:path parameters:parameters success:success failure:failure];
            break;
        case Q8HTTPRequestMethodPUT:
            [self PUT:path parameters:parameters success:success failure:failure];
            break;
        case Q8HTTPRequestMethodDELETE:
            [self DELETE:path parameters:parameters success:success failure:failure];
            break;
        default:
            break;
    }
}

- (void)needAuthorize:(BOOL)authorize {
    if (authorize) {
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:[Q8CurrentUser accessToken] password:[Q8CurrentUser userSessionUDID]];
    } else {
        [self.requestSerializer clearAuthorizationHeader];
    }
}

#pragma mark - Authorization

- (void)registerWithEmail:(NSString *)email
                     name:(NSString *)name
                 password:(NSString *)password
             onCompletion:(void (^)(BOOL success))completion
                   sender:(UIViewController *)sender {
    
    // Determines if "no internet" alert will be generated
    silenceNoInternerAlert = NO;
    
    NSString *requestPath = REQUEST_REGISTRATION_EMAIL;
    NSDictionary *userParams = @{@"name" : name ?: @"",
                                 @"email" : email ?: @"",
                                 @"password" : password ?: @"",
                                 @"udid" : [Q8CurrentUser userSessionUDID] ?: @""};
    
    [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                           path:requestPath
               checkAccessToken:NO
                     authorized:NO
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           WLDebLog(@"%@",responseObject);
           
           // Registered
           [self saveUserInfoFromDict:responseObject];
           
           // Save device token
           [self saveDeviceToken:[Q8CurrentUser deviceToken] onCompletion:^(BOOL success) {} sender:nil];
           
           completion(YES);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSInteger statusCode = [self getStatusCodeByError:error];
           
           // Display alert if controller is still on screen
           if (sender.isViewLoaded && sender.view.window) {
               switch (statusCode) {
                   case 422:
                       // Email taken
                       [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonEmailTaken]];
                       break;
                       
                   default:
                       [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@(statusCode)] delegate:nil];
                       break;
               }
           }
           completion(NO);
       }];
}

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
                  role:(Q8UserRole)role
          onCompletion:(void (^)(BOOL success))completion
                sender:(UIViewController *)sender {
    
    // Determines if "no internet" alert will be generated
    silenceNoInternerAlert = NO;
    
    NSString *requestPath = REQUEST_LOGIN_EMAIL;
    NSDictionary *userParams = @{@"login" : email ?: @"",
                                 @"password" : password ?: @"",
                                 @"udid" : [Q8CurrentUser userSessionUDID] ?: @""};
    [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                           path:requestPath
               checkAccessToken:NO
                     authorized:NO
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           WLDebLog(@"%@",responseObject);
           
           // Login successfull
           [self saveUserInfoFromDict:responseObject];
           
           // Save device token
            [self saveDeviceToken:[Q8CurrentUser deviceToken] onCompletion:^(BOOL success) {} sender:nil];
           
           completion(YES);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSInteger statusCode = [self getStatusCodeByError:error];
           
           // Display alert if controller is still on screen
           if (sender.isViewLoaded && sender.view.window) {
               switch (statusCode) {
                   case 422:
                       // Invalid credentials
                       [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonInvalidCredentials]];
                       break;
                       
                   default:
                       [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@(statusCode)] delegate:nil];
                       break;
               }
           }
           completion(NO);
       }];
}

- (void)authorizeUserWithFBOnCompletion:(void (^)(BOOL success, BOOL isRegistration))completion
                                 sender:(UIViewController *)sender {
    NSString *facebookToken = [FBSDKAccessToken currentAccessToken].tokenString;
    [self authorizeUserWithSocialNetwork:Q8SocialNetworkTypeFacebook socialNetworkToken:facebookToken socialNetworkSecret:@"" onCompletion:completion sender:sender];
}

- (void)authorizeUserWithGoogleToken:(NSString *)googleToken
                        onCompletion:(void (^)(BOOL success, BOOL isRegistration))completion
                              sender:(UIViewController *)sender {
    [self authorizeUserWithSocialNetwork:Q8SocialNetworkTypeGoogle socialNetworkToken:googleToken socialNetworkSecret:@"" onCompletion:completion sender:sender];
}

- (void)authorizeUserWithTwitterToken:(NSString *)twitterToken
                         twitterSecret:(NSString *)twitterSecret
                          onCompletion:(void (^)(BOOL success, BOOL isRegistration))completion
                                sender:(UIViewController *)sender {
    [self authorizeUserWithSocialNetwork:Q8SocialNetworkTypeTwitter socialNetworkToken:twitterToken socialNetworkSecret:twitterSecret onCompletion:completion sender:sender];
}


- (void)authorizeUserWithInstagramToken:(NSString *)instagramToken
                           onCompletion:(void (^)(BOOL success, BOOL isRegistration))completion
                                 sender:(UIViewController *)sender {
    [self authorizeUserWithSocialNetwork:Q8SocialNetworkTypeInstagram socialNetworkToken:instagramToken socialNetworkSecret:@"" onCompletion:^(BOOL success, BOOL isRegistration) {
        if (completion) {
            completion(success, isRegistration);
        }
    } sender:sender];
}

- (void)authorizeUserWithSocialNetwork:(Q8SocialNetworkType)socialNetwork
                    socialNetworkToken:(NSString *)socialNetworkToken
                    socialNetworkSecret:(NSString *)socialNetworkSecret
                          onCompletion:(void (^)(BOOL success, BOOL isRegistration))completion
                                sender:(UIViewController *)sender {
    
    // Determines if "no internet" alert will be generated
    silenceNoInternerAlert = NO;
    
    // If no Facebook token - failed
    if (!socialNetworkToken.length) {
        [Q8CurrentUser logOutAndMoveToLoginScreen:NO];
        completion(NO, NO);
    } else {
        NSString *socialNetworkKey = @"";
        switch (socialNetwork) {
            case Q8SocialNetworkTypeFacebook:
                socialNetworkKey = @"facebook";
                break;
            case Q8SocialNetworkTypeGoogle:
                socialNetworkKey = @"google";
                break;
            case Q8SocialNetworkTypeTwitter:
                socialNetworkKey = @"twitter";
                break;
            case Q8SocialNetworkTypeInstagram:
                socialNetworkKey = @"instagram";
                break;
            default:
                break;
        }
        NSDictionary *userParameters = @{@"code" : socialNetworkToken ? socialNetworkToken : @"",
                                         @"socialId" : socialNetworkKey ?: @"",
                                         @"secret" : socialNetworkSecret ?: @"",
                                         @"udid" : [Q8CurrentUser userSessionUDID] ?: @""};
        WLDebLog(@"%@",userParameters);
        
        [self.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
        [self POST:REQUEST_FB_AUTHORIZE
        parameters:userParameters
          progress:nil
           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
               WLDebLog(@"%@ %ld",responseObject, (long)httpResponse.statusCode);
               
               // Logged in and received current user info
               [[Q8ServerAPIHelper sharedHelper] saveUserInfoFromDict:responseObject];
               
               // Save social network data
               [Q8CurrentUser saveUserSocialNetworkType:socialNetwork];
               NSDictionary *socialDictionary = responseObject[@"social"];
               [Q8CurrentUser saveUserSocialNetworkAccount:socialDictionary[@"name"] ? socialDictionary[@"name"] : socialDictionary[@"email"]];
               
               // Save device token
               [self saveDeviceToken:[Q8CurrentUser deviceToken] onCompletion:^(BOOL success) {} sender:nil];
               
               BOOL isRegistration = httpResponse.statusCode==201;
               
               completion(YES, isRegistration);
               
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               NSHTTPURLResponse *httpResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
               NSString *errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]
                                                               encoding:NSUTF8StringEncoding];
               NSInteger statusCode = httpResponse.statusCode;
               WLErrLog(@"%ld %@ %@", (long)statusCode, [error localizedDescription], errorResponse);
               
               // Display alert if controller is still on screen
               if (sender.isViewLoaded && sender.view.window) {
                   NSInteger responseCode = 0;
                   
                   @try {
                       NSDictionary *responseJSON = [WLUtilityHelper dictFromJsonString:errorResponse];
                       responseCode = [[responseJSON objectForKey:@"code"] integerValue];
                   } @catch (NSException *exception) {
                       WLErrLog(@"%@",exception);
                   } @finally {
                   }
                   
                   if (statusCode==422 && responseCode==101) {
                       // Email in this network is already taken, show tip to link
                       [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonSocialNetworkEmailTaken]];
                   } else {
                       [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@(statusCode)] delegate:nil];
                   }
               }
               [Q8CurrentUser logOutAndMoveToLoginScreen:NO];
               completion(NO, NO);
           }];
    }
}

- (void)saveUserInfoFromDict:(NSDictionary *)dictionary {
    
    NSString *name = [dictionary objectForKey:@"name"];
    [Q8CurrentUser saveUserName:name];
    
    NSString *email = [dictionary objectForKey:@"email"];
    [Q8CurrentUser saveUserEmail:email];
    
    BOOL isVIP = [[dictionary objectForKey:@"isActive"] boolValue];
    [Q8CurrentUser saveVIP:isVIP];
    
    if ([dictionary objectForKey:@"authKey"]) {
        NSString *accessToken = [dictionary objectForKey:@"authKey"];
        [Q8CurrentUser saveAccessToken:accessToken];
    }
    
    if ([dictionary objectForKey:@"id"]) {
        NSString *userId = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"id"]];
        [Q8CurrentUser saveUserId:userId];
    }
    
    if ([dictionary objectForKey:@"role"]) {
        Q8UserRole role = (([[dictionary objectForKey:@"role"] integerValue] == 30 ||
                            [[dictionary objectForKey:@"role"] integerValue] == 20) ?
                           Q8UserRoleBusiness :
                           [[dictionary objectForKey:@"role"] integerValue] == 15 ? Q8UserRoleModerator :
                           Q8UserRoleClient);
        [Q8CurrentUser saveUserRole:role];
    }
    
    if (dictionary[@"social"]) {
        NSDictionary *socialDictionary = dictionary[@"social"];
        NSString *socialNetwork = socialDictionary[@"source"];
        Q8SocialNetworkType networkType = 0;
        if ([socialNetwork isEqualToString:@"facebook"]) {
            networkType = Q8SocialNetworkTypeFacebook;
        } else if ([socialNetwork isEqualToString:@"google"]) {
            networkType = Q8SocialNetworkTypeGoogle;
        } else if ([socialNetwork isEqualToString:@"twitter"]) {
            networkType = Q8SocialNetworkTypeTwitter;
        }else if ([socialNetwork isEqualToString:@"instagram"]) {
            networkType = Q8SocialNetworkTypeInstagram;
        }
        [Q8CurrentUser saveUserSocialNetworkType:networkType];
        [Q8CurrentUser saveUserSocialNetworkAccount:socialDictionary[@"name"] ? socialDictionary[@"name"] : socialDictionary[@"email"]];
    }
}

#pragma mark - User info

- (void)sendForgotPasswordToEmail:(NSString *)email
                     onCompletion:(void (^)(BOOL))completion sender:(UIViewController *)sender {
    
    // Determines if "no internet" alert will be generated
    silenceNoInternerAlert = NO;
    
    NSString *requestPath = REQUEST_FORGOT_PASSWORD;
    NSDictionary *userParams = @{@"email" : email ?: @""};

    [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                           path:requestPath
               checkAccessToken:NO
                     authorized:NO
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           WLDebLog(@"%@",responseObject);
           
           completion(YES);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSInteger statusCode = [self getStatusCodeByError:error];
           
           // Display alert if controller is still on screen
           if (sender.isViewLoaded && sender.view.window) {
               switch (statusCode) {
                   case 422:
                       // Email not found
                       [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonEmailNotFound]];
                       break;
                       
                   default:
                       [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@(statusCode)] delegate:nil];
                       break;
               }
           }
           
           completion(NO);
       }];
}

- (void)sendNewPassword:(NSString*)password withToken:(NSString*)token onCompletion:(void (^)(BOOL))completion sender:(UIViewController*)sender {
	NSString *requestPath = REQUEST_SEND_NEW_PASSWORD;
	NSDictionary *userParams = @{@"token": token,
								 @"password" : password
								 };
	
	[self sendRequestWithMethod:Q8HTTPRequestMethodPOST
						   path:requestPath
			   checkAccessToken:NO
					 authorized:NO
					 parameters:userParams
						success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
							WLDebLog(@"%@", responseObject);
							completion(YES);
						} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
							NSInteger statusCode = [self getStatusCodeByError:error];
							if (sender.isViewLoaded && sender.view.window) {
								switch (statusCode) {
									case 422:
										[WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonInvalidCredentials]];
										break;
										
									default:
										[WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@(statusCode)] delegate:nil];
										break;
								}
							}
							completion(NO);
						}];
}

- (void)activateVIPCode:(NSString *)code
           onCompletion:(void (^)(BOOL success, BOOL codeIsInvalid))completion
                 sender:(UIViewController *)sender {
    
    // Determines if "no internet" alert will be generated
    silenceNoInternerAlert = NO;
    
    NSString *requestPath = REQUEST_ACTIVATE_VIP;
    NSDictionary *userParams = @{@"token" : code ?: @""};

    [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           WLDebLog(@"%@",responseObject);
           
           [Q8CurrentUser saveVIP:YES];
           
           // VIP code succes
           completion(YES, NO);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSInteger statusCode = [self getStatusCodeByError:error];
           
           // Display alert if controller is still on screen
           if (sender.isViewLoaded && sender.view.window) {
               switch (statusCode) {
                   case 422:
                       // Invalid code
                       [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonCodeInvalid]];
                       completion(NO, YES);
                       break;
                       
                   default:
                       completion(NO, NO);
                       [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@(statusCode)] delegate:nil];
                       break;
               }
           }
       }];
}

- (void)getCurrentUserInfoOnCompletion:(void (^)(BOOL success))completion
                                sender:(UIViewController *)sender {
    
}

- (void)saveDeviceToken:(NSString *)deviceToken
           onCompletion:(void (^)(BOOL success))completion
                 sender:(UIViewController *)sender {
    if ([Q8CurrentUser userRole] == Q8UserRoleClient && deviceToken) {
        NSString *requestPath = REQUEST_DEVICE_TOKEN([Q8CurrentUser userId]);
        NSDictionary *userParams = @{@"id" : [Q8CurrentUser userId],
                                     @"device_token" : deviceToken,
                                     @"type" : @"IOS"};
        [self sendRequestWithMethod:Q8HTTPRequestMethodPOST path:requestPath checkAccessToken:YES authorized:YES parameters:userParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            WLDebLog(@"%@",responseObject);
            completion(YES);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            completion(NO);
        }];

    } else {
         completion(NO);
    }
}

- (void)removeDeviceToken:(NSString *)deviceToken
             onCompletion:(void (^)(BOOL success))completion
                   sender:(UIViewController *)sender {
    if ([Q8CurrentUser userId] && deviceToken) {
        NSString *requestPath = REQUEST_DEVICE_TOKEN([Q8CurrentUser userId]);
        NSDictionary *userParams = @{@"id" : [Q8CurrentUser userId],
                                     @"device_token" : deviceToken};
        [self sendRequestWithMethod:Q8HTTPRequestMethodDELETE path:requestPath checkAccessToken:NO authorized:YES parameters:userParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            WLDebLog(@"%@",responseObject);
            completion(YES);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            completion(NO);
        }];
    } else {
        completion(NO);
    }
    
}

- (void)linkFBOnCompletion:(void (^)(BOOL success))completion
                    sender:(UIViewController *)sender {
    NSString *facebookToken = [FBSDKAccessToken currentAccessToken].tokenString;
    [self connectUserWithSocialNetwork:Q8SocialNetworkTypeFacebook socialNetworkToken:facebookToken socialNetworkSecret:@"" onCompletion:completion sender:sender];
}

- (void)linkGoogleToken:(NSString *)googleToken
           onCompletion:(void (^)(BOOL success))completion
                 sender:(UIViewController *)sender {
    [self connectUserWithSocialNetwork:Q8SocialNetworkTypeGoogle socialNetworkToken:googleToken socialNetworkSecret:@"" onCompletion:completion sender:sender];
}

- (void)linkTwitterToken:(NSString *)twitterToken
           twitterSecret:(NSString *)twitterSecret
            onCompletion:(void (^)(BOOL success))completion
                  sender:(UIViewController *)sender {
    [self connectUserWithSocialNetwork:Q8SocialNetworkTypeTwitter socialNetworkToken:twitterToken socialNetworkSecret:twitterSecret onCompletion:completion sender:sender];
}

- (void)linkInstagramToken:(NSString *)instagramToken
              onCompletion:(void (^)(BOOL success))completion
                    sender:(UIViewController *)sender {
    [self connectUserWithSocialNetwork:Q8SocialNetworkTypeInstagram socialNetworkToken:instagramToken socialNetworkSecret:@"" onCompletion:completion sender:sender];
}

- (void)connectUserWithSocialNetwork:(Q8SocialNetworkType)socialNetwork
                  socialNetworkToken:(NSString *)socialNetworkToken
                 socialNetworkSecret:(NSString *)socialNetworkSecret
                        onCompletion:(void (^)(BOOL success))completion
                              sender:(UIViewController *)sender {
    
    // Determines if "no internet" alert will be generated
    silenceNoInternerAlert = NO;
    
    // If no Facebook token - failed
    
        NSString *socialNetworkKey = @"";
        switch (socialNetwork) {
            case Q8SocialNetworkTypeFacebook:
                socialNetworkKey = @"facebook";
                break;
            case Q8SocialNetworkTypeGoogle:
                socialNetworkKey = @"google";
                break;
            case Q8SocialNetworkTypeTwitter:
                socialNetworkKey = @"twitter";
                break;
            case Q8SocialNetworkTypeInstagram:
                socialNetworkKey = @"instagram";
                break;
            default:
                break;
        }
        NSDictionary *userParameters = @{@"code" : socialNetworkToken ? socialNetworkToken : @"",
                                         @"socialId" : socialNetworkKey ?: @"",
                                         @"secret" : socialNetworkSecret ?: @""};
        WLDebLog(@"%@",userParameters);

        [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                               path:REQUEST_SOCIAL([Q8CurrentUser userId])
                   checkAccessToken:YES
                         authorized:YES
                         parameters:userParameters
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            WLDebLog(@"%@",responseObject);
            
            // Save social network data
            [Q8CurrentUser saveUserSocialNetworkType:socialNetwork];
            NSDictionary *socialDictionary = responseObject[@"social"];
            [Q8CurrentUser saveUserSocialNetworkAccount:socialDictionary[@"name"] ? socialDictionary[@"name"] : socialDictionary[@"email"]];
                                
            completion(YES);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSInteger statusCode = [self getStatusCodeByError:error];
            switch (statusCode) {
                case 406:
                    [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonSocialAccountUsed]];
                    break;
                default:
                    [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@(statusCode)] delegate:nil];
                    break;
            }
            
            completion(NO);
        }];    
}

- (void)disconnectUserSocialNetwork:(NSString *)userID
                       onCompletion:(void (^)(BOOL success))completion
                             sender:(UIViewController *)sender {
    [self sendRequestWithMethod:Q8HTTPRequestMethodDELETE
                           path:REQUEST_SOCIAL([Q8CurrentUser userId])
               checkAccessToken:YES
                     authorized:YES
                     parameters:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            WLDebLog(@"%@",responseObject);
                            
            completion(YES);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (sender.isViewLoaded && sender.view.window) {
                NSInteger statusCode = [self getStatusCodeByError:error];
                switch (statusCode) {
                    case 406:
                        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonCantUnlinkNoPass]];
                        break;
                    default:
                        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@(statusCode)] delegate:nil];
                        break;
                }
            }
            
            completion(NO);
    }];
}

- (void)updateUserEmail:(NSString *)email name:(NSString *)name password:(NSString *)password
           onCompletion:(void (^)(BOOL success))completion
                 sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_UPDATE_USER;
    NSDictionary *userParams = @{@"email" : email,
                                 @"name" : name,
                                 @"password" : password};
    
    [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            completion(YES);
                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            if (sender.isViewLoaded && sender.view.window) {
                                [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
                            }
                            completion(NO);
                        }];
    
}

- (void)getUserSettings:(NSString *)userID
           onCompletion:(void (^)(BOOL success, Q8EndUserSetting *userSetting))completion
                 sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_SETTINGS(userID);
    [self sendRequestWithMethod:Q8HTTPRequestMethodGET
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        WLDebLog(@"%@",responseObject);
        completion(YES, [Q8EndUserSetting endUserSettingFromDictionary:responseObject]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (sender.isViewLoaded && sender.view.window) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
        }
        completion(NO, nil);
    }];
}

- (void)saveEndUserSettings:(NSString *)userID
                   settings:(Q8EndUserSetting *)userSetting
               onCompletion:(void (^)(BOOL success))completion
                     sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_SETTINGS(userID);
    NSDictionary *userParams = @{@"email_near_offer" : @(@(userSetting.isOfferEmailsEnabled).intValue),
                                 @"push_near_offer" : @(@(userSetting.isOfferPushesEnabled).intValue),
                                 @"email_followed_offer" : @(@(userSetting.isMerchantEmailsEnabled).intValue),
                                 @"push_followed_offer" : @(@(userSetting.isMerchantPushesEnabled).intValue),
                                 @"email_coupon_available" : @(@(userSetting.isCouponsEmailsEnabled).intValue),
                                 @"push_coupon_available" : @(@(userSetting.isCouponsPushesEnabled).intValue)};
    [self sendRequestWithMethod:Q8HTTPRequestMethodPUT
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            WLDebLog(@"%@",responseObject);
        completion(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (sender.isViewLoaded && sender.view.window) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
        }
        completion(NO);
    }];
}

#pragma mark - Offers

- (void)applyToOffer:(Q8Offer *)offer
       onCompletions:(void (^)(BOOL success, Q8Coupon *coupon))completion
              sender:(UIViewController *)sender {
    
    // Determines if "no internet" alert will be generated
    silenceNoInternerAlert = NO;
    
    NSString *requestPath = REQUEST_APPLY_TO_OFFER;
    NSDictionary *userParams = @{@"offer_id" : offer.offerId ?: @""};

    [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           WLDebLog(@"%@",responseObject);
           
           // Applied successfully
           completion(YES, [Q8Coupon couponFromDictionary:responseObject]);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSInteger statusCode = [self getStatusCodeByError:error];
           
           // Display alert if controller is still on screen
           if (sender.isViewLoaded && sender.view.window) {
               switch (statusCode) {
                   case 409:
                       // No more coupons left
                       [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonOfferReachedMaxAmountCoupons]];
                       completion(NO, nil);
                       break;
                       
                   default:
                       completion(NO, nil);
                       [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@(statusCode)] delegate:nil];
                       break;
               }
           }
       }];
}

- (void)getOffersByCategoryID:(NSString *)categoryID
                   businessID:(NSString *)businessID
                         text:(NSString *)text
                     latitude:(NSString *)latitude
                   longtitude:(NSString *)longtitude
                         page:(NSInteger)page
               searchByfollow:(BOOL)searchByfollow
                 onCompletion:(void (^)(BOOL success, NSArray <Q8Offer *> *offersArray, NSInteger offersCount, NSString *searchText))completion
                       sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_GET_OFFER_BY_LOCATION;
    NSDictionary *userParams = @{@"category_id" : categoryID,
                                 @"business_id" : businessID,
                                 @"text" : text,
                                 @"latitude" : latitude,
                                 @"longitude" : longtitude,
                                 @"page" : @(page),
                                 @"per-page" : @(20),
                                 @"follow" : @(searchByfollow),
                                 @"is_active" : @(YES),
                                 @"expand" : @"locations, myFollow, countLikes, myLike, countCoupons, myCoupon, business"};
    
    [self sendRequestWithMethod:Q8HTTPRequestMethodGET
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          WLDebLog(@"%@",responseObject);
          
          NSMutableArray *objects = [NSMutableArray array];
          for (NSDictionary *dictionary in responseObject) {
              [objects addObject:[Q8Offer offerFromDictionary:dictionary]];
          }
          
          NSDictionary *dictHeader = [self getResponseHeaderByTask:task];
          NSInteger offerTotalCount = [[dictHeader objectForKey:PAGINATION_TOTAL_COUNT] integerValue];
          // Applied successfully
          completion(YES, objects, offerTotalCount, text);
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          if (sender.isViewLoaded && sender.view.window) {
              [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
          }
          
          completion(NO, nil, 0, text);
      }];
    
}

- (void)getActiveOffersForBusiness:(NSString *)businessID
                              page:(NSInteger)page
                     onCompletions:(void (^)(BOOL success, NSArray <Q8Offer *> *offersArray, NSInteger offersCount))completion
                            sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_GET_ACTIVE_BUSINESS_OFFER;
    NSDictionary *userParams = @{@"business_id" : businessID,
                                 @"page" : @(page),
                                 @"per-page" : @(20),
                                 @"expand" : @"active_coupons, used_coupons, expired_coupons,max_members, locations"};
    [self sendRequestWithMethod:Q8HTTPRequestMethodGET
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          WLDebLog(@"%@",responseObject);
          
          NSMutableArray *objects = [NSMutableArray array];
          for (NSDictionary *dictionary in responseObject) {
              [objects addObject:[Q8Offer offerFromDictionary:dictionary]];
          }
          
          NSDictionary *dictHeader = [self getResponseHeaderByTask:task];
          NSInteger offerTotalCount = [[dictHeader objectForKey:PAGINATION_TOTAL_COUNT] integerValue];
          // Applied successfully
          completion(YES, objects, offerTotalCount);
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          if (sender.isViewLoaded && sender.view.window) {
              [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
          }
          
          completion(NO, nil, 0);
      }];
}

- (void)getStatisticsByOfferID:(NSString *)offerID
                 onCompletions:(void (^)(BOOL success, NSInteger appliedCount, NSInteger usedCount, NSInteger expiredCount))completion
                        sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_GET_OFFER_STATISTICS;
    NSDictionary *userParams = @{@"offer_id" : offerID};
    [self sendRequestWithMethod:Q8HTTPRequestMethodGET
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          WLDebLog(@"%@",responseObject);
          NSInteger usedCount = [responseObject[@"used"] integerValue];
          NSInteger expiredCount = [responseObject[@"expired"] integerValue];
          NSInteger appliedCount = [responseObject[@"active"] integerValue] + expiredCount + usedCount;
          completion(YES, appliedCount, usedCount, expiredCount);
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          if (sender.isViewLoaded && sender.view.window) {
              [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
          }
          
          completion(NO, 0, 0, 0);
      }];    
}

- (void)getOfferNotification:(NSInteger)page
               onCompletions:(void (^)(BOOL success, NSArray <Q8BusinessNotification *> *notificationArray, NSInteger notificationCount))completion
                      sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_GET_OFFER_NOTIFICATIONS;
    NSDictionary *userParams = @{@"page" : @(page),
                                 @"per-page" : @(20)};
    [self sendRequestWithMethod:Q8HTTPRequestMethodGET
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          WLDebLog(@"%@",responseObject);
          NSMutableArray *objects = [NSMutableArray array];
          for (NSDictionary *dictionary in responseObject) {
              [objects addObject:[Q8BusinessNotification notificationFromDictionary:dictionary]];
          }
          NSDictionary *dictHeader = [self getResponseHeaderByTask:task];
          NSInteger notificationTotalCount = [[dictHeader objectForKey:PAGINATION_TOTAL_COUNT] integerValue];
          
          completion(YES, objects, notificationTotalCount);
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          if (sender.isViewLoaded && sender.view.window) {
              [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
          }
          completion(NO, nil, 0);
      }];
}

- (void)getOfferByOfferID:(NSString *)offerID
            onCompletions:(void (^)(BOOL success, Q8Offer *offer))completion
                   sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_GET_OFFER(offerID);
    NSDictionary *userParams = @{@"id" : offerID,
                                 @"expand" : @"locations, myFollow, countLikes, myLike, countCoupons, business"};
    [self sendRequestWithMethod:Q8HTTPRequestMethodGET path:requestPath checkAccessToken:YES authorized:YES parameters:userParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        WLDebLog(@"%@",responseObject);
        completion(YES,  [Q8Offer offerFromDictionary:responseObject]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (sender.isViewLoaded && sender.view.window) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
        }
        completion(NO, nil);
    }];
}

- (void)addLikeToOffer:(NSString *)offerID
          onCompletion:(void (^)(BOOL success))completion
                sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_UPDATE_OFFER_LIKE(offerID);
    [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        WLDebLog(@"%@",responseObject);
        completion(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (sender.isViewLoaded && sender.view.window) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
        }
        completion(NO);
    }];
}

- (void)removeLikeFromOffer:(NSString *)offerID
               onCompletion:(void (^)(BOOL success))completion
                     sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_UPDATE_OFFER_LIKE(offerID);
    [self sendRequestWithMethod:Q8HTTPRequestMethodDELETE
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        WLDebLog(@"%@",responseObject);
        completion(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (sender.isViewLoaded && sender.view.window) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
        }
        completion(NO);
    }];
}

- (void)followOffer:(NSString *)offerID
       onCompletion:(void (^)(BOOL success))completion
             sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_UPDATE_OFFER_FOLLOW(offerID);
    NSDictionary *userParams = @{@"id" : offerID};
    [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            WLDebLog(@"%@",responseObject);
                            completion(YES);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (sender.isViewLoaded && sender.view.window) {
                [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
            }
            completion(NO);
    }];
}

- (void)removeFollowFromOffer:(NSString *)offerID
                 onCompletion:(void (^)(BOOL success))completion
                       sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_UPDATE_OFFER_FOLLOW(offerID);
    NSDictionary *userParams = @{@"id" : offerID};
    [self sendRequestWithMethod:Q8HTTPRequestMethodDELETE
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            WLDebLog(@"%@",responseObject);
                            completion(YES);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (sender.isViewLoaded && sender.view.window) {
                [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
            }
            completion(NO);
    }];
}

- (void)reportOffer:(NSString *)offerID
     reportCategory:(NSInteger)categoryID
       onCompletion:(void (^)(BOOL success))completion
             sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_REPORT_OFFER(offerID);
    NSDictionary *userParams = @{@"category_id" : @(categoryID)};
    [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            WLDebLog(@"%@",responseObject);
                            completion(YES);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (sender.isViewLoaded && sender.view.window) {
                [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
            }
            completion(NO);
    }];
}

#pragma mark - Business

- (void)getMerchantsByCategoryID:(NSString *)categoryID
                            text:(NSString *)text
                        latitude:(NSString *)latitude
                      longtitude:(NSString *)longtitude
                            page:(NSInteger)page
                  searchByfollow:(BOOL)searchByfollow
          onCompletion:(void (^)(BOOL success, NSArray <Q8Merchant *> *, NSInteger merchantTotalCount, NSString *searchText))completion
                sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_GET_BUSINESS;
    NSDictionary *userParams = @{@"category_id" : categoryID,
                                 @"text" : text,
                                 @"latitude" : latitude,
                                 @"longitude" : longtitude,                                 
                                 @"page" : @(page),
                                 @"per-page" : @(20),
                                 @"follow" : @(searchByfollow),
                                 @"expand" : @"category, photos, businessLocations, myFollow, countActiveOffers"};
    
    [self sendRequestWithMethod:Q8HTTPRequestMethodGET
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           WLDebLog(@"%@",responseObject);
           
           NSMutableArray *objects = [NSMutableArray array];
           for (NSDictionary *dictionary in responseObject) {
               [objects addObject:[Q8Merchant merchantFromDictionary:dictionary]];
           }
           NSDictionary *dictHeader = [self getResponseHeaderByTask:task];
           NSInteger merchantTotalCount = [[dictHeader objectForKey:PAGINATION_TOTAL_COUNT] integerValue];
           // Applied successfully
           completion(YES, objects, merchantTotalCount, text);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           if (sender.isViewLoaded && sender.view.window) {
               [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
           }
           completion(NO, nil, 0, text);
       }];
}

- (void)getMerchantAndOffers:(NSString *)merchantID
                onCompletion:(void (^)(BOOL success, Q8Merchant *merchant, NSArray <Q8Offer *> *))completion
                      sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_GET_BUSINESS_OFFERS(merchantID);
    NSDictionary *userParams = @{@"expand" : @"offers, countActiveOffers, category, myFollow, businessLocations"};
    [self sendRequestWithMethod:Q8HTTPRequestMethodGET
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          WLDebLog(@"%@",responseObject);
        
          Q8Merchant *merchant = [Q8Merchant merchantFromDictionary:responseObject];
        // Applied successfully
          completion(YES, merchant, merchant.allOffers);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // Display alert if controller is still on screen
        if (sender.isViewLoaded && sender.view.window) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
        }
        completion(NO, nil, nil);
    }];
}

- (void)followMerchant:(NSString *)merchantID
          onCompletion:(void (^)(BOOL success))completion
                sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_UPDATE_BUSINESS_FOLLOW(merchantID);
    NSDictionary *userParams = @{@"id" : merchantID};
    [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            WLDebLog(@"%@",responseObject);
                            completion(YES);
                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            if (sender.isViewLoaded && sender.view.window) {
                                [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
                            }
                            completion(NO);
    }];

}

- (void)removeFollowFromMerchant:(NSString *)merchantID
                    onCompletion:(void (^)(BOOL success))completion
                          sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_UPDATE_BUSINESS_FOLLOW(merchantID);
    NSDictionary *userParams = @{@"id" : merchantID};
    [self sendRequestWithMethod:Q8HTTPRequestMethodDELETE
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            WLDebLog(@"%@",responseObject);
                            completion(YES);
                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            if (sender.isViewLoaded && sender.view.window) {
                                [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
                            }
                            completion(NO);
    }];
}

- (void)reportBusiness:(NSString *)businessID
        reportCategory:(NSInteger)categoryID
          onCompletion:(void (^)(BOOL success))completion
                sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_REPORT_BUSINESS(businessID);
    NSDictionary *userParams = @{@"category_id" : @(categoryID)};
    [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            WLDebLog(@"%@",responseObject);
                            completion(YES);
                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            if (sender.isViewLoaded && sender.view.window) {
                                [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
                            }
                            completion(NO);
    }];
}

#pragma mark - Coupons

- (void)getCouponsByCategory:(NSString *)category
                        page:(NSInteger)page
                onCompletion:(void (^)(BOOL success, NSArray <Q8Coupon *> *, Q8CouponsCount *couponsCount, NSInteger couponsTotalCount))completion
                      sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_GET_MY_COUPONS;
    NSDictionary *userParams = @{@"category" : category,
                                 @"page" : @(page),
                                 @"per-page" : @(20),
                                 @"expand" : @"offer,locationsByOffer"};
    [self sendRequestWithMethod:Q8HTTPRequestMethodGET
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          WLDebLog(@"%@",responseObject);
          
          NSMutableArray *objects = [NSMutableArray array];
          for (NSDictionary *dictionary in responseObject) {
              [objects addObject:[Q8Coupon couponFromDictionary:dictionary]];
          }
          
          NSDictionary *dictHeader = [self getResponseHeaderByTask:task];
          NSInteger couponTotalCount = [[dictHeader objectForKey:PAGINATION_TOTAL_COUNT] integerValue];
          Q8CouponsCount *couponsCount = [Q8CouponsCount new];
          couponsCount.activeCount = [dictHeader[COUPON_ACTIVE_COUNT] integerValue];
          couponsCount.archivedCount = [dictHeader[COUPON_ARCHIVED_COUNT] integerValue];
          couponsCount.expiredCount = [dictHeader[COUPON_EXPIRED_COUNT] integerValue];
          couponsCount.usedCount = [dictHeader[COUPON_USED_COUNT] integerValue];
          // Applied successfully
          completion(YES, objects, couponsCount, couponTotalCount);
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSHTTPURLResponse *httpResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
          NSString *errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]
                                                          encoding:NSUTF8StringEncoding];
          NSInteger statusCode = httpResponse.statusCode;
          WLErrLog(@"%ld %@ %@", (long)statusCode, [error localizedDescription], errorResponse);
          
          // Display alert if controller is still on screen
          if (sender.isViewLoaded && sender.view.window) {
              switch (statusCode) {
                  case 403:
                      // No more coupons left
                      [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonCodeInvalid]];
                      completion(NO, nil, nil, 1);
                      break;
                      
                  default:
                      completion(NO, nil, nil, 1);
                      [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@(statusCode)] delegate:nil];
                      break;
              }
          }
      }];
}

- (void)updateCoupon:(NSInteger )couponID
             archive:(BOOL)archive
        onCompletion:(void (^)(BOOL success))completion
              sender:(UIViewController *)sender {
    NSString *requestPath =  REQUEST_PATH_COUPON_ID([@(couponID) stringValue]);
    NSDictionary *userParams = @{@"archive" : @(archive)};
    [self sendRequestWithMethod:Q8HTTPRequestMethodPUT
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        WLDebLog(@"%@",responseObject);
        completion(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (sender.isViewLoaded && sender.view.window) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
        }
        completion(NO);
    }];
}

- (void)deleteCoupon:(NSInteger )couponID
        onCompletion:(void (^)(BOOL success))completion
              sender:(UIViewController *)sender {
    NSString *requestPath =  REQUEST_PATH_COUPON_ID([@(couponID) stringValue]);
    [self sendRequestWithMethod:Q8HTTPRequestMethodDELETE
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        WLDebLog(@"%@",responseObject);
        completion(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (sender.isViewLoaded && sender.view.window) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
        }
        completion(NO);
    }];
}

- (void)applyCouponToken:(NSString *)couponToken
            onCompletion:(void (^)(BOOL success, NSString *offerID, Q8CouponStatus couponStatus))completion
                  sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_APPLY_COUPON;
    NSDictionary *userParams = @{@"token" : couponToken,
                                 @"location_id" : [Q8CurrentUser userLocationID] ?: @""};
    [self sendRequestWithMethod:Q8HTTPRequestMethodPOST
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           WLDebLog(@"%@",responseObject);

           completion(YES, responseObject[@"offer_id"], Q8CouponStatusActive);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSInteger statusCode = [self getStatusCodeByError:error];
           Q8CouponStatus couponStatus;
           switch (statusCode) {
               case 406:
                   couponStatus = Q8CouponStatusUsed;
                   break;
               case 412:
                   couponStatus = Q8CouponStatusExpired;
                   break;
               case 417:
                   couponStatus = Q8CouponStatusWrongLocation;
                   break;
               default:
                   couponStatus = Q8CouponStatusError;
                   break;
           }
           completion(NO, nil, couponStatus);
       }];
}

- (void)getCouponByCouponToken:(NSString *)couponToken
                  onCompletion:(void (^)(BOOL success, Q8Coupon *coupon))completion
                        sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_GET_COUPON_BY_TOKEN;
    NSDictionary *userParams = @{@"token" : couponToken,
                                 @"expand" : @"offer"};
    [self sendRequestWithMethod:Q8HTTPRequestMethodGET
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            WLDebLog(@"%@",responseObject);
                            
                            completion(YES, [Q8Coupon couponFromDictionary:responseObject]);
                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                NSInteger statusCode = [self getStatusCodeByError:error];
                                switch (statusCode) {
                                    case 403:
                                        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonCouponInvalidCredentials] titleArguments:nil bodyArguments:@[@(statusCode)] delegate:nil];
                                        break;
                                    default:
                                        [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@(statusCode)] delegate:nil];
                                        break;
                            }
                            completion(NO, nil);
    }];
}

#pragma mark - Location

- (void)getMerchantsByLocation:(NSString *)latitude
                    longtitude:(NSString *)longtitude
                    searchtext:(NSString *)text
                  onCompletion:(void (^)(BOOL success, NSArray <Q8Merchant *> *, NSString *searchText))completion
                        sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_GET_MERCHANTS_BY_LOCATION;
    NSDictionary *userParams = @{@"latitude" : latitude,
                                 @"longitude" : longtitude,
                                 @"text" : text,
                                 @"shortView" : @(YES),
                                 @"expand" : @"category_id"};
    [self sendRequestWithMethod:Q8HTTPRequestMethodGET
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        WLDebLog(@"%@",responseObject);
        NSMutableArray *objects = [NSMutableArray array];
        for (NSDictionary *dictionary in responseObject) {
            [objects addObject:[Q8Merchant merchantFromDictionary:dictionary]];
        }
        // Applied successfully
        completion(YES, objects, text);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (sender.isViewLoaded && sender.view.window) {
            [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
        }
        completion(NO, nil, text);
    }];
    
}

- (void)getMerchantLocationsByLatitude:(NSString *)latitude
                  longtitude:(NSString *)longtitude
                        page:(NSInteger)page
                onCompletion:(void (^)(BOOL success, NSArray <Q8MerchantLocation *> *,  NSInteger merchantTotalCount))completion
                      sender:(UIViewController *)sender {
    NSString *requestPath = REQUEST_GET_MERCHANTS_BY_LOCATION;
    NSDictionary *userParams = @{@"latitude" : latitude,
                                 @"longitude" : longtitude,
                                 @"page" : @(page),
                                 @"per-page" : @(20),
                                 @"self" : @(YES)};
    [self sendRequestWithMethod:Q8HTTPRequestMethodGET
                           path:requestPath
               checkAccessToken:YES
                     authorized:YES
                     parameters:userParams
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            WLDebLog(@"%@",responseObject);

                            // Applied successfully
                            NSDictionary *dictHeader = [self getResponseHeaderByTask:task];
                            NSInteger lcoationTotalCount = [[dictHeader objectForKey:PAGINATION_TOTAL_COUNT] integerValue];
                            completion(YES, [Q8MerchantLocation locationsFromArray:responseObject], lcoationTotalCount);
                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            if (sender.isViewLoaded && sender.view.window) {
                                [WLAlertHelper createAlertControllerForReason:[Q8AlertHelper convertToString:Q8ReasonServerFailure] titleArguments:nil bodyArguments:@[@([self getStatusCodeByError:error])] delegate:nil];
                            }
                            completion(NO, nil, 0);
                        }];
    
}

#pragma mark - Reachability

+ (BOOL)isNetworkReachable {
    // Method to check internet avilablitity.
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Get Response Headers

- (NSDictionary *)getResponseHeaderByTask:(NSURLSessionDataTask *)task {
    NSDictionary *dictHeader;
    if ([task.response respondsToSelector:@selector(allHeaderFields)]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        dictHeader = [response allHeaderFields];
    }
    
    return dictHeader;
}

- (NSInteger)getStatusCodeByError:(NSError *)error {
    NSHTTPURLResponse *httpResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    
    return httpResponse.statusCode;
}

@end
