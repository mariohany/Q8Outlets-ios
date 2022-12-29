//
//  WLUtilityHelper.m
//  WLHelpers
//
//  Created by Lesya Verbina on 6/1/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import "WLUtilityHelper.h"
@import Photos;
#import "WLLogHelper.h"

@implementation NSString (levenshteinDistance)
- (NSUInteger)levenshteinDistanceToString:(NSString *)string {
    NSUInteger sl = [self length];
    NSUInteger tl = [string length];
    NSUInteger *d = calloc(sizeof(*d), (sl+1) * (tl+1));
    
#define d(i, j) d[((j) * sl) + (i)]
    for (NSUInteger i = 0; i <= sl; i++) {
        d(i, 0) = i;
    }
    for (NSUInteger j = 0; j <= tl; j++) {
        d(0, j) = j;
    }
    for (NSUInteger j = 1; j <= tl; j++) {
        for (NSUInteger i = 1; i <= sl; i++) {
            if ([self characterAtIndex:i-1] == [string characterAtIndex:j-1]) {
                d(i, j) = d(i-1, j-1);
            } else {
                d(i, j) = MIN(d(i-1, j), MIN(d(i, j-1), d(i-1, j-1))) + 1;
            }
        }
    }
    
    NSUInteger r = d(sl, tl);
#undef d
    
    free(d);
    
    return r;
}
@end


/**
 *  Category on NSMutableAttributedString, adding ability to choose
 *  color for specific substring with attributes (attributed string)
 */
@implementation NSMutableAttributedString (Color)

- (void)setColorForText:(NSString *)textToFind withColor:(UIColor *)color
{
    NSRange range = [self.mutableString rangeOfString:textToFind options:NSCaseInsensitiveSearch];
    
    if (range.location != NSNotFound) {
        [self addAttribute:NSForegroundColorAttributeName value:color range:range];
    }
}
@end

@implementation WLUtilityHelper

#pragma mark - Application related

+ (void)openRateAppInAppstore:(NSString *)appstoreId {
    // Appstore app will be opened
    NSString *iOSAppStoreURLFormat =   @"itms-apps://itunes.apple.com/app/id%@";
    
    NSURL *rateURL = [NSURL URLWithString:[NSString stringWithFormat:iOSAppStoreURLFormat, appstoreId]];
    
    if (![[UIApplication sharedApplication] canOpenURL:rateURL]) {
        WLErrLog(@"Was unable to open the specified ratings URL: %@", rateURL);
    }  else {
        [[UIApplication sharedApplication] openURL:rateURL];
    }
}


+ (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store files. This code uses a directory named "com.YOUR BUNDLE" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Storyboard and navigation

// Animated window root controller change
+ (void)changeWindowRootControllerAnimated:(BOOL)animated toController:(UIViewController *)newRootController loadView:(BOOL)loadView {
    if (loadView) {
        [newRootController loadView];
    }
    
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    
    if (!mainWindow.rootViewController) {
        mainWindow.rootViewController = newRootController;
        return;
    }
    
    UIView *snapshot = [mainWindow snapshotViewAfterScreenUpdates:YES];
    [newRootController.view addSubview:snapshot];
    
    mainWindow.rootViewController = newRootController;
    
    [UIView animateWithDuration:animated ? 0.2 : 0.0
                     animations:^{
                         snapshot.layer.opacity = 0;
                         snapshot.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.3);
                     } completion:^(BOOL finished) {
                         [snapshot removeFromSuperview];
                     }];
}

// Convinience retrieval
+ (UIViewController *)viewControllerFromSBWithIdentifier:(NSString *)identifier {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *desiredController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    return desiredController;
}

+ (UIViewController *)viewControllerFromStoryboard:(NSString *)storyboardName controllerIdentifier:(NSString *)identifier {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *desiredController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    return desiredController;
}

#pragma mark - Validity checks

