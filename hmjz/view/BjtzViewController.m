//
//  BjtzViewController.m
//  hmjz
//
//  Created by yons on 14-10-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "BjtzViewController.h"
#import "GgtzTableViewCell.h"
#import "Utils.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "GgxqViewController.h"
#import "MJRefresh.h"

@interface BjtzViewController (){
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
}

@end

@implementation BjtzViewController
@synthesize dataSource;
@synthesize mytableview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //初始化tableview
    CGRect cg;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        cg = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-49-64);
    }else{
        cg = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-49-64);
    }
    mytableview = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [mytableview setTableFooterView:v];
    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
    
    mytableview.dataSource = self;
    mytableview.delegate = self;
    [self.view addSubview:mytableview];
    
    
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    // 添加下拉刷新控件
    self.mytableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //初始化数据
        [self loadData];
    }];
    self.mytableview.footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [self loadMore];
    }];
    [self.mytableview.header beginRefreshing];

}


//加载数据
- (void)loadData{
    
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:10];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    NSString *classid = [class objectForKey:@"classid"];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    [dic setValue:classid forKey:@"recordId"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:userid forKey:@"userid"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/Pnotice/findbyidclass.do",HOST];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.mytableview.header endRefreshing];
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
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                self.dataSource = [NSMutableArray arrayWithArray:arr];
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
                [mytableview reloadData];
            }
        }else{
            [self showHint:msg];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        [self.mytableview.header endRefreshing];
        [self showHint:[error localizedDescription]];
    }];
}

- (void)loadMore{
    if ([page intValue] < [totalpage intValue]) {
        page = [NSNumber numberWithInt:[page intValue] +1];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *class = [userDefaults objectForKey:@"class"];
        NSString *classid = [class objectForKey:@"classid"];
        NSString *userid = [userDefaults objectForKey:@"userid"];
        [dic setValue:classid forKey:@"recordId"];
        [dic setValue:page forKey:@"page"];
        [dic setValue:rows forKey:@"rows"];
        [dic setValue:userid forKey:@"userid"];
        
        NSString *urlString = [NSString stringWithFormat:@"http://%@/Pnotice/findbyidclass.do",HOST];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
        [manager GET:urlString parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.mytableview.footer endRefreshing];
            //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
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
                NSDictionary *data = [resultDict objectForKey:@"data"];
                if (data != nil) {
                    NSArray *arr = [data objectForKey:@"rows"];
                    [self.dataSource addObjectsFromArray:arr];
                    NSNumber *total = [data objectForKey:@"total"];
                    if ([total intValue] % [rows intValue] == 0) {
                        totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                    }else{
                        totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                    }
                    [mytableview reloadData];
                }
            }else{
                [self showHint:msg];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
            [self.mytableview.footer endRefreshing];
            [self showHint:[error localizedDescription]];
        }];
    }
    
}


#pragma mark - UITableViewDatasource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self dataSource] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ggtzcell";
    GgtzTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GgtzTableViewCell" owner:self options:nil] lastObject];
    }
    NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
    NSString *tntitle = [info objectForKey:@"tntitle"];
    NSString *teacherfileid = [info objectForKey:@"fileid"];
    NSString *tncontent = [info objectForKey:@"tncontent"];
    NSNumber *noticecount = [info objectForKey:@"noticecount"];
    NSString *tncreatedate = [info objectForKey:@"tncreatedate"];
    NSString *source = [info objectForKey:@"noticename"];
    cell.gtitle.text = tntitle;
    
    if ([Utils isBlankString:teacherfileid]) {
        [cell.imageview setImage:[UIImage imageNamed:@"nopicture.png"]];
    }else{
        //            [cell.imageview setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],teacherfileid]] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
        [cell.imageview setImageWithURL:[NSURL URLWithString:teacherfileid] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
    }
    cell.gdispcription.text = tncontent;
    cell.gdispcription.numberOfLines = 2;// 不可少Label属性之一
    cell.gdispcription.lineBreakMode = NSLineBreakByCharWrapping;// 不可少Label属性之二
    //[cell.gdispcription sizeToFit];
    cell.gpinglun.text = [NSString stringWithFormat:@"评论(%@)",noticecount];
    cell.gdate.text = tncreatedate;
    cell.gsource.text = [NSString stringWithFormat:@"来自:%@",source];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
    NSString *tnid = [info objectForKey:@"tnid"];
    GgxqViewController *ggxq = [[GgxqViewController alloc]init];
    ggxq.title = @"公告详情";
    ggxq.tnid = tnid;
    [self.navigationController pushViewController:ggxq animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"班级公告"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"班级公告"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
