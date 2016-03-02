//
//  BaseRepository.h
//  iVNmob
//
//  Created by HTK INC on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface BaseRepository : NSObject {
//  NSString *entityName_;
}

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, copy, readonly) NSString *entityName;

- (void)performBlock:(void (^)())block autoSaveContext: (BOOL) save;

- (void) performBlock:(void (^)())block;

- (id)initWithManageObjectContext:(NSManagedObjectContext *)context;
- (id)initWithPrivateQueue;

- (NSArray *)allEntities;
- (NSArray *)allEntitiesWithSortOption:(NSArray *)sortOptions;

- (NSManagedObject *)createObject;
- (void)insertObject:(NSManagedObject *)object;
- (void)removeObject:(NSManagedObject *)object;
- (void)removeAllEntities;
- (NSArray *)allEntitiesSortByDateCreation;
- (void)removeAllEntitiesInArray:(NSArray *)array;

- (NSArray *)fetchProperty:(NSString *)property withPredicate:(NSPredicate *)predicate sortArray:(NSArray *)sortArray distinctResult:(BOOL)distinct;


- (NSArray *)fetchItemsWithPredicate:(NSPredicate *)predicate 
                           sortArray:(NSArray *)sortArray;
- (NSArray *)fetchItemsDistinctWithPredicate:(NSPredicate *)predicate 
                           sortArray:(NSArray *)sortArray;

- (NSManagedObject *)firstObjectWithFieldName:(NSString *)name hasValue:(NSObject *)value;
- (NSArray *)firstObjectWithFieldNameWithContact:(NSString *)name hasValue:(NSObject *)value;
- (NSManagedObject *)firstObjectWithDictionary:(NSDictionary *)dictionary;
- (void)reset;

@end
