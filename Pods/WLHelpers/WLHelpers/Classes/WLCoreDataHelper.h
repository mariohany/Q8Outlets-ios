//
//  WLCoreDataHelper.h
//  WLHelpers
//
//  Created by Lesya Verbina on 7/13/16.
//  Copyright © 2016 Wonderslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface WLCoreDataHelper : NSObject

/**
 *  Singleton of core data helper, to access instance methods.
 *
 *  @return Core data helper shared instance.
 */
+ (WLCoreDataHelper *)sharedHelper;

/**
 *  This is preferebbly done in application delegate - this sets name of the database we will be looking for.
 *  Name of .xcdatamodeld file, containing your model.
 *
 *  @param userDatabaseName Database name, name of the model.
 */
- (void)setDatabaseName:(NSString *)userDatabaseName;

/**
 *  Managed object context to be accessed and used, main point of entry for database.
 */
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/**
 *  The managed object model for the application.
 */
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

/**
 *  The persistent store coordinator for the application.
 *  Implementation creates and returns a coordinator, having added the store for the application to it.
 */
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 *  Drop a specific table. Remove all entities of a certain type.
 *
 *  @param entityDescription Entitiy to remove.
 */
- (void)deleteAllEntitiesOf:(NSString *)entityDescription;

/**
 *  Flushes the whole datamodel completely, removing database file and recreating it later.
 */
- (void)flushDatabase;

/**
 *  Core Data saving support. Can be called manually, and is always called when app terminates.
 */
- (void)saveContext;


@end
