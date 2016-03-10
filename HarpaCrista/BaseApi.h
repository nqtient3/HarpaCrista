//
//  FavoritosViewController.h
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.

#import <Foundation/Foundation.h>
#import "JSONObject.h"
#import "Constants.h"

typedef void (^ResponseSuccessBlock)(id data, id header);
typedef void (^ResponseSuccessBlockIndex)(id data, id header, int index);
typedef void (^ResponseFailBlock)(NSInteger code, NSError * error);

@interface NSDictionary (Utility)

@end

#import <UIKit/UIKit.h>

@interface BaseApi : NSObject
@property (nonatomic, copy) NSString *server;
@property (nonatomic, copy) NSString *csrf;

@property (nonatomic) NSString *apiKey;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, assign) int index_;

+ (BaseApi*) client;

- (NSString*) urlStringFromUri: (NSString*) uri;

- (void) postJSON: (id)object
          headers: (NSDictionary*) header
            toUri: (NSString*) uri
        onSuccess: (ResponseSuccessBlock) success
          onError: (ResponseFailBlock) error;

- (void) getJSON: (id)object
         headers: (NSDictionary*) header
           toUri: (NSString*) uri
       onSuccess: (ResponseSuccessBlock) success
         onError: (ResponseFailBlock) error;


- (void) cancelAllRequests;


@end
