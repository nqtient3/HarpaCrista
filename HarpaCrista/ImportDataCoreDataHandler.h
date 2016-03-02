//
//  ImportDataCoreDataHandler.h
//  kabamapp
//
//  Created by Long Vo on 12/18/14.
//  Copyright (c) 2014 Dimitar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseRepository.h"

// Sample:
// [[ImportDataCoreDataHandler sharedInstance] importDataWithBlock: ^((BaseRepository* ) repo) {
//      Event* event = [repo createEvent];
//
// } repository: [BaseRepository createEventRepo]]

@interface ImportDataCoreDataHandler : NSObject

+ (ImportDataCoreDataHandler* ) sharedInstance;

- (void) importDataWithBlock: (void(^)(BaseRepository*)) block
             repositoryClass: (Class) repoClass;

@end
