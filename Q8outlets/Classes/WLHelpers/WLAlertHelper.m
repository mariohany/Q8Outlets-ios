//
//  WLAlertHelper.m
//  WLHelpers
//
//  Created by Lesya Verbina on 6/1/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import "WLAlertHelper.h"
#import <objc/runtime.h>
#import "WLUtilityHelper.h"

@interface UIAlertController (Window)
- (void)show;
- (void)show:(BOOL)animated;
@end

@interface UIAlertController (Private)
@property (nonatomic, strong) UIWindow *alertWindow;
@end

@implementation UIAlertController (Private)

@dynamic alertWindow;

- (void)setAlertWindow:(UIWindow *)alertWindow {
    objc_setAssociatedObject(self, @selector(alertWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)alertWindow {
    return objc_getAssociatedObject(self, @selector(alertWindow));
}

@end

@implementation UIAlertController (Window)

- (void)show {
    [self show:YES];
}

- (void)show:(BOOL)animated {
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.rootViewController = [[UIViewController alloc] init];
    
    // We inherit the main window's tintColor
    self.alertWindow.tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    // Window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard)
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
    self.alertWindow.windowLevel = topWindow.windowLevel + 1;
    
    [self.alertWindow makeKeyAndVisible];
    
    // Animate fade in
    self.alertWindow.alpha = 0.0f;
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.alertWindow.alpha = 1.0f;
                     }];
    
    // Needed for iPad presentation, will present from the bottom center of the screen
    self.popoverPresentationController.sourceView = self.alertWindow.rootViewController.view;
    self.popoverPresentationController.sourceRect = CGRectMake(self.alertWindow.rootViewController.view.bounds.size.width / 2.0,
                                                               self.alertWindow.rootViewController.view.bounds.size.height,
                                                               1.0, 1.0);
    
    [self.alertWindow.rootViewController presentViewController:self animated:animated completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Making controller gradually disappear
    [UIView animateWithDuration:0.1f
                     animations:^{
                         self.alertWindow.alpha = 0.0f;
                     }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Precaution to insure window gets destroyed
    self.alertWindow.hidden = YES;
    self.alertWindow = nil;
}

@end

@implementation WLAlertHelper {
    BOOL showingAlert;
    
    UIColor *tintColor;
    
    NSString *pathForAlertsFile;
}

+ (WLAlertHelper *)sharedHelper {
    static dispatch_once_t onceToken;
    static WLAlertHelper *sharedHelper = nil;
    
    dispatch_once(&onceToken, ^{
        sharedHelper = [[WLAlertHelper alloc] init];
    });
    
    return sharedHelper;
}

+ (UIAlertController *)createAlertControllerForReason:(NSInteger)reason {
    return [[WLAlertHelper sharedHelper] createAlertControllerForReason:reason titleArguments:nil bodyArguments:nil delegate:nil];
}

+ (UIAlertController *)createAlertControllerForReason:(NSInteger)reason delegate:(id<WLAlertControllerDelegate>)delegate {
    return [[WLAlertHelper sharedHelper] createAlertControllerForReason:reason titleArguments:nil bodyArguments:nil delegate:delegate];
}

+ (UIAlertController *)createAlertControllerForReason:(NSInteger)reason
                                       titleArguments:(NSArray <NSString *> *)titleArguments
                                        bodyArguments:(NSArray <NSString *> *)bodyArguments
                                             delegate:(id<WLAlertControllerDelegate>)delegate {
    return [[WLAlertHelper sharedHelper] createAlertControllerForReason:reason titleArguments:titleArguments bodyArguments:bodyArguments delegate:delegate];
}

+ (void)setAlertControllerButtonsTintColor:(UIColor *)desiredTintColor {
    // Set tint color of alert controller window so button's text color is customized.
    [[WLAlertHelper sharedHelper] setAlertControllerButtonsTintColor:desiredTintColor];
}

- (void)setAlertControllerButtonsTintColor:(UIColor *)desiredTintColor {
    tintColor = desiredTintColor;
}

- (UIAlertController *)createAlertControllerForReason:(NSInteger)reason
                                       titleArguments:(NSArray <NSString *> *)titleArguments
                                        bodyArguments:(NSArray <NSString *> *)bodyArguments
                                             delegate:(id<WLAlertControllerDelegate>)delegate {
    
    // If already displaying alert - not displaying new one
    if (showingAlert) {
        return nil;
    }
    showingAlert = YES;
    
    // Parsing alert contents
    NSDictionary *messageDict = [WLAlertHelper alerDictionaryFromJsonFileForReason:reason];
    NSString *title = [messageDict objectForKey:@"title"];
    NSString *body = [messageDict objectForKey:@"body"];
    NSArray *actionTitles = [messageDict objectForKey:@"action_titles"];
    NSString *cancelTitle = [messageDict objectForKey:@"cancel_title"];
    NSString *deleteTitle = [messageDict objectForKey:@"delete_title"];
    NSArray *textFieldPlaceholders = [messageDict objectForKey:@"text_fields"];
    if (!cancelTitle.length) {
        cancelTitle = NSLocalizedString(@"Ok", @"default alert cancel title");
    }
    
    // If provided arguments for title formatted string of body formatted string, adding them
    if ([titleArguments count]) {
        NSArray *a = [titleArguments arrayByAddingObjectsFromArray:@[@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X"]];
        title = [NSString stringWithFormat:title, a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10] ];
    }
    if ([bodyArguments count]) {
        NSArray *a = [bodyArguments arrayByAddingObjectsFromArray:@[@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X"]];
        body = [NSString stringWithFormat:body, a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10] ];
    }
    
    UIAlertController *alertController;
    
    // If body or title are absent, make them nil
    if (!body.length) {
        body = nil;
    }
    if (!title.length) {
        title = nil;
    }
    
    // If more than 3 buttons - action sheet
    if ([actionTitles count] > 1 && ![textFieldPlaceholders count]) {
        alertController = [UIAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleActionSheet];
    } else {
        alertController = [UIAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleAlert];
    }
    
    // Cancel action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self->showingAlert = NO;
        if (delegate && [delegate respondsToSelector:@selector(didUseCancelActionOfAlertController:)]) {
            [delegate didUseCancelActionOfAlertController:reason];
        }
    }];
    [alertController addAction:cancelAction];
    
    // Destructive action, if any
    if (deleteTitle.length) {
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            self->showingAlert = NO;
            if (delegate && [delegate respondsToSelector:@selector(didUseDestructiveActionOfAlertController:)]) {
                [delegate didUseDestructiveActionOfAlertController:reason];
            }
        }];
        [alertController addAction:deleteAction];
        
    }
    
    // Action titles, if any
    for (NSString *actionTitle in actionTitles) {
        UIAlertAction *actionAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self->showingAlert = NO;
            if (delegate && [delegate respondsToSelector:@selector(didUseActionAtIndex:ofAlertController:withReason:)]) {
                [delegate didUseActionAtIndex:[actionTitles indexOfObject:actionTitle] ofAlertController:alertController withReason:reason];
            }
        }];
        [alertController addAction:actionAction];
    }
    
    for (NSString *textFieldPlaceholder in textFieldPlaceholders) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = textFieldPlaceholder;
        }];
    }
    
    [alertController show];
    // Customize buttons tint color
    if (tintColor) {
        alertController.alertWindow.tintColor = tintColor;
    }
    
    // Returning alert controller, so that view controller
    // can access it and text fields in it, in particular
    return alertController;
}

+ (NSDictionary *)alerDictionaryFromJsonFileForReason:(NSInteger)reason {
    NSDictionary *jsonDictionary = (NSDictionary *)[WLUtilityHelper arrayFromJsonFileAtPath:[[WLAlertHelper sharedHelper] pathForAlertsFile]];
    if ([jsonDictionary respondsToSelector:@selector(objectForKey:)]) {
        NSString *reasonString = [NSString stringWithFormat:@"%ld",(long)reason];
        return [jsonDictionary objectForKey:reasonString];
    } else {
        NSLog(@"%@ is not a dict", jsonDictionary);
        return [NSDictionary new];
    }
}

+ (void)setPathForAlertsFile:(NSString *)newPathForAlertsFile {
    [[WLAlertHelper sharedHelper] setPathForAlertsFile:newPathForAlertsFile];
}

- (void)setPathForAlertsFile:(NSString *)newPathForAlertsFile {
    pathForAlertsFile = newPathForAlertsFile;
}

- (NSString *)pathForAlertsFile {
    return pathForAlertsFile ?: [[NSBundle mainBundle] pathForResource:@"Alerts" ofType:@"json"];
}

@end
