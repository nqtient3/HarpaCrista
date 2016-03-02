//
//  CoreDataManagement.m
//  Offic
//
//  Created by Long Nguyen on 8/24/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "CoreDataManagement.h"
#import "BaseRepository.h"

@interface CoreDataManagement ()
@property (nonatomic, strong, readonly) NSManagedObjectContext *writerManagedObjectContext;
@property (nonatomic, strong, readonly) NSURL *modelPath;
@property (nonatomic, strong, readonly) NSURL *storagePath;
@end

@implementation CoreDataManagement {
    NSURL *_modelPath;
    NSURL *_storagePath;
    
    NSMutableDictionary *workerContexts;
}

@synthesize writerManagedObjectContext = _writerManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize mainManagedObjectContext = _mainManagedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype) shareInstance {
    static CoreDataManagement *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[CoreDataManagement alloc] init];
    });
    
    return _shareInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSURL*) modelPath {
    
    if([self.datasource respondsToSelector:@selector(modelPathForCoredataManagement:)]) {
        _modelPath = [self.datasource modelPathForCoredataManagement: self];
    }

    if(!_modelPath) {
        @throw @"Need to call setupModelPath:storagePath: before using";
    }
    return  _modelPath;
}

- (NSURL*) storagePath {
    if([self.datasource respondsToSelector:@selector(storagePathForCoredataManagement:)]) {
        NSURL *newURL = [self.datasource storagePathForCoredataManagement: self];
        _storagePath = newURL;
    }
    
    if(!_storagePath) {
        @throw @"Need to call setupModelPath:storagePath: before using";
    }
    return  _storagePath;
}


- (void) setupModelPath: (NSURL*) modelPath storagePath: (NSURL*) storagePath {
    if(![_modelPath isEqual: modelPath] || ![_storagePath isEqual: storagePath]) {
        [self resetDataWithNewStorage:storagePath];
    }
    if (!modelPath) {
        @throw @"modelPath must not nil";
    }
    if (!storagePath) {
        @throw @"storagePath must not nil";
    }
    _modelPath = modelPath;
    _storagePath = storagePath;
}

- (BOOL) resetDataWithNewStorage: (NSURL*) newURL {
    if([newURL isEqual: _storagePath]) {
        return NO;
    }
    _persistentStoreCoordinator = nil;
    _managedObjectModel = nil;
    
    for (NSManagedObjectContext *context in [workerContexts allValues]) {
        [context performBlock:^{
           
            [context rollback];
        }];
    }
        
    [_mainManagedObjectContext rollback];
    [_writerManagedObjectContext rollback];
    
    _mainManagedObjectContext = nil;
    _writerManagedObjectContext = nil;
    workerContexts = nil;
    
    return YES;
}

#pragma mark - CoreData stack

- (NSManagedObjectContext*) workerContextForTaskType:(NSString *)type {
    if(!workerContexts) {
        workerContexts = [[NSMutableDictionary alloc] init];
    }
    NSManagedObjectContext *workerContext = [workerContexts objectForKey:type];
    if (!workerContext) {
        workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        workerContext.parentContext = self.mainManagedObjectContext;
        [workerContexts setObject:workerContext forKey:type];
    }
    return workerContext;
}

- (NSManagedObjectContext*) writerManagedObjectContext {
    if(_writerManagedObjectContext != nil) {
        return _writerManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _writerManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
        [_writerManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _writerManagedObjectContext;
}

- (NSManagedObjectContext *)mainManagedObjectContext
{
    if (_mainManagedObjectContext != nil)
    {
        return _mainManagedObjectContext;
    }
    
    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    _mainManagedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    _mainManagedObjectContext.parentContext = self.writerManagedObjectContext;
    
    return _mainManagedObjectContext;
}

-(NSManagedObjectModel*) managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: self.modelPath];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
//    NSDictionary *options = nil;
//    
//#pragma mark Enable Default and Automatic Lightweight Migration
//    options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption : @YES};
//    
//    NSError *error = nil;
//    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
//    
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storagePath options:options error:&error]) {
//        // Report any error we got.
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
//        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
//        dict[NSUnderlyingErrorKey] = error;
//        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//        // Replace this with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
    
    return _persistentStoreCoordinator;
}

//------------------------------------------------------------------------------
#pragma mark - Data Migration
//------------------------------------------------------------------------------

