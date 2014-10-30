//
//  LoginViewController.m
//  hmjz
//
//  Created by yons on 14-10-22.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import"MKNetworkKit.h"
#import "MainViewController.h"
#import "Utils.h"

@interface LoginViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
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
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    self.username.text = @"13276367907";
    self.password.text = @"123456";
    
}
//登陆
-(void)loginTag:(UITapGestureRecognizer *) rapGr{
    [self viewTapped:rapGr];
    HUD.labelText = @"正在加载中";
    [HUD show:YES];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.username.text forKey:@"userId"];
    [dic setValue:self.password.text forKey:@"password"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/sma/app/Plogin.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
//        NSString *code = [resultDict objectForKey:@"code"];
        if ([success boolValue]) {
            //[HUD hide:YES];
//            NSLog(@"%@",msg);
            NSDictionary *data = [resultDict objectForKey:@"data"];
//            NSLog(@"%@", [data objectForKey:@"hxusercode"]);
//            NSLog(@"%@", [data objectForKey:@"userid"]);
            NSString *userid = [data objectForKey:@"userid"];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:userid forKey:@"userid"];
//            NSLog(@"%@", [data objectForKey:@"hxpassword"]);
            
            [self getParentInfo:userid];//获取家长信息
            
            
            }else{
            [HUD hide:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = msg;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1];
        }
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

//登陆之后根据userid获取家长信息
- (void)getParentInfo:(NSString *)userid{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:userid forKey:@"userid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/sma/Parent/findbyid.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        
        if ([success boolValue]) {
            NSArray *array = [resultDict objectForKey:@"data"];
            if ([array count] > 0) {
                NSDictionary *data = [array objectAtIndex:0];
                NSString *parentid = [data objectForKey:@"id"];
                //NSString *parentname = [data objectForKey:@"parentname"];
                [self getChildrenInfo:parentid];//获取宝宝信息
            }else{
                
            }
        }else{
            [HUD hide:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = msg;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1];
        }
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

//根据家长id获取宝宝信息
- (void)getChildrenInfo:(NSString *)parentid{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:parentid forKey:@"parentid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/sma/Puser/findbyid.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        
        if ([success boolValue]) {
            NSArray *array = [resultDict objectForKey:@"data"];
            if ([array count] == 1) {//只有一个宝宝默认选择
                NSDictionary *data = [array objectAtIndex:0];
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:data forKey:@"student"];//将默认的一个宝宝存入userdefaults
                
                NSString *studentid = [data objectForKey:@"studentid"];//学生id
                [self getClassInfo:studentid];//获取班级信息
                
            }else if([array count] > 1){//有多个宝宝需要用户选择
                NSDictionary *data = [array objectAtIndex:0];
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:data forKey:@"student"];//将默认的一个宝宝存入userdefaults
                
                NSString *studentid = [data objectForKey:@"studentid"];//学生id
                [self getClassInfo:studentid];//获取班级信息
                
            }
        }else{
            [HUD hide:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = msg;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1];
        }
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
//根据学生id获取班级信息
- (void)getClassInfo:(NSString *)studentid{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:studentid forKey:@"studentid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/sma/Pclass/findbyid.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        
        if ([success boolValue]) {
            NSArray *array = [resultDict objectForKey:@"data"];
            if ([array count] == 1) {//只有一个班级默认选择
                NSDictionary *data = [array objectAtIndex:0];
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:data forKey:@"class"];//讲班级存入userdefaults
                
                MainViewController *mvc = [[MainViewController alloc] init];
//                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:mvc];
                
                
                
                //UIModalTransitionStyleCoverVertical 从下往上
                //UIModalTransitionStyleCrossDissolve 渐变
                //UIModalTransitionStyleFlipHorizontal 翻转
                //UIModalTransitionStylePartialCurl从下往上翻页
                //mvc.userid = userid;
//                mvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//                self.navigationController.delegate = self;
                [self.navigationController pushViewController:mvc animated:YES];
//                [self presentViewController:nc animated:YES completion:^{
//                    NSLog(@"completion");
//                }];

                
            }else if([array count] > 1){//有多个班级需要用户选择
                
                
            }
            [HUD hide:YES];
        }else{
            [HUD hide:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = msg;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1];
        }
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

//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    NSLog(@"%@",viewController);
////    if ([viewController isKindOfClass:[MainViewController class]]) {
////        [self.navigationController setNavigationBarHidden:YES];
////    }
//}

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
        if(self.view.frame.origin.y == 0){
            [self moveView:-40];
        }
        
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
