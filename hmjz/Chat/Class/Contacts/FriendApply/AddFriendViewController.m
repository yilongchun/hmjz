/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "AddFriendViewController.h"

#import "ApplyViewController.h"
#import "UIViewController+HUD.h"
#import "AddFriendCell.h"
#import "ApplyEntity.h"
#import "WCAlertView.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "ChatViewController.h"
#import "UIImageView+AFNetworking.h"
#import "FriendCell.h"

@interface AddFriendViewController ()<UITextFieldDelegate, UIAlertViewDelegate>{
    MKNetworkEngine *engine;
    
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
}

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation AddFriendViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _dataSource = [NSMutableArray array];
        //初始化网络引擎
        engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
        
    }
    return self;
}

- (void)loadData{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *class = [userDefaults objectForKey:@"class"];
    NSString *classid = [class objectForKey:@"classid"];
    [dic setValue:classid forKey:@"classId"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Parentfield/findTlist.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
//        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                [self.dataSource addObjectsFromArray:arr];
                
                
                
//                [userDefaults setObject:arr forKey:@"friendarr"];
                
                
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
                [self.tableView reloadData];
            }
        }else{
            
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:10];
    
    [self loadData];
    
	// Do any additional setup after loading the view.
//    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
//    {
//        [self setEdgesForExtendedLayout:UIRectEdgeNone];
//    }
    self.title = @"小纸条";
    self.view.backgroundColor = [UIColor whiteColor];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    //self.tableView.tableHeaderView = self.headerView;
    
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    self.tableView.tableFooterView = footerView;
    [self.view addSubview:self.textField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

//- (UITextField *)textField
//{
//    if (_textField == nil) {
//        _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 40)];
//        _textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//        _textField.layer.borderWidth = 0.5;
//        _textField.layer.cornerRadius = 3;
//        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
//        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//        _textField.leftViewMode = UITextFieldViewModeAlways;
//        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        _textField.font = [UIFont systemFontOfSize:15.0];
//        _textField.backgroundColor = [UIColor whiteColor];
//        _textField.placeholder = @"输入要查找的好友";
//        _textField.returnKeyType = UIReturnKeyDone;
//        _textField.delegate = self;
//    }
//    
//    return _textField;
//}

- (UIView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
        _headerView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
        
        [_headerView addSubview:_textField];
    }
    
    return _headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    if (section == 0) {
//        return [self.dataSource count];
//    }else{
        return [self.dataSource count];
//    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"friendcell";
        
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        //    AddFriendCell *cell = (AddFriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            //        cell = [[AddFriendCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:self options:nil] lastObject];
        }
        NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
        NSString *name = [data objectForKey:@"parentname"];
        NSString *relationname = [data objectForKey:@"relationname"];
        NSString *fileid = [data objectForKey:@"fileid"];
        [cell.myimageview setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
        //    [cell.imageView setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
        cell.namelabel.text = name;
        //    cell.textLabel.text = name;
        cell.detaillabel.text = relationname;
        //    cell.detailTextLabel.text = relationname;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else{
        static NSString *CellIdentifier = @"friendcell";
        
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        //    AddFriendCell *cell = (AddFriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            //        cell = [[AddFriendCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:self options:nil] lastObject];
        }
        NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
        NSString *name = [data objectForKey:@"parentname"];
        NSString *relationname = [data objectForKey:@"relationname"];
        NSString *fileid = [data objectForKey:@"fileid"];
        [cell.myimageview setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
        //    [cell.imageView setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
        cell.namelabel.text = name;
        //    cell.textLabel.text = name;
        cell.detaillabel.text = relationname;
        //    cell.detailTextLabel.text = relationname;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 51;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndexPath = indexPath;
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSString *hxusercode = [data objectForKey:@"hxusercode"];
    NSString *username = [data objectForKey:@"parentname"];
    
    NSString *buddyName = hxusercode;
    
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    if ([loginUsername isEqualToString:buddyName]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"不能跟自己聊天" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
//    if ([self didBuddyExist:buddyName]) {
//        NSString *message = [NSString stringWithFormat:@"'%@'已经是你的好友了!", username];
//        [WCAlertView showAlertWithTitle:message
//                                message:nil
//                     customizationBlock:nil
//                        completionBlock:nil
//                      cancelButtonTitle:@"确定"
//                      otherButtonTitles: nil];
//        
//    }
    
    else{
        ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:hxusercode isGroup:NO];
        chatVC.title = username;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
//    else if([self hasSendBuddyRequest:buddyName])
//    {
//        NSString *message = [NSString stringWithFormat:@"您已向'%@'发送好友请求了!", username];
//        [WCAlertView showAlertWithTitle:message
//                                message:nil
//                     customizationBlock:nil
//                        completionBlock:nil
//                      cancelButtonTitle:@"确定"
//                      otherButtonTitles: nil];
//
//    }else{
    
//        EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
//        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
//        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
//        if (loginUsername && loginUsername.length > 0) {
//            if ([loginUsername isEqualToString:buddy.username]) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"不能跟自己聊天" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alertView show];
//                
//                return;
//            }
//        }
        
    
        
        
        
        //发送加好友申请
//        [self showMessageAlertView];
//    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//- (NSString *)tableView:(UITableView *)tableView
//
//titleForHeaderInSection:(NSInteger)section {
//    
//    NSString *key = @"A";
//    
//    return key;
//    
//}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    
//    NSArray *arr = [NSArray arrayWithObjects:@"A",@"B",@"C", nil];
//    return arr;
//    
//}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - action

- (void)searchAction
{
    [_textField resignFirstResponder];
    if(_textField.text.length > 0)
    {
    //warning 由用户体系的用户，需要添加方法在已有的用户体系中查询符合填写内容的用户
    //warning 以下代码为测试代码，默认用户体系中有一个符合要求的同名用户
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
        if ([_textField.text isEqualToString:loginUsername]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"不能添加自己为好友" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
        }
        
        //判断是否已发来申请
        NSArray *applyArray = [[ApplyViewController shareController] dataSource];
        if (applyArray && [applyArray count] > 0) {
            for (ApplyEntity *entity in applyArray) {
                ApplyStyle style = [entity.style intValue];
                BOOL isGroup = style == ApplyStyleFriend ? NO : YES;
                if (!isGroup && [entity.applicantUsername isEqualToString:_textField.text]) {
                    NSString *str = [NSString stringWithFormat:@"%@已经给你发来了申请", _textField.text];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    
                    return;
                }
            }
        }
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObject:_textField.text];
        [self.tableView reloadData];
    }
}

- (BOOL)hasSendBuddyRequest:(NSString *)buddyName
{
    NSArray *buddyList = [[[EaseMob sharedInstance] chatManager] buddyList];
    for (EMBuddy *buddy in buddyList) {
        if ([buddy.username isEqualToString:buddyName] &&
            buddy.followState == eEMBuddyFollowState_NotFollowed &&
            buddy.isPendingApproval) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)didBuddyExist:(NSString *)buddyName{
    NSArray *buddyList = [[[EaseMob sharedInstance] chatManager] buddyList];
    for (EMBuddy *buddy in buddyList) {
        if ([buddy.username isEqualToString:buddyName] &&
            buddy.followState != eEMBuddyFollowState_NotFollowed) {
            return YES;
        }
    }
    return NO;
}

- (void)showMessageAlertView{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"说点啥子吧" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView cancelButtonIndex] != buttonIndex) {
        UITextField *messageTextField = [alertView textFieldAtIndex:0];
        
        NSString *messageStr = @"";
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *username = [loginInfo objectForKey:kSDKUsername];
        if (messageTextField.text.length > 0) {
            messageStr = [NSString stringWithFormat:@"%@：%@", username, messageTextField.text];
        }
        else{
            messageStr = [NSString stringWithFormat:@"%@ 邀请你为好友", username];
        }
        [self sendFriendApplyAtIndexPath:self.selectedIndexPath
                                 message:messageStr];
    }
}

- (void)sendFriendApplyAtIndexPath:(NSIndexPath *)indexPath
                           message:(NSString *)message
{
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSString *hxusercode = [data objectForKey:@"hxusercode"];
    
    NSString *buddyName = hxusercode;
    if (buddyName && buddyName.length > 0) {
        [self showHudInView:self.view hint:@"正在发送申请..."];
        EMError *error;
        [[EaseMob sharedInstance].chatManager addBuddy:buddyName message:message error:&error];
        [self hideHud];
        if (error) {
            [self showHint:@"发送申请失败，请重新操作"];
        }
        else{
            [self showHint:@"发送申请成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
