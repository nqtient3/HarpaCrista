//
//  NSDictionary+Json.m
//  Nuscore
//
//  Created by Dimitar Plamenov on 11/4/14.
//  Copyright (c) DP. All rights reserved.
//


#import "NSDictionary+Json.h"

@implementation NSDictionary (Json)

- (NSString*) JSONString {
  NSError *error;
  NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
  NSString* json = nil;
  if (! jsonData) {
    NSLog(@"Got an error: %@", error);
  } else {
    json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  }
  return json;
}
@end
