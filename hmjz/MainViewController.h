//
//  MainViewController.h
//  hmjz
//  首页
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<UINavigationControllerDelegate>

- (IBAction)ysdtAction:(UIButton *)sender;
- (IBAction)bwhdAction:(UIButton *)sender;
- (IBAction)yezxAction:(UIButton *)sender;
- (IBAction)jzydAction:(UIButton *)sender;
- (IBAction)kcbAction:(UIButton *)sender;
- (IBAction)bbspAction:(UIButton *)sender;
- (IBAction)bbqdAction:(UIButton *)sender;
- (IBAction)xztAction:(UIButton *)sender;
@property(nonatomic,copy) NSString *userid;

@end
