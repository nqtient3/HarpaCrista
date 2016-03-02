//
//  BaseRepository.m
//  iVNmob
//
//  Created by HTK INC on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseRepository.h"
#import "AppDelegate.h"
#import "CoreDataManagement.h"

#define TASK_TYPE @"worker"

@implementation BaseRepository {
    
}
@synthesize managedObjectContext = managedObjectContext_;

- (id)init
{
    NSManagedObjectContext *context;
    if([NSThread isMainThread]) {
        context = [CoreDataManagement shareInstance].mainManagedObjectContext;
    } else {
        context = [[CoreDataManagement shareInstance] workerContextForTaskType: TASK_TYPE];
    }
    
    self =  [self initWithManageObjectContext: context];
    
    return self;
}

- (id)initWithPrivateQueue {
     NSManagedObjectContext *context = [[CoreDataManagement shareInstance] workerContextForTaskType: TASK_TYPE];
    self = [self initWithManageObjectContext: context];
    return self;
}

- (id)initWithManageObjectContext:(NSManagedObjectContext *)context {
    self = [super init];
    if (self) {
        NSAssert([self.entityName length], @"Entity name must be implemented in subclasses of BaseRepository");
        managedObjectContext_ = context;
    }
    return self;
}

- (NSManagedObject *)createObject {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName: self.entityName inManagedObjectContext:self.managedObjectContext];
    return object;
}

- (void)insertObject:(NSManagedObject *)object {
    if(object)
        [self.managedObjectContext insertObject:object];
}

- (void)removeObject:(NSManagedObject *)object {
    if(object)
        [self.managedObjectContext deleteObject:object];
    
}

//Get all entities
- (NSArray *)allEntities {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSArray *items = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    items = [self.managedObjectContext executeFetchRequest:request error:nil];
    return items;
}

- (NSArray *)allEntitiesSortByDateCreation {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    //DateCreation
    NSSortDescriptor *sortDateCreation = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES];
    NSArray *sortArray = [NSArray arrayWithObject:sortDateCreation];
    [request setSortDescriptors:sortArray];
    
    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return items;
    
}

- (NSArray *)allEntitiesWithSortOption:(NSArray *)sortOptions {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:managedObjectContext_];
    [request setEntity:entity];
    
    [request setSortDescriptors:sortOptions];
    
    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return items;
    
}

//Remove all entites
- (void)removeAllEntities {
    NSArray *items = [self allEntities];
    for (NSManagedObject *manageObject in items) {
        [self removeObject:manageObject];
    }
}

- (void)removeAllEntitiesInArray:(NSArray *)array {
    for (NSManagedObject *object in array) {
        [self removeObject:object];
    }
}

- (NSArray *)fetchProperty:(NSString *)property withPredicate:(NSPredicate *)predicate sortArray:(NSArray *)sortArray distinctResult:(BOOL)distinct {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:managedObjectContext_];
    
    [request setEntity:entity];
    if (distinct) {
        [request setReturnsDistinctResults:YES];
    }
    
    NSDictionary *properties = [entity propertiesByName];
    NSArray *propertiesToFetch = [NSArray arrayWithObject:[properties objectForKey:property]];
    [request setPropertiesToFetch:propertiesToFetch];
    
    
    request.resultType = NSDictionaryResultType;
    
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    
    if (sortArray != nil) {
        [request setSortDescriptors:sortArray];
    }
    
    //Execute request
    NSError *error = nil;
    NSArray *items = [managedObjectContext_ executeFetchRequest:request error:&error];
    if (items == nil) {
        //error
    }
    
    return items;
}

- (NSArray *)fetchItemsWithPredicate:(NSPredicate *)predicate
                           sortArray:(NSArray *)sortArray {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSArray *items = nil;
    
    // TODO: Crash app when run app on xcode 7
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:managedObjectContext_];
    
    
    [request setEntity:entity];
    
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    
    if (sortArray != nil) {
        [request setSortDescriptors:sortArray];
    }
    
    //Execute request
    NSError *error = nil;
    items = [managedObjectContext_ executeFetchRequest:request error:&error];
    if (items == nil) {
        //error
    }
    
    return items;
}

- (NSArray *)fetchItemsDistinctWithPredicate:(NSPredicate *)predicate
                                   sortArray:(NSArray *)sortArray {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setReturnsDistinctResults:YES];
    NSArray *items = nil;
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:managedObjectContext_];
    [request setEntity:entity];
    
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    
    if (sortArray != nil) {
        [request setSortDescriptors:sortArray];
    }
    
    //Execute request
    NSError *error = nil;
    items = [managedObjectContext_ executeFetchRequest:request error:&error];
    if (items == nil) {
        //error
    }

    return items;
}

- (NSManagedObject *)firstObjectWithFieldName:(NSString *)name hasValue:(NSObject *)value {
    NSString *string = [NSString stringWithFormat:@"%@ = '%@'", name, value];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    NSArray *items = [self fetchItemsWithPredicate:predicate sortArray:nil];
    if (items != nil) {
        if ([items count] > 0) {
            return [items objectAtIndex:0];
        }
    }
    return nil;
}

- (NSArray *)firstObjectWithFieldNameWithContact:(NSString *)name hasValue:(NSObject *)value{
    NSString *string = [NSString stringWithFormat:@"%@ = '%@'", name, value];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    NSArray *items = [self fetchItemsWithPredicate:predicate sortArray:nil];
    if (items != nil) {
        if ([items count] > 0) {
            return items;
        }
    }
    return nil;
}

- (NSManagedObject *)firstObjectWithDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    for (NSString *key in [dictionary allKeys]) {
        id value = [dictionary objectForKey:key];
        if([value isKindOfClass: [NSString class]]) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"%@ = '%@'", key, (NSString*) value]];
        } else {
            [predicates addObject:[NSPredicate predicateWithFormat:@"%@ = %@", key, value]];
        }
    }
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates: predicates];
    
    
    NSArray *items = [self fetchItemsWithPredicate:predicate sortArray:nil];
    if (items != nil) {
        if ([items count] > 0) {
            return [items objectAtIndex:0];
        }
    }
    return nil;
}

- (void)reset {
    [self removeAllEntities];
}

- (void)performBlock:(void (^)())block autoSaveContext: (BOOL) save {
    
    __block NSManagedObjectContext *currentContext = self.managedObjectContext;

    [currentContext performBlock:^{
        block();
        
        if(save) {
            [self performSaveContext: currentContext];
        }
    }];
}

- (void) performSaveContext: (NSManagedObjectContext*) context {
    if(context) {
        [context performBlock:^{
            if(![context save: nil]){
                abort();
            }
            if(context.parentContext) {
                [self performSaveContext: context.parentContext];
            }
        }];
    }
}

- (void) performBlock:(void (^)())block {
    [self performBlock:block autoSaveContext: YES];
}

@end
