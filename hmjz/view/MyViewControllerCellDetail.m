//
//  MyViewControllerCellDetail.m
//  hmjz
//  班务活动详情
//  Created by yons on 14-10-30.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "MyViewControllerCellDetail.h"
#import "Utils.h"
#import "UIImageView+AFNetworking.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"
#import "ContentCell.h"
#import "PinglunTableViewCell.h"
#import "CustomMoviePlayerViewController.h"
#import "KrVideoPlayerController.h"
#import "TapImageView.h"
#import "ImgScrollView.h"
#import "SRRefreshView.h"
#import "IQKeyboardManager.h"

@interface MyViewControllerCellDetail ()<MBProgressHUDDelegate,TapImageViewDelegate,ImgScrollViewDelegate,UIScrollViewDelegate,SRRefreshDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
    NSNumber *activityType;
    
    UIScrollView *myScrollView;
    NSInteger currentIndex;
    int imgCount;
    UIView *markView;
    UIView *scrollPanel;
    ContentCell *tapCell;
}
@property BOOL  show;
@property (nonatomic, strong) KrVideoPlayerController  *videoController;
@property (strong, nonatomic)UIButton *videoPlayButton;
@property (nonatomic, strong) SRRefreshView         *slimeView;
@end

@implementation MyViewControllerCellDetail
@synthesize mytableview;

- (id)init{
    self = [super init];
    if(self){
        //添加键盘监听器
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification 
                                                   object:nil];		
    }
    
    return self;
}
//提交
-(void)resignTextView
{
    if (textView.text.length == 0) {
        return;
    }
    [HUD show:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *student = [userDefaults objectForKey:@"student"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.detailid forKey:@"recordId"];
    [dic setValue:[userDefaults objectForKey:@"userid"]  forKey:@"userId"];
    [dic setValue:textView.text forKey:@"commentContent"];
    [dic setValue:activityType forKey:@"type"];
    [dic setValue:[student objectForKey:@"studentid"] forKey:@"commentAttr1"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Comment/sava.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
//        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        
        if ([success boolValue]) {
            self.dataSource = [NSMutableArray arrayWithObject:[self.dataSource objectAtIndex:0]];
            page = [NSNumber numberWithInt:1];
//            [self.mytableview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
            [self loadDataPingLun];
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
    
    
    
    [textView resignFirstResponder];
    textView.text = @"";
}
//点击其他位置 隐藏键盘
-(void)hideKeyboard{
    [textView resignFirstResponder];
}

//显示键盘
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}
//隐藏键盘
-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}
//调整文本域高度
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    containerView.frame = r;
}
//初始化文本输入框
-(void)initTextView{
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
    
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    textView.returnKeyType = UIReturnKeyDefault; //just as an example
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"我也说点什么吧...";
    // textView.animateHeightChange = NO; //turns off animation
    [self.view addSubview:containerView];
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    textView.layer.borderColor = [UIColor colorWithRed:221/255.0 green:223/255.0 blue:226/255.0 alpha:1].CGColor;
    textView.layer.borderWidth = 1.0;
    // view hierachy
    [containerView addSubview:imageView];
    [containerView addSubview:textView];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 5, 63, 30);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [doneBtn setTitle:@"提交" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
    
    [doneBtn setBackgroundColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    doneBtn.layer.borderColor = [UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1].CGColor;
    doneBtn.layer.borderWidth = 1.0;
    doneBtn.layer.cornerRadius = 5.0f;
    [containerView addSubview:doneBtn];
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    //添加手势，点击输入框其他区域隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGr.cancelsTouchesInView =NO;
    [self.mytableview addGestureRecognizer:tapGr];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        [self.mytableview setFrame:CGRectMake(0, 0, self.mytableview.frame.size.width, self.mytableview.frame.size.height+64)];
    }
    
    [self initTextView];
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [mytableview setTableFooterView:v];
    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.mytableview addSubview:self.slimeView];
    
    
    
    scrollPanel = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    scrollPanel.backgroundColor = [UIColor clearColor];
    scrollPanel.alpha = 0;
    [self.view addSubview:scrollPanel];
    
    markView = [[UIView alloc] initWithFrame:scrollPanel.bounds];
    markView.backgroundColor = [UIColor blackColor];
    markView.alpha = 0.0;
    [scrollPanel addSubview:markView];
    
    myScrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [scrollPanel addSubview:myScrollView];
    myScrollView.pagingEnabled = YES;
    myScrollView.delegate = self;
    
    
    imgCount = 0;
    
    [self setTitle:self.title];
    [self loadData];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

#pragma mark - getter

