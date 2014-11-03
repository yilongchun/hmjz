//
//  ChooseClassViewController.h
//  hmjz
//
//  Created by yons on 14-10-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseClassViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSArray *dataSource;
@end
