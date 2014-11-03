//
//  ChooseClassViewController.m
//  hmjz
//
//  Created by yons on 14-10-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "ChooseClassViewController.h"
#import "Utils.h"
#import "MKNetworkKit.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"

@interface ChooseClassViewController ()<MBProgressHUDDelegate>{
    NSInteger currentIndex;
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
}


@end

@implementation ChooseClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"选择班级";
    [self.navigationController setNavigationBarHidden:NO];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    currentIndex = -1;
    [self loadData];
}

- (void)loadData{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.dataSource = [userDefaults objectForKey:@"classes"];
    
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    NSString *classid = [class objectForKey:@"classid"];
    
    for (int i = 0 ; i < [self.dataSource count]; i++) {
        NSDictionary *data = [self.dataSource objectAtIndex:i];
        NSString *classid2 = [data objectForKey:@"classid"];
        if ([classid isEqualToString:classid2]) {
            currentIndex = i;
            break;
        }else{
            
        }
    }
    
    
    
    [self.mytableview reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSString *classname = [data objectForKey:@"classname"];
    cell.textLabel.text = classname;
    // 重用机制，如果选中的行正好要重用
    if (currentIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 取消前一个选中的，就是单选啦
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:currentIndex inSection:0];
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:lastIndex];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    
    // 选中操作
    UITableViewCell *cell = [tableView  cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // 保存选中的
    currentIndex = indexPath.row;
    
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:@"class"];//将默认的一个宝宝存入userdefaults
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    MainViewController *mvc = [[MainViewController alloc] init];
    [HUD hide:YES];
    [self.navigationController pushViewController:mvc animated:YES];

    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
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
