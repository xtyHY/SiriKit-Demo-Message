//
//  RCUserInfo+HYUserInfoTool.h
//  SiriKitTest
//
//  Created by 寰宇 on 2016/12/14.
//  Copyright © 2016年 maihaoche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RCUserInfo.h>
#import <MJExtension/MJExtension.h>

@interface RCUserInfo (HYUserInfoTool)

+ (RCUserInfo *)userInfoModelByUserId:(NSString *)userId;
+ (NSArray<RCUserInfo *> *)userInfos;

@end
