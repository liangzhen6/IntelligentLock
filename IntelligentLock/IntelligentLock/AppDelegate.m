//
//  AppDelegate.m
//  IntelligentLock
//
//  Created by liangzhen on 2018/9/9.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "AppDelegate.h"
#import "Socket.h"
#import <AFNetworking.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            //网络状态 改变 重新连接
            if ([[Socket shareSocket] socketConnectType] == connectingConnectType) {
                [[Socket shareSocket] setSocketConnectType:unConnectConnectType];
            }
            [[Socket shareSocket] connectServer];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [[Socket shareSocket] setAppIsAction:NO];
    //断开连接
    [[Socket shareSocket] closeConnectServer];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[Socket shareSocket] setAppIsAction:YES];
    //连接服务器
    [[Socket shareSocket] connectServer];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
