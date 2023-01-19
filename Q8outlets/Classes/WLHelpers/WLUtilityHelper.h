//
//  WLUtilityHelper.h
//  WLHelpers
//
//  Created by Lesya Verbina on 6/1/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Contacts/Contacts.h>


/**
 Weakify macro. (Has to be used in pair with the strongify macro).
 Creates a weak copy of the object.

 @param var Object to weakify.
 @return A weak copy.
 */
#define WLWeakify(var) __weak typeof(var) WLWeak_##var = var;


/**
 Strongify macro. (Has to be used in pair with the weakify macro).
 Creates a local strong variable from a weak copy, that overshadows original strong instance.

 @param var Object to strongify back.
 @return A local strong variable.
 */
#define WLStrongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = WLWeak_##var; \
_Pragma("clang diagnostic pop")


/**
 *  Category on NSString, addin levenshtein distance method to compare to other string.
 */
@interface NSString (levenshteinDistance)
- (NSUInteger)levenshteinDistanceToString:(NSString *)string;
@end

/**
 *  Category on NSMutableAttributedString, adding ability to choose
 *  color for specific substring with attributes (attributed string).
 */
@interface NSMutableAttributedString (Color)
- (void)setColorForText:(NSString *)textToFind withColor:(UIColor *)color;
@end

@interface WLUtilityHelper : NSObject

#pragma mark - Application related

/**
 * Open Appstore with your app selected on "review" page. For "Rate this app" buttons.
 * Appstore id can be found on iTunesConnect page for the app, and never changes.
 *
 *  @param appstoreId Appstore id of desired app.
 */
+ (void)openRateAppInAppstore:(NSString *)appstoreId;

/**
 *  URL for documents directory for main bundle.
 *
 *  @return URL for application documents directory.
 */
+ (NSURL *)applicationDocumentsDirectory;

#pragma mark - Storyboard and navigation

/**
 *  Window root controller change, to move from one app section to another.
 *  For example, from unauthorized part with login/registration to authorized part of your app.
 *
 *  @param animated          Flag if change should be animated.
 *  @param newRootController New root controller, to which app will be navigated.
 *  @param loadView          Flag to load receiving view controller, so animated transition is not black.
 */
+ (void)changeWindowRootControllerAnimated:(BOOL)animated toController:(UIViewController *)newRootController loadView:(BOOL)loadView;

/**
 *  Convinience retrieval of view controllers from Main storyboard in Main bundle.
 *
 *  @param identifier Storyboard identifier of desired controller.
 *  @warning If storyboard does not contain controller with such identifier, exception will be raised.
 *
 *  @return View controller from storyboard by provided identifier.
 */
+ (UIViewController *)viewControllerFromSBWithIdentifier:(NSString *)identifier;


/**
 Convinience retrieval of view controllers from a specified storyboard in Main bundle.

 @param storyboardName Storyboard to retrieve.
 @param identifier Storyboard identifier of desired controller.
 @warning If storyboard does not contain controller with such identifier, exception will be raised.
 @return  View controller from storyboard by provided identifier.
 */
+ (UIViewController *)viewControllerFromStoryboard:(NSString *)storyboardName controllerIdentifier:(NSString *)identifier;


#pragma mark - Validity checks

/**
 *  Check email for validity with reasonably strict regular expression.
 *
 *  @param email Email string to check.
 *
 *  @return Flag indicating if email is valid.
 */
+ (BOOL)isEmailValid:(NSString *)email;

#pragma mark - Permissions

/**
 *  Async photo library permission check.
 *
 *  @param completion Block to be called on completion of a check, containing "success" flag.
 */
+ (void)getImageLibraryPermissionOnCompletion:(void (^)(BOOL success))completion;

/**
 *  Async camera permission check.
 *
 *  @param completion Block to be called on completion of a check, containing "success" flag.
 */
+ (void)getCameraPermissionOnCompletion:(void (^)(BOOL success))completion;

/**
 *  Async microphone permission check.
 *
 *  @param completion Block to be called on completion of a check, containing "success" flag.
 */
+ (void)getMicrophonePermissionOnCompletion:(void (^)(BOOL success))completion;

/**
 *  Async contacts book permission check.
 *
 *  @param completion Block to be called on completion of a check, containing "success" flag.
 */
+ (void)getContactsPermissionOnCompletion:(void (^)(BOOL success))completion;

#pragma mark - Contacts

