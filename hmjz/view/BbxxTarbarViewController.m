//
//  BbxxTarbarViewController.m
//  hmjz
//
//  Created by yons on 14-11-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "BbxxTarbarViewController.h"
#import "YqjsViewController.h"
#import "GgtzViewController.h"
#import "XxhdViewController.h"

@interface BbxxTarbarViewController ()

@end

@implementation BbxxTarbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO ;
    
    //    初始化第一个视图控制器
    YqjsViewController *vc1 = [[YqjsViewController alloc] init];
    UITabBarItem *item1 = [[UITabBarItem alloc] init];
    [item1 setFinishedSelectedImage:[UIImage imageNamed:@"xxjs_high.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"xxjs.png"]];
    item1.title = @"学校介绍";
    [item1 setTag:0];
    vc1.tabBarItem = item1;
    

    
    //    初始化第二个视图控制器
    GgtzViewController *vc2 = [[GgtzViewController alloc] init];
    
    UITabBarItem *item2 = [[UITabBarItem alloc] init];
    [item2 setFinishedSelectedImage:[UIImage imageNamed:@"xxgg_high.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"xxgg.png"]];
    item2.title = @"学校公告";
    [item2 setTag:1];
    vc2.tabBarItem = item2;
    


    //    初始化第三个视图控制器
    XxhdViewController *vc3 = [[XxhdViewController alloc] init];
    UITabBarItem *item3 = [[UITabBarItem alloc] init];
    [item3 setFinishedSelectedImage:[UIImage imageNamed:@"xxhd_high.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"xxhd.png"]];
    item3.title = @"学校活动";
    [item3 setTag:2];
    vc3.tabBarItem = item3;
    
    //    把导航控制器加入到数组
    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2,vc3, nil];
    
    self.title = @"学校介绍";
    self.viewControllers = viewArr_;
    
    self.selectedIndex = 0;
    [[self tabBar] setSelectedImageTintColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = @"学校介绍";
    }else if (item.tag == 1){
        self.title = @"学校公告";
    }else if (item.tag == 2){
        self.title = @"学校活动";
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

@end
