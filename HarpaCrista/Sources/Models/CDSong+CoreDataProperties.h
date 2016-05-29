//
//  CDSong+CoreDataProperties.h
//  HarpaCrista
//
//  Created by Chinh Le on 5/26/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDSong.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDSong (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *cdChord;
@property (nullable, nonatomic, retain) NSNumber *cdIsFavorite;
@property (nullable, nonatomic, retain) NSNumber *cdSongID;
@property (nullable, nonatomic, retain) NSString *cdTitle;
@property (nullable, nonatomic, retain) NSString *cdSongLink;

@end

NS_ASSUME_NONNULL_END
