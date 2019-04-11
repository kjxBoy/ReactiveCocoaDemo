//
//  ViewController.m
//  RACGOGOGO
//
//  Created by yiche on 2018/12/20.
//  Copyright © 2018 yiche. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveObjc.h"
#import "Masonry.h"

@interface ViewController ()


@property (weak, nonatomic) IBOutlet UITextField *phonenumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;




@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RACSignal* (^counterSignal)(NSNumber *count) = ^RACSignal* (NSNumber *count) {
        
        // 每间隔1s执行一次
        RACSignal *timerSignal = [RACSignal interval:1
                                         onScheduler:[RACScheduler mainThreadScheduler]];
        // scanWithStart:reduce: 打印数字变换结果
        // 到某个值结束
        RACSignal *counterSignal = [[timerSignal scanWithStart:count
                                                        reduce:^id _Nullable(NSNumber *  _Nullable running, id  _Nullable next) {
            return @(running.integerValue - 1);
        }] takeUntilBlock:^BOOL(NSNumber*  _Nullable x) {
            return x.integerValue < 0;
        }];

        return [counterSignal startWith:count];

    };
    
    // 判断是否符合电话号码计数
    RACSignal *enableSignal = [self.phonenumberTextField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @(value.length == 11);
    }];
    
    
    // 判断验证码是否符合要求
    RACSignal *verificationCodeSignal = [self.verificationCodeTextField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @(value.length == 6);
    }];
    
    // 判断发送按钮的状态
    RACSignal* sendButtonSignal = [RACSignal combineLatest:@[enableSignal, verificationCodeSignal] reduce:^id _Nonnull(NSNumber *account,NSNumber *pwd){
        return @(account.boolValue && pwd.boolValue);
    }];
    
    
    /**
     验证码Button的
     @paramer enableSignal 信号被启用的条件，当符合电话号码时候，信号可以被启用
     @paramer counterSignal(@10) RACCommand内的信号
     */
    RACCommand *command = [[RACCommand alloc] initWithEnabled:enableSignal
                                                  signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
                                                      NSLog(@"发送验证码的网络请求");
                                                      return counterSignal(@10);
                                                  }];
    
    RACCommand *sendButtonCommand = [[RACCommand alloc] initWithEnabled:sendButtonSignal
                                                            signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
       return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSLog(@"登录请求");
           [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    
    // count - 0
    RACSignal *counterStringSignal = [[command.executionSignals switchToLatest]
                                      map:^id _Nullable(NSNumber*  _Nullable value) {
                                          return [value stringValue];
                                      }];
    // command没有正在执行
    RACSignal *resetStringSignal = [[command.executing
                                     filter:^BOOL(NSNumber * _Nullable value) {
                                            return !value.boolValue;
    }]
                                 mapReplace:@"点击获取验证码"];


    [self.refreshButton rac_liftSelector:@selector(setTitle:forState:)
                             withSignals:[RACSignal merge:@[counterStringSignal,resetStringSignal]], [RACSignal return:@(UIControlStateNormal)], nil];


    
    self.refreshButton.rac_command = command;
    self.loginButton.rac_command = sendButtonCommand;
    
    
}



@end
