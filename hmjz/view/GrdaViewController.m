//
//  GrdaViewController.m
//  hmjz
//
//  Created by yons on 14-10-30.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "GrdaViewController.h"
#import "Utils.h"
#import "UIImageView+AFNetworking.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"

@interface GrdaViewController ()<MBProgressHUDDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
    NSString *name;
    NSNumber *age;
    NSString *sex;
    NSString *classname;
}

@end

@implementation GrdaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    [self setTitle:@"个人档案"];
    
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateImgAction:)];
    [self.myimageview addGestureRecognizer:singleTap1];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
    }else{
        [self.myimageview setFrame:CGRectMake(self.myimageview.frame.origin.x, self.myimageview.frame.origin.y-64, self.myimageview.frame.size.width, self.myimageview.frame.size.height)];
        [self.mytableview setFrame:CGRectMake(self.mytableview.frame.origin.x, self.mytableview.frame.origin.y-64, self.mytableview.frame.size.width, self.mytableview.frame.size.height)];
        [self.headbackgroundimg setFrame:CGRectMake(self.headbackgroundimg.frame.origin.x, self.headbackgroundimg.frame.origin.y-64, self.headbackgroundimg.frame.size.width, self.headbackgroundimg.frame.size.height)];
    }
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    [self.mytableview setSeparatorColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    [self loadData];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"上传中";
    [self.view addSubview:HUD];
    HUD.delegate = self;
}

- (void)loadData{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *student = [userDefaults objectForKey:@"student"];
    name = [student objectForKey:@"studnetname"];
    age = [student objectForKey:@"age"];
    NSNumber *sexnum = [student objectForKey:@"studentsex"];
    if ([sexnum intValue]== 0) {
        sex = @"女";
    }else if ([sexnum intValue]== 1){
        sex = @"男";
    }
    
    NSDictionary *class= [userDefaults objectForKey:@"class"];
    classname = [class objectForKey:@"classname"];
    NSString *flieid = [student objectForKey:@"flieid"];
    
    //设置头像
    if ([Utils isBlankString:flieid]) {
        [self.myimageview setImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    }else{
//        [self.myimageview setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],flieid]] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
        [self.myimageview setImageWithURL:[NSURL URLWithString:flieid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
        
//        [self.myimageview setImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getHostname],flieid]] placeHolderImage:[UIImage imageNamed:@"nopicture.png"] usingEngine:engine animation:YES];
    }
    
    self.myimageview.layer.cornerRadius = self.myimageview.frame.size.height/2;
    self.myimageview.layer.masksToBounds = YES;
    [self.myimageview setContentMode:UIViewContentModeScaleAspectFill];
    [self.myimageview setClipsToBounds:YES];
    self.myimageview.layer.borderColor = [UIColor yellowColor].CGColor;
    self.myimageview.layer.borderWidth = 1.0f;
    self.myimageview.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    self.myimageview.layer.shadowOpacity = 0.5;
    self.myimageview.layer.shadowRadius = 2.0;
    
    
    
    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableViewDatasource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"姓名：%@",name];
            break;
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"年龄：%@",age];
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"性别：%@",sex];
            break;
        case 3:
            cell.textLabel.text = [NSString stringWithFormat:@"班级：%@",classname];
            break;
            
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([self.dataSource count] == indexPath.row) {
//        return 44;
//    }else{
//        return 100;
//    }
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//点击头像 修改照片
- (void)updateImgAction:(UITapGestureRecognizer *)sender{
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择", nil];
    [actionsheet showInView:self.view];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex) {
        case 0://照相机
        {
            //检查相机模式是否可用
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                NSLog(@"sorry, no camera or camera is unavailable.");
                return;
            }
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects:@"public.image", nil];
//            imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
            [self presentViewController:imagePicker animated:YES completion:^{
                
            }];
            
        }
            break;
        case 1://本地相簿
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects:@"public.image", nil];
            [self presentViewController:imagePicker animated:YES completion:^{
                
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        UIImage  *img = [info objectForKey:UIImagePickerControllerEditedImage];
        NSData *fildData = UIImageJPEGRepresentation(img, 0.5);//UIImagePNGRepresentation(img); //
        [self uploadImg:fildData];
        //        self.fileData = UIImageJPEGRepresentation(img, 1.0);
    }
//    else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"kUTTypeMovie"]) {
//        NSString *videoPath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
//        self.fileData = [NSData dataWithContentsOfFile:videoPath];
//    }
    [picker dismissViewControllerAnimated:YES completion:^{
        [HUD show:YES];
        
    }];
}
//上传图片
-(void)uploadImg:(NSData *)fileData{
    
    //将文件保存到本地
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:@"saveFore.jpg"];
    BOOL saveFlag = [fileData writeToFile:savedImagePath atomically:YES];
    
    
    MKNetworkOperation *op =[engine operationWithURLString:[NSString stringWithFormat:@"http://%@/image/upload.do",[Utils getImageHostname]] params:nil httpMethod:@"POST"];
    [op addFile:savedImagePath forKey:@"allFile"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            //上传成功 删除文件  还有返回的问题
            [self updateImgData:[resultDict objectForKey:@"data"]];
            
        }else{
            [self showHint:@"上传失败"];
        }
        if (saveFlag) {
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *err;
            [fileMgr removeItemAtPath:savedImagePath error:&err];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        if (saveFlag) {
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *err;
            [fileMgr removeItemAtPath:savedImagePath error:&err];
        }
        [HUD hide:YES];
        [self showHint:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
    
    
}
//修改数据
- (void)updateImgData:(NSString *)fileid{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *student = [userDefaults objectForKey:@"student"];
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:[userDefaults objectForKey:@"userid"] forKey:@"userid"];
    [dic setValue:fileid forKey:@"fileid"];
    [dic setValue:[student objectForKey:@"studentid"] forKey:@"studentid"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Puser/updateimage.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
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
            [self.myimageview setImageWithURL:[NSURL URLWithString:fileid]];
            [HUD hide:YES];
            
            NSMutableDictionary *updatestudent = [[NSMutableDictionary alloc] initWithDictionary:[userDefaults objectForKey:@"student"]];
            [updatestudent setValue:fileid forKey:@"flieid"];
//            [userDefaults removeObjectForKey:@"student"];
            [userDefaults setObject:updatestudent forKey:@"student"];
            [userDefaults setObject:@"1" forKey:@"updateImgFlag"];
            UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            [self showHint:msg customView:imageview];
        }else{
            [HUD hide:YES];
            [self showHint:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self showHint:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"个人档案"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"个人档案"];
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
