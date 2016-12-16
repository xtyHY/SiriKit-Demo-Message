//
//  RCUserInfo+HYUserInfoTool.m
//  SiriKitTest
//
//  Created by 寰宇 on 2016/12/14.
//  Copyright © 2016年 maihaoche. All rights reserved.
//

#import "RCUserInfo+HYUserInfoTool.h"

@implementation RCUserInfo (HYUserInfoTool)

+ (RCUserInfo *)userInfoModelByUserId:(NSString *)userId{
    
    for (RCUserInfo *userInfo in [self userInfos]) {
        if ([userInfo.userId isEqualToString:userId]) {
            return userInfo;
        }
    }
    
    return nil;
}

+ (NSArray<RCUserInfo *> *)userInfos{
    
    static NSArray<RCUserInfo *> *userInfos;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userInfos = [RCUserInfo mj_objectArrayWithFilename:@"NameData.plist"];
    });
    
    return userInfos;
}

@end