/**
 *  Contacts from user's contact book.
 *
 *  @return Contacts array.
 */
+ (NSArray<CNContact *> *)userContactsBookContacts;

#pragma mark - Strings

/**
 *  Sort array of strings by levenstein distance to other string. Usefull for autocompletes.
 *
 *  @param array  Array of strings to be sorted.
 *  @param string String with which to compare every element of sorted array.
 *
 *  @return Array sorted by levenstein distance to provided string.
 */
+ (NSArray *)stringsSortedByLevenstein:(NSArray *)array toString:(NSString *)string;

/**
 *  Abbreviation/acronym from provided phrase.
 *
 *  @param string    Phrase to abbriviate.
 *  @param maxLength Max length of resulting abbreviation/acronym.
 *
 *  @return Abbreviation/acronym from provided phrase.
 */
+ (NSString *)abbreviationFromString:(NSString *)string maxLength:(NSInteger)maxLength;

/**
 *  Ordinal number suffix: -st, -nd, -rd, -th. Like 2nd, 5th, etc.
 *
 *  @param number Number of order.
 *
 *  @return String suffix for number.
 */
+ (NSString *)numberSuffixForInteger:(NSInteger)number;

#pragma mark - Arrays

// Custom objects array sorting.
/**
 *  Sorting of array of custom objects. If items in array do not respond to selector, no exception will be raised.
 *
 *  @param array      Array of custrom objects to sort.
 *  @param descriptor Descriptor by which to sort all items in array.
 *  @param ascending  Flag to indicate ascending/descending sorting.
 *
 *  @return Array of custom objects sorted by descriptor.
 */
+ (NSArray *)arraySorted:(NSArray *)array byDescriptor:(NSString *)descriptor ascending:(BOOL)ascending;

#pragma mark - JSON parsing

/**
 *  Pasre dictionaries in array from JSON file.
 *
 *  @param filename Filename of JSON file in Main bundle.
 *
 *  @return Parsed dictionaries in array from JSON file.
 */
+ (NSArray *)arrayFromJsonFile:(NSString *)filename;


/**
 Parse dictionaried in array from JSON file at path.

 @param path Path to JSON.
 @return Parsed dictionaries in array from JSON file.
 */
+ (NSArray *)arrayFromJsonFileAtPath:(NSString *)path;


/**
 *  Parse dictionary from JSON string.
 *
 *  @param jsonString String in JSON format.
 *
 *  @return Parsed dictionary from JSON file.
 */
+ (NSDictionary *)dictFromJsonString:(NSString *)jsonString;


/**
 *  Clean JSONs from NSNulls. Usefull for server response cleaning.
 *
 *  @param serverResponse Array or dictionary with potential NSNull objects.
 *
 *  @return Cleaned array or dictionary without NSNulls.
 */
+ (id)JSONcleanedFromNulls:(id)serverResponse;

/**
 *  Clean dictionary from NSNulls.
 *
 *  @param dictionary Dictionary with potential NSNull objects.
 *
 *  @return Cleaned dictionary without NSNulls.
 */
+ (NSDictionary *)dictionaryCleanedFromNulls:(NSDictionary *)dictionary;

#pragma mark - Date and time

/**
 *  Calculating days between two dates.
 *
 *  @param fromDateTime Starting date.
 *  @param toDateTime   End date.
 *
 *  @return Number of days between first and second date.
 */
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

/**
 *  Checks if two dates happened on the same day.
 *
 *  @param date1 First date to check.
 *  @param date2 Second date to check.
 *
 *  @return Flag if two dates happened on the same day.
 */
+ (BOOL)checkIfSameDate:(NSDate *)date1 date2:(NSDate *)date2;

/**
 *  Checks if two dates happened on the same week.
 *
 *  @param date1 First date to check.
 *  @param date2 Second date to check.
 *
 *  @return Flag if two dates happened on the same week.
 */
+ (BOOL)checkIfSameWeek:(NSDate *)date1 date2:(NSDate *)date2;

/**
 *  Checks if two dates happened in the same month.
 *
 *  @param date1 First date to check.
 *  @param date2 Second date to check.
 *
 *  @return Flag if two dates happened on the same month.
 */
+ (BOOL)checkIfSameMonth:(NSDate *)date1 date2:(NSDate *)date2;

/**
 *  Moving dates by full days.
 *
 *  @param daysToAdd Number of days to add to date.
 *  @param date      Date to move.
 *
 *  @return Date, moved by number of full days.
 */
