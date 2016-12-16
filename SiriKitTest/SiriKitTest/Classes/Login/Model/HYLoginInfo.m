//
//  HYLoginInfo.m
//  SiriKitTest
//
//  Created by 寰宇 on 2016/12/13.
//  Copyright © 2016年 maihaoche. All rights reserved.
//

#import "HYLoginInfo.h"
#import "SiriKitTest-Prefix.h"

@implementation HYLoginInfo

+ (instancetype)share{
    
    static HYLoginInfo *info;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        info = [[HYLoginInfo alloc] init];
        info.token = [[[NSUserDefaults alloc] initWithSuiteName:SuitName] valueForKey:@"token"];
        info.userId = [[[NSUserDefaults alloc] initWithSuiteName:SuitName] valueForKey:@"userId"];
    });
    
    return info;
}

- (void)updateUser {
    
    [[[NSUserDefaults alloc] initWithSuiteName:SuitName] setValue:self.token forKey:@"token"];
    [[[NSUserDefaults alloc] initWithSuiteName:SuitName] setValue:self.userId forKey:@"userId"];
}

- (void)removeUser {
    
    [[[NSUserDefaults alloc] initWithSuiteName:SuitName] removeObjectForKey:@"token"];
    [[[NSUserDefaults alloc] initWithSuiteName:SuitName] removeObjectForKey:@"userId"];
    self.token = nil;
    self.userId = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLogout" object:nil];
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"%@ %@", self.token, self.userId];
}

@end
