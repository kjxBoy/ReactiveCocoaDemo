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
    
    RACChannelTerminal *terminal = self.phonenumberTextField.rac_newTextChannel;
    
    [[terminal map:^id _Nullable(NSString *  _Nullable value) {
        const char *str = [value UTF8String];
        char newStr[15] = {0};
        int count = 0;

        for (unsigned int i = 0; i < value.length; ++i) {
            const char c = str[i];
            if (c <= '9' && c >= '0') {
                if (count == 4 || count == 9) {
                    newStr[count] = '-';
                    ++count;
                }
            }

            newStr[count] = c;
            ++count;

            if (count >= 14) {
                break;
            }
        }

        NSString *newString = [NSString stringWithUTF8String:newStr];
        return newString;
    }] subscribe:terminal] ;
    
}



@end