+ (NSDate *)dateByAddingDays:(NSInteger)daysToAdd toDate:(NSDate *)date;

/**
 *  Moving dates by months.
 *
 *  @param monthsToAdd Number of month to add to date.
 *  @param date        Date to move.
 *
 *  @return Date, moved by number of months.
 */
+ (NSDate *)dateByAddingMonth:(NSInteger)monthsToAdd toDate:(NSDate *)date;

/**
 *  Date formatting to string, using default full format: 1983/12/30 18:05.
 *
 *  @param date Date to format.
 *
 *  @return String from date in default full format.
 */
+ (NSString *)formatDateToFullString:(NSDate *)date;

/**
 *  Date formatting to string, using specified format.
 *
 *  @param date            Date to format.
 *  @param preferredFormat Specified format.
 *
 *  @return String from date in the specified format.
 */
+ (NSString *)formatDateToFullString:(NSDate *)date preferredFormat:(NSString *)preferredFormat;

/**
 *  Date formatted to string in format of "10:30"(just time) for today, "Yesterday 12:20", "Date, time".
 *
 *  @param date    Date to format.
 *  @param cutTime Flag to cut or include time in final string.
 *
 *  @return Date formatted to string in pretty format.
 */
+ (NSString *)formatDateToCompactString:(NSDate *)date cutTime:(BOOL)cutTime;

/**
 *  Day calendar component from date.
 *
 *  @param date Date from which to take a component.
 *
 *  @return Day calendar components from date.
 */
+ (NSInteger)dayFromDate:(NSDate *)date;

/**
 *  Weekday calendar component from date, in enum format. Starts on sunday, enum from 1 to 7.
 *
 *  @param date Date from which to take a component.
 *
 *  @return Weekday calendar component from date.
 */
+ (NSInteger)weekdayFromDate:(NSDate *)date;

/**
 *  Month calendar component from date, in enum format.
 *
 *  @param date Date from which to take a component.
 *
 *  @return Month calendar component from date.
 */
+ (NSInteger)monthFromDate:(NSDate *)date;

/**
 *  Year calendar component from date.
 *
 *  @param date Date from which to take a component.
 *
 *  @return Year calendar component from date.
 */
+ (NSInteger)yearFromDate:(NSDate *)date;

/**
 *  Date formatting by separate components. Month component from the date, in string form.
 *
 *  @param date Date from which to take a component and format.
 *
 *  @return Month from date, in string form.
 */
+ (NSString *)stringWithMonthFromDate:(NSDate *)date;

/**
 *  Date formatting by separate components. Weekday component from the date.
 *  Example: "Wednesday"
 *
 *  @param date Date from which to take a component and format.
 *
 *  @return Weekday from date, in string form.
 */
+ (NSString *)stringWithWeekdayFromDate:(NSDate *)date;

/**
 *  Date formatting by separate components. Weekday component from the date, in string form, and also day.
 *  Example: "Wed, 23".
 *
 *  @param date Date from which to take a component and format.
 *
 *  @return Weekday from date, in string form, and also day.
 */
+ (NSString *)stringWithWeekdayAndShortDateFromDate:(NSDate *)date;

/**
 *  Date with no time from date.
 *
 *  @param date Date to format.
 *
 *  @return Date with no time from date.
 */
+ (NSString *)stringWithJustDate:(NSDate *)date;

/**
 *  Time with no date from time date.
 *
 *  @param time Date to format.
 *
 *  @return Time with no date from time date.
 */
+ (NSString *)stringWithJustTime:(NSDate *)time;

/**
 Convert ISO string to NSDate. ISO string contains timezone which can be ignored if needed.

 @param isoString String to convert.
 @param ignoreTimezone Flag to ignore timezone.
 @return NSDate from ISO string.
 */
+ (NSDate *)dateFromISOSting:(NSString *)isoString ignoreTimezone:(BOOL)ignoreTimezone;


/**
 String in ISO format from NSDate.

 @param date Date to convert.
 @return String from date.
 */
+ (NSString *)ISOstringFromDate:(NSDate *)date;

#pragma mark - Countries

/**
 *  Converting country name to country ISO code. Usefull for phone code searches.
 *
 *  @param fullCountryName Country name to convert.
 *
 *  @return Country ISO code from provided name.
 */
+ (NSString *)countryCodeFromFullName:(NSString *)fullCountryName;