// Check email for validity
+ (BOOL)isEmailValid:(NSString *)emailString {
    NSString *emailRegex = @"^[0-9a-zA-Z-._+]+@[0-9a-zA-Z]+([-.][0-9a-zA-Z]+)*([0-9a-zA-Z]*[.])[a-zA-Z]{2,6}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL didValidate = [emailTest evaluateWithObject:emailString];
    
    return didValidate;
}

#pragma mark - Permissions

// Async image library check, with prompts
+ (void)getImageLibraryPermissionOnCompletion:(void (^)(BOOL))completion {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        // Access has been granted
        completion(YES);
    } else if (status == PHAuthorizationStatusNotDetermined) {
        // Access has not been determined, requesting
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    // Access has been granted
                    completion(YES);
                } else {
                    // Access has been denied
                    completion(NO);
                }
            });
        }];
    } else {
        // Access has been denied/restricted
        completion(NO);
    }
}

// Async camera permission check.
+ (void)getCameraPermissionOnCompletion:(void (^)(BOOL success))completion {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) {
        // Access has been granted
        completion(YES);
    } else if (status == AVAuthorizationStatusNotDetermined) {
        // Access has not been determined, requesting
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Main queue so controllers that invoke this method can proceed without glitches
                if (granted) {
                    completion(YES);
                } else {
                    completion(NO);
                }
            });
        }];
    } else {
        // Access has been denied/restricted
        completion(NO);
    }
}

// Async microphone permission check.
+ (void)getMicrophonePermissionOnCompletion:(void (^)(BOOL success))completion {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        // Mic permission granted
        completion(YES);
    } else if (authStatus == AVAuthorizationStatusNotDetermined){
        // Access has not been determined, requesting
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Main queue so controllers that invoke this method can proceed without glitches
                if(granted){
                    completion(YES);
                } else {
                    completion(NO);
                }
            });
        }];
    } else {
        // Access has been denied/restricted.
        completion(NO);
    }
}

// Async contacts permission check.
+ (void)getContactsPermissionOnCompletion:(void (^)(BOOL success))completion {
    CNContactStore *contactStore = [CNContactStore new];
    
    // Request access to contacts if have not requested before
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
        [contactStore requestAccessForEntityType:CNEntityTypeContacts
                               completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                   if (granted) {
                                       completion(YES);
                                   } else {
                                       completion(NO);
                                   }
                               }];
    } else if (([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusRestricted) ||
               ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusDenied)) {
        completion(NO);
    } else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        completion(YES);
    }
}

#pragma mark - Contacts

// Contacts from user's contact book.
+ (NSArray<CNContact *> *)userContactsBookContacts {
    CNContactStore *contactStore = [CNContactStore new];
    
    // Keys with fetching properties
    NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
    NSString *containerId = contactStore.defaultContainerIdentifier;
    NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
    NSError *error;
    
    // Fetching CN contacts
    NSArray *cnContacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
    if (error) {
        WLErrLog(@"error fetching contacts %@", error);
        return @[];
    } else {
        return cnContacts;
    }
}

#pragma mark - Strings

// Sort array of strings by levenstein distance to other string
+ (NSArray *)stringsSortedByLevenstein:(NSArray *)array toString:(NSString *)match {
    NSMutableArray *sortedArrayDicts = [NSMutableArray new];
    for (NSString *string in array) {
        // Storing levenshtein distance as object so we can sort by it
        NSInteger levDistance = [string levenshteinDistanceToString:match];
        NSDictionary *stringDict = @{@"string" : string,
                                     @"distance" : @(levDistance)};
        [sortedArrayDicts addObject:stringDict];
    }
    sortedArrayDicts = [[WLUtilityHelper arraySorted:sortedArrayDicts byDescriptor:@"distance" ascending:YES] mutableCopy];
    
    NSMutableArray *sortedArray = [NSMutableArray new];
    for (NSDictionary *dict in sortedArrayDicts) {
        // Now we have to extract strings from sorted dict
        [sortedArray addObject:[dict objectForKey:@"string"]];
    }
    
    return sortedArray;
}

