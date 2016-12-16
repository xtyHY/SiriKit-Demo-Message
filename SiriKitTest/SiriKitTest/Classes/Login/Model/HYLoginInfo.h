//
//  HYLoginInfo.h
//  SiriKitTest
//
//  Created by 寰宇 on 2016/12/13.
//  Copyright © 2016年 maihaoche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYLoginInfo : NSObject

+ (instancetype)share;

- (void)updateUser;
- (void)removeUser;

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *userId;

@end
