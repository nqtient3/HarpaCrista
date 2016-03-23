//
//  FavoritosViewController.h
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.

#import "BaseApi.h"
#import "LRResty.h"
#import "NSDictionary+Json.h"
#import "NSArray+Json.h"
#import "LRRestyResponse+Json.h"
#import <Foundation/Foundation.h>
#import "Constants.h"

@implementation NSDictionary (Utility)


@end


@implementation BaseApi {
    LRRestyClient *client_;
    NSString *csrf_;
}

+ (BaseApi*) client {
    static BaseApi *staticInstance = nil;
    if(!staticInstance) {
        staticInstance = [[BaseApi alloc] init];
    }
    return  staticInstance;
}

- (id) init {
    self = [super init];
    if(self) {
        client_ = [LRResty client];
        [client_ setHandlesCookiesAutomatically: YES];
        [LRResty setDebugLoggingEnabled: YES];
        __block BaseApi* this = self;
        [client_ setGlobalTimeout:60.0 handleWithBlock:^(LRRestyRequest *client) {
            [this handleRequestTimeout];
        }];
        
    }
    return self;
}

- (void) cancelAllRequests {
    [client_ cancelAllRequests];
}


#pragma mark - Post

- (void) postJSON: (id)object
          headers: (NSDictionary*) header
            toUri: (NSString*) uri
        onSuccess: (ResponseSuccessBlock)successBlock
          onError: (ResponseFailBlock)errorBlock {
    
    JSONObject *json;
    if([object isKindOfClass:[NSString class]]) {
        json = [[JSONObject alloc] initWithJSONString:object];
    } else if ([object isKindOfClass:[NSDictionary class]]){
        json = [[JSONObject alloc] initWithDictionary:object];
    } else if([object isKindOfClass:[NSArray class]]) {
        json = [[JSONObject alloc] initWithArray:object];
    }
    
    NSString *url = [self urlStringFromUri: uri];
    [client_ post:url
          payload:json
     //headers:nil
          headers:header
        withBlock:^(LRRestyResponse *response) {
            
            if(response.status == 200 ||            // Status OK
               response.status == 201 ||            // Status
               response.status == 202               // Status Accepted
               ) {
                id data = nil;
                data = [response asJSONObject];
                
                successBlock(data, response.headers);
            } else {
                NSError *error = nil;
                error = [self generateErrorWithCode:response.status description: response.asString];
                errorBlock(response.status, error);
            }
        }];
}

#pragma mark - Get

- (void) getJSON: (id)object
         headers: (NSDictionary*) header
           toUri: (NSString*) uri
       onSuccess: (ResponseSuccessBlock)successBlock
         onError: (ResponseFailBlock)errorBlock {
    JSONObject *json;
    if([object isKindOfClass:[NSString class]]) {
        json = [[JSONObject alloc] initWithJSONString:object];
    } else if ([object isKindOfClass:[NSDictionary class]]){
        json = [[JSONObject alloc] initWithDictionary:object];
    } else if([object isKindOfClass:[NSArray class]]) {
        json = [[JSONObject alloc] initWithArray:object];
    }

    //NSDictionary *headers = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
  
    NSString *url = [self urlStringFromUri: uri];
    
    NSLog(@"url = %@",url);

    [client_ get:url
      parameters:object
         headers:header
       withBlock:^(LRRestyResponse *response) {
           
           if(response.status == 200) {
               id data = nil;
               data = [response asJSONObject];
               successBlock(data, response.headers);
           } else {
               NSError *error = nil;
               error = [self generateErrorWithCode:response.status description: response.asString];
               NSLog(@"error = %@",error);
               errorBlock(response.status, error);
           }
       }];
}

- (NSString*) urlStringFromUri: (NSString*) uri {
    uri = [uri stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    if ([uri hasPrefix:@"http:"] || [uri hasPrefix:@"https:"] ) {
        return uri;
    } else if([uri hasPrefix:@"/"]) {
        NSString *url = [NSString stringWithFormat:@"%@%@", self.server, uri];
        return url;
    } else {
        
        NSString *url = [NSString stringWithFormat:@"%@/%@", self.server, uri];
        return url;
    }
    
}

- (NSError*) generateErrorWithCode: (NSInteger) code description: (NSString*) description {
    NSError *anError;
    // Create and return the custom domain error.
    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : description };
    
    anError = [[NSError alloc] initWithDomain: NSUnderlyingErrorKey
                                         code: code
                                     userInfo: errorDictionary];
    return anError;
}

- (void) handleRequestTimeout {
    [self showAlertView];
}

- (void) showAlertView {
    if(!_alert){
        _alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request timeout" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    } else {
        if(!_alert.visible)
            [_alert show];
    }
}


@end
