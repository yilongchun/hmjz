//
//  MyViewControllerCellDetail.m
//  hmjz
//
//  Created by yons on 14-10-30.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "MyViewControllerCellDetail.h"
#import "Utils.h"
#import "UIImageView+AFNetworking.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"

@interface MyViewControllerCellDetail ()<MBProgressHUDDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
}

@end

@implementation MyViewControllerCellDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"%@",self.detailid);
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    [self setTitle:self.title];
    
    [self loadData];
}

- (void)loadData{
    [HUD show:YES];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.detailid forKey:@"activityId"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/classActivity/findbyid.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        //        NSString *msg = [resultDict objectForKey:@"msg"];
        //        NSString *code = [resultDict objectForKey:@"code"];
        if ([success boolValue]) {
            [HUD hide:YES];
            
//            NSDictionary *data = [resultDict objectForKey:@"data"];
//            if (data != nil) {
//                NSArray *arr = [data objectForKey:@"rows"];
//                self.dataSource = [NSMutableArray arrayWithArray:arr];
//                [self.mytableview reloadData];
//                NSNumber *total = [data objectForKey:@"total"];
//                if ([total intValue] % [rows intValue] == 0) {
//                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
//                }else{
//                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
//                }
//                NSLog(@"%@",totalpage);
//                
//            }
        }else{
            [HUD hide:YES];
            
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        
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

@end
