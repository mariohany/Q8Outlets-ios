//
//  WLKeychainHelper.h
//  Apple's Keychain Services Programming Guide
//
//  Created by Tim Mitra on 11/17/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface WLKeychainHelper : NSObject


/**
 Write object to secure keychain storage.

 @param object Object to write to keychain.
 @param key Key by which to retrieve the object from the keychain later.
 */
+ (void)setObject:(id)object forKey:(id)key;


/**
 Retrieves object from secure keychain storage.

 @param key Key by which to retrieve the object.
 @return Object for key from the keychain.
 */
+ (id)objectForKey:(id)key;


/**
 Reset keychain objects, clear the storage.
 */
+ (void)resetKeychain;

@end
