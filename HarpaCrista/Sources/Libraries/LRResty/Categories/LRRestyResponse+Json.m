//
//  LRRestyResponse+Json.m
//  Nuscore
//
//  Created by Dimitar Plamenov on 11/4/14.
//  Copyright (c) DP. All rights reserved.
//


#import "LRRestyResponse+Json.h"

@implementation LRRestyResponse (Json)
- (id)asJSONObject {
  return [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
}
@end
