//
//  SiriKitTest-Prefix.h
//  SiriKitTest
//
//  Created by 寰宇 on 2016/12/12.
//  Copyright © 2016年 maihaoche. All rights reserved.
//

#ifndef SiriKitTest_Prefix_h
#define SiriKitTest_Prefix_h

#endif /* SiriKitTest_Prefix_h */

#import "HYLoginInfo.h"
#import "RCUserInfo+HYUserInfoTool.h"
#import <UIImageView+WebCache.h>
#import <RongIMLib/RongIMLib.h>
#import <RongIMKit/RongIMKit.h>

#define NSLog(format, ...) \
do { \
printf("\n<%s : %d : %s>-: %s", \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], \
__LINE__, \
__FUNCTION__, \
[[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]); \
} while(0)

#define Appkey @"y745wfm8yokxv"
#define SuitName @"group.com.maihaoche.SiriKitTest"
#define GroupPath [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:SuitName].path
