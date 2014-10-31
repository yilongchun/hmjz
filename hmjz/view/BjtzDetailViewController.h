//
//  BjtzDetailViewController.h
//  hmjz
//
//  Created by yons on 14-10-31.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BjtzDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic,copy) NSString *title;
@end
