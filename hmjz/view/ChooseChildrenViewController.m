//
//  ChooseChildrenViewController.m
//  hmjz
//
//  Created by yons on 14-10-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "ChooseChildrenViewController.h"
#import "ChildrenTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "Utils.h"


@interface ChooseChildrenViewController (){
    NSInteger currentIndex;
}

@end

@implementation ChooseChildrenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"切换宝宝";
    self.mytableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.navigationController setNavigationBarHidden:NO];
    
    currentIndex = -1;
    [self loadData];
}

- (void)loadData{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.dataSource = [userDefaults objectForKey:@"students"];
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
    
    static NSString *cellIdentifier = @"childrencell";
    ChildrenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ChildrenTableViewCell" owner:self options:nil] lastObject];
//        [cell.layer setMasksToBounds:YES];
//        cell.layer.cornerRadius=5;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSString *studentname = [data objectForKey:@"studnetname"];
    NSNumber *studentsex = [data objectForKey:@"studentsex"];
    NSString *sex;
    if ([studentsex intValue]== 0) {
        sex = @"男";
    }else if ([studentsex intValue]== 1){
        sex = @"女";
    }
    NSString *fileid = [data objectForKey:@"flieid"];
    
    cell.namelabel.text = [NSString stringWithFormat:@"姓名：%@",studentname] ;
    cell.sexlabel.text = [NSString stringWithFormat:@"性别：%@",sex];
    
    if ([Utils isBlankString:fileid]) {
        [cell.img setImage:[UIImage imageNamed:@"iOS_42.png"]];
    }else{
        [cell.img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],fileid]] placeholderImage:[UIImage imageNamed:@"iOS_42.png"]];
    }
    
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
    [userDefaults setObject:data forKey:@"student"];//将默认的一个宝宝存入userdefaults
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
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
