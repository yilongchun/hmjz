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
//#import "YsdtViewController.h"
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
#import "BbspViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "ApplyViewController.h"
#import "MyTabbarController.h"
#import "BbxxTarbarViewController.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface MainViewController ()<MBProgressHUDDelegate,UIAlertViewDelegate>{
    MKNetworkEngine *engine;
    NSArray *typearr;//育儿资讯分类
    NSArray *kcbarr;//课程表
    NSArray *sparr;//食谱
    MBProgressHUD *HUD;
    
    UILabel *unreadlabel;
}

@property (strong, nonatomic)NSDate *lastPlaySoundDate;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
    //获取未读消息数，此时并没有把self注册为SDK的delegate，读取出的未读数是上次退出程序时的
    [self didUnreadMessagesCountChanged];
    //warning 把self注册为SDK的delegate
    [self registerNotifications];
    
    [[ApplyViewController shareController] loadDataSourceFromLocalDB];
//    _mainController = [[MainChatViewController alloc] init];
    _chatListController = [[ChatListViewController alloc] init];
    _chatListController.title = @"会话";
//    [_chatListController registerNotifications];
    
    
    
    
    //设置导航栏
    self.navigationController.delegate = self;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil]];
    [self.navigationController setNavigationBarHidden:YES];
    
    // 禁用 iOS7 返回手势
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
    
        
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    
    //初始化网络引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    unreadlabel = [[UILabel alloc] init];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
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
    
    [self setButtons];
    [self initData];
    
    [self setupUnreadMessageCount];
    
}

