//
//  ImportDataCoreDataHandler.m
//  kabamapp
//
//  Created by Long Vo on 12/18/14.
//  Copyright (c) 2014 HTK-INC. All rights reserved.
//

#import "ImportDataCoreDataHandler.h"
#import "CoreDataManagement.h"

@interface ImportDataCoreDataHandler()

@end

@implementation ImportDataCoreDataHandler

+ (ImportDataCoreDataHandler*) sharedInstance {
    static ImportDataCoreDataHandler *staticInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[ImportDataCoreDataHandler alloc] init];
    });
    return staticInstance;
}

- (void) importDataWithBlock:(void (^)(BaseRepository *))block
             repositoryClass:(__unsafe_unretained Class)repoClass {
    __block BaseRepository *repo = [[repoClass alloc] initWithPrivateQueue];
    [repo performBlock:^{
        block(repo);
    }];
}

@end
