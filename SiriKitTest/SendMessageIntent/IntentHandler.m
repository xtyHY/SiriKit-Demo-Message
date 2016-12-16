//
//  IntentHandler.m
//  SendMessageIntent
//
//  Created by 寰宇 on 2016/12/13.
//  Copyright © 2016年 maihaoche. All rights reserved.
//

#import "IntentHandler.h"
#import "SiriKitTest-Prefix.h"

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

@interface IntentHandler () <INSendMessageIntentHandling, INSearchForMessagesIntentHandling, INSetMessageAttributeIntentHandling>

@end

@implementation IntentHandler

- (id)handlerForIntent:(INIntent *)intent {
    // This is the default implementation.  If you want different objects to handle different intents,
    // you can override this and return the handler you want for that particular intent.
    
    // 根据intent类型来匹配一个合适的intet对象（一个IntentHandler可以用来处理多个intet，也可以单个）
    if ([intent isKindOfClass:[INSendMessageIntent class]] ||
        [intent isKindOfClass:[INSearchForMessagesIntent class]] ||
        [intent isKindOfClass:[INSetMessageAttributeIntent class]]) {
        //我这里是一个处理SMS相关Intent Domain的，其实可以拆成一个一个的
        return self;
    } else {
        //发送别的intet对象
        return nil;
    }
    
    return self;
}

#pragma mark - INSendMessageIntentHandling 发送信息意图的解决方法实现
#pragma mark 实现1->匹配联系人
// Implement resolution methods to provide additional information about your intent (optional).
- (void)resolveRecipientsForSendMessage:(INSendMessageIntent *)intent withCompletion:(void (^)(NSArray<INPersonResolutionResult *> *resolutionResults))completion {
    
    NSArray<INPerson *> *recipients = intent.recipients;
    // If no recipients were provided we'll need to prompt for a value.
    if (recipients.count == 0) {
        completion(@[[INPersonResolutionResult needsValue]]);
        return;
    }
    NSMutableArray<INPersonResolutionResult *> *resolutionResults = [NSMutableArray array];
    
    // 根据用户说的发送对象来匹配一个INPerson，很有可能是根据通讯录来的，暂时不知如何获取原文= =
    NSMutableArray<INPerson *> *matchingContacts = [NSMutableArray array];
    for (INPerson *recipient in recipients) {
        NSLog(@"resolveRecipient: %@", recipient.displayName);
        
        //主要看匹配的算法了
        for (RCUserInfo *userInfo in [RCUserInfo userInfos]) {
            //匹配相似
            if ([userInfo.name containsString:recipient.displayName] || [recipient.displayName containsString:userInfo.name]) {
                INPerson *samePerson = [[INPerson alloc] initWithPersonHandle:[[INPersonHandle alloc] initWithValue:userInfo.userId type:INPersonHandleTypePhoneNumber] nameComponents:nil displayName:userInfo.name image:[INImage imageWithURL:[NSURL URLWithString:userInfo.portraitUri]] contactIdentifier:nil customIdentifier:nil aliases:nil suggestionType:INPersonSuggestionTypeSocialProfile];
                [matchingContacts addObject:samePerson];
            }
            //匹配相同
//            if ([userInfo.name isEqualToString:recipient.displayName]) {
//                [matchingContacts addObject:recipient];
//            }
        }
        
        if (matchingContacts.count > 1) {
            // We need Siri's help to ask user to pick one from the matches.
            [resolutionResults addObject:[INPersonResolutionResult disambiguationWithPeopleToDisambiguate:matchingContacts]];

        } else if (matchingContacts.count == 1) {
            // We have exactly one matching contact
            INPerson *person = matchingContacts.lastObject;
            [resolutionResults addObject:[INPersonResolutionResult successWithResolvedPerson:person]];
            
        } else {
            // We have no contacts matching the description provided
            [resolutionResults addObject:[INPersonResolutionResult unsupported]];
        }
    }
    completion(resolutionResults);
}

#pragma mark 实现2->确定要发送的消息
- (void)resolveContentForSendMessage:(INSendMessageIntent *)intent withCompletion:(void (^)(INStringResolutionResult *resolutionResult))completion {
    NSString *text = intent.content;
    
    if (text && ![text isEqualToString:@""]) {
        completion([INStringResolutionResult successWithResolvedString:text]);
    } else {
        completion([INStringResolutionResult needsValue]);
    }
}

