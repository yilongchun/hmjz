//
//  GgxqViewController.h
//  hmjz
//  公告详情
//  Created by yons on 14-10-24.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GgxqViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic,copy) NSString *tnid;//公告id

@end
