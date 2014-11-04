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
#import "GgtzViewController.h"
#import "ShezhiViewController.h"
#import "ChooseChildrenViewController.h"
#import "ChooseClassViewController.h"
#import "BjtzViewController.h"
#import "BwhdViewController.h"
#import "MyViewController.h"
#import "JYSlideSegmentController.h"
#import "GrdaViewController.h"
#import "KcbViewController.h"

@interface MainViewController (){
    MKNetworkEngine *engine;
    NSArray *typearr;//育儿资讯分类
    NSArray *kcbarr;//课程表
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
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    
    //初始化网络引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    
    
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(grdaAction:)];
    [self.studentimg addGestureRecognizer:singleTap1];
    
    self.studentimg.layer.cornerRadius = self.studentimg.frame.size.height/2;
    self.studentimg.layer.masksToBounds = YES;
    [self.studentimg setContentMode:UIViewContentModeScaleAspectFill];
    [self.studentimg setClipsToBounds:YES];
    self.studentimg.layer.borderColor = [UIColor yellowColor].CGColor;
    self.studentimg.layer.borderWidth = 1.0f;
    self.studentimg.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    self.studentimg.layer.shadowOpacity = 0.5;
    self.studentimg.layer.shadowRadius = 2.0;
    
    [self loadData];//设置学生信息
    [self loadYezx];//加载育儿资讯分类
    [self loadKcb];//加载课程表
}

//加载信息设置
- (void)loadData{
    //设置信息
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *student = [userDefaults objectForKey:@"student"];
    NSString *studentname = [student objectForKey:@"studnetname"];
    NSNumber *studentage = [student objectForKey:@"age"];
    NSString *flieid = [student objectForKey:@"flieid"];
    
    self.studentname.text = studentname;
    self.studentage.text = [NSString stringWithFormat:@"年龄：%@岁",studentage];
    
    //设置头像
    if ([Utils isBlankString:flieid]) {
        [self.studentimg setImage:[UIImage imageNamed:@"iOS_42.png"]];
    }else{
        [self.studentimg setImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],flieid]] placeHolderImage:[UIImage imageNamed:@"iOS_42.png"] usingEngine:engine animation:YES];
    }
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
    ChooseChildrenViewController *cc = [[ChooseChildrenViewController alloc] init];
    [self.navigationController pushViewController:cc animated:YES];
}
//选择班级
- (IBAction)chooseClass:(UIButton *)sender {
    
    ChooseClassViewController *cc = [[ChooseClassViewController alloc] init];
    [self.navigationController pushViewController:cc animated:YES];
}

