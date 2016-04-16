//
//  AppDelegate.m
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTabbarController.h"
#import "Constants.h"
#import "TutorialViewController.h"

#define GOOGLE_ANALYTICS_TRACKING_ID @"UA-64354435-1"
//#define GOOGLE_ANALYTICS_TRACKING_ID @"UA-76493241-1"

#define PUSH_NOTIFICATION_APP_ID @"a97ee6a1-abf5-4206-b311-09bb350b1e85"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Setup Google Analytics
    [self startGoogleAnalyticsTracking];
    [self performSelector:@selector(sendGoogleAnalyticsStartup) withObject:nil afterDelay:3];
    
    // Setup Push Notification service
    self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions appId:PUSH_NOTIFICATION_APP_ID handleNotification:^(NSString* message, NSDictionary* additionalData, BOOL isActive) {
        // This function gets call when a notification is tapped on or one is received while the app is in focus.
        NSString* messageTitle = @"Harpa Crista";
        NSString* fullMessage = [message copy];
        
        if (additionalData) {
            if (additionalData[@"inAppTitle"])
                messageTitle = additionalData[@"inAppTitle"];
            
            if (additionalData[@"actionSelected"])
                fullMessage = [fullMessage stringByAppendingString:[NSString stringWithFormat:@"\nPressed ButtonId:%@", additionalData[@"actionSelected"]]];
        }
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:messageTitle
                                                            message:fullMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }];
    
    // create a standardUserDefaults variable
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *isLoadTutorial = [standardUserDefaults objectForKey:keyLoadTutorial];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([isLoadTutorial boolValue]) {
        MainTabbarController *mainTabbarController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabbarController"];
        self.window.rootViewController = mainTabbarController;
    } else {
        TutorialViewController *tutorialViewController = [storyboard instantiateViewControllerWithIdentifier:@"tutorialViewController"];
        self.window.rootViewController = tutorialViewController;
    }
    
    // synchronize the settings
    [standardUserDefaults synchronize];    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [self performSelector:@selector(stopGoogleAnalyticsTracking) withObject:nil afterDelay:3];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self performSelector:@selector(stopGoogleAnalyticsTracking) withObject:nil afterDelay:3];
    
    [self saveContext];
}

#define mark - Google Analytics
- (void)startGoogleAnalyticsTracking {
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].dispatchInterval = 10;
    self.googleAnalyticsTracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_ANALYTICS_TRACKING_ID];
}

- (void)sendGoogleAnalyticsStartup {
    [self.googleAnalyticsTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Application Events" action:@"Open the app" label:@"Tracking Starts" value:nil] build]];
}

- (void)stopGoogleAnalyticsTracking {
    [self.googleAnalyticsTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Application Events" action:@"Close the app" label:@"Tracking Suspended /Stopped" value:nil] build]];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "gcs.HarpaCrista" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HarpaCrista" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"HarpaCrista.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
