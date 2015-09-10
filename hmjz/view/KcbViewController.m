//
//  KcbViewController.m
//  hmjz
//
//  Created by yons on 14-10-31.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "KcbViewController.h"

@interface KcbViewController ()


@end

@implementation KcbViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadData];
    
}

- (void)loadData{
    
    if (self.dataSource.count > 0) {
        NSString *leftstr = [[NSMutableString alloc] initWithString:@""];
        NSString *rightstr = [[NSMutableString alloc] initWithString:@""];
        if ([self.dataSource count] > 9) {
            for (int i = 0 ; i < 9; i++) {
                NSDictionary *data = [self.dataSource objectAtIndex:i];
                NSString *starttime = [data objectForKey:@"startTime"];
                NSString *content = [data objectForKey:self.weekName];
                leftstr = [leftstr stringByAppendingString:starttime];
                leftstr = [leftstr stringByAppendingString:@" "];
                leftstr = [leftstr stringByAppendingString:content];
                leftstr = [leftstr stringByAppendingString:@"\n"];
            }
            for (int i = 9; i < [self.dataSource count]; i++) {
                NSDictionary *data = [self.dataSource objectAtIndex:i];
                NSString *starttime = [data objectForKey:@"startTime"];
                NSString *content = [data objectForKey:self.weekName];
                rightstr = [rightstr stringByAppendingString:starttime];
                rightstr = [rightstr stringByAppendingString:@" "];
                rightstr = [rightstr stringByAppendingString:content];
                rightstr = [rightstr stringByAppendingString:@"\n"];
            }
        }else{
            for (int i = 0 ; i < [self.dataSource count]; i++) {
                NSDictionary *data = [self.dataSource objectAtIndex:i];
                NSString *starttime = [data objectForKey:@"startTime"];
                NSString *content = [data objectForKey:self.weekName];
                leftstr = [leftstr stringByAppendingString:starttime];
                leftstr = [leftstr stringByAppendingString:@" "];
                leftstr = [leftstr stringByAppendingString:content];
                leftstr = [leftstr stringByAppendingString:@"\n"];
            }
        }
        
        self.leftContent.text = leftstr;
        NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:self.leftContent.text];
        NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle1 setLineSpacing:3];
        [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [self.leftContent.text length])];
        [self.leftContent setAttributedText:attributedString1];
        [self.leftContent sizeToFit];
        
        self.rightContent.text = rightstr;
        NSMutableAttributedString * attributedString2 = [[NSMutableAttributedString alloc] initWithString:self.rightContent.text];
        NSMutableParagraphStyle * paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle2 setLineSpacing:3];
        [attributedString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [self.rightContent.text length])];
        [self.rightContent setAttributedText:attributedString2];
        [self.rightContent sizeToFit];
        CGFloat height = self.leftContent.frame.size.height;
        if (self.rightContent.frame.size.height > height) {
            height = self.rightContent.frame.size.height;
        }
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
            if (iPhone4) {
                height += 50;
            }
        }else{
            height += 64;
        }
        [self.conBackground setFrame:CGRectMake(self.conBackground.frame.origin.x, self.conBackground.frame.origin.y, self.conBackground.frame.size.width, height+80+44)];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 禁用 iOS7 返回手势
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"课程表"];
    
    // 开启
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"课程表"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
