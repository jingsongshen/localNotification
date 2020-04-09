//
//  ViewController.m
//  LocalNotificationDemo
//
//  Created by 谌靖松 on 2020/4/9.
//  Copyright © 2020 谌靖松. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

#define LocalNotiReqIdentifer    @"LocalNotiReqIdentifer2"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.messageLabel.text = @"测试本地通知";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptLocalNotification:) name:@"acceptLocalNotification" object:nil];
    // Do any additional setup after loading the view.
}

- (IBAction)postLocalNotificationAction:(id)sender {
    NSLog(@"5秒后发送本地通知");
    self.messageLabel.text = @"5秒后发送本地通知";
    [self postLocalNotification];
}

- (void)postLocalNotification{
    static int i = 0;
    NSString *title = @"title - 测试本地通知";
    NSString *subTitle = @"subtitle - 副标题";
    NSString *body = @"点击进入";
    NSInteger badge = 0;
    NSInteger timeInteval = 5;
    NSDictionary *userInfo = @{@"id":@"LOCAL_NOTIFY_SCHEDULE_ID"};
    
    if (@available(iOS 10.0, *)) {
        // 1.创建通知内容
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.sound = [UNNotificationSound defaultSound];
        content.title = title;
        content.subtitle = subTitle;
        content.body = body;
        content.badge = @(badge);

        content.userInfo = userInfo;
        
        //图片附件 最大10M
        [self addNotificationAttachmentContent:content attachmentName:@"image.jpeg" options:nil withCompletion:^(NSError *error, UNNotificationAttachment *notificationAtt) {
            content.attachments = @[notificationAtt];
        }];
        
//        //视频文件 取第一秒截图为缩略图、最大50M
//        [self addNotificationAttachmentContent:content attachmentName:@"video01.mp4" options:@{@"UNNotificationAttachmentOptionsThumbnailTimeKey":@1} withCompletion:^(NSError *error, UNNotificationAttachment *notificationAtt) {
//            content.attachments = @[notificationAtt];
//        }];
        //同样支持音频附件。最大5M
        
        // 2.设置声音
        UNNotificationSound *sound = [UNNotificationSound soundNamed:@"sound01.wav"];// [UNNotificationSound defaultSound];
        content.sound = sound;

        // 3.触发模式
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInteval repeats:NO];

        // 4.设置UNNotificationRequest 相同的Identifier会被处理为同一个通知。
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[LocalNotiReqIdentifer stringByAppendingFormat:@"%d",i++] content:content trigger:trigger];

        //5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        }];

    } else {
    
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        // 1.设置触发时间（如果要立即触发，无需设置）
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        
        // 2.设置通知标题
        localNotification.alertBody = title;
        
        // 3.设置通知动作按钮的标题
        localNotification.alertAction = @"Action Title";
        
        //
        localNotification.alertLaunchImage = @"image";
        
        // 4.设置提醒的声音
        localNotification.soundName = @"sound01.wav";// UILocalNotificationDefaultSoundName;
        
        // 5.设置通知的 传递的userInfo
        localNotification.userInfo = userInfo;
        
        // 6.在规定的日期触发通知
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        // 6.立即触发一个通知
        //[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

-(void)addNotificationAttachmentContent:(UNMutableNotificationContent *)content attachmentName:(NSString *)attachmentName  options:(NSDictionary *)options withCompletion:(void(^)(NSError * error , UNNotificationAttachment * notificationAtt))completion{
    NSArray * arr = [attachmentName componentsSeparatedByString:@"."];
    NSError * error;
    NSString * path = [[NSBundle mainBundle] pathForResource:arr[0] ofType:arr[1]];
    UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:[NSString stringWithFormat:@"notificationAtt_%@",arr[1]] URL:[NSURL fileURLWithPath:path] options:options error:&error];
    if (error) {
        NSLog(@"attachment error %@", error);
    }
    completion(error,attachment);
    //获取通知下拉放大图片
    content.launchImageName = attachmentName;
}

#pragma mark - notify
- (void)acceptLocalNotification:(NSNotification *)noti{
    self.messageLabel.text = @"点击了本地推送通知o(￣▽￣)ｄ";
}
@end
