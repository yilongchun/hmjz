//
//  ChildrenTableViewCell.m
//  hmjz
//
//  Created by yons on 14-11-3.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "ChildrenTableViewCell.h"

@implementation ChildrenTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线，
//        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1].CGColor);
//        CGContextStrokeRect(context, CGRectMake(0, 0, rect.size.width, 1));
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
    
}

@end