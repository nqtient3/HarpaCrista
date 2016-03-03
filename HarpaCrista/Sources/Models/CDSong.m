//
//  CDSong.m
//  HarpaCrista
//
//  Created by Chinh Le on 3/2/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDSong.h"
#import "AppDelegate.h"

@implementation CDSong

//The common managed object context from AppDelegate
+ (NSManagedObjectContext *)context {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.managedObjectContext;
}

//Return the existing card or create a new card
+ (CDSong *)getOrCreateSongWithId:(int)songID {
    CDSong *song = (CDSong*)[CDSong firstSongWithID:songID];
    if (song) {
        return song;
    }
    
    song = (CDSong*)[CDSong createNewSong];
    song.cdSongID = [NSNumber numberWithInt:songID];
    
    return song;
}

+ (CDSong *)firstSongWithID:(int)songID {
    NSString *string = [NSString stringWithFormat:@"cdSongID == %i", songID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    NSArray *items = [CDSong fetchItemsWithPredicate:predicate];
    if (items != nil) {
        if ([items count] > 0) {
            return [items objectAtIndex:0];
        }
    }
    
    return nil;
}

//Create a new thumbnail
+ (CDSong *)createNewSong {
    CDSong *card = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CDSong class]) inManagedObjectContext:[CDSong context]];
    [card save];
    
    return card;
}

+ (NSArray *)fetchItemsWithPredicate:(NSPredicate *)predicate {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSArray *items = nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([CDSong class]) inManagedObjectContext:[CDSong context]];
    
    
    [request setEntity:entity];
    
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    
    // define a sort descriptor
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"cdSongID" ascending:YES];
    
    NSArray *scArray = [[NSArray alloc]initWithObjects:descriptor, nil];
    request.sortDescriptors = scArray;
    
    //Execute request
    NSError *error = nil;
    items = [[CDSong context] executeFetchRequest:request error:&error];
    
    return items;
}

//Get all cards
+ (NSArray *)getAllSongs {
    NSArray *songs = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([CDSong class]) inManagedObjectContext:[CDSong context]];
    [request setEntity:entity];
    
    // define a sort descriptor
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"cdSongID" ascending:YES];
    
    NSArray *scArray = [[NSArray alloc]initWithObjects:descriptor, nil];
    // give sort descriptor array to the fetch request
    request.sortDescriptors = scArray;
    
    songs = [[CDSong context] executeFetchRequest:request error:nil];
    
    return songs;
}

//Get the card with title
+ (NSArray *)getAllFavoriteSongs {
    NSArray *songs = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([CDSong class]) inManagedObjectContext:[CDSong context]];
    [request setEntity:entity];
    
    // setup a predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cdIsFavorite == %i", [[NSNumber numberWithBool:YES] intValue]];
    
    // give the predicate to the fetch request
    request.predicate = predicate;
    
    // define a sort descriptor
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"cdSongID" ascending:YES];
    
    NSArray *scArray = [[NSArray alloc]initWithObjects:descriptor, nil];
    // give sort descriptor array to the fetch request
    request.sortDescriptors = scArray;
    
    songs = [[CDSong context] executeFetchRequest:request error:nil];
    
    return songs;
}

+ (void)makeSongWithSongID:(int)songID isFavorite:(BOOL)isFavorite {
    CDSong *songItem = [CDSong getOrCreateSongWithId:songID];
    songItem.cdIsFavorite = [NSNumber numberWithBool:isFavorite];
    [CDSong saveContext];
}

//Save context to write data into DB
+ (void)saveContext {
    NSManagedObjectContext *context = [CDSong context];
    if (context) {
        [context performBlockAndWait:^{
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Error: %@", [error localizedDescription]);
            }
        }];
    } else {
        NSLog(@"Error: [Card context] is nil");
    }
}


- (void)save {
    NSManagedObjectContext *context = [self managedObjectContext];
    if (context) {
        [context performBlockAndWait:^{
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Error: %@", [error localizedDescription]);
            }
        }];
    } else {
        NSLog(@"Error: [Card context] is nil");
    }
}

@end
