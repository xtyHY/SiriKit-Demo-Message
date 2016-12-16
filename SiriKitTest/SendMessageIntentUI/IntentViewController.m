//
//  IntentViewController.m
//  SendMessageIntentUI
//
//  Created by 寰宇 on 2016/12/13.
//  Copyright © 2016年 maihaoche. All rights reserved.
//

#import "IntentViewController.h"
#import <Intents/Intents.h>
#import "SiriKitTest-Prefix.h"

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

@interface IntentViewController ()

@property (weak, nonatomic) IBOutlet UILabel *fromLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *toNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fromIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *fromMessage;
@property (weak, nonatomic) IBOutlet UIImageView *fromMessageBG;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation IntentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //测试路径与Host app是否一致
    NSString *groupPath = [[NSFileManager alloc] containerURLForSecurityApplicationGroupIdentifier:SuitName].path;
    NSString *bundlePath = [NSBundle mainBundle].bundlePath;
    NSString *sandyPath = NSHomeDirectory();
    NSLog(@"groupPath: %@ \n bundlePath: %@ \n sandyPath: %@", groupPath, bundlePath, sandyPath);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - INUIHostedViewControlling
// 准备界面
// Prepare your view controller for the interaction to handle.
- (void)configureWithInteraction:(INInteraction *)interaction context:(INUIHostedViewContext)context completion:(void (^)(CGSize))completion {
    // Do configuration here, including preparing views and calculating a desired size for presentation.
    
    self.errorView.hidden = YES;
//    INIntentHandlingStatusUnspecified = 0,
//    INIntentHandlingStatusReady,
//    INIntentHandlingStatusInProgress,
//    INIntentHandlingStatusSuccess,
//    INIntentHandlingStatusFailure,
//    INIntentHandlingStatusDeferredToApplication,
    
//    if (interaction.intentHandlingStatus == INIntentHandlingStatusSuccess) {
//        <#statements#>
//    }
    //使用T发送消息 --0（没有值，没有对应的联系人---resovle阶段）
    //使用T发小给xx说xxxx --1（消息有内容，找到了对应的联系人，或者说取消，---对应cofrim阶段）
    //确定发送--3（其实是对应的--handle阶段）
    NSLog(@"handle status: %ld", interaction.intentHandlingStatus);

    // 显示头像
    NSString *fromIconPath = [GroupPath stringByAppendingPathComponent:[NSString stringWithFormat:@"fromIcon_%@",[HYLoginInfo share].userId]];
    self.fromIconImageView.backgroundColor = [UIColor redColor];
    
    NSData *data = [NSData dataWithContentsOfFile:fromIconPath];
    UIImage *image = [UIImage imageWithData:data];
    self.fromIconImageView.image = image;
    self.fromIconImageView.layer.cornerRadius = self.fromIconImageView.frame.size.height;
    
    // 显示消息
    INSendMessageIntent *intent;
    
    if ([interaction.intent isKindOfClass:[INSendMessageIntent class]]) {
        intent = (INSendMessageIntent *)(interaction.intent);
    }
    NSString *p = intent.recipients.lastObject.displayName;
    NSString *v = intent.content;
    
    self.toNameLabel.text = p;
    self.fromMessage.text = v;
    
    //消息内容是空的时候不显示
    self.fromMessageBG.hidden = !v.length;
    
    CGSize maxSize = (CGSize){CGRectGetMinX(self.fromIconImageView.frame)-CGRectGetMinX(self.fromLeftLabel.frame)-10-20-20, [self desiredSize].height-40-10-10};
    
    self.fromMessageBG.translatesAutoresizingMaskIntoConstraints = YES;
    CGSize MessageSize = [v boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size;
    
    self.fromMessageBG.frame = (CGRect){maxSize.width - MessageSize.width, 40, MessageSize.width + 21, MessageSize.height + 10};

    //消息填充的阶段和是否确认发送的阶段，进行动画
    if (interaction.intentHandlingStatus == INIntentHandlingStatusReady ||
        interaction.intentHandlingStatus == INIntentHandlingStatusUnspecified) {
        
        CAKeyframeAnimation *messageBGAnimation = [self animationWithStart:self.fromMessageBG.center end:(CGPoint){self.fromMessageBG.center.x, self.fromMessageBG.center.y + 10}];
        [self.fromMessage.layer addAnimation:messageBGAnimation forKey:nil];
        [self.fromMessageBG.layer addAnimation:messageBGAnimation forKey:nil];
    } else {
        
        [self.fromMessage.layer removeAllAnimations];
        [self.fromMessageBG.layer removeAllAnimations];
    }
    
    //其实这货应该是用在comfirm和handle的时候出错了添加东西的
    NSUserActivity *activity = interaction.intentResponse.userActivity;
    NSString *errorInfo = activity.userInfo[@"failure"];
    if (errorInfo.length) {
        self.errorView.hidden = NO;
        self.errorLabel.text = errorInfo;
    } else {
        self.errorView.hidden = YES;
        self.errorLabel.text = @"";
    }
    
    //有毒这个view宽度是screenWidth，但是实际可显示的宽度，特么没那么大
    
    NSLog(@"%@", [self.view subviews]);
    
    //width screenWidth height 120 ~ 200
    NSLog(@"%lf %lf", [self desiredSize].width, [self desiredSize].height);
    NSLog(@"%lf %lf", [self extensionContext].hostedViewMaximumAllowedSize.width, [self extensionContext].hostedViewMaximumAllowedSize.height);
    
    if (completion) {
        completion((CGSize){[self desiredSize].width, 50});
    }
}

- (CAKeyframeAnimation *)animationWithStart:(CGPoint)start end:(CGPoint)end {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:start]; //一定要设置 不然底层的CGPathRef找不到起始点，将会崩溃
    [path addLineToPoint:end]; //以左下角和右上角为控制点
    [path addLineToPoint:start];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path.CGPath;
    animation.duration = 3.0f;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT;
    
    return animation;
}

- (BOOL)displaysMessage {
    //返YES以阻止默认的message界面，需要准守INUIHostedViewSiriProviding代理
    return YES;
}

- (CGSize)desiredSize {
    return [self extensionContext].hostedViewMinimumAllowedSize;
}

@end
