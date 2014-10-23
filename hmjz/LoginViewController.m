//
//  LoginViewController.m
//  hmjz
//
//  Created by yons on 14-10-22.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "MKNetworkOperation.h"
#import "MKNetworkEngine.h"

@interface LoginViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    NSString *hostname;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //添加手势，点击输入框其他区域隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView =NO;
    [self.view addGestureRecognizer:tapGr];
    //添加登陆事件
    self.loginBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginTag:)];
    [self.loginBtn addGestureRecognizer:singleTap];
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    //从资源文件获取请求路径
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary *infolist = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    hostname = [infolist objectForKey:@"Httpurl"];
    
}
//登陆
-(void)loginTag:(UITapGestureRecognizer *) rapGr{
    [self viewTapped:rapGr];
    HUD.labelText = @"正在加载中";
    [HUD show:YES];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:hostname customHeaderFields:nil];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:@"13276367907" forKey:@"userId"];
    [dic setValue:@"123456" forKey:@"password"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/sma/app/Plogin.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSLog(@"%@", [resultDict objectForKey:@"code"]);
        NSLog(@"%@", [resultDict objectForKey:@"msg"]);
        NSLog(@"%@", [resultDict objectForKey:@"success"]);
        NSDictionary *data = [resultDict objectForKey:@"data"];
        NSLog(@"%@", [data objectForKey:@"hxusercode"]);
        NSLog(@"%@", [data objectForKey:@"userid"]);
        NSLog(@"%@", [data objectForKey:@"hxpassword"]);
        [HUD hide:YES];
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请求失败";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    }];
    [engine enqueueOperation:op];

}


//隐藏键盘
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    [self moveView:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 输入框代理
-(void)textFieldDidBeginEditing:(UITextField *)textField{   //开始编辑时，整体上移
    if(textField.tag == 0){
        [self moveView:-40];
    }else if(textField.tag == 1){
        if(self.view.frame.origin.y == -40){
            [self moveView:-40];
        }else if(self.view.frame.origin.y == 0){
            [self moveView:-80];
        }
    }
}

#pragma mark - 键盘回车
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag==0) {
        [self.password becomeFirstResponder];
    }
    if (textField.tag==1) {
        [self loginTag:nil];
    }
    return YES;
}
//界面根据键盘的显示和隐藏上下移动
-(void)moveView:(float)move{
    NSTimeInterval animationDuration = 1.0f;
    CGRect frame = self.view.frame;
    if(move == 0){
        frame.origin.y =0;
    }else{
        frame.origin.y +=move;//view的X轴上移
    }
    [UIView beginAnimations:@"ResizeView" context:nil];
    self.view.frame = frame;
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];//设置调整界面的动画效果
}


@end