- (void)setButtons{
    
//    float height = [UIScreen mainScreen].bounds.size.height;
    float width = [UIScreen mainScreen].bounds.size.width;
    
//    [mainScrollView setFrame:CGRectMake(0, 170, width, height-170)];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    [dic setValue:[class objectForKey:@"schoolid"] forKey:@"schoolId"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/pcontrol/findAllList.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        //        NSString *msg = [resultDict objectForKey:@"msg"];
        if ([success boolValue]) {
            NSArray *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                self.menus = [[NSMutableArray alloc] init];
                for (int i = 0 ; i < [data count]; i++) {
                    NSDictionary *menu = [data objectAtIndex:i];
                    NSEnumerator * enumerator = [menu keyEnumerator];
                    id object;
                    //遍历输出
                    while(object = [enumerator nextObject])
                    {
                        id objectValue = [menu objectForKey:object];
                        if(objectValue != nil)
                        {
                            if ([objectValue boolValue]) {
                                [self.menus addObject:object];
                            }
                        }
                    }
                }
                
                
//                if (self.menus.count > 6) {
//                    if (height <= 480) {
//                        [mainScrollView setContentSize:CGSizeMake(width*2, height-170)];
//                        spacePageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0.0, height-30, width, 10)];
//                        [spacePageControl setPageIndicatorImage:[UIImage imageNamed:@"pageDot"]];
//                        [spacePageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"currentPageDot"]];
//                        spacePageControl.numberOfPages = 2;
//                        spacePageControl.indicatorMargin = 10.0f;
//                        spacePageControl.indicatorDiameter = 10.0f;
//                        spacePageControl.userInteractionEnabled = NO;
//                        [self.view addSubview:spacePageControl];
//                    }else{
//                        [mainScrollView setContentSize:CGSizeMake(width, height-170)];
//                    }
//                }else{
//                    [mainScrollView setContentSize:CGSizeMake(width, height-170)];
//                }
                
                
                int i = 0;
                for (NSString *menuStr in self.menus) {
//                    NSString *menuStr = [self.menus objectAtIndex:i];
                    
                    if ([menuStr isEqualToString:@"2_groupleChat"] ||
                        [menuStr isEqualToString:@"2_checkin"] ||
                        [menuStr isEqualToString:@"2_shuttle"]) {
                        continue;
                    }
                    
                    CGRect btnr;
                    switch (i) {
                        case 0:
                            btnr = CGRectMake(10, 170, 90, 90);
                            break;
                        case 1:
                            btnr = CGRectMake(width/2-45, 170, 90, 90);
                            break;
                        case 2:
                            btnr = CGRectMake(width-100, 170, 90, 90);
                            break;
                        case 3:
                            btnr = CGRectMake(10, 320, 90, 90);
                            break;
                        case 4:
                            btnr = CGRectMake(width/2-45, 320, 90, 90);
                            break;
                        case 5:
                            btnr = CGRectMake(width-100, 320, 90, 90);
                            break;
//                        case 6:
//                            if (height <= 480) {
//                                btnr = CGRectMake(width+10, 10, 90, 90);
//                            }else{
//                                btnr = CGRectMake(10, 260, 90, 90);
//                            }
//                            break;
                        default:
                            btnr = CGRectMake(0, 0, 0, 0);
                            break;
                    }
                    
                    if ([menuStr isEqualToString:@"26_singleChat"]) {//2_singleChat">小纸条
                        UIButton *btn4 = [[UIButton alloc] init];
                        [btn4 setFrame:btnr];
                        [btn4 setBackgroundImage:[UIImage imageNamed:@"ic_index_009.png"] forState:UIControlStateNormal];
//                        [btn4 setBackgroundImage:[UIImage imageNamed:@"ic_index_009_high.png"] forState:UIControlStateHighlighted];
                        [btn4 addTarget:self action:@selector(xztAction:) forControlEvents:UIControlEventTouchUpInside];
                        UILabel *label4 = [[UILabel alloc] init];
                        [label4 setFrame:CGRectMake(btn4.frame.origin.x, btn4.frame.origin.y+95, 90, 20)];
                        label4.text = @"小纸条";
                        label4.textAlignment = NSTextAlignmentCenter;
                        [label4 setFont:[UIFont systemFontOfSize:16]];
                        [label4 setBackgroundColor:[UIColor clearColor]];
                        [unreadlabel setFrame:CGRectMake(btn4.frame.origin.x + btn4.frame.size.width - 20, btn4.frame.origin.y, 20, 20)];
                        unreadlabel.layer.cornerRadius = unreadlabel.frame.size.height/2;
                        unreadlabel.layer.masksToBounds = YES;
                        [unreadlabel setTextColor:[UIColor whiteColor]];
                        [unreadlabel setTextAlignment:NSTextAlignmentCenter];
                        [unreadlabel setBackgroundColor:[UIColor redColor]];
                        [unreadlabel setHidden:YES];
//                        [mainScrollView addSubview:btn4];
//                        [mainScrollView addSubview:label4];
//                        [mainScrollView addSubview:unreadlabel];
                        [self.view addSubview:btn4];
                        [self.view addSubview:label4];
                        [self.view addSubview:unreadlabel];
                    }else if([menuStr isEqualToString:@"1_groupleChat"]){//1_groupleChat">教师园地
//                        UIButton *btn2 = [[UIButton alloc] init];
//                        [btn2 setFrame:btnr];
//                        [btn2 setBackgroundImage:[UIImage imageNamed:@"ic_index_005.png"] forState:UIControlStateNormal];
//                        [btn2 setBackgroundImage:[UIImage imageNamed:@"ic_index_005_high.png"] forState:UIControlStateHighlighted];
//                        [btn2 addTarget:self action:@selector(jsydAction:) forControlEvents:UIControlEventTouchUpInside];
//                        UILabel *label2 = [[UILabel alloc] init];
//                        [label2 setFrame:CGRectMake(btn2.frame.origin.x, btn2.frame.origin.y+95, 90, 20)];
//                        label2.text = @"教师园地";
//                        label2.textAlignment = NSTextAlignmentCenter;
//                        [label2 setFont:[UIFont systemFontOfSize:16]];
//                        [mainScrollView addSubview:btn2];
//                        [mainScrollView addSubview:label2];
                    }else if([menuStr isEqualToString:@"21_school"]){//2_school">宝宝学校
                        UIButton *btn2 = [[UIButton alloc] init];
                        [btn2 setFrame:btnr];
                        [btn2 setBackgroundImage:[UIImage imageNamed:@"ic_index_002.png"] forState:UIControlStateNormal];
//                        [btn2 setBackgroundImage:[UIImage imageNamed:@"ic_index_003_high.png"] forState:UIControlStateHighlighted];
                        [btn2 addTarget:self action:@selector(bbxxAction:) forControlEvents:UIControlEventTouchUpInside];
                        UILabel *label2 = [[UILabel alloc] init];
                        [label2 setFrame:CGRectMake(btn2.frame.origin.x, btn2.frame.origin.y+95, 90, 20)];
                        label2.text = @"宝宝学校";
                        label2.textAlignment = NSTextAlignmentCenter;
                        [label2 setFont:[UIFont systemFontOfSize:16]];
                        [label2 setBackgroundColor:[UIColor clearColor]];
//                        [mainScrollView addSubview:btn2];
//                        [mainScrollView addSubview:label2];
                        [self.view addSubview:btn2];
                        [self.view addSubview:label2];
                    }else if([menuStr isEqualToString:@"22_class"]){//2_class">宝宝班级
                        UIButton *btn1 = [[UIButton alloc] init];
                        [btn1 setFrame:btnr];
                        [btn1 setBackgroundImage:[UIImage imageNamed:@"ic_index_003.png"] forState:UIControlStateNormal];
//                        [btn1 setBackgroundImage:[UIImage imageNamed:@"ic_index_002_high.png"] forState:UIControlStateHighlighted];
                        [btn1 addTarget:self action:@selector(bbbjAction:) forControlEvents:UIControlEventTouchUpInside];
                        UILabel *label1 = [[UILabel alloc] init];
                        [label1 setFrame:CGRectMake(btn1.frame.origin.x, btn1.frame.origin.y+95, 90, 20)];
                        label1.text = @"宝宝班级";
                        label1.textAlignment = NSTextAlignmentCenter;
                        [label1 setFont:[UIFont systemFontOfSize:16]];
                        [label1 setBackgroundColor:[UIColor clearColor]];
//                        [mainScrollView addSubview:btn1];
//                        [mainScrollView addSubview:label1];
                        [self.view addSubview:btn1];
                        [self.view addSubview:label1];
                    }else if([menuStr isEqualToString:@"24_cookbook"]){//2_cookbook">宝宝食谱
                        UIButton *btn3 = [[UIButton alloc] init];
                        [btn3 setFrame:btnr];
                        [btn3 setBackgroundImage:[UIImage imageNamed:@"ic_index_007.png"] forState:UIControlStateNormal];
//                        [btn3 setBackgroundImage:[UIImage imageNamed:@"ic_index_004_high.png"] forState:UIControlStateHighlighted];
                        [btn3 addTarget:self action:@selector(bbspAction:) forControlEvents:UIControlEventTouchUpInside];
                        UILabel *label3 = [[UILabel alloc] init];
                        [label3 setFrame:CGRectMake(btn3.frame.origin.x, btn3.frame.origin.y+95, 90, 20)];
                        label3.text = @"宝宝食谱";
                        label3.textAlignment = NSTextAlignmentCenter;
                        [label3 setFont:[UIFont systemFontOfSize:16]];
                        [label3 setBackgroundColor:[UIColor clearColor]];
//                        [mainScrollView addSubview:btn3];
//                        [mainScrollView addSubview:label3];
                        [self.view addSubview:btn3];
                        [self.view addSubview:label3];
                    }else if([menuStr isEqualToString:@"25_information"]){//2_information">育儿资讯
                        UIButton *btn5 = [[UIButton alloc] init];
                        [btn5 setFrame:btnr];
                        [btn5 setBackgroundImage:[UIImage imageNamed:@"ic_index_004.png"] forState:UIControlStateNormal];
//                        [btn5 setBackgroundImage:[UIImage imageNamed:@"ic_index_006_high.png"] forState:UIControlStateHighlighted];
                        [btn5 addTarget:self action:@selector(yezxAction:) forControlEvents:UIControlEventTouchUpInside];
                        UILabel *label5 = [[UILabel alloc] init];
                        [label5 setFrame:CGRectMake(btn5.frame.origin.x, btn5.frame.origin.y+95, 90, 20)];
                        label5.text = @"育儿资讯";
                        label5.textAlignment = NSTextAlignmentCenter;
                        [label5 setFont:[UIFont systemFontOfSize:16]];
                        [label5 setBackgroundColor:[UIColor clearColor]];
//                        [mainScrollView addSubview:btn5];
//                        [mainScrollView addSubview:label5];
                        [self.view addSubview:btn5];
                        [self.view addSubview:label5];
                    }else if([menuStr isEqualToString:@"23_course"]){//2_course">课程表
                        UIButton *btn6 = [[UIButton alloc] init];
                        [btn6 setFrame:btnr];
                        [btn6 setBackgroundImage:[UIImage imageNamed:@"ic_index_006.png"] forState:UIControlStateNormal];
//                        [btn6 setBackgroundImage:[UIImage imageNamed:@"ic_index_007_high.png"] forState:UIControlStateHighlighted];
                        [btn6 addTarget:self action:@selector(kcbAction:) forControlEvents:UIControlEventTouchUpInside];
                        UILabel *label6 = [[UILabel alloc] init];
                        [label6 setFrame:CGRectMake(btn6.frame.origin.x, btn6.frame.origin.y+95, 90, 20)];
                        label6.text = @"课程表";
                        label6.textAlignment = NSTextAlignmentCenter;
                        [label6 setFont:[UIFont systemFontOfSize:16]];
                        [label6 setBackgroundColor:[UIColor clearColor]];
//                        [mainScrollView addSubview:btn6];
//                        [mainScrollView addSubview:label6];
                        [self.view addSubview:btn6];
                        [self.view addSubview:label6];
                    }
                    i++;
                }
            }
            [HUD hide:YES];
        }else{
            [HUD hide:YES];
            [self alertMsg:@"获取菜单失败"];
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self alertMsg:@"获取菜单失败"];
        [HUD hide:YES];
    }];
    [engine enqueueOperation:op];
    
    
}