// First letters of words
+ (NSString *)abbreviationFromString:(NSString *)string maxLength:(NSInteger)maxLength {
    NSMutableString * firstCharacters = [NSMutableString string];
    NSArray *words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString *word in words) {
        // Need only as many letters, as specified
        if (firstCharacters.length==maxLength) {
            break;
        }
        if ([word length] > 0) {
            NSString * firstLetter = [word substringWithRange:[word rangeOfComposedCharacterSequenceAtIndex:0]];
            [firstCharacters appendString:[firstLetter uppercaseString]];
        }
    }
    
    if (firstCharacters.length<maxLength && string.length>1) {
        firstCharacters = [[string substringToIndex:maxLength] mutableCopy];
    }
    return [firstCharacters uppercaseString];
}

+ (NSString *)numberSuffixForInteger:(NSInteger)number {
    // Ordinal number suffix: -st, -nd, -rd, -th. Like 2nd, 5th, etc.
    if ((number / 10) % 10 == 1) {
        return @"th";       // Special cases 11th, 12th, 13th
    }
    switch (number % 10) {
        case 1:  return @"st";
        case 2:  return @"nd";
        case 3:  return @"rd";
        default: return @"th";
    }
}

#pragma mark - Arrays

// Custom objects array sorting
+ (NSArray *)arraySorted:(NSArray *)array byDescriptor:(NSString *)descriptor ascending:(BOOL)ascending {
    // Checking if array items actually respond to selector
    if ([array count]) {
        @try {
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:descriptor
                                                         ascending:ascending];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            NSArray *sortedArray = [array sortedArrayUsingDescriptors:sortDescriptors];
            return sortedArray;
        } @catch (NSException *exception) {
            WLErrLog(@"%@",exception);
        }
    }
    
    return array;
}

#pragma mark - JSON parsing

// Json dictionaries in array, from json file
+ (NSArray *)arrayFromJsonFile:(NSString *)filename {
    return [WLUtilityHelper arrayFromJsonFileAtPath:[[NSBundle mainBundle] pathForResource:filename ofType:@"json"]];
}

+ (NSArray *)arrayFromJsonFileAtPath:(NSString *)path {
    // Parsing json file into array
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *localError = nil;
    NSArray *arrayFromJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        WLErrLog(@"%@", [localError userInfo]);
        return [NSArray new];
    } else {
        return arrayFromJson;
    }
}

// Parse of JSON string
+ (NSDictionary *)dictFromJsonString:(NSString *)jsonString {
    NSError *jsonError;
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
    return jsonDict;
}

//Clean JSONs from [NSNull nulls]
+ (id)JSONcleanedFromNulls:(id)serverResponse {
    // JSON response can be array or dictionary
    if ([serverResponse respondsToSelector:@selector(objectAtIndex:)]) {
        NSMutableArray *cleanedArray = [NSMutableArray new];
        
        // If response is array, check each potential pair for "NSNull"
        for (NSDictionary *possibleDictionary in serverResponse) {
            if ([possibleDictionary respondsToSelector:@selector(objectForKey:)]) {
                [cleanedArray addObject:[WLUtilityHelper dictionaryCleanedFromNulls:possibleDictionary]];
            }
        }
        
        return cleanedArray;
    } else if ([serverResponse respondsToSelector:@selector(objectForKey:)]) {
        
        // If response was not array, possibly it is dictionary
        NSDictionary *cleanedResponse = [WLUtilityHelper dictionaryCleanedFromNulls:serverResponse];
        return cleanedResponse;
    } else {
        // If neither array nor dictionary, cannot clean
        return serverResponse;
    }
}