#pragma mark 实现3->确定发送消息？可选
// Once resolution is completed, perform validation on the intent and provide confirmation (optional).
- (void)confirmSendMessage:(INSendMessageIntent *)intent completion:(void (^)(INSendMessageIntentResponse *response))completion {
    // Verify user is authenticated and your app is ready to send a message.
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
    INSendMessageIntentResponse *response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeReady userActivity:userActivity];
    completion(response);
}

#pragma mark 实现3->发送消息(必须实现)
// Handle the completed intent (required).
- (void)handleSendMessage:(INSendMessageIntent *)intent completion:(void (^)(INSendMessageIntentResponse *response))completion {
    // Implement your application logic to send a message here.
    
    NSString *token =[HYLoginInfo share].token;
    [[RCIMClient sharedRCIMClient] initWithAppKey:Appkey];
    [[RCIMClient sharedRCIMClient] connectWithToken:token success:^(NSString *userId) {
        
        NSString *toId = intent.recipients.lastObject.personHandle.value;
        NSString *toText = intent.content;
        
        RCTextMessage *content = [RCTextMessage messageWithContent:toText];
        content.senderUserInfo = [[RCUserInfo alloc] initWithUserId:userId name:nil portrait:nil];
        
        NSLog(@"发送人: %@, 接收人: %@, 内容: %@", userId, toId, toText);
        
        [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:toId content:content pushContent:nil pushData:nil success:^(long messageId) {
            NSLog(@"成功messageid%ld",messageId);
            NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
            INSendMessageIntentResponse *response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeSuccess userActivity:userActivity];
            completion(response);
        } error:^(RCErrorCode nErrorCode, long messageId) {
            NSLog(@"发送失败");
            NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
            userActivity.userInfo = @{@"failure" : [NSString stringWithFormat:@"发送失败%ld",nErrorCode]};
            INSendMessageIntentResponse *response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeFailure userActivity:userActivity];
            completion(response);
        }];
    } error:^(RCConnectErrorCode status) {
        NSLog(@"登陆的错误码为:%li", status);
        NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
        userActivity.userInfo = @{@"failure" : [NSString stringWithFormat:@"登录失败%ld",status]};
        INSendMessageIntentResponse *response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeFailure userActivity:userActivity];
        completion(response);
    } tokenIncorrect:^{
        NSLog(@"token错误");
        NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
        userActivity.userInfo = @{@"failure" : [NSString stringWithFormat:@"token不对"]};
        INSendMessageIntentResponse *response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeFailure userActivity:userActivity];
        completion(response);
    }];
}

#pragma mark - INSearchForMessagesIntentHandling 搜索信息
// Implement handlers for each intent you wish to handle.  As an example for messages, you may wish to also handle searchForMessages and setMessageAttributes.
- (void)handleSearchForMessages:(INSearchForMessagesIntent *)intent completion:(void (^)(INSearchForMessagesIntentResponse *response))completion {
    // Implement your application logic to find a message that matches the information in the intent.
    
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSearchForMessagesIntent class])];
    INSearchForMessagesIntentResponse *response = [[INSearchForMessagesIntentResponse alloc] initWithCode:INSearchForMessagesIntentResponseCodeSuccess userActivity:userActivity];
    // Initialize with found message's attributes
    response.messages = @[[[INMessage alloc]
        initWithIdentifier:@"identifier"
        content:@"I am so excited about SiriKit!"
        dateSent:[NSDate date]
        sender:[[INPerson alloc] initWithPersonHandle:[[INPersonHandle alloc] initWithValue:@"sarah@example.com" type:INPersonHandleTypeEmailAddress] nameComponents:nil displayName:@"Sarah" image:nil contactIdentifier:nil customIdentifier:nil]
        recipients:@[[[INPerson alloc] initWithPersonHandle:[[INPersonHandle alloc] initWithValue:@"+1-415-555-5555" type:INPersonHandleTypePhoneNumber] nameComponents:nil displayName:@"John" image:nil contactIdentifier:nil customIdentifier:nil]]
    ]];
    completion(response);
}

#pragma mark - INSetMessageAttributeIntentHandling 发送附件短信
- (void)handleSetMessageAttribute:(INSetMessageAttributeIntent *)intent completion:(void (^)(INSetMessageAttributeIntentResponse *response))completion {
    // Implement your application logic to set the message attribute here.
    
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSetMessageAttributeIntent class])];
    INSetMessageAttributeIntentResponse *response = [[INSetMessageAttributeIntentResponse alloc] initWithCode:INSetMessageAttributeIntentResponseCodeSuccess userActivity:userActivity];
    completion(response);
}

@end
