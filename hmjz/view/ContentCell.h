//
//  ContentCell.h
//  hmjz
//
//  Created by yons on 14-10-31.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentTitle;
@property (weak, nonatomic) IBOutlet UILabel *contentDate;
@property (weak, nonatomic) IBOutlet UILabel *content;

@end
