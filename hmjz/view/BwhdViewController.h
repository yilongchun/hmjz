//
//  BwhdViewController.h
//  hmjz
//  班务活动
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BwhdViewController : UIViewController<UITabBarDelegate>

@property(nonatomic, assign) UIViewController *selectedViewController;
@property (weak, nonatomic) IBOutlet UITabBar *mytabbar;
@property(nonatomic, assign) NSInteger selectedViewControllerIndex;
@end
