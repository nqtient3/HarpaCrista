//
//  CDSong.h
//  HarpaCrista
//
//  Created by Chinh Le on 3/2/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDSong : NSManagedObject

//The common managed object context from AppDelegate
+ (NSManagedObjectContext *)context;

//Return the existing card or create a new card
+ (CDSong *)getOrCreateSongWithId:(int)songID;

+ (CDSong *)firstSongWithID:(int)songID;

//Create a new thumbnail
+ (CDSong *)createNewSong;

+ (NSArray *)fetchItemsWithPredicate:(NSPredicate *)predicate;

//Get all cards
+ (NSArray *)getAllSongs;

+ (NSArray *)getAllSongsWithKeyword:(NSString *)keyword;

//Get the card with title
+ (NSArray *)getAllFavoriteSongs;

+ (NSArray *)getAllFavoriteSongsWithKeyword:(NSString *)keyword;

+ (void)makeSongWithSongID:(int)songID isFavorite:(BOOL)isFavorite;

//Save context to write data into DB
+ (void)saveContext;

- (void)save;

@end

NS_ASSUME_NONNULL_END

#import "CDSong+CoreDataProperties.h"
