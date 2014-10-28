//
//  BwhdViewController.m
//  hmjz
//
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "BwhdViewController.h"
#import "Bwhd2ViewController.h"
#import "BjtzViewController.h"

@interface BwhdViewController ()

@end

@implementation BwhdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"班务活动";
    
    //设置被选中的颜色
    [self.mytabbar setSelectedImageTintColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    
    Bwhd2ViewController *vc1 = [[Bwhd2ViewController alloc] init];
    
    BjtzViewController *vc2 = [[BjtzViewController alloc] init];
    vc2.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-49);

    
    [self addChildViewController:vc1];
    [self addChildViewController:vc2];
    
    
    self.selectedViewControllerIndex = 0;
    
}



- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if (self.selectedViewControllerIndex != item.tag) {
        self.selectedViewControllerIndex = item.tag;
    }
}


- (void)setSelectedViewControllerIndex:(NSInteger)index
{
    if (!_selectedViewController) {
        _selectedViewController = self.childViewControllers[index];
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f) {
            CGFloat deltaTop = 20.0f;
            if (self.navigationController && !self.navigationController.navigationBar.translucent) {
                deltaTop = self.navigationController.navigationBar.frame.size.height;
            }
            
            CGRect frame = self.view.frame;
            [_selectedViewController view].frame = CGRectMake(frame.origin.x, frame.origin.y - deltaTop, frame.size.width, frame.size.height-49);
            //            [[_selectedViewController view] sizeToFit];
        } else {
            CGRect frame = self.view.frame;
            [_selectedViewController view].frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height-49);
        }
        [self.view addSubview:[_selectedViewController view]];
        [_selectedViewController didMoveToParentViewController:self];
    } else {
        
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f) {
            [self.childViewControllers[index] view].frame = self.view.frame;
        }
        
        [self transitionFromViewController:_selectedViewController toViewController:self.childViewControllers[index] duration:0.0f options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
            _selectedViewController = self.childViewControllers[index];
            _selectedViewControllerIndex = index;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
