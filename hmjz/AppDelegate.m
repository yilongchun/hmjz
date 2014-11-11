//
//  AppDelegate.m
//  hmjz
//
//  Created by yons on 14-10-22.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
    [vc setNavigationBarHidden:YES];
//    UIViewController *vc = [[LoginViewController alloc] init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    }
    
    
    
//    [self registerRemoteNotification];
//    
//#warning SDK注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
//    NSString *apnsCertName = nil;
//#if DEBUG
//    apnsCertName = @"chatdemoui_dev";
//#else
//    apnsCertName = @"chatdemoui";
//#endif
//    [[EaseMob sharedInstance] registerSDKWithAppKey:@"whhm918#hmjyt" apnsCertName:apnsCertName];
//    
//#if DEBUG
//    [[EaseMob sharedInstance] enableUncaughtExceptionHandler];
//#endif
//    [[[EaseMob sharedInstance] chatManager] setAutoFetchBuddyList:YES];
//    
//    //以下一行代码的方法里实现了自动登录，异步登录，需要监听[didLoginWithInfo: error:]
//    //demo中此监听方法在MainViewController中
//    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
//    
//    //注册为SDK的ChatManager的delegate (及时监听到申请和通知)
//    [[EaseMob sharedInstance].chatManager removeDelegate:self];
//    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
//
//    
//    
//    [self loginStateChange:nil];
    

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
}

////系统方法
//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
//    //SDK调用
//    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
//}
//
////系统方法
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//{
//    //SDK方法调用
//    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册推送失败"
//                                                    message:error.description
//                                                   delegate:nil
//                                          cancelButtonTitle:@"确定"
//                                          otherButtonTitles:nil];
//    [alert show];
//}
//
////系统方法
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    //SDK方法调用
//    [[EaseMob sharedInstance] application:application didReceiveRemoteNotification:userInfo];
//}
////系统方法
//- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
//{
//    //SDK方法调用
//    [[EaseMob sharedInstance] application:application didReceiveLocalNotification:notification];
//}
//
//
//- (void)registerRemoteNotification{
//#if !TARGET_IPHONE_SIMULATOR
//    UIApplication *application = [UIApplication sharedApplication];
//    
//    //iOS8 注册APNS
//    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
//        [application registerForRemoteNotifications];
//        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
//        [application registerUserNotificationSettings:settings];
//    }else{
//        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
//        UIRemoteNotificationTypeSound |
//        UIRemoteNotificationTypeAlert;
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
//    }
//    
//#endif
//}
//
//#pragma mark - private
//
//-(void)loginStateChange:(NSNotification *)notification
//{
//    UINavigationController *nav = nil;
//    
//    BOOL isAutoLogin = [[[EaseMob sharedInstance] chatManager] isAutoLoginEnabled];
//    BOOL loginSuccess = [notification.object boolValue];
//    
//    if (isAutoLogin || loginSuccess) {
//        [[ApplyViewController shareController] loadDataSourceFromLocalDB];
//        if (_mainController == nil) {
//            _mainController = [[MainViewController alloc] init];
//            nav = [[UINavigationController alloc] initWithRootViewController:_mainController];
//        }else{
//            nav  = _mainController.navigationController;
//        }
//    }else{
//        _mainController = nil;
//        LoginViewController *loginController = [[LoginViewController alloc] init];
//        nav = [[UINavigationController alloc] initWithRootViewController:loginController];
//        loginController.title = @"环信Demo";
//    }
//    
//    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0){
//        nav.navigationBar.barStyle = UIBarStyleDefault;
//        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"titleBar"]
//                                forBarMetrics:UIBarMetricsDefault];
//        
//        [nav.navigationBar.layer setMasksToBounds:YES];
//    }
//    
//    self.window.rootViewController = nav;
//    
//    [nav setNavigationBarHidden:YES];
//    [nav setNavigationBarHidden:NO];
//}


@end
