//
//  WLLogHelper.h
//  WLHelpers
//
//  Created by Lesya Verbina on 6/1/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Log helper provides two funtions: WLDebLog and WLErrLog which will automatically create cosmetic formatting around log,
 * and track from which controller and which method the log is used, greatly improving transparency of logs, so they are easy to read and navigate.
 * 
 * Define DONT_LOG_DEBUG to stop all debug logs.
 * Define DONT_LOG_ERRORS to stop all error logs.
 */
@interface WLLogHelper : NSObject

#ifndef DONT_LOG_DEBUG
#define WLDebLog(fmt, ...) NSLog((@"DEBUG: %s [Line %d]\n\t " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define WLDebLog(...)
#endif

#ifndef DONT_LOG_ERRORS
#define WLErrLog(fmt, ...) NSLog((@"❌ ERROR: %s [Line %d]\n\t " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define WLErrLog(...)
#endif

@end
