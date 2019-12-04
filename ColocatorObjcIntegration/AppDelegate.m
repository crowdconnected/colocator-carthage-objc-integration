//
//  AppDelegate.m
//  ColocatorObjcIntegration
//
//  Created by TCode on 03/12/2019.
//  Copyright © 2019 CrowdConnected. All rights reserved.
//

#import "AppDelegate.h"

#import <CCLocation/CCLocation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [CCLocation.sharedInstance startWithApiKey:@"CC_APP_KEY" urlString:@"colocator.net:443/socket"];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    NSDictionary *params = [[launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"appsInfo"];
    if (params) {
      //Use params here
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSString * deviceTokenString = [[[[deviceToken description]
    stringByReplacingOccurrencesOfString: @"<" withString: @""]
   stringByReplacingOccurrencesOfString: @">" withString: @""]
  stringByReplacingOccurrencesOfString: @" " withString: @""];
  [CCLocation.sharedInstance addAliasWithKey:@"apns_user_id" value:deviceTokenString];
  NSLog(@"Sent device token %@", deviceTokenString);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"Failed to register for Remote Notidications %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  NSDictionary *apsInfo = [userInfo objectForKey:@"apsInfo"];
  NSString *source = [apsInfo objectForKey:@"source"];
  if ([source isEqualToString:@"colcoator"]) {
    [CCLocation.sharedInstance receivedSilentNotificationWithUserInfo:userInfo clientKey:@"CC_APP_KEY" completion:^(BOOL result) {}];
  }
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
