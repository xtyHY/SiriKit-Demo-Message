//
//  HYMainTabBarViewController.m
//  SiriKitTest
//
//  Created by 寰宇 on 2016/12/13.
//  Copyright © 2016年 maihaoche. All rights reserved.
//

#import "HYMainTabBarViewController.h"
#import "HYSettingViewController.h"
#import "HYRecentChatViewController.h"

@interface HYMainTabBarViewController ()

@end

@implementation HYMainTabBarViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        HYRecentChatViewController *v1 = [HYRecentChatViewController new];
        HYSettingViewController    *v3 = [HYSettingViewController new];
        
        v1.title = @"聊天";
        v3.title = @"设置";
        
        UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:v1];
        UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:v3];
        self.viewControllers = @[nav1, nav3];
        
        NSString *groupPath = [[NSFileManager alloc] containerURLForSecurityApplicationGroupIdentifier:@"group.com.maihaoche.SiriKitTest"].path;
        NSString *bundlePath = [NSBundle mainBundle].bundlePath;
        NSString *sandyPath = NSHomeDirectory();
        NSLog(@"groupPath: %@ \n bundlePath: %@ \n sandyPath: %@", groupPath, bundlePath, sandyPath);
        
        
        RCUserInfo *userInfo = [RCUserInfo userInfoModelByUserId:[HYLoginInfo share].userId];
        
        //更好的是用md5将头像url转成字符串，可以处理同一个用户换头像了，这里省事就没这样处理
        NSLog(@"--------%@", GroupPath);
        NSString *fromIconPath = [GroupPath stringByAppendingPathComponent:[NSString stringWithFormat:@"fromIcon_%@",userInfo.userId]];
        NSLog(@"--------%@", fromIconPath);
        
        //没有头像地址或者这个用户的头像已经下载过了，就不再下载了
        if (userInfo.portraitUri.length && ![NSData dataWithContentsOfFile:fromIconPath]) {
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:userInfo.portraitUri] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
                NSLog(@"----%@ %@ %@",image,imageURL, error);
                
                [UIImagePNGRepresentation(image) writeToFile:fromIconPath atomically:NO];
            }];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