/**
 *  Converting country code (locale code) to country name.
 *
 *  @param localeSring Country code to convert.
 *
 *  @return Country name from country (locale) code.
 */
+ (NSString *)englishCountryNameFromLocaleString:(NSString *)localeSring;

#pragma mark - Getting subviews and parent views

/**
 *  For getting top-level views.
 *
 *  @param superviewClass Name of the class of a superview we are searching for.
 *  @param view           View which superview we need.
 *
 *  @return Superview of provided class.
 */
+ (UIView *)superviewWithClass:(Class)superviewClass fromView:(UIView *)view;

#pragma mark - Random generation

/**
 *  Random string generation.
 *
 *  @param length Desired length of random string.
 *
 *  @return Randomly generated string of length.
 */
+ (NSString *)randomStringWithLength:(NSInteger)length;

/**
 *  Generating random profile name, from the list of names.
 *
 *  @return Random human name, first name + last name.
 */
+ (NSString *)randomHumanName;

/**
 *  Random medium-sized text. Usefull for bios and reviews.
 *
 *  @return Random medium-sized text.
 */
+ (NSString *)randomMediumText;

/**
 *  Random cooridnate in provided radius around center coordinate. Usefull for testing places near the current location of a user.
 *
 *  @param radius     Radius in which to generate coordinate, in meters.
 *  @param coordinate Center coordinate.
 *
 *  @return Random cooridnate in provided radius around center coordinate.
 */
+ (CLLocationCoordinate2D)randomCoordinateInRadius:(NSInteger)radius aroundCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 *  Random address string from UK.
 *
 *  @return Random address string from UK.
 */
+ (NSString *)randomAddress;

/**
 *  Random time in 24h format.
 *
 *  @return Random time in 24h format.
 */
+ (NSString *)randomTimeString;

/**
 *  Random date string in 30/12/1983 format.
 *
 *  @return Random date string.
 */
+ (NSString *)randomDateString;

/**
 *  Random weekdays in enum format 0-6, where monday is 0.
 *
 *  @return Random weekdays as integers.
 */
+ (NSArray *)randomWeekdays;

/**
 *  Random ridiculous title name. Usefull for product names, car names, etc.
 *
 *  @return Random title name.
 */
+ (NSString *)randomCarName;

/**
 *  Pick object from array at random.
 *
 *  @param items Array of objects of any type.
 *
 *  @return Random object from specified array.
 */
+ (id)chooseRandomFromItems:(NSArray *)items;

/**
 *  Random color, on the dark side.
 *
 *  @return Random darkish color.
 */
+ (UIColor *)randomDarkColor;

/**
 *  Random color, on the light side.
 *
 *  @return Random lightish color.
 */
+ (UIColor *)randomLightColor;

/**
 *  Random color, one of the pre-defined colors.
 *  All colors in the list are bright.
 *
 *  @return Random pretty color.
 */
+ (UIColor *)randomBrightPrettyColor;

#pragma mark - Location address helper

/**
 *  Full address string from placemark without "null"s.
 *
 *  @param placemark Placemark with address.
 *
 *  @return String with address country, city, street, house number.
 */
+ (NSString *)addressStringFromPlacemark:(MKPlacemark *)placemark;

/**
 *  Reverse geocoding map coordinate to placemark that can be transformed to string.
 *
 *  @param coordinate Coordinate to reverse-geocode.
 *  @param completion Block to be executed when reverse-geocode receives result.
 */
+ (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate onCompletion:(void (^)(MKPlacemark *placemark))completion;

#pragma mark - Core location


/**
 Calculates distance between to coordinates in meters.

 @param coordinateFrom First coordinate.
 @param coordinateTo   Second coordinate.

 @return Distance between coordinates in meters.
 */
+ (double)distanceBetweenCoordinate:(CLLocationCoordinate2D)coordinateFrom andCoordinate:(CLLocationCoordinate2D)coordinateTo;

#pragma mark - Multithreading

/**
 *  Run block on main thread without deadlocking.
 *
 *  @param block Block to run.
 */
+ (void)runOnMainThreadWithoutDeadlocking:(void (^)(void))block;

#pragma mark - Accessing defaults

/**
 Write data to common user defaults.

 @param data Property to save.
 @param key Property key.
 */
+ (void)writeDataToDefaults:(id)data forKey:(NSString *)key;

/**
 Read data from common user defaults.

 @param key Property key.
 @return Property from defaults.
 */
+ (id)dataFromDefaultsWithKey:(NSString *)key;

@end
