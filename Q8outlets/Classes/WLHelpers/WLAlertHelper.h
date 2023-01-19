//
//  WLAlertHelper.h
//  WLHelpers
//
//  Created by Lesya Verbina on 6/1/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  Delegate much like UIAlertView delegate.
 */
@protocol WLAlertControllerDelegate <NSObject>

@optional
/**
 *  When dismiss action of controller is used, this method fires.
 *
 *  @param alertControllerReason Reason of alert controler, as provided on creation.
 */
- (void)didUseCancelActionOfAlertController:(NSInteger)alertControllerReason;

/**
 *  When destructive action of controller is used, this method fires.
 *
 *  @param alertControllerReason Reason of alert controler, as provided on creation.
 */
- (void)didUseDestructiveActionOfAlertController:(NSInteger)alertControllerReason;

@required

/**
 *  When actions of controller are used, this method fires.
 *
 *  @param actionIndex           Index of used action, from 0 to N.
 *  @param alertController       Alert controller object, so text fields can be accessed.
 *  @param alertControllerReason Reason of alert controler, as provided on creation.
 */
- (void)didUseActionAtIndex:(NSInteger)actionIndex
          ofAlertController:(UIAlertController *)alertController
                 withReason:(NSInteger)alertControllerReason;
@end

/**
 * Alert reasons will have to bee provided as integers, and stored in enum format in your project.
 * Their ids need to correspond those in alerts JSON file, as this is the way JSON alerts will be retrieved.
 *
 * Example of alert reason enum:
 * enum {
 *      WLAlertReason = 100,
 *  };
 *
 * Corresponding JSON file
 * {
 *   "100": {
 *          "reason" : "WLAlertReason", // Readable reason
 *          "title" : "Accept user?",   // Alert title
 *          "body" : "You can enter short message", // Alert body
 *          "action_titles" : ["Accept user", "Decline user"], // OPTIONAL Action titles,
 *          "cancel_title" : "Cancel", // OPTIONAL Cancel button title, if not provided, "OK" will be used
 *          "text_fields" : ["Message"], // OPTIONAL text fields to be added to controller, providing placeholder text as string
 *      }
 *  }
 */
@interface WLAlertHelper : NSObject

/**
 *  Method that creates and displays alert controller with provided reason. Info for controller will be taken from Alerts.json file in main bundle.
 *
 *  @param reason Reason of alert controler, by which alert details will be accessed in Alerts.json file.
 *
 *  @return Alert controller object that will be shown.
 */
+ (UIAlertController *)createAlertControllerForReason:(NSInteger)reason;

/**
 Method that creates and displays alert controller with provided reason. Info for controller will be taken from Alerts.json file in main bundle.
 Delegate will receive callbacks on dissmiss, destructive and regular actions.

 @param reason   Reason of alert controler, by which alert details will be accessed in Alerts.json file.
 @param delegate Delegate or nil.

 @return Alert controller object that will be shown.
 */
+ (UIAlertController *)createAlertControllerForReason:(NSInteger)reason
                                             delegate:(id<WLAlertControllerDelegate>)delegate;

/**
 Method that creates and displays alert controller with provided reason. Info for controller will be taken from Alerts.json file in main bundle.
 Delegate will receive callbacks on dissmiss, destructive and regular actions.
 Can provide arguments for formatted title or message body.

 @param reason         Reason of alert controler, by which alert details will be accessed in Alerts.json file.
 @param titleArguments Arguments for formatted string in alert title.
 @param bodyArguments  Arguments for formatted string in alert body.
 @param delegate       Delegate or nil.

 @return Alert controller object that will be shown.
 */
+ (UIAlertController *)createAlertControllerForReason:(NSInteger)reason
                                        titleArguments:(NSArray <NSString *> *)titleArguments
                                        bodyArguments:(NSArray <NSString *> *)bodyArguments
                                             delegate:(id<WLAlertControllerDelegate>)delegate;


/**
 Set tint color of alert controller window so button's text color is customized.

 @param tintColor Desired tint color of alert controller.
 */
+ (void)setAlertControllerButtonsTintColor:(UIColor *)tintColor;


/**
 Custom path for alerts file.

 @param newPathForAlertsFile Custom path for alerts file.
 */
+ (void)setPathForAlertsFile:(NSString *)newPathForAlertsFile;

@end