//Clean dictionary from [NSNull nulls]
+ (NSDictionary *)dictionaryCleanedFromNulls:(NSDictionary *)dictionary {
    NSMutableDictionary *cleanedDict = [NSMutableDictionary new];
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        for (id key in [dictionary allKeys]) {
            // If element is not NSNull, pass it to cleaned dictionary
            if ([dictionary objectForKey:key]!=[NSNull null]) {
                
                if ([[dictionary objectForKey:key] respondsToSelector:@selector(objectForKey:)]) {
                    NSDictionary *nestedDictionary = [dictionary objectForKey:key];
                    // Recursive cleaning of nested dictionaries
                    nestedDictionary = [WLUtilityHelper dictionaryCleanedFromNulls:nestedDictionary];
                    // Pass cleaned dictionary
                    [cleanedDict setObject:nestedDictionary forKey:key];
                } else {
                    // If object is not dictionary, just add it
                    [cleanedDict setObject:[dictionary objectForKey:key] forKey:key];
                }
                
            }
        }
    } else {
        NSLog(@"%@ is not a dictionary", dictionary);
    }
    
    return cleanedDict;
}

#pragma mark - Date and time

// Calculating days between dates
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

// Moving dates
+ (NSDate *)dateByAddingDays:(NSInteger)daysToAdd toDate:(NSDate *)date {
    // If no date, make it obvious by 1970
    if (!date) {
        date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSDate *newDate = [date dateByAddingTimeInterval:60*60*24*daysToAdd];
    return newDate;
}
+ (NSDate *)dateByAddingMonth:(NSInteger)monthsToAdd toDate:(NSDate *)date {
    // If no date, make it obvious by 1970
    if (!date) {
        date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *newDate = [calendar dateByAddingUnit:NSCalendarUnitMonth value:monthsToAdd toDate:date options:0];
    return newDate;
}

// Date components
+ (NSInteger)dayFromDate:(NSDate *)date {
    if (!date) {
        date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date];
    NSInteger day = [components day];
    return day;
}

+ (NSInteger)weekdayFromDate:(NSDate *)date {
    if (!date) {
        date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date];
    NSInteger weekday = [components weekday];
    return weekday;
}

+ (NSInteger)monthFromDate:(NSDate *)date {
    if (!date) {
        date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:date];
    NSInteger month = [components month];
    return month;
}

+ (NSInteger)yearFromDate:(NSDate *)date {
    if (!date) {
        date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:date];
    NSInteger year = [components year];
    return year;
}

// Date formatting to string
+ (NSString *)formatDateToFullString:(NSDate *)date {
    // Default formal format
    return [WLUtilityHelper formatDateToFullString:date preferredFormat:@"yyyy/MM/dd HH:mm"];
}

+ (NSString *)formatDateToFullString:(NSDate *)date preferredFormat:(NSString *)preferredFormat {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:preferredFormat];
    NSString *result = [df stringFromDate:date];
    return result;
}

// Date in format of "10:30"(just time) for today, "Yesterday 12:20", "Date, time"
+ (NSString *)formatDateToCompactString:(NSDate *)date cutTime:(BOOL)cutTime {
    NSString *prefix = @"";
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    BOOL isToday = [WLUtilityHelper checkIfSameDate:[NSDate date] date2:date];
    if (isToday) {
        [df setDateFormat:@"HH:mm"];
    } else {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *oneDayComp = [[NSDateComponents alloc] init];
        oneDayComp.day = 1;
        NSDate *nextDayDate = [calendar dateByAddingComponents:oneDayComp toDate:date options:0];
        BOOL isYesterday = [WLUtilityHelper checkIfSameDate:[NSDate date] date2:nextDayDate];
        if (isYesterday) {
            prefix = @"Yesterday, ";
            [df setDateFormat:@"HH:mm"];
        } else {
            if ([WLUtilityHelper checkIfSameWeek:[NSDate date] date2:date]) {
                [df setDateFormat:@"EEEE, HH:mm"];
            } else {
                if (cutTime) {
                    [df setDateFormat:@"dd/MM/yyyy"];
                } else {
                    [df setDateFormat:@"dd/MM/yyyy, HH:mm"];
                }
            }
        }
    }
    
    NSString *result = [NSString stringWithFormat:@"%@%@",prefix,[df stringFromDate:date]];
    return result;
}

+ (BOOL)checkIfSameDate:(NSDate *)date1 date2:(NSDate *)date2 {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date1];
    NSDate *firstDateFromComponents = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date2];
    NSDate *secondDateFromComponents = [cal dateFromComponents:components];
    
    return [firstDateFromComponents isEqualToDate:secondDateFromComponents];
}