- (SRRefreshView *)slimeView
{
    if (!_slimeView) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
        _slimeView.backgroundColor = [UIColor whiteColor];
    }
    
    return _slimeView;
}

//加载内容
- (void)loadData{
    
    
    [HUD show:YES];
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.detailid forKey:@"activityId"];
    [dic setValue:[userdefaults objectForKey:@"userid"] forKey:@"userId"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/pactivity/findbyid.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        //        NSString *code = [resultDict objectForKey:@"code"];
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                self.dataSource = [NSMutableArray arrayWithObject:data];
                
                
                NSArray *filelist = [data objectForKey:@"filelist"];
                if ([filelist count] > 0) {
                    CGSize contentSize = myScrollView.contentSize;
                    contentSize.height = self.view.bounds.size.height;
                    contentSize.width = self.view.bounds.size.width * [filelist count];
                    myScrollView.contentSize = contentSize;
                    imgCount = [filelist count];
                }
                
                activityType = [data objectForKey:@"activityType"];
                [self loadDataPingLun];
                [self.mytableview reloadData];
            }
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
}

//加载评论
- (void)loadDataPingLun{
    
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:10];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.detailid forKey:@"recordId"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:activityType forKey:@"type"];
    MKNetworkOperation *op = [engine operationWithPath:@"/Comment/findPageList.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                [self.dataSource addObjectsFromArray:arr];
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
                [self.mytableview reloadData];
            }
            [HUD hide:YES];
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
}

