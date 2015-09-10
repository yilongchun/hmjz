//
//  GgtzViewController.m
//  hmjz
//
//  Created by yons on 14-10-24.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "GgtzViewController.h"
#import "GgtzTableViewCell.h"
#import "AFNetworking.h"
#import "Utils.h"
#import "GgxqViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MJRefresh.h"


@interface GgtzViewController (){
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
    
    NSString *schoolid;
    NSString *userid;
}


@end

@implementation GgtzViewController
@synthesize dataSource;
@synthesize mytableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    //初始化tableview
    CGRect cg;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        cg = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-49-64);
    }else{
        cg = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-49-64);
    }
    mytableView = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [mytableView setTableFooterView:v];
    if ([mytableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [mytableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([mytableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [mytableView setLayoutMargins:UIEdgeInsetsZero];
    }
    mytableView.dataSource = self;
    mytableView.delegate = self;
    [self.view addSubview:mytableView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    schoolid = [class objectForKey:@"schoolid"];
    userid = [userDefaults objectForKey:@"userid"];
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    // 添加下拉刷新控件
    self.mytableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //初始化数据
        [self loadData];
    }];
    self.mytableView.footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [self loadMore];
    }];
    [self.mytableView.header beginRefreshing];
}

//加载数据
- (void)loadData{
    
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:10];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:userid forKey:@"userid"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:schoolid forKey:@"recordId"];
    
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/Pnotice/findbyidList.do",HOST];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    
        [self.mytableView.header endRefreshing];
        NSString *result = [operation responseString];
        NSLog(@"operation responseString:%@",result);
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
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
                [self.mytableView reloadData];
            }
        }else{
            [self showHint:msg];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.mytableView.header endRefreshing];
        [self showHint:@"连接失败"];
    }];
}

- (void)loadMore{
    if ([page intValue] < [totalpage intValue]) {
        page = [NSNumber numberWithInt:[page intValue] +1];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:userid forKey:@"userid"];
        [dic setValue:page forKey:@"page"];
        [dic setValue:rows forKey:@"rows"];
        [dic setValue:schoolid forKey:@"recordId"];
        NSString *urlString = [NSString stringWithFormat:@"http://%@/Pnotice/findbyidList.do",HOST];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
        [manager GET:urlString parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.mytableView.footer endRefreshing];
            NSString *result = [operation responseString];
            NSError *error;
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            if (resultDict == nil) {
                NSLog(@"json parse failed \r\n");
            }
            NSNumber *success = [resultDict objectForKey:@"success"];
            NSString *msg = [resultDict objectForKey:@"msg"];
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
                    [self.mytableView reloadData];
                }
            }else{
                [self showHint:msg];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.mytableView.footer endRefreshing];
            [self showHint:@"连接失败"];
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
    NSString *tncontent = [info objectForKey:@"tncontent"];
    NSNumber *noticecount = [info objectForKey:@"noticecount"];
    NSString *tncreatedate = [info objectForKey:@"tncreatedate"];
    NSString *source = [info objectForKey:@"noticename"];
    NSString *fileid = [info objectForKey:@"fileid"];
    cell.gtitle.text = tntitle;
    cell.gdispcription.text = tncontent;
    cell.gdispcription.numberOfLines = 2;// 不可少Label属性之一
    cell.gdispcription.lineBreakMode = NSLineBreakByCharWrapping;// 不可少Label属性之二
    //[cell.gdispcription sizeToFit];
    cell.gpinglun.text = [NSString stringWithFormat:@"评论(%@)",noticecount];
    cell.gdate.text = tncreatedate;
    cell.gsource.text = [NSString stringWithFormat:@"来自:%@",source];
    
    if ([Utils isBlankString:fileid]) {
        [cell.imageview setImage:[UIImage imageNamed:@"nopicture.png"]];
    }else{
        [cell.imageview setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
    }
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
    [MobClick beginLogPageView:@"学校公告"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"学校公告"];
}


@end