- (BOOL) isMigrationNeeded
{
    BOOL migrationNeeded = NO;
    NSError *error = nil;
    
    // Check if we need to migrate
    NSDictionary *sourceMetadata = [self sourceMetadata:&error];
    if (nil != error) {
        return migrationNeeded;
    }
    
    if (nil != sourceMetadata) {
        NSManagedObjectModel *destinationModel = [self managedObjectModel];
        
        // Migration is needed if destinationModel is NOT compatible
        migrationNeeded = ![destinationModel isConfiguration:nil
                                 compatibleWithStoreMetadata:sourceMetadata];
    }
    
    return migrationNeeded;
}

- (NSString*) storeType
{
    return NSSQLiteStoreType;
}

- (NSDictionary*) sourceMetadata:(NSError **)error
{
    return [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:[self storeType] URL:[self persistentStoreURL] error:error];
}

- (NSURL*) persistentStoreURL
{
    return [self.datasource storagePathForCoredataManagement: self];
}

- (NSMappingModel*) inferredMappingModelForMigration
{
    NSError *error = nil;
    NSMappingModel *mappingModel = nil;
    
    NSManagedObjectModel *currentStoreModel = [self persistentStoreManagedObjectModel];
    NSManagedObjectModel *newStoreModel = [self managedObjectModel];
    
    if (nil != currentStoreModel && nil != newStoreModel) {
        mappingModel = [NSMappingModel inferredMappingModelForSourceModel:currentStoreModel destinationModel:newStoreModel error:&error];
    }
    return mappingModel;
}

- (NSManagedObjectModel*) persistentStoreManagedObjectModel
{
    NSError *error = nil;
    NSDictionary *sourceMetadata = [self sourceMetadata:&error];
    if (nil != error) {
        return nil;
    }
    
    return [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]
                                       forStoreMetadata:sourceMetadata];
}

- (BOOL) isSamplePersistentStoreExist
{
    NSURL *storeURL = [self persistentStoreURL];
    return [[NSFileManager defaultManager] fileExistsAtPath:storeURL.path];
}

- (NSPersistentStore*) addPersistentStoreWithOptions:(NSDictionary*)options error:(NSError**)error
{
    NSURL *storeURL = [self persistentStoreURL];
    
    NSPersistentStore *persistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType:[self storeType] configuration:nil URL:storeURL options:options error:error];
    
    return persistentStore;
}

// Merge changesDataOtherContexts
- (void)mergeChangesDataContexts:(NSNotification *)notification
{
    if ([NSThread isMainThread] == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self mergeChangesDataContexts:notification];
        });
        
        return;
    }
    NSManagedObjectContext *savedContext = [notification object];
    NSManagedObjectContext *savedContextWorker = [[CoreDataManagement shareInstance] workerContextForTaskType:@"worker"];
    
    if (savedContext != savedContextWorker) {
        return;
    }
    if (savedContext.parentContext == nil) {
        return;
    }
    
    // Ignore changes for other databases.
    if (savedContextWorker.persistentStoreCoordinator != savedContext.persistentStoreCoordinator) {
        return;
    }
    
    if ([[[notification userInfo] objectForKey:NSInsertedObjectsKey] count] > 0 || [[[notification userInfo] objectForKey:NSDeletedObjectsKey] count] > 0) {
        return;
    }
    else {
        [savedContext.parentContext performBlock: ^{
            [savedContext.parentContext mergeChangesFromContextDidSaveNotification: notification];
        }];
        //BUG FIX: When the notification is merged it only updates objects which are already registered in the context.
        //If the predicate for a NSFetchedResultsController matches an updated object but the object is not registered
        //in the FRC's context then the FRC will fail to include the updated object. The fix is to force all updated
        //objects to be refreshed in the context thus making them available to the FRC.
        //Note that we have to be very careful about which methods we call on the managed objects in the notifications userInfo.
        for (NSManagedObject *unsafeManagedObject in notification.userInfo[NSUpdatedObjectsKey]) {
            //Force the refresh of updated objects which may not have been registered in this context.
            NSManagedObject *manangedObject = [savedContext existingObjectWithID:unsafeManagedObject.objectID error:NULL];
            if (manangedObject != nil) {
                [savedContext refreshObject:manangedObject mergeChanges:YES];
            }
        }
    }
    
}


@end