- (void)loadDataPingLunMore{
    if ([page intValue]< [totalpage intValue]) {
        page = [NSNumber numberWithInt:[page intValue] +1];
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.detailid forKey:@"recordId"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:activityType forKey:@"type"];
    MKNetworkOperation *op = [engine operationWithPath:@"/Comment/findPageList.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                [self.dataSource addObjectsFromArray:arr];
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
                [self.mytableview reloadData];
            }
            [HUD hide:YES];
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([page intValue]!= [totalpage intValue] && [self.dataSource count] != 1) {
        return [[self dataSource] count] + 1;
    }else{
        return [[self dataSource] count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        static NSString *cellIdentifier = @"contentcell";
        ContentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ContentCell" owner:self options:nil] lastObject];
        }
        NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
        NSString *title = [data objectForKey:@"activityTitle"];
        NSString *date = [data objectForKey:@"createDate"];
        NSString *content = [data objectForKey:@"activityContent"];
        NSArray *filelist = [data objectForKey:@"filelist"];
        cell.contentTitle.text = title;
        cell.contentDate.text = date;
        cell.content.text = content;
//            cell.content.text = @"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试";
        cell.content.numberOfLines = 0;
        cell.content.lineBreakMode = NSLineBreakByCharWrapping;
        [cell.content sizeToFit];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width ;
        UIFont *font = [UIFont systemFontOfSize:17];
        CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth-16, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        [cell.content setFrame:CGRectMake(cell.content.frame.origin.x, cell.content.frame.origin.y, cell.content.frame.size.width, size.height)];
        
        if ([filelist count] > 0) {
            NSDictionary *file = [filelist objectAtIndex:0];
            NSString *type = [file objectForKey:@"type"];
            if ([type isEqualToString:@"t_activity_image"]) {//显示图片
                CGFloat x = 0;
                CGFloat y = cell.content.frame.origin.y+10+cell.content.frame.size.height;
                for (int i = 0 ; i < [filelist count]; i++) {
                    file = [filelist objectAtIndex:i];
                    if ((i % 3 == 0) && i != 0) {
                        y += 105;
                    }
                    x = 5+(105 * (i % 3));
                    TapImageView *tmpView = [[TapImageView alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
                    tmpView.t_delegate = self;
                    [tmpView setImageWithURL:[file objectForKey:@"fileId"]];
                    tmpView.tag = 10 + i;
                    [cell.contentView addSubview:tmpView];
                    
                    tmpView = (TapImageView *)[cell.contentView viewWithTag:10+i];
                    tmpView.identifier = cell;
                }
                
                
                
                
//                for (int i = 0; i < 3; i ++)
//                {
//                    TapImageView *tmpView = [[TapImageView alloc] initWithFrame:CGRectMake(5+105*i, 10, 100, 100)];
//                    tmpView.t_delegate = self;
//                    tmpView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i+1]];
//                    tmpView.tag = 10 + i;
//                    [cell.contentView addSubview:tmpView];
//                }
                
                
            }else if ([type isEqualToString:@"t_activity_video"]){//显示视频
                self.videoPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *backgroundImage = [UIImage imageNamed:@"chat_video_play.png"];
                [self.videoPlayButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
                [self.videoPlayButton addTarget:self action:@selector(playVideoAction) forControlEvents:UIControlEventTouchUpInside];
                [self.videoPlayButton setFrame:CGRectMake(10, cell.content.frame.origin.y+10+cell.content.frame.size.height, 50, 50)];
                [cell addSubview:self.videoPlayButton];
            }
        }
        return cell;
    }else{
        if ([self.dataSource count] == indexPath.row) {
            static NSString *cellIdentifier = @"morecell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.textLabel.text = @"点击加载更多";
            }
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            return cell;
            
        }else{
            static NSString *cellIdentifier = @"pingluncell";
            PinglunTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"PinglunTableViewCell" owner:self options:nil] lastObject];
            }
            NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
            
            NSString *fileid = [data objectForKey:@"fileid"];
            NSString *userName = [data objectForKey:@"userName"];
            NSString *commentDate = [data objectForKey:@"commentDate"];
            NSString *commentContent = [data objectForKey:@"commentContent"];
            cell.namelabel.text = userName;
            [cell.namelabel setTextColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
            cell.datelabel.text = commentDate;
            
            //评论内容 高度自适应
            cell.commentlabel.text = commentContent;
            cell.commentlabel.numberOfLines = 0;
            cell.commentlabel.lineBreakMode = NSLineBreakByCharWrapping;
            [cell.commentlabel sizeToFit];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width ;
            UIFont *font = [UIFont systemFontOfSize:14];
            CGSize size = [commentContent sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth-59, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            [cell.commentlabel setFrame:CGRectMake(cell.commentlabel.frame.origin.x, cell.commentlabel.frame.origin.y, cell.commentlabel.frame.size.width, size.height)];
            
            if ([Utils isBlankString:fileid]) {
                [cell.img setImage:[UIImage imageNamed:@"chatListCellHead.png"]];
            }else{
                //            [cell.img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],fileid]] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
                [cell.img setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NSInteger row = [indexPath row];
        // 列寬
        CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width;
        // 用何種字體進行顯示
        UIFont *font = [UIFont systemFontOfSize:17];
        // 該行要顯示的內容
        NSString *content = [[self.dataSource objectAtIndex:row] objectForKey:@"activityContent"];
//            NSString *content = @"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试";
        // 計算出顯示完內容需要的最小尺寸
        CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth-16, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        size.height = size.height + 87;
        NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
        NSArray *filelist = [data objectForKey:@"filelist"];
        if ([filelist count] > 0) {
            NSDictionary *file = [filelist objectAtIndex:0];
            NSString *type = [file objectForKey:@"type"];
            if ([type isEqualToString:@"t_activity_image"]) {//显示图片
                int count = 0;
                if ([filelist count] % 3 == 0) {
                    count = [filelist count] / 3;
                }else{
                    count = [filelist count] / 3 + 1;
                }
                size.height = size.height + 100 * count + 5;
            }else if ([type isEqualToString:@"t_activity_video"]){//显示视频
                size.height = size.height + 70;
            }
        }
        return size.height;
    }else{
        if ([self.dataSource count] == indexPath.row) {
            return 44;
        }else{
            NSInteger row = [indexPath row];
            // 列寬
            CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width-59;
            // 用何種字體進行顯示
            UIFont *font = [UIFont systemFontOfSize:14];
            // 該行要顯示的內容
            NSString *content = [[self.dataSource objectAtIndex:row] objectForKey:@"commentContent"];
            //        NSString *content = @"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测";
            // 計算出顯示完內容需要的最小尺寸
            CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            
            return size.height+60;
        }
        
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataSource count] != 1) {
        if ([self.dataSource count] == indexPath.row) {
            if (page == totalpage) {
                
            }else{
                [HUD show:YES];
                [self loadDataPingLunMore];
            }
        }else{
            
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//提示
- (void)alertMsg:(NSString *)msg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
}

#pragma mark - video

/**
 @method 播放视频
 */
-(void)playVideoAction{
    NSDictionary *data = [self.dataSource objectAtIndex:0];
    NSArray *filelist = [data objectForKey:@"filelist"];
    if ([filelist count] > 0) {
        NSDictionary *video = [filelist objectAtIndex:0];
        NSString *fileId = [video objectForKey:@"fileId"];
        if ([Utils isBlankString:fileId]) {
            [self alertMsg:@"视频地址错误，播放失败"];
            return;
        }
        
        NSURL *url = [NSURL URLWithString:fileId];
        [self addVideoPlayerWithURL:url];
        
//        CustomMoviePlayerViewController *moviePlayer = [[CustomMoviePlayerViewController alloc] init];
//        //将视频地址传过去
//        moviePlayer.movieURL = [NSURL URLWithString:fileId];
//        //然后播放就OK了
//        [moviePlayer readyPlayer];
//        [self presentViewController:moviePlayer animated:YES completion:^{
//        }];
    }
}

- (void)addVideoPlayerWithURL:(NSURL *)url{
    if (!self.videoController) {
        self.videoController = [[KrVideoPlayerController alloc] initWithFrame:self.view.frame];
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
            [weakSelf toolbarHidden:NO];
            weakSelf.show = NO;
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        }];
        [self.videoController setWillBackOrientationPortrait:^{
            [weakSelf toolbarHidden:NO];
            weakSelf.show = YES;
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        }];
        [self.videoController setWillChangeToFullscreenMode:^{
            [weakSelf toolbarHidden:YES];
            weakSelf.show = YES;
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        }];
        [self.videoController showInWindow];
        self.show = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    self.videoController.contentURL = url;
}

- (void)toolbarHidden:(BOOL)Bool{
    //    self.navigationController.navigationBar.hidden = Bool;
    //    self.tabBarController.tabBar.hidden = Bool;
    //    [[UIApplication sharedApplication] setStatusBarHidden:Bool];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
    //UIStatusBarStyleDefault = 0 黑色文字，浅色背景时使用
    //UIStatusBarStyleLightContent = 1 白色文字，深色背景时使用
}

- (BOOL)prefersStatusBarHidden
{
    return self.show; // 返回NO表示要显示，返回YES将hiden
}


#pragma mark -
#pragma mark - custom method
- (void) addSubImgView
{
    for (UIView *tmpView in myScrollView.subviews)
    {
        [tmpView removeFromSuperview];
    }
    
    for (int i = 0; i < imgCount; i ++)
    {
        if (i == currentIndex)
        {
            continue;
        }
        
        TapImageView *tmpView = (TapImageView *)[tapCell viewWithTag:10 + i];
        
        //转换后的rect
        CGRect convertRect = [[tmpView superview] convertRect:tmpView.frame toView:self.view];
        
        ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){i*myScrollView.bounds.size.width,0,myScrollView.bounds.size}];
        [tmpImgScrollView setContentWithFrame:convertRect];
        [tmpImgScrollView setImage:tmpView.image];
        [myScrollView addSubview:tmpImgScrollView];
        tmpImgScrollView.i_delegate = self;
        
        [tmpImgScrollView setAnimationRect];
    }
}

- (void) setOriginFrame:(ImgScrollView *) sender
{
    [UIView animateWithDuration:0.2 animations:^{
        [sender setAnimationRect];
        markView.alpha = 1.0;
        [self.navigationController setNavigationBarHidden:YES];
    }];
}

#pragma mark -
#pragma mark - custom delegate
- (void) tappedWithObject:(id)sender
{
    
    [self.view bringSubviewToFront:scrollPanel];
    scrollPanel.alpha = 1.0;
    
    TapImageView *tmpView = sender;
    currentIndex = tmpView.tag - 10;
    
    tapCell = tmpView.identifier;
    
    //转换后的rect
    CGRect convertRect = [[tmpView superview] convertRect:tmpView.frame toView:self.view];
    
    CGPoint contentOffset = myScrollView.contentOffset;
    contentOffset.x = currentIndex*self.view.frame.size.width;
    myScrollView.contentOffset = contentOffset;
    
    //添加
    [self addSubImgView];
    
    ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){contentOffset,myScrollView.bounds.size}];
    [tmpImgScrollView setContentWithFrame:convertRect];
    [tmpImgScrollView setImage:tmpView.image];
    [myScrollView addSubview:tmpImgScrollView];
    tmpImgScrollView.i_delegate = self;
    
    [self performSelector:@selector(setOriginFrame:) withObject:tmpImgScrollView afterDelay:0.1];
    
}

- (void) tapImageViewTappedWithObject:(id)sender
{
    [self.navigationController setNavigationBarHidden:NO];
    ImgScrollView *tmpImgView = sender;
    
    [UIView animateWithDuration:0.2 animations:^{
        markView.alpha = 0;
        [tmpImgView rechangeInitRdct];
    } completion:^(BOOL finished) {
        scrollPanel.alpha = 0;
    }];
    
}

#pragma mark -
#pragma mark - scrollView delegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    currentIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
}

#pragma mark - slimeRefresh delegate
//刷新消息列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    
    [self loadData];
    [_slimeView endRefresh];
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