+ (BOOL)checkIfSameWeek:(NSDate *)date1 date2:(NSDate *)date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *date1Week = [calendar components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitWeekOfYear) fromDate:date1];
    NSDateComponents *date2Week = [calendar components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitWeekOfYear) fromDate:date2];
    return date1Week==date2Week;
}

// Checks if two dates happened in the same month.
+ (BOOL)checkIfSameMonth:(NSDate *)date1 date2:(NSDate *)date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *date1Month = [calendar components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:date1];
    NSDateComponents *date2Month = [calendar components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:date2];
    return date1Month==date2Month;
}

// Date formatting by separate components
+ (NSString *)stringWithMonthFromDate:(NSDate *)date {
    // If no date, make it obvious by 1970
    if (!date) {
        date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"LLLL"];
    NSString *monthString = [df stringFromDate:date];
    
    return monthString;
}


//Date formatting by separate components. Weekday component from the date.
//Example: "Wednesday"
+ (NSString *)stringWithWeekdayFromDate:(NSDate *)date {
    NSString *weekdayString = [WLUtilityHelper formatDateToFullString:date preferredFormat:@"EEE"];
    return weekdayString;
}

+ (NSString *)stringWithWeekdayAndShortDateFromDate:(NSDate *)date {
    // If no date, make it obvious by 1970
    if (!date) {
        date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDate *onlyDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:onlyDate
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    
    NSString *weekdayString = [WLUtilityHelper formatDateToFullString:date preferredFormat:@"EEE"];
    NSString *formattedString = [NSString stringWithFormat:@"%@ %@",[weekdayString uppercaseString], dateString];
    
    return formattedString;
}

+ (NSString *)stringWithJustDate:(NSDate *)date {
    // If no date, make it obvious by 1970
    if (!date) {
        date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDate *onlyDate = [[NSCalendar currentCalendar]
                        dateFromComponents:components];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:onlyDate
                                                          dateStyle:NSDateFormatterMediumStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    return dateString;
}

+ (NSString *)stringWithJustTime:(NSDate *)time {
    // If no date, make it obvious by 1970
    if (!time) {
        time = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:time];
    NSDate *onlyTime = [[NSCalendar currentCalendar]
                        dateFromComponents:components];
    
    NSString *timeString = [NSDateFormatter localizedStringFromDate:onlyTime
                                                          dateStyle:NSDateFormatterNoStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    return timeString;
}

+ (NSDate *)dateFromISOSting:(NSString *)isoString ignoreTimezone:(BOOL)ignoreTimezone {
    NSDateFormatter *formatter = [WLUtilityHelper ISOdateFormatter];
    NSDate *date = [formatter dateFromString:isoString];
    
    if (ignoreTimezone) {
        @try {
            // Add timezone offset to date
            float timezoneOffset = 0.0f;
            NSRange rangeOfTimezoneStart = [isoString rangeOfString:@"+"];
            if (rangeOfTimezoneStart.location == NSNotFound) {
                rangeOfTimezoneStart = [isoString rangeOfString:@"-"];
            }
            
            if (rangeOfTimezoneStart.location != NSNotFound) {
                NSString *offsetString = [isoString substringFromIndex:rangeOfTimezoneStart.location];
                if(offsetString.length == 5) {
                    timezoneOffset = [[offsetString substringToIndex:1] isEqualToString:@"-"] ? -1 : 1;
                    
                    // Format will be +0100, hours component is from +, two symbols
                    NSString *hoursComponent = [offsetString substringWithRange:NSMakeRange(1, 2)];
                    NSString *minutesComponent = [offsetString substringWithRange:NSMakeRange(3, 2)];
                    timezoneOffset *= [hoursComponent integerValue] * 60*60 + [minutesComponent integerValue] *60;
                }
            }
            
            date = [date dateByAddingTimeInterval:timezoneOffset];
            WLDebLog(@"%@ %@", isoString, date);
        } @catch (NSException *exception) {
            WLErrLog(@"%@",exception);
        } @finally {
        }
    }
    
    return date;
}

+ (NSString *)ISOstringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [WLUtilityHelper ISOdateFormatter];
    NSString *isoString = [formatter stringFromDate:date];
    return isoString;
}

+ (NSDateFormatter *)ISOdateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    return formatter;
}


#pragma mark - Countries

// Country codes, usefull for phone code searches
+ (NSString *)countryCodeFromFullName:(NSString *)fullCountryName {
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    NSMutableArray *countriesNative = [NSMutableArray arrayWithCapacity:[countryCodes count]];
    NSMutableArray *countriesEnglish = [NSMutableArray arrayWithCapacity:[countryCodes count]];
    
    for (NSString *countryCode in countryCodes) {
        NSString *identifier = [NSLocale localeIdentifierFromComponents:@{ NSLocaleCountryCode : countryCode }];
        
        NSLocale *adequateCountryLocale = [NSLocale localeWithLocaleIdentifier:countryCode];
        NSString *countryNative = [adequateCountryLocale displayNameForKey:NSLocaleIdentifier value:identifier];
        [countriesNative addObject:countryNative];
        
        NSString *countryEnglish = [[NSLocale localeWithLocaleIdentifier:@"en_US"] displayNameForKey:NSLocaleIdentifier value:identifier];
        if ([countryEnglish isEqualToString:@"Russia"]) {
            countryEnglish = @"Russian Federation";
        }
        [countriesEnglish addObject:countryEnglish];
    }
    
    // Checking both native country name Україна
    NSDictionary *codeForCountryDictionaryNative = [[NSDictionary alloc] initWithObjects:countryCodes forKeys:countriesNative];
    NSString *countryCode = [codeForCountryDictionaryNative objectForKey:fullCountryName];
    // And english Ukraine
    if (!countryCode) {
        NSDictionary *codeForCountryDictionaryEnglish = [[NSDictionary alloc] initWithObjects:countryCodes forKeys:countriesEnglish];
        countryCode = [codeForCountryDictionaryEnglish objectForKey:fullCountryName];
    }
    return countryCode;
}

+ (NSString *)englishCountryNameFromLocaleString:(NSString *)localeSring {
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeSring];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSString *countryName = [[NSLocale localeWithLocaleIdentifier:@"en_US"] displayNameForKey:NSLocaleCountryCode value:countryCode];
    return countryName;
}

