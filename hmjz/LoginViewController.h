//
//  LoginViewController.h
//  hmjz
//  登陆
//  Created by yons on 14-10-22.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseMob.h"
#import "MainViewController.h"

@interface LoginViewController : UIViewController<UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (nonatomic,copy) NSString *logintype;
@property (strong, nonatomic) MainViewController *mainController;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

- (IBAction)login:(id)sender;

@end
