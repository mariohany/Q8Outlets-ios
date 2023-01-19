//
//  WLCoreDataHelper.m
//  WLHelpers
//
//  Created by Lesya Verbina on 7/13/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import "WLCoreDataHelper.h"
#import "WLUtilityHelper.h"
#import "WLLogHelper.h"

@implementation WLCoreDataHelper {
    NSString *databaseName;
}

+ (WLCoreDataHelper *)sharedHelper {
    static dispatch_once_t onceToken;
    static WLCoreDataHelper *sharedHelper = nil;
    
    dispatch_once(&onceToken, ^{
        sharedHelper = [[WLCoreDataHelper alloc] init];
        // Register helper for application termination notification
        [[NSNotificationCenter defaultCenter] addObserver:sharedHelper
                                                 selector:@selector(applicationWillTerminate)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    });
    return sharedHelper;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDatabaseName:(NSString *)userDatabaseName {
    // This is preferebbly done in application delegate - this sets name of the database we will be looking for
    databaseName = userDatabaseName;
}

- (void)applicationWillTerminate {
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:databaseName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSString *sqliteDatabaseName = [NSString stringWithFormat:@"%@.sqlite",databaseName];
    NSURL *storeURL = [[WLUtilityHelper applicationDocumentsDirectory] URLByAppendingPathComponent:sqliteDatabaseName];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"WLCOREDATA_ERROR_DOMAIN" code:9999 userInfo:dict];
        
        // Error while saving data does not generate crash
        WLErrLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (void)deleteAllEntitiesOf:(NSString *)entityDescription  {
    if (entityDescription.length) {
        // Drop a specific table
        
        // Gather all entities of a type
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:[[WLCoreDataHelper sharedHelper] managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSError *error;
        NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        // Remove all entities
        for (NSManagedObject *managedObject in items) {
            [_managedObjectContext deleteObject:managedObject];
        }
        
        // Save changes
        [self saveContext];
    }
}


- (void)flushDatabase{
    // Flush the whole datamodel completely
    [_managedObjectContext performBlockAndWait:^{
        NSArray *stores = [_persistentStoreCoordinator persistentStores];
        for(NSPersistentStore *store in stores) {
            [_persistentStoreCoordinator removePersistentStore:store error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
        }
    }];
    _managedObjectModel    = nil;
    _managedObjectContext  = nil;
    _persistentStoreCoordinator = nil;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Error while saving data does not generate crash
            WLErrLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

@end
