//
//  GgtzViewController.m
//  hmjz
//
//  Created by yons on 14-10-24.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "GgtzViewController.h"
#import "GgtzTableViewCell.h"
#import"MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "GgxqViewController.h"

@interface GgtzViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
}
    


@end

@implementation GgtzViewController
@synthesize dataSource;
@synthesize mytableView;

- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化tableview
    CGRect cg = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    mytableView = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    [mytableView setSeparatorColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    if ([mytableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [mytableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([mytableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [mytableView setLayoutMargins:UIEdgeInsetsZero];
    }
    mytableView.dataSource = self;
    mytableView.delegate = self;
    [self.view addSubview:mytableView];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    //初始化数据
    [self loadData];
    
}

//加载数据
- (void)loadData{
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    //userid=23b3850a-8758-48e6-9027-122388f07a7b&page=1&rows=15&recordId=
    
    [dic setValue:@"9edd09c5-2b5f-47f6-8cd0-5479d268d338" forKey:@"userid"];
    [dic setValue:@"1" forKey:@"page"];
    [dic setValue:@"10" forKey:@"rows"];
    [dic setValue:@"8671eb9e-c834-41dd-8e37-62c1ac730c65" forKey:@"recordId"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/sma/Pnotice/findbyidList.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
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
            [HUD hide:YES];
            [self okMsk:@"加载成功"];
            
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *rows = [data objectForKey:@"rows"];
                self.dataSource = rows;
                [self.mytableView reloadData];
//                NSDictionary *total = [data objectForKey:@"total"];
//                NSLog(@"%@",rows);
                
            }
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:@"请求失败"];
    }];
    [engine enqueueOperation:op];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)okMsk:(NSString *)msg{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.delegate = self;
    HUD.labelText = msg;
    [HUD show:YES];
    [HUD hide:YES afterDelay:0.5];
}


//提示
- (void)alertMsg:(NSString *)msg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.5];
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
    cell.gtitle.text = tntitle;
    cell.gdispcription.text = tncontent;
    cell.gdispcription.numberOfLines = 2;// 不可少Label属性之一
    cell.gdispcription.lineBreakMode = NSLineBreakByCharWrapping;// 不可少Label属性之二
    [cell.gdispcription sizeToFit];
    cell.gpinglun.text = [NSString stringWithFormat:@"评论(%@)",noticecount];
    cell.gdate.text = tncreatedate;
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
    NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
    NSString *tnid = [info objectForKey:@"tnid"];
    GgxqViewController *ggxq = [[GgxqViewController alloc]init];
    ggxq.title = @"公告详情";
    ggxq.tnid = tnid;
    [self.navigationController pushViewController:ggxq animated:YES];
    
}





@end
