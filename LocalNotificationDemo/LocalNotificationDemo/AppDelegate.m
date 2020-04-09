//
//  AppDelegate.m
//  LocalNotificationDemo
//
//  Created by 谌靖松 on 2020/4/9.
//  Copyright © 2020 谌靖松. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //注册消息推送
    [self p_registerForUserNotificationHandler:application];
    
    return YES;
}

- (void)p_registerForUserNotificationHandler:(UIApplication *)application{
    if (@available(iOS 10.0,*)) {
        //iOS10特有
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // 必须写代理，不然无法监听通知的接收与点击
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // 点击允许
                NSLog(@"requestAuthorization成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"getNotificationSettings :: %@", settings);
                }];
            } else {
                // 点击不允许
                NSLog(@"requestAuthorization失败");
            }
        }];
    }else{
        //iOS8 - iOS10
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
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

#pragma mark - ios 8 - 10 收到通知。
- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {// app位于前台通知
        NSLog(@"前台本地通知，didReceiveLocalNotification");
    }else{
        NSLog(@"后台本地通知，didReceiveLocalNotification");
    }
}

#pragma mark - ios >= 10 收到通知。
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(nonnull UNNotification *)notification withCompletionHandler:(nonnull void (^)(UNNotificationPresentationOptions))completionHandler __IOS_AVAILABLE(10.0) {
    NSDictionary * userInfo = notification.request.content.userInfo;
    if (userInfo) {
    NSLog(@"app位于前台通知(willPresentNotification:):%@", userInfo);
    }
    //前台显示通知消息 仅支持10以后。
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
//    completionHandler(UNNotificationPresentationOptionNone);

}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler __IOS_AVAILABLE(10.0) {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if (userInfo) {
    NSLog(@"app位于后台通知 点击通知触发 (didReceiveNotificationResponse:):%@,", userInfo);
        if ([userInfo[@"id"] isEqualToString:@"LOCAL_NOTIFY_SCHEDULE_ID"]) {
            NSLog(@"收到了指定通知 做出特定处理");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"acceptLocalNotification" object:nil];
        }
        //如果设置了badge值 需要清除。
    }
    
    completionHandler();
}

@end
