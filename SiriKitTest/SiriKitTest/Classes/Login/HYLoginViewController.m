//
//  HYLoginViewController.m
//  SiriKitTest
//
//  Created by 寰宇 on 2016/12/12.
//  Copyright © 2016年 maihaoche. All rights reserved.
//

#import "HYLoginViewController.h"
#import "AppDelegate.h"
#import "HYMainTabBarViewController.h"
#import "RCUserInfo+HYUserInfoTool.h"

@interface HYLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFiledAccount;


@end

@implementation HYLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)clickLoginBtn:(id)sender {
    
    [self.view endEditing:YES];
    
    [[RCIMClient sharedRCIMClient] connectWithToken:self.textFiledAccount.text success:^(NSString *userId) {
        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
        [HYLoginInfo share].token = self.textFiledAccount.text;
        [HYLoginInfo share].userId = userId;
        [[HYLoginInfo share] updateUser];
        
        HYMainTabBarViewController * mainTab = [HYMainTabBarViewController new];
        [UIApplication sharedApplication].keyWindow.rootViewController = mainTab;
    } error:^(RCConnectErrorCode status) {
        NSLog(@"登陆的错误码为:%li", status);
    } tokenIncorrect:^{
        NSLog(@"token错误");
    }];
}

@end
