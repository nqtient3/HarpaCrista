//
//  LRRestyRequestPayload.m
//  LRResty
//
//  Created by Luke Redpath on 05/08/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "LRRestyRequestPayload.h"
#import "LRRestyRequest.h"
#import "NSDictionary+QueryString.h"

#pragma mark -
#pragma mark Private Headers

@interface LRRestyDataPayload : NSObject <LRRestyRequestPayload>
{
  NSData *requestData;
  NSString *contentType;
}
- (id)initWithData:(NSData *)data;
- (id)initWithEncodable:(id)encodable encoding:(NSStringEncoding)encoding;
@end

@interface LRRestyFormEncodedPayload : NSObject <LRRestyRequestPayload>
{
  NSDictionary *dictionary;
}
- (id)initWithDictionary:(NSDictionary *)aDictionary;
@end

#pragma mark -

@implementation LRRestyRequestPayloadFactory

+ (id)payloadFromObject:(id)object;
{
  if ([object conformsToProtocol:@protocol(LRRestyRequestPayload)]) {
    return object;
  }
  if ([object respondsToSelector:@selector(dataUsingEncoding:)]) {
    return [[LRRestyDataPayload alloc] initWithEncodable:object encoding:NSUTF8StringEncoding];
  }
  if ([object isKindOfClass:[NSDictionary class]]) {
    return [[LRRestyFormEncodedPayload alloc] initWithDictionary:object];
  }
  if ([object isKindOfClass:[NSData class]]) {
    return [[LRRestyDataPayload alloc] initWithData:object];
  }
  return nil;
}

@end

#pragma mark -
#pragma mark Native payloads

@implementation LRRestyDataPayload

- (id)initWithData:(NSData *)data;
{
  if ((self = [super init])) {
    requestData = [data copy];
    contentType = [@"application/octet-stream" copy];
  }
  return self;
}

- (id)initWithEncodable:(id)encodable encoding:(NSStringEncoding)encoding
{
  if (![encodable respondsToSelector:@selector(dataUsingEncoding:)]) {
    [NSException raise:NSInternalInconsistencyException format:@"Expected an object that responds to dataUsingEncoding", nil];
  }
  if ((self = [self init])) {
    requestData = [[encodable dataUsingEncoding:encoding] copy];
    contentType = [@"text/plain" copy];
  }
  return self;
}


- (NSData *)dataForRequest
{
  return requestData;
}

- (NSString *)contentTypeForRequest
{
  return contentType;
}

@end

@implementation LRRestyFormEncodedPayload

- (id)initWithDictionary:(NSDictionary *)aDictionary;
{
  if ((self = [super init])) {
    dictionary = [aDictionary copy];
  }
  return self;
}


- (NSData *)dataForRequest
{
  return [[dictionary stringWithFormEncodedComponents] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)contentTypeForRequest
{
  return @"application/x-www-form-urlencoded";
}

@end



@implementation LRRestyRequestMultipartFormData


- (id) init{
  self = [super init];
  if(self) {
    parts = [NSMutableArray array];
    boundary = [self generateBoundaryWithLen:10];
  }
  
  return self;
}

- (void)addPart:(void (^)(LRRestyRequestMultipartPart *))block {
  LRRestyRequestMultipartPart *part = [[LRRestyRequestMultipartPart alloc] init];
  block(part);
  [parts addObject: part];
}

- (NSData*) dataForRequest {
  NSMutableData *data = [NSMutableData data];
  
  for(LRRestyRequestMultipartPart *part in parts) {
    if(part.contentType) {
      [data appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
      [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", part.name, part.fileName] dataUsingEncoding:NSUTF8StringEncoding]];
      [data appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", part.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
    } else {
      [data appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
      [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", part.name] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [data appendData: part.data];
    [data appendData: [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  }
  
  [data appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  
  return data;
}

- (NSString*) contentTypeForRequest {
  return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
}

- (NSString *) generateBoundaryWithLen: (NSInteger) len {
  NSString *letters = @"-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
  for (int i=0; i<len; i++) {
    [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
  }
  return randomString;
}

@end





@implementation LRRestyRequestMultipartPart

@synthesize contentType, name, fileName, data;

- (NSString *)contentDisposition
{
  NSMutableArray *components = [NSMutableArray array];
  [components addObject:@"form-data"];
  [components addObject:[NSString stringWithFormat:@"name=\"%@\"", name]];
  if (fileName) {
    [components addObject:[NSString stringWithFormat:@"filename=\"%@\"", fileName]];
  }
  return [components componentsJoinedByString:@"; "];
}

- (void)modifyRequest:(LRRestyRequest *)request
{

}

@end


