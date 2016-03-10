//
//  NSObject+Block.h
//  Nuscore
//
//  Created by Dimitar Plamenov on 11/4/14.
//  Copyright (c) DP. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSObject (Block)
- (void)performBlock: (dispatch_block_t)block
          afterDelay: (NSTimeInterval)delay;

- (void)performBlockOnMainThread: (dispatch_block_t)block;

- (void)performBlockInBackground: (dispatch_block_t)block;
@end
