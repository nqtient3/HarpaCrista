//
//  NSObject+Block.m
//  Nuscore
//
//  Created by Dimitar Plamenov on 11/4/14.
//  Copyright (c) DP. All rights reserved.
//


#import "NSObject+Block.h"

@implementation NSObject (Block)
- (void)performBlock: (dispatch_block_t)block
          afterDelay: (NSTimeInterval)delay
{
	dispatch_time_t dispatchTime = dispatch_time(
                                               DISPATCH_TIME_NOW,
                                               delay * NSEC_PER_SEC);
  
//	dispatch_after(
//                 dispatchTime,
//                 dispatch_get_current_queue(),
//                 block);
    dispatch_after(
                   dispatchTime,
                   dispatch_get_main_queue(),
                   block);
}

- (void)performBlockOnMainThread: (dispatch_block_t)block
{
	dispatch_sync(
                dispatch_get_main_queue(),
                block);
}

- (void)performBlockInBackground: (dispatch_block_t)block
{
	dispatch_queue_t globalQueue = dispatch_get_global_queue(
                                                           DISPATCH_QUEUE_PRIORITY_BACKGROUND, 
                                                           0);
  
	dispatch_async(
                 globalQueue, 
                 block);
}
@end
