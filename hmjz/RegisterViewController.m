//
//  RegisterViewController.m
//  hmjz
//
//  Created by yons on 15-7-16.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import "RegisterViewController.h"
#import "MKNetworkKit.h"
#import "UIViewController+HUD.h"
#import "Utils.h"
#import "IQKeyboardManager.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController{
    NSMutableArray *schoolArr;
    NSMutableArray *relationArr;
    NSInteger selectedIndex;
    NSInteger selectedIndex2;
    int pickerType;
    
    MKNetworkEngine *engine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"注册";
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = done;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    self.phoneTextField.leftViewMode = UITextFieldViewModeAlways;
    self.phoneTextField.leftView = view;
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.leftView = view2;
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    self.passwordTextField2.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField2.leftView = view3;
    UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    self.noTextField.leftViewMode = UITextFieldViewModeAlways;
    self.noTextField.leftView = view4;
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    [self initView];//初始化弹出选择控件
    [self initPickerData];//初始化选择数据
    
}

#pragma mark - init view
- (void)initView {
    self.maskView = [[UIView alloc] initWithFrame:kScreen_Frame];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0.3;
    [self.maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMyPicker)]];
    self.pickerBgView.width = kScreen_Width;
}
//初始化选择数据
-(void)initPickerData{
    
    relationArr = [NSMutableArray arrayWithObjects:@"爸爸",@"妈妈",@"爷爷",@"奶奶",@"外公",@"外婆", nil];
    
    [self showHudInView:self.view hint:@"加载中"];
    MKNetworkOperation *op = [engine operationWithPath:@"/School/findAll.do" params:nil httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        [self hideHud];
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        DLog(@"%@",resultDict);
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            NSArray *array = [resultDict objectForKey:@"data"];
            schoolArr = [NSMutableArray arrayWithArray:array];
        }else{
            [self showHint:@"获取学校信息失败"];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hideHud];
    }];
    [engine enqueueOperation:op];
}

#pragma mark - private method
- (void)showMyPicker {
    [self.myPicker reloadAllComponents];
    
    switch (pickerType) {
        case 1:
        {
            [self.myPicker selectRow:selectedIndex inComponent:0 animated:YES];
            break;
        }
            break;
        case 2:
        {
            [self.myPicker selectRow:selectedIndex2 inComponent:0 animated:YES];
            break;
        }
        default:
            break;
    }

    [self.view addSubview:self.maskView];
    [self.view addSubview:self.pickerBgView];
    self.maskView.alpha = 0.3;
    self.pickerBgView.top = self.view.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0.3;
        self.pickerBgView.bottom = self.view.height;
    }];
}

- (void)hideMyPicker {
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0;
        self.pickerBgView.top = self.view.height;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
        [self.pickerBgView removeFromSuperview];
    }];
}
#pragma mark - xib click
- (IBAction)cancel:(id)sender {
    [self hideMyPicker];
}

- (IBAction)ensure:(id)sender {
    switch (pickerType) {
        case 1:
        {
            NSDictionary *info = [schoolArr objectAtIndex:selectedIndex];
            NSString *schoolName = [info objectForKey:@"schoolName"];
            [self.chooseSchoolBtn setTitle:[NSString stringWithFormat:@"   %@",schoolName] forState:UIControlStateNormal];
            [self.chooseSchoolBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
            break;
        case 2:
        {
            NSString *relationName = [relationArr objectAtIndex:selectedIndex2];
            [self.chooseRelationBtn setTitle:[NSString stringWithFormat:@"   %@",relationName] forState:UIControlStateNormal];
            [self.chooseRelationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
    [self hideMyPicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPicker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (pickerType) {
        case 1:
            return [schoolArr count];
            break;
        case 2:
            return [relationArr count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (pickerType) {
        case 1:
        {
            NSDictionary *info = [schoolArr objectAtIndex:row];
            NSString *schoolName = [info objectForKey:@"schoolName"];
            return schoolName;
        }
            break;
        case 2:
            return [relationArr objectAtIndex:row];
            break;
        default:
            return @"";
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (pickerType) {
        case 1:
        {
            selectedIndex = row;
            NSDictionary *info = [schoolArr objectAtIndex:selectedIndex];
            NSString *schoolName = [info objectForKey:@"schoolName"];
            [self.chooseSchoolBtn setTitle:[NSString stringWithFormat:@"   %@",schoolName] forState:UIControlStateNormal];
            [self.chooseSchoolBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
            break;
        case 2:
        {
            selectedIndex2 = row;
            NSString *relationName = [relationArr objectAtIndex:selectedIndex2];
            [self.chooseRelationBtn setTitle:[NSString stringWithFormat:@"   %@",relationName] forState:UIControlStateNormal];
            [self.chooseRelationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
}

- (IBAction)chooseSchool:(id)sender {
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    pickerType = 1;
    [self showMyPicker];
}

- (IBAction)chooseRelation:(id)sender {
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    pickerType = 2;
    [self showMyPicker];
}

-(void)done{
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    
    if (self.phoneTextField.text.length < 11) {
        [self showHint:@"请填写完整的手机号码"];
        return;
    }
    if (self.passwordTextField.text.length < 6) {
        [self showHint:@"请填写至少6位数密码"];
        return;
    }
    if (![self.passwordTextField2.text isEqualToString:self.passwordTextField.text]) {
        [self showHint:@"两次密码不一致，请重新输入"];
        return;
    }
    if (self.noTextField.text.length == 0) {
        [self showHint:@"请填写宝宝学号"];
        return;
    }
    if ([self.chooseSchoolBtn.currentTitle isEqualToString:@"   请选择幼儿园"]) {
        [self showHint:@"请选择幼儿园"];
        return;
    }
    if ([self.chooseRelationBtn.currentTitle isEqualToString:@"   请选择关系"]) {
        [self showHint:@"请选择关系"];
        return;
    }
    
    NSDictionary *info = [schoolArr objectAtIndex:selectedIndex];
    NSString *schoolId = [info objectForKey:@"id"];
    NSString *relationName = [relationArr objectAtIndex:selectedIndex2];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:self.phoneTextField.text forKey:@"userId"];
    [params setObject:self.passwordTextField.text forKey:@"password"];
    [params setObject:self.noTextField.text forKey:@"studentCode"];
    [params setObject:schoolId forKey:@"schoolId"];
    [params setObject:relationName forKey:@"relationName"];
    
    [self showHudInView:self.view hint:@"加载中"];
    MKNetworkOperation *op = [engine operationWithPath:@"/app/PRegister.do" params:params httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        [self hideHud];
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        DLog(@"%@",resultDict);
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        [self showHint:msg];
        if ([success boolValue]) {
            [self performSelector:@selector(back) withObject:nil afterDelay:1.5];
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hideHud];
    }];
    [engine enqueueOperation:op];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:self.phoneTextField.text forKey:@"userId"];
    [params setObject:self.passwordTextField.text forKey:@"password"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"registerSuccessedAndLogin" object:nil userInfo:params];
}
@end