- (void)grdaAction:(UITapGestureRecognizer *)sender{
    GrdaViewController *vc = [[GrdaViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

//设置
- (IBAction)setup:(UIButton *)sender {
    
    ShezhiViewController *sz = [[ShezhiViewController alloc] init];
    [self.navigationController pushViewController:sz animated:YES];
}
//园所动态
- (IBAction)ysdtAction:(UIButton *)sender {
    
    
    YsdtViewController *ysdt = [[YsdtViewController alloc] init];
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
    
    
    
    [self.navigationController pushViewController:tabBarCtl animated:YES];
    [tabBarCtl.navigationController setNavigationBarHidden:NO];
}

- (void)loadYezx{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userid = [userDefaults objectForKey:@"userid"];
        [dic setValue:userid forKey:@"userid"];
    
        MKNetworkOperation *op = [engine operationWithPath:@"/MationType/findAllList.do" params:dic httpMethod:@"POST"];
        [op addCompletionHandler:^(MKNetworkOperation *operation) {
//            NSLog(@"[operation responseData]-->>%@", [operation responseString]);
            NSString *result = [operation responseString];
            NSError *error;
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            if (resultDict == nil) {
                NSLog(@"json parse failed \r\n");
            }
            NSNumber *success = [resultDict objectForKey:@"success"];
//            NSString *msg = [resultDict objectForKey:@"msg"];
            //        NSString *code = [resultDict objectForKey:@"code"];
            if ([success boolValue]) {
                NSArray *data = [resultDict objectForKey:@"data"];
                if (data != nil) {
                    typearr = data;
                }
            }else{
    
    
            }
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        }];
        [engine enqueueOperation:op];
}

//育儿资讯
- (IBAction)yezxAction:(UIButton *)sender {
    
    NSMutableArray *vcs = [NSMutableArray array];
    for (int i = 0; i < [typearr count]; i++) {
        NSDictionary *type = [typearr objectAtIndex:i];
        
        MyViewController *vc = [[MyViewController alloc] init];
        vc.typeId = [type objectForKey:@"id"];
//        UIViewController *vc = [[UIViewController alloc] init];
        vc.title = [NSString stringWithFormat:@"%@", [type objectForKey:@"typename"]];
        [vcs addObject:vc];
    }
    
    JYSlideSegmentController *slideSegmentController = [[JYSlideSegmentController alloc] initWithViewControllers:vcs];
    slideSegmentController.title = @"育儿资讯";
    slideSegmentController.indicatorInsets = UIEdgeInsetsMake(0, 8, 8, 8);
    slideSegmentController.indicator.backgroundColor = [UIColor greenColor];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:slideSegmentController animated:YES];
    
   
}
//家长园地
- (IBAction)jzydAction:(UIButton *)sender {
}

- (void)loadKcb{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    NSString *classid = [class objectForKey:@"classid"];
    [dic setValue:classid forKey:@"classid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Schedule/findPbyid.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
//        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        //            NSString *msg = [resultDict objectForKey:@"msg"];
        //        NSString *code = [resultDict objectForKey:@"code"];
        if ([success boolValue]) {
            NSArray *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                kcbarr = data;
            }
        }else{
            
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}
//课程表
- (IBAction)kcbAction:(UIButton *)sender {
    NSMutableArray *vcs = [NSMutableArray array];
    
    KcbViewController *vc1 = [[KcbViewController alloc] init];
    vc1.title = @"周一";
    vc1.dataSource = kcbarr;
    vc1.weekName = @"monday";
    [vcs addObject:vc1];
    KcbViewController *vc2 = [[KcbViewController alloc] init];
    vc2.title = @"周二";
    vc2.dataSource = kcbarr;
    vc2.weekName = @"tuesday";
    [vcs addObject:vc2];
    KcbViewController *vc3 = [[KcbViewController alloc] init];
    vc3.title = @"周三";
    vc3.dataSource = kcbarr;
    vc3.weekName = @"wednesday";
    [vcs addObject:vc3];
    KcbViewController *vc4 = [[KcbViewController alloc] init];
    vc4.title = @"周四";
    vc4.dataSource = kcbarr;
    vc4.weekName = @"thursday";
    [vcs addObject:vc4];
    KcbViewController *vc5 = [[KcbViewController alloc] init];
    vc5.title = @"周五";
    vc5.dataSource = kcbarr;
    vc5.weekName = @"friday";
    [vcs addObject:vc5];
    

    JYSlideSegmentController *slideSegmentController = [[JYSlideSegmentController alloc] initWithViewControllers:vcs];
    //设置背景图片
    UIImage *image = [UIImage imageNamed:@"ic_kcb_bg.png"];
    slideSegmentController.view.layer.contents = (id)image.CGImage;
    

    slideSegmentController.title = @"课程表";
    slideSegmentController.indicatorInsets = UIEdgeInsetsMake(0, 8, 8, 8);
    slideSegmentController.indicator.backgroundColor = [UIColor greenColor];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:slideSegmentController animated:YES];
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

//返回到该页面调用
- (void)viewDidAppear:(BOOL)animated{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backflag = [userDefaults objectForKey:@"backflag"];
//    NSLog(@"%@",backflag);
    if ([@"1" isEqualToString:backflag]) {
        [userDefaults removeObjectForKey:@"backflag"];
        [self loadData];//设置学生信息
        [self loadYezx];//加载育儿资讯分类
        [self loadKcb];//加载课程表
        
    }
    NSString *loginflag = [userDefaults objectForKey:@"loginflag"];
    if ([@"1" isEqualToString:loginflag]) {
        [userDefaults removeObjectForKey:@"loginflag"];
    }
}
@end
