//
//  HYRecentChatViewController.m
//  SiriKitTest
//
//  Created by 寰宇 on 2016/12/13.
//  Copyright © 2016年 maihaoche. All rights reserved.
//

#import "HYRecentChatViewController.h"
#import "HYFirendsCell.h"
#import "RCUserInfo+HYUserInfoTool.h"

@interface HYRecentChatViewController ()

@end

@implementation HYRecentChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置需要显示哪些类型的会话
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),
                                        @(ConversationType_DISCUSSION),
                                        @(ConversationType_CHATROOM),
                                        @(ConversationType_GROUP),
                                        @(ConversationType_APPSERVICE),
                                        @(ConversationType_SYSTEM)]];
    //设置需要将哪些类型的会话在会话列表中聚合显示
    [self setCollectionConversationType:@[@(ConversationType_DISCUSSION),
                                          @(ConversationType_GROUP)]];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    for (RCUserInfo *info in [RCUserInfo userInfos]) {
        [[RCIM sharedRCIM] refreshUserInfoCache:info withUserId:info.userId];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//重写RCConversationListViewController的onSelectedTableRow事件
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
    RCConversationViewController *conversationVC = [[RCConversationViewController alloc]init];
    conversationVC.conversationType = model.conversationType;
    conversationVC.targetId = model.targetId;
    conversationVC.title = model.senderUserId;
    conversationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:conversationVC animated:YES];
}

@end