- (void)initData{
    [self loadData];//设置学生信息
    [self loadYezx];//加载育儿资讯分类
    [self loadKcb];//加载课程表
    [self loadBbsp];//加载食谱
    [self loadData2];
   
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
        [self.studentimg setImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    }else{
//        [self.studentimg setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],flieid]] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
        [self.studentimg setImageWithURL:[NSURL URLWithString:flieid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    }
}
//家长列表
- (void)loadData2{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    NSString *classid = [class objectForKey:@"classid"];
    [dic setValue:classid forKey:@"classId"];
    [dic setValue:@"1" forKey:@"page"];
    [dic setValue:@"10" forKey:@"rows"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Parentfield/findPageList.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                [userDefaults setObject:arr forKey:@"friendarr"];
                for (int i = 0; i < arr.count; i++) {
                    NSDictionary *data = [arr objectAtIndex:i];
                    NSString *hxusercode = [data objectForKey:@"hxusercode"];
                    [userDefaults setObject:data forKey:hxusercode];
                }
            }
        }else{
            
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
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
//宝宝学校
- (IBAction)bbxxAction:(UIButton *)sender {
    
    BbxxTarbarViewController *vc = [[BbxxTarbarViewController alloc] init];
    
//    YsdtViewController *ysdt = [[YsdtViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}
//宝宝班级
- (IBAction)bbbjAction:(UIButton *)sender {
    
    //    初始化第一个视图控制器
//    BwhdViewController *vc1 = [[BwhdViewController alloc] init];
//    vc1.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"班务活动" image:[UIImage imageNamed:@"ic_bwrz_002.png"] tag:0];
//    
//    
//    //    初始化第二个视图控制器
//    BjtzViewController *vc2 = [[BjtzViewController alloc] init];
//    vc2.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"班级通知" image:[UIImage imageNamed:@"ic_bwrz_003.png"] tag:1];
//
//    //    把导航控制器加入到数组
//    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2, nil];
    
    
    MyTabbarController *tabBarCtl = [[MyTabbarController alloc] init];
    
    //    把视图数组放到tabbarcontroller 里面
//    UITabBarController *tabBarCtl = [[UITabBarController alloc] init];
//    [tabBarCtl.view setFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height)];
//    tabBarCtl.title = @"班务活动";
//    tabBarCtl.viewControllers = viewArr_;
//    
//    tabBarCtl.selectedIndex = 0;
//    [[tabBarCtl tabBar] setSelectedImageTintColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    
    
    
    [self.navigationController pushViewController:tabBarCtl animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
    
}

- (void)loadYezx{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userid = [userDefaults objectForKey:@"userid"];
        [dic setValue:userid forKey:@"userid"];
    
        MKNetworkOperation *op = [engine operationWithPath:@"/MationType/findAllList.do" params:dic httpMethod:@"GET"];
        [op addCompletionHandler:^(MKNetworkOperation *operation) {

            NSString *result = [operation responseString];
            NSError *error;
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            if (resultDict == nil) {
                NSLog(@"json parse failed \r\n");
            }
            NSNumber *success = [resultDict objectForKey:@"success"];
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

- (void)loadKcb{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    NSString *classid = [class objectForKey:@"classid"];
    [dic setValue:classid forKey:@"classid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Schedule/findPbyid.do" params:dic httpMethod:@"GET"];
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

//加载食谱
- (void)loadBbsp{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *student = [userDefaults objectForKey:@"student"];
    NSString *studentid = [student objectForKey:@"studentid"];
    [dic setValue:studentid forKey:@"studentid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Pcookbook/findCookList.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            NSArray *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                sparr = data;
            }
        }else{
            
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

//宝宝食谱
- (IBAction)bbspAction:(UIButton *)sender {
    
    NSMutableArray *vcs = [NSMutableArray array];
    
    for (int i = 0 ; i < [sparr count]; i++) {
        BbspViewController *vc = [[BbspViewController alloc] init];
        NSArray *data = [sparr objectAtIndex:i];
        vc.dataSource = data;
        NSDictionary *info = [data objectAtIndex:0];
        NSString *date = [info objectForKey:@"occurDate"];
        if (date.length > 5) {
            switch (i) {
                case 0:
                    vc.title = @"周一";
                    break;
                case 1:
                    vc.title = @"周二";
                    break;
                case 2:
                    vc.title = @"周三";
                    break;
                case 3:
                    vc.title = @"周四";
                    break;
                case 4:
                    vc.title = @"周五";
                    break;
                default:
                    break;
            }
            
            
            
            
//            vc.title = [[info objectForKey:@"occurDate"] substringFromIndex:5];
        }
        [vcs addObject:vc];
    }
    
//    BbspViewController *vc1 = [[BbspViewController alloc] init];
//    vc1.title = @"11-03";
//    [vcs addObject:vc1];
//    BbspViewController *vc2 = [[BbspViewController alloc] init];
//    vc2.title = @"周二";
//    [vcs addObject:vc2];
//    BbspViewController *vc3 = [[BbspViewController alloc] init];
//    vc3.title = @"周三";
//    [vcs addObject:vc3];
//    BbspViewController *vc4 = [[BbspViewController alloc] init];
//    vc4.title = @"周四";
//    [vcs addObject:vc4];
//    BbspViewController *vc5 = [[BbspViewController alloc] init];
//    vc5.title = @"周五";
//    [vcs addObject:vc5];
    
    if (vcs.count > 0) {
        JYSlideSegmentController *slideSegmentController = [[JYSlideSegmentController alloc] initWithViewControllers:vcs];
        
        //设置背景图片
        UIImage *image = [UIImage imageNamed:@"ic_sp_001.png"];
        slideSegmentController.view.layer.contents = (id)image.CGImage;

        
        slideSegmentController.title = @"食谱";
        slideSegmentController.indicatorInsets = UIEdgeInsetsMake(0, 8, 8, 8);
        slideSegmentController.indicator.backgroundColor = [UIColor greenColor];
        
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController pushViewController:slideSegmentController animated:YES];
    }else{
        //提示没有信息
        [self alertMsg:@"未获取到食谱信息，请稍后查看"];
    }
    
}


//小纸条
- (IBAction)xztAction:(UIButton *)sender {
    
    if ([[EaseMob sharedInstance].chatManager loginInfo] == nil) {
        [self showHint:@"请稍后使用小纸条功能"];
        return;
    }
    
//    if (_mainController == nil) {
//        _mainController = [[MainChatViewController alloc] init];
//    }
    if (_chatListController == nil) {
        _chatListController = [[ChatListViewController alloc] init];
    }
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:_chatListController animated:YES];
}

//返回到该页面调用
- (void)viewDidAppear:(BOOL)animated{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backflag = [userDefaults objectForKey:@"backflag"];
    if ([@"1" isEqualToString:backflag]) {//选择完班级和宝宝 返回重新加载
        [userDefaults removeObjectForKey:@"backflag"];
        [self loadData];//设置学生信息
        [self loadYezx];//加载育儿资讯分类
        [self loadBbsp];//加载食谱
        [self loadKcb];//加载课程表
    }
    NSString *loginflag = [userDefaults objectForKey:@"loginflag"];//如果是登陆则删除标识符
    if ([@"1" isEqualToString:loginflag]) {
        [userDefaults removeObjectForKey:@"loginflag"];
    }
    NSString *updateImgFlag = [userDefaults objectForKey:@"updateImgFlag"];//如果是修改头像返回则重新加载学生信息
    if ([@"1" isEqualToString:updateImgFlag]) {
        [userDefaults removeObjectForKey:@"updateImgFlag"];
        [self loadData];
    }
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
}

//提示
- (void)alertMsg:(NSString *)msg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
}


- (void)dealloc{
    [self unregisterNotifications];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            [[EaseMob sharedInstance].chatManager asyncLogoffWithCompletion:^(NSDictionary *info, EMError *error) {
                [[ApplyViewController shareController] clear];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
            } onQueue:nil];
        }
    }
    else if (alertView.tag == 100) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    } else if (alertView.tag == 101) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
}

#pragma mark - private

-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

//显示该界面 刷新未读消息数
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupUnreadMessageCount];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NSLog(@"viewWillAppear");
}


//设置未读消息数
- (void)setupUnreadMessageCount{
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (unreadCount > 0) {
        if (unreadCount < 9) {
            unreadlabel.font = [UIFont systemFontOfSize:13];
        }else if(unreadCount > 9 && unreadCount < 99){
            unreadlabel.font = [UIFont systemFontOfSize:12];
        }else{
            unreadlabel.font = [UIFont systemFontOfSize:10];
        }
        [unreadlabel setHidden:NO];
        unreadlabel.text = [NSString stringWithFormat:@"%ld",(long)unreadCount];
    }else{
        [unreadlabel setHidden:YES];
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

#pragma mark - IChatMangerDelegate 消息变化
- (void)didUpdateConversationList:(NSArray *)conversationList
{
    [_chatListController refreshDataSource];
}
// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
    [self setupUnreadMessageCount];
}
- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages{
    [self setupUnreadMessageCount];
}
- (BOOL)needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupList];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    
    if (ret) {
        EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
        
        do {
            if (options.noDisturbing) {
                NSDate *now = [NSDate date];
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute
                                                                               fromDate:now];
                
                NSInteger hour = [components hour];
                //        NSInteger minute= [components minute];
                
                NSUInteger startH = options.noDisturbingStartH;
                NSUInteger endH = options.noDisturbingEndH;
                if (startH>endH) {
                    endH += 24;
                }
                
                if (hour>=startH && hour<=endH) {
                    ret = NO;
                    break;
                }
            }
        } while (0);
    }
    
    return ret;
}
// 收到消息回调
-(void)didReceiveMessage:(EMMessage *)message
{
    BOOL needShowNotification = message.isGroup ? [self needShowNotification:message.conversation.chatter] : YES;
    if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
        [self playSoundAndVibration];
        
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            [self showNotificationWithMessage:message];
        }else{
        }
        
