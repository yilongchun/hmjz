//
//  GrdaViewController.m
//  hmjz
//
//  Created by yons on 14-10-30.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "GrdaViewController.h"
#import "Utils.h"
#import "UIImageView+AFNetworking.h"
#import "MKNetworkKit.h"

@interface GrdaViewController (){
    MKNetworkEngine *engine;
    NSString *name;
    NSNumber *age;
    NSString *sex;
    NSString *classname;
}

@end

@implementation GrdaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    [self setTitle:@"个人档案"];
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    [self.mytableview setSeparatorColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    [self loadData];
}

- (void)loadData{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *student = [userDefaults objectForKey:@"student"];
    name = [student objectForKey:@"studnetname"];
    age = [student objectForKey:@"age"];
    NSNumber *sexnum = [student objectForKey:@"studentsex"];
    if ([sexnum intValue]== 0) {
        sex = @"男";
    }else if ([sexnum intValue]== 1){
        sex = @"女";
    }

    NSString *flieid = [student objectForKey:@"flieid"];
    
    //设置头像
    if ([Utils isBlankString:flieid]) {
        [self.myimageview setImage:[UIImage imageNamed:@"iOS_42.png"]];
    }else{
        [self.myimageview setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],flieid]] placeholderImage:[UIImage imageNamed:@"iOS_42.png"]];
        
//        [self.myimageview setImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getHostname],flieid]] placeHolderImage:[UIImage imageNamed:@"iOS_42.png"] usingEngine:engine animation:YES];
    }
    
    self.myimageview.layer.cornerRadius = self.myimageview.frame.size.height/2;
    self.myimageview.layer.masksToBounds = YES;
    [self.myimageview setContentMode:UIViewContentModeScaleAspectFill];
    [self.myimageview setClipsToBounds:YES];
    self.myimageview.layer.borderColor = [UIColor yellowColor].CGColor;
    self.myimageview.layer.borderWidth = 1.0f;
    self.myimageview.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    self.myimageview.layer.shadowOpacity = 0.5;
    self.myimageview.layer.shadowRadius = 2.0;
    
    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableViewDatasource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"姓名：%@",name];
            break;
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"年龄：%@",age];
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"性别：%@",sex];
            break;
        case 3:
            
            break;
            
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([self.dataSource count] == indexPath.row) {
//        return 44;
//    }else{
//        return 100;
//    }
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
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
