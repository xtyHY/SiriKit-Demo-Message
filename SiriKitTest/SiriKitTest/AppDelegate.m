//
//  AppDelegate.m
//  SiriKitTest
//
//  Created by 寰宇 on 2016/12/12.
//  Copyright © 2016年 maihaoche. All rights reserved.
//

#import "AppDelegate.h"
#import "HYLoginViewController.h"
#import "HYMainTabBarViewController.h"
#import "RCUserInfo+HYUserInfoTool.h"

@interface AppDelegate ()<RCIMUserInfoDataSource>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLogin) name:@"UserLogout" object:nil];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor    = [UIColor whiteColor];
    self.window.rootViewController = [UIViewController alloc];
    [self.window makeKeyAndVisible];
    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
    [[RCIMClient sharedRCIMClient] initWithAppKey:Appkey];
    
    if (![HYLoginInfo share].token){
        [self showLogin];
        return YES;
    }
    
    [[RCIM sharedRCIM] setUserInfoDataSource:self];
    [[RCIMClient sharedRCIMClient] connectWithToken:[HYLoginInfo share].token success:^(NSString *userId) {
        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
        HYMainTabBarViewController * mainTab = [HYMainTabBarViewController new];
        self.window.rootViewController = mainTab;
        [self.window makeKeyAndVisible];
        
        RCUserInfo *info = [RCIMClient sharedRCIMClient].currentUserInfo;
        NSLog(@"%@",info);
    } error:^(RCConnectErrorCode status) {
        
        [self showLogin];
        NSLog(@"登陆的错误码为:%li", status);
    } tokenIncorrect:^{
        
        [self showLogin];
        NSLog(@"token错误");
    }];
    
    return YES;
}

- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion{
    
    completion([RCUserInfo userInfoModelByUserId:userId]);
}

- (void)showLogin {
    
    HYLoginViewController *vc = [HYLoginViewController new];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:vc];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
