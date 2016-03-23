//
//
//  FavoritosViewController.h
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.

#import <Foundation/Foundation.h>

#import "LRRestyRequestPayload.h"

@interface JSONObject : NSObject <LRRestyRequestPayload>
- (id) initWithDictionary: (NSDictionary*) dict;
- (id) initWithArray: (NSArray*) array;
- (id) initWithJSONString: (NSString*) json;
@end
