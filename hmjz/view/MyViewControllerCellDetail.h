//
//  MyViewControllerCellDetail.h
//  hmjz
//
//  Created by yons on 14-10-30.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyViewControllerCellDetail : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic,copy) NSString *detailid;
@property (nonatomic,copy) NSString *title;

@end