#endif
    }
    [self setupUnreadMessageCount];
}

- (void)playSoundAndVibration{
    
    //如果距离上次响铃和震动时间太短, 则跳过响铃
    NSLog(@"%@, %@", [NSDate date], self.lastPlaySoundDate);
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        return;
    }
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EaseMob sharedInstance].deviceManager asyncPlayNewMessageSound];
    // 收到消息时，震动
    [[EaseMob sharedInstance].deviceManager asyncPlayVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = @"[图片]";
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = @"[位置]";
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = @"[音频]";
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = @"[视频]";
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        if (message.isGroup) {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversation.chatter]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, group.groupSubject];
                    break;
                }
            }
        }
        
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        notification.alertBody = @"您有一条新消息";
    }
    
    //#warning 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    //notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    notification.alertAction = @"打开";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //    UIApplication *application = [UIApplication sharedApplication];
    //    application.applicationIconBadgeNumber += 1;
}

#pragma mark - IChatManagerDelegate 登陆回调（主要用于监听自动登录是否成功）
- (void)didLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (error) {
        /*NSString *hintText = @"";
         if (error.errorCode != EMErrorServerMaxRetryCountExceeded) {
         if (![[[EaseMob sharedInstance] chatManager] isAutoLoginEnabled]) {
         hintText = @"你的账号登录失败，请重新登陆";
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
         message:hintText
         delegate:self
         cancelButtonTitle:@"确定"
         otherButtonTitles:nil,
         nil];
         alertView.tag = 99;
         [alertView show];
         }
         } else {
         hintText = @"已达到最大登陆重试次数，请重新登陆";
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
         message:hintText
         delegate:self
         cancelButtonTitle:@"确定"
         otherButtonTitles:nil,
         nil];
         alertView.tag = 99;
         [alertView show];
         }*/
        NSString *hintText = @"你的账号登录失败，正在重试中... \n点击 '登出' 按钮跳转到登录页面 \n点击 '继续等待' 按钮等待重连成功";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:hintText
                                                           delegate:self
                                                  cancelButtonTitle:@"继续等待"
                                                  otherButtonTitles:@"登出",
                                  nil];
        alertView.tag = 99;
        [alertView show];
    }
}

#pragma mark - IChatManagerDelegate 登录状态变化

- (void)didLoginFromOtherDevice
{
    [[EaseMob sharedInstance].chatManager asyncLogoffWithCompletion:^(NSDictionary *info, EMError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"你的账号已在其他地方登录"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil,
                                  nil];
        alertView.tag = 100;
        [alertView show];
    } onQueue:nil];
}

- (void)didRemovedFromServer {
    [[EaseMob sharedInstance].chatManager asyncLogoffWithCompletion:^(NSDictionary *info, EMError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"你的账号已被从服务器端移除"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil,
                                  nil];
        alertView.tag = 101;
        [alertView show];
    } onQueue:nil];
}

- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    [_chatListController networkChanged:connectionState];
}

#pragma mark -

- (void)willAutoReconnect{
    [self hideHud];
    [self showHudInView:self.view hint:@"正在重连中..."];
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    [self hideHud];
    if (error) {
        [self showHint:@"重连失败，稍候将继续重连"];
    }else{
        [self showHint:@"重连成功！"];
    }
}


@end