#pragma mark - Getting subviews and parent views

+ (UIView *)superviewWithClass:(Class)superviewClass fromView:(UIView *)view {
    while (view) {
        if ([view isKindOfClass:superviewClass]) {
            return view;
        }
        view = view.superview;
    }
    return nil;
}

#pragma mark - Random generation

// Random string generation
+ (NSString *)randomStringWithLength:(NSInteger)length {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    
    return randomString;
}

// Full name
+ (NSString *)randomHumanName {
    NSArray *randomNames = @[@"Ranulf Alastair",@"Greig Roddy",
                             @"Lindsey Scott",@"Fionnghuala Seòsaidh",
                             @"Fingall Fife",@"Beathan Munro",
                             @"Kenina Moyna",@"Angus Monroe",
                             @"Seòras Kirsty",@"Sheona Kenna",
                             @"Niven Ishbel",@"Bhàtair Morna",
                             @"Fergie Maisie",@"Archibald Sìne",
                             @"Frazier Kester",@"Aidan Cormag"];
    int randomNameId = arc4random_uniform((int)randomNames.count);
    return randomNames[randomNameId];
}

// For bios and reviews
+ (NSString *)randomMediumText {
    NSArray *randomTexts = @[@"In a pit there lived a magical, curvy moose named Maud Humble. Not a sticky brown, derelict pit, filled with coins and a pointy smell, nor yet a ripped, incredible, damp pit with nothing in it to sit down on or to eat: it was a moose-pit, and that means happiness",
                             @"However, Boris is wounded at the Battle of Blenheim and the two reconcile just before Maud engages in some serious sitting.",
                             @"Maud accepts one of the three violent dice and returns home to her pit a very wealthy moose.",
                             @"In the search for the wizard-guarded dice",
                             @"One day, after a troubling visit from the wizard Boris Walker",
                             @"Okay"];
    int randomTextId = arc4random_uniform((int)randomTexts.count);
    return randomTexts[randomTextId];
}

