//
//  BwhdViewController.m
//  hmjz
//
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "BwhdViewController.h"
#import "GgtzTableViewCell.h"
#import "MBProgressHUD.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "MyViewControllerCellDetail.h"

@interface BwhdViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
}

@end

@implementation BwhdViewController
@synthesize dataSource;
@synthesize mytableview;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    //初始化tableview
    CGRect cg = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    mytableview = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    mytableview.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [mytableview setSeparatorColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
//    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
//        [mytableview setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
//        [mytableview setLayoutMargins:UIEdgeInsetsZero];
//    }
    mytableview.dataSource = self;
    mytableview.delegate = self;
    [self.view addSubview:mytableview];
    
    //添加下拉刷新
//    if (_refreshHeaderView == nil) {
//        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.mytableview.bounds.size.height, self.view.frame.size.width, self.mytableview.bounds.size.height)];
//        view.delegate = self;
//        [mytableview addSubview:view];
//        _refreshHeaderView = view;
//    }
//    //  update the last update date
//    [_refreshHeaderView refreshLastUpdatedDate];

    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    
    
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:10];
    //初始化数据
    [self loadData];

}

//加载数据
- (void)loadData{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    
    NSString *classid = [class objectForKey:@"classid"];
    
    [dic setValue:classid forKey:@"classId"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:@"t_activity_title" forKey:@"type"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/classActivity/findPageList.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
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
            [HUD hide:YES];
//            [self okMsk:@"加载成功"];
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                self.dataSource = [NSMutableArray arrayWithArray:arr];
//                NSLog(@"%lu",(unsigned long)[arr count]);
                [mytableview reloadData];
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
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

- (void)loadMore{
    
    if (page < totalpage) {
        page = [NSNumber numberWithInt:[page intValue] +1];
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    NSString *classid = [class objectForKey:@"classid"];
    
    [dic setValue:classid forKey:@"classId"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:@"t_activity_title" forKey:@"type"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/classActivity/findPageList.do" params:dic httpMethod:@"POST"];
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
            //[self okMsk:@"加载成功"];
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                [self.dataSource addObjectsFromArray:arr];
                [mytableview reloadData];
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
                NSLog(@"%@",totalpage);
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

//成功
- (void)okMsk:(NSString *)msg{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.delegate = self;
    hud.labelText = msg;
    [hud show:YES];
    [hud hide:YES afterDelay:0.5];
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
//    if (page != totalpage && [self.dataSource count] != 0) {
//        return [[self dataSource] count] + 1;
//    }else{
        return [[self dataSource] count];
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if ([self.dataSource count] == indexPath.row) {
//        static NSString *cellIdentifier = @"morecell";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        if (!cell) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//            cell.textLabel.text = @"点击加载更多";
//        }
//        cell.textLabel.textAlignment = NSTextAlignmentCenter;
//        return cell;
//        
//    }else{
        static NSString *cellIdentifier = @"ggtzcell";
        GgtzTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"GgtzTableViewCell" owner:self options:nil] lastObject];
        }
        NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
        NSString *tntitle = [info objectForKey:@"activityTitle"];
        NSString *teacherfileid = [info objectForKey:@"teacherfileid"];
        NSString *tncontent = [info objectForKey:@"activityDigest"];
        NSNumber *noticecount = [info objectForKey:@"count"];
        NSString *tncreatedate = [info objectForKey:@"createDate"];
        NSString *source = [info objectForKey:@"teachername"];
        cell.gtitle.text = tntitle;
        
        if ([Utils isBlankString:teacherfileid]) {
            [cell.imageview setImage:[UIImage imageNamed:@"iOS_42.png"]];
        }else{
            [cell.imageview setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],teacherfileid]] placeholderImage:[UIImage imageNamed:@"iOS_42.png"]];
        }
        cell.gdispcription.text = tncontent;
        cell.gdispcription.numberOfLines = 2;// 不可少Label属性之一
        cell.gdispcription.lineBreakMode = NSLineBreakByCharWrapping;// 不可少Label属性之二
        //[cell.gdispcription sizeToFit];
        cell.gpinglun.text = [NSString stringWithFormat:@"评论(%@)",noticecount];
        cell.gdate.text = tncreatedate;
        cell.gsource.text = [NSString stringWithFormat:@"来自:%@",source];
        return cell;
//    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([self.dataSource count] == indexPath.row) {
//        return 44;
//    }else{
        return 100;
//    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([self.dataSource count] == indexPath.row) {
//        if (page == totalpage) {
//            
//        }else{
//            [HUD show:YES];
//            [self loadMore];
//        }
//        
//    }else{
//        NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
//        NSString *tnid = [info objectForKey:@"tnid"];
//        GgxqViewController *ggxq = [[GgxqViewController alloc]init];
//        ggxq.title = @"公告详情";
//        ggxq.tnid = tnid;
//        [self.navigationController pushViewController:ggxq animated:YES];
//    }
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSString *detailid = [data objectForKey:@"id"];
    MyViewControllerCellDetail *detail = [[MyViewControllerCellDetail alloc] init];
    detail.detailid = detailid;
    detail.title = @"活动详情";
    [self.navigationController pushViewController:detail animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

//- (void)reloadTableViewDataSource{
//    page = [NSNumber numberWithInt:1];
//    [HUD show:YES];
//    [self loadData];
//    //  should be calling your tableviews data source model to reload
//    //  put here just for demo
//    _reloading = YES;
//}
//
//- (void)doneLoadingTableViewData{
//    //  model should call this when its done loading
//    _reloading = NO;
//    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:mytableview];
//    
//}
//
//#pragma mark -
//#pragma mark UIScrollViewDelegate Methods
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
//    
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
//    
//}
//
//
//#pragma mark -
//#pragma mark EGORefreshTableHeaderDelegate Methods
//
//- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
//    
//    [self reloadTableViewDataSource];
//    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
//    
//}
//
//- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
//    return _reloading; // should return if data source model is reloading
//    
//}
//
//- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
//    return [NSDate date]; // should return date data source was last changed
//    
//}
//
//#pragma mark -
//#pragma mark Memory Management
//
//
//
//- (void)viewDidUnload {
//    _refreshHeaderView=nil;
//}
//
//- (void)dealloc {
//    _refreshHeaderView = nil;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
