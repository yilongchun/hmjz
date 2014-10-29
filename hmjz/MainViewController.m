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
#import "ShezhiViewController.h"
#import "ChooseChildrenViewController.h"
#import "ChooseClassViewController.h"
#import "BjtzViewController.h"
#import "BwhdViewController.h"

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
    
    //设置信息
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *userid = [userDefaults objectForKey:@"userid"];
    
    
    NSDictionary *student = [userDefaults objectForKey:@"student"];
    NSString *studentname = [student objectForKey:@"studnetname"];
    NSNumber *studentage = [student objectForKey:@"age"];
    NSString *flieid = [student objectForKey:@"flieid"];
    
//    NSString *flieid = @"3b276e4a-5589-460a-a68e-7e16a1701a34";
    
    self.studentname.text = studentname;
    self.studentage.text = [NSString stringWithFormat:@"年龄：%@岁",studentage];
    
    //设置头像
    if ([Utils isBlankString:flieid]) {
        [self.studentimg setImage:[UIImage imageNamed:@"iOS_42.png"]];
    }else{
        [self.studentimg setImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/SM/image/show.do?id=%@",[Utils getHostname],flieid]] placeHolderImage:[UIImage imageNamed:@"iOS_42.png"] usingEngine:engine animation:YES];
    }
    self.studentimg.layer.cornerRadius = self.studentimg.frame.size.height/2;
    self.studentimg.layer.masksToBounds = YES;
    [self.studentimg setContentMode:UIViewContentModeScaleAspectFill];
    [self.studentimg setClipsToBounds:YES];
    self.studentimg.layer.borderColor = [UIColor yellowColor].CGColor;
    self.studentimg.layer.borderWidth = 1.0f;
    self.studentimg.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    self.studentimg.layer.shadowOpacity = 0.5;
    self.studentimg.layer.shadowRadius = 2.0;
    
    
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
//隐藏导航栏
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController isKindOfClass:[MainViewController class]]) {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

//选择宝宝
- (IBAction)chooseChildren:(UIButton *)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    ChooseChildrenViewController *cc = [[ChooseChildrenViewController alloc] init];
    [self.navigationController pushViewController:cc animated:YES];
}
//选择班级
- (IBAction)chooseClass:(UIButton *)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    ChooseClassViewController *cc = [[ChooseClassViewController alloc] init];
    [self.navigationController pushViewController:cc animated:YES];
}
//设置
- (IBAction)setup:(UIButton *)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    ShezhiViewController *sz = [[ShezhiViewController alloc] init];
    [self.navigationController pushViewController:sz animated:YES];
}
//园所动态
- (IBAction)ysdtAction:(UIButton *)sender {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    YsdtViewController *ysdt = [[YsdtViewController alloc] init];
    ysdt.userid = self.userid;
    [self.navigationController pushViewController:ysdt animated:YES];
}
//班务活动
- (IBAction)bwhdAction:(UIButton *)sender {
    
    //    初始化第一个视图控制器
    BwhdViewController *vc1 = [[BwhdViewController alloc] init];
    vc1.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"班务活动" image:[UIImage imageNamed:@"ic_bwrz_002.png"] tag:0];
    
    //    初始化第二个视图控制器
    BjtzViewController *vc2 = [[BjtzViewController alloc] init];
    vc2.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"班级通知" image:[UIImage imageNamed:@"ic_bwrz_003.png"] tag:1];

    //    把导航控制器加入到数组
    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2, nil];
    
    //    把视图数组放到tabbarcontroller 里面
    UITabBarController *tabBarCtl = [[UITabBarController alloc] init];
    tabBarCtl.title = @"班务活动";
    tabBarCtl.viewControllers = viewArr_;
    
    tabBarCtl.selectedIndex = 0;
    [[tabBarCtl tabBar] setSelectedImageTintColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    [self.navigationController pushViewController:tabBarCtl animated:YES];
    [tabBarCtl.navigationController setNavigationBarHidden:NO];
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