// Random coordinate around coordinate
+ (CLLocationCoordinate2D)randomCoordinateInRadius:(NSInteger)radius aroundCoordinate:(CLLocationCoordinate2D)coordinate;  {
    
    int randomLatitudeDeltaMeters = (int)(arc4random_uniform((int)(radius)) - radius/2);
    int randomLongitudeDeltaMeters = (int)(arc4random_uniform((int)(radius)) - radius/2);
    // We recieved radius in meters, we need it in degrees
    double randomLatitudeDelta = randomLatitudeDeltaMeters / 63710.0;
    double randomLongitudeDelta = randomLongitudeDeltaMeters / 63710.0;
    
    float randomLatitude = coordinate.latitude + randomLatitudeDelta;
    float randomLongitude = coordinate.longitude + randomLongitudeDelta;
    
    return CLLocationCoordinate2DMake(randomLatitude, randomLongitude);
}

// Random address string from UK
+ (NSString *)randomAddress {
    NSArray *randomAddresses = @[@"11 Johnston Ave, Hebburn, Tyne and Wear NE31, UK",
                                 @"11 Puddledock, London EC4V 3PD, UK",
                                 @"7 Lime Ct, Bath and North East Somerset BS31, UK",
                                 @"1 Mid New Cultins, Edinburgh, Edinburgh EH11, UK",
                                 @"15 Cochrane Cl, West Midlands DY9, UK",
                                 @"86 Broomfield Rd, Admaston, Telford TF5, UK",
                                 @"6 Pottersfield, Corpusty, Norwich, UK",
                                 @"19 Pinehill Rd, Crowthorne, Bracknell, UK",
                                 @"12 New St, Broadbottom, Hyde SK14 6AN, UK",
                                 @"463 Carnhill Derry BT48 8BU, UK",
                                 @"2 Oatland Ct, Leeds, West Yorkshire LS7 1SD, UK",
                                 @"Twitchens Ln, Draycott, Cheddar, UK",
                                 @"7 Killygoney Terrace, Ballynahinch, UK"];
    int randomAddressId = arc4random_uniform((int)randomAddresses.count);
    return randomAddresses[randomAddressId];
}

// Random time in 24h format + AM
+ (NSString *)randomTimeString {
    int firstDigit = arc4random_uniform(2);
    int secondDigit = arc4random_uniform(4);
    int thirdDigit = arc4random_uniform(5);
    int fouthDigit = arc4random_uniform(9);
    
    return [NSString stringWithFormat:@"%d%d:%d%d", firstDigit, secondDigit, thirdDigit, fouthDigit];
}

+ (NSString *)randomDateString {
    int day = arc4random_uniform(29) + 1;
    int month = arc4random_uniform(11) + 1;
    
    return [NSString stringWithFormat:@"%d/%d/2016", day, month];
}

