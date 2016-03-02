//
//  CoreDataManagement.h
//  Offic
//
//  Created by Long Nguyen on 8/24/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BaseRepository;
@protocol CoreDataManagementDatasource;

@interface CoreDataManagement : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, weak) id<CoreDataManagementDatasource> datasource;

+ (instancetype) shareInstance;
- (void) setupModelPath: (NSURL*) modelPath
            storagePath: (NSURL*) storagePath;

- (NSManagedObjectContext*) workerContextForTaskType:(NSString *)type;
- (BOOL) resetDataWithNewStorage: (NSURL*) newURL ;

- (BOOL) isSamplePersistentStoreExist;
// Migration
- (BOOL) isMigrationNeeded;
- (NSMappingModel*) inferredMappingModelForMigration;
- (NSPersistentStore*) addPersistentStoreWithOptions:(NSDictionary*)options error:(NSError**)error;
- (void)mergeChangesDataContexts:(NSNotification *)notification;
@end

@protocol CoreDataManagementDatasource <NSObject>

- (NSURL*) modelPathForCoredataManagement: (CoreDataManagement*) management;
- (NSURL*) storagePathForCoredataManagement: (CoreDataManagement*) management;

@end