//
//  GgtzViewController.h
//  hmjz
//  公告通知
//  Created by yons on 14-10-24.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface GgtzViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate>{
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    //  Reloading var should really be your tableviews datasource
    //  Putting it here for demo purposes
    BOOL _reloading;
}

@property (nonatomic, strong) UITableView *mytableView;
@property (nonatomic, strong) NSArray *dataSource;
@property(nonatomic,copy) NSString *userid;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
