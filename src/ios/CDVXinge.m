#import "CDVXinge.h"

NSString *XG_ACCESS_ID = @"xg_access_id";
NSString *XG_ACCESS_KEY = @"xg_access_key";

@interface CDVXinge ()<XGPushDelegate>
@end

@implementation CDVXinge

- (void)pluginInitialize {
    self.xgAccessID = [[[self.commandDelegate settings] objectForKey:XG_ACCESS_ID] unsignedIntValue];
    self.xgAccessKey = [[self.commandDelegate settings] objectForKey:XG_ACCESS_KEY];
}

- (void)registerDevice:(CDVInvokedUrlCommand *)command {
    [[XGPush defaultManager] startXGWithAppID:self.xgAccessID appKey:self.xgAccessKey delegate:self];
    [[XGPush defaultManager] setXgApplicationBadgeNumber:0];
    [[XGPush defaultManager] setBadge:0];
}

- (void)bindAccount:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:(true)];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)unbindAccount:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:(true)];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark - XGPushDelegate
- (void)xgPushDidFinishStart:(BOOL)isSuccess error:(NSError *)error {
    NSLog(@"[CDVXinge] 启动信鸽服务%@", (isSuccess?@"成功":@"失败"));
}

- (void)xgPushDidFinishStop:(BOOL)isSuccess error:(NSError *)error {
    NSLog(@"[CDVXinge] 注销信鸽服务%@", (isSuccess?@"成功":@"失败"));
}

- (void)xgPushDidRegisteredDeviceToken:(NSString *)deviceToken error:(NSError *)error {
    NSLog(@"[CDVXinge] 注册信鸽%@, token %@, error %@", (error?@"失败":@"成功"), deviceToken, error);
}

// iOS 10 新增 API
// iOS 10 会走新 API, iOS 10 以前会走到老 API
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// App 用户点击通知
// App 用户选择通知中的行为
// App 用户在通知中心清除消息
// 无论本地推送还是远程推送都会走这个回调
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"[CDVXinge] click notification");

    NSInteger number = [[XGPush defaultManager] xgApplicationBadgeNumber];
    [[XGPush defaultManager] setXgApplicationBadgeNumber:number - 1];
    [[XGPush defaultManager] setBadge:number - 1];
    [[XGPush defaultManager] reportXGNotificationResponse:response];

    completionHandler();
}

// App 在前台弹通知需要调用这个接口
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    [[XGPush defaultManager] reportXGNotificationInfo:notification.request.content.userInfo];
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}
#endif

- (void)xgPushDidReceiveRemoteNotification:(id)notification withCompletionHandler:(void (^)(NSUInteger))completionHandler {
    if ([notification isKindOfClass:[NSDictionary class]]) {
        completionHandler(UIBackgroundFetchResultNewData);
    } else if ([notification isKindOfClass:[UNNotification class]]) {
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    }
}

- (void)xgPushDidSetBadge:(BOOL)isSuccess error:(NSError *)error {
    NSLog(@"[CDVXinge] 设置应用角标%@, error %@", (isSuccess?@"成功":@"失败"), error);
}

@end