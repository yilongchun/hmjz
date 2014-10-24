//
//  YsdtViewController.m
//  hmjz
//
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "YsdtViewController.h"
#import "YqjsViewController.h"
#import "GgtzViewController.h"

@interface YsdtViewController ()
@end

@implementation YsdtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    
    YqjsViewController *yqjs = [[YqjsViewController alloc] init];
    yqjs.title = @"园情介绍";
    GgtzViewController *ggtz = [[GgtzViewController alloc] init];
    ggtz.title = @"公告通知";
    ggtz.userid = self.userid;
    [self setViewControllers:[NSArray arrayWithObjects:yqjs, ggtz, nil]];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