// Random weekdays in enum format
+ (NSArray *)randomWeekdays {
    NSArray *weekdays = @[@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun"];
    int weekdaysCount = arc4random_uniform((int)weekdays.count-2) + 1;
    NSMutableArray *randomWeekdays = [NSMutableArray new];
    for (int i=0; i<weekdaysCount; i++) {
        int randomWeekday = arc4random_uniform((int)weekdays.count);
        [randomWeekdays addObject:@(randomWeekday)];
    }
    return randomWeekdays;
}

// Random ridiculous car name
+ (NSString *)randomCarName {
    NSArray *randomNames = @[@"Toyota Orbit LE",@"Toyota Voyage",@"Toyota Alabaster",
                             @"Toyota Momentum",@"Toyota Prime",@"Toyota Starlight",
                             @"Toyota Majesty",@"Mercedes Meridian SE",@"Mercedes Behemoth",
                             @"Mercedes Thunder",@"Mercedes Sanctuary",@"Mercedes Spirit",
                             @"Mercedes Blitz",@"Lanos Prospect",@"Lanos Patron",
                             @"Lanos Blast",@"Lanos Pulse",@"Lanos Supremacy",
                             @"Lanos Tarragon",@"Lanos Instinct",@"Lanos Gallop LE"];
    int randomNameId = arc4random_uniform((int)randomNames.count);
    return randomNames[randomNameId];
}

// Random item from array
+ (id)chooseRandomFromItems:(NSArray *)items {
    // If no items, return nil
    if (![items count]) {
        return nil;
    }
    
    int randomItemId = arc4random_uniform((int)items.count);
    return items[randomItemId];
}


// Random color, on the dark side.
+ (UIColor *)randomDarkColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 );  //  0.5 to 1.0, away from black, not adding anything as color has to be dark
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

// Random color, on the light side.
+ (UIColor *)randomLightColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

+ (UIColor *)randomBrightPrettyColor {
    // One of the pre-defined pretty colors
    NSArray *hues = @[ @76, @98, @160, @217, @292, @318, @327, @21, @30, @41, @48, @58 ];
    NSNumber *hue = hues[arc4random_uniform((int)hues.count)];
    UIColor *color = [UIColor colorWithHue:[hue doubleValue] / 360.0 saturation:1.0 brightness:1.0 alpha:1.0];
    return color;
}

#pragma mark - Location address helper

// Address string from placemark without "null"s
+ (NSString *)addressStringFromPlacemark:(MKPlacemark *)placemark {
    
    NSMutableArray *addressBits = [NSMutableArray new];
    if (placemark.postalCode) {
        [addressBits addObject:placemark.postalCode];
    }
    if (placemark.locality) {
        [addressBits addObject:placemark.locality];
    }
    if (placemark.subThoroughfare) {
        [addressBits addObject:placemark.subThoroughfare];
    }
    if (placemark.thoroughfare) {
        [addressBits addObject:placemark.thoroughfare];
    }
    if (placemark.country) {
        [addressBits addObject:placemark.country];
    }
    
    // If array is empty, at least we will have placemark name
    NSString *addressString = placemark.name;
    if ([addressBits count]) {
        addressString = [addressBits componentsJoinedByString:@", "];
    }
    
    return addressString;
}

// Coordiante on map to address string
+ (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate onCompletion:(void (^)(MKPlacemark *placemark))completion {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count]) {
            CLPlacemark *placemarkCL = [placemarks lastObject];
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:placemarkCL];
            
            completion(placemark);
        }
    }];
}

#pragma mark - Core location


// Calculates distance between to coordinates in meters.
+ (double)distanceBetweenCoordinate:(CLLocationCoordinate2D)coordinateFrom andCoordinate:(CLLocationCoordinate2D)coordinateTo {
    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:coordinateFrom.latitude longitude:coordinateFrom.longitude];
    CLLocation *toLocation = [[CLLocation alloc] initWithLatitude:coordinateTo.latitude longitude:coordinateTo.longitude];
    // Distance in meters
    return [fromLocation distanceFromLocation:toLocation];
}

#pragma mark - Multithreading


+ (void)runOnMainThreadWithoutDeadlocking:(void (^)(void))block {
    // Run block on main thread without deadlocking.
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

#pragma mark - Accessing defaults

+ (void)writeDataToDefaults:(id)data forKey:(NSString *)key {
    if (data && key) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:data forKey:key];
        [userDefaults synchronize];
    }
}

+ (id)dataFromDefaultsWithKey:(NSString *)key {
    if (key) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        return [userDefaults objectForKey:key];
    }
    return nil;
}

@end
