//
//  GrdaViewController.h
//  hmjz
//
//  Created by yons on 14-10-30.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrdaViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *myimageview;
@property (weak, nonatomic) IBOutlet UITableView *mytableview;

@end
