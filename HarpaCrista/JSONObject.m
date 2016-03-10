//
//  FavoritosViewController.h
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
#import "JSONObject.h"
#import "NSDictionary+Json.h"
#import "NSArray+Json.h"
#import "LRResty.h"

@implementation JSONObject {
  NSString *jsonString_;
}

- (id) initWithDictionary: (NSDictionary*) dict {
  self = [super init];
  if(self) {
      jsonString_ = [[dict JSONString] copy];
  }
  return self;
}

- (id) initWithArray: (NSArray*) array {
  self = [super init];
  if(self) {
    jsonString_ = [[array JSONString] copy];
  }
  return self;

    
}

- (id) initWithJSONString: (NSString*) json {
  self = [super init];
  if(self) {
    jsonString_ = [json copy];
  }
  return self;
}

/**
 The data to be used in the request body.
 */
- (NSData *)dataForRequest {
  return [jsonString_ dataUsingEncoding:NSUTF8StringEncoding];
}

/**
 The MIME type that will be used in the Content-Type header
 */
- (NSString *)contentTypeForRequest{
  return @"application/json";
}

- (void)modifyRequestBeforePerforming:(LRRestyRequest *)request {
    [request addHeader:@"Accept" value:@"application/json, text/plain, */*"];
}

@end
