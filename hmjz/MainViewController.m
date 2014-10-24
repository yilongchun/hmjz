//
//  MainViewController.m
//  hmjz
//
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "MainViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "YsdtViewController.h"
#import "BwhdViewController.h"
#import "YezxViewController.h"

#import "GgtzViewController.h"

@interface MainViewController (){
    MKNetworkEngine *engine;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏
    self.navigationController.delegate = self;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil]];
    [self.navigationController setNavigationBarHidden:YES];
    
    //初始化网络引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    [self getParentInfo:self.userid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)getParentInfo:(NSString *) userid{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:userid forKey:@"userid"];
    MKNetworkOperation *op = [engine operationWithPath:@"/Notice/findbyidList.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        
        NSNumber *success = [resultDict objectForKey:@"success"];
//        NSString *msg = [resultDict objectForKey:@"msg"];
        
        if ([success boolValue]) {
            
        }else{
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        
    }];
    [engine enqueueOperation:op];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//隐藏导航栏
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController isKindOfClass:[MainViewController class]]) {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

//园所动态
- (IBAction)ysdtAction:(UIButton *)sender {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    YsdtViewController *ysdt = [[YsdtViewController alloc] init];
//    GgtzViewController *ysdt = [[GgtzViewController alloc] init];
    [self.navigationController pushViewController:ysdt animated:YES];
}
//班务活动
- (IBAction)bwhdAction:(UIButton *)sender {
    BwhdViewController *vc = [[BwhdViewController alloc] init];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    [self.navigationController pushViewController:vc animated:YES];
}
//育儿资讯
- (IBAction)yezxAction:(UIButton *)sender {
    YezxViewController *vc = [[YezxViewController alloc] init];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    [self.navigationController pushViewController:vc animated:YES];
}
//家长园地
- (IBAction)jzydAction:(UIButton *)sender {
}
//课程表
- (IBAction)kcbAction:(UIButton *)sender {
}
//宝宝食谱
- (IBAction)bbspAction:(UIButton *)sender {
}
//宝宝签到
- (IBAction)bbqdAction:(UIButton *)sender {
}
//小纸条
- (IBAction)xztAction:(UIButton *)sender {
}
@end
