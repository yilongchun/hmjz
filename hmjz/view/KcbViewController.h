//
//  KcbViewController.h
//  hmjz
//
//  Created by yons on 14-10-31.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KcbViewController : UIViewController

@property (nonatomic, strong) NSArray *dataSource;
@property(nonatomic,copy) NSString *weekName;
@property (weak, nonatomic) IBOutlet UILabel *leftContent;
@property (weak, nonatomic) IBOutlet UILabel *rightContent;

@end
