//
//  RegisterViewController.h
//  hmjz
//
//  Created by yons on 15-7-16.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+RGSize.h"

@interface RegisterViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField2;
@property (weak, nonatomic) IBOutlet UITextField *noTextField;
- (IBAction)chooseSchool:(id)sender;
- (IBAction)chooseRelation:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *chooseSchoolBtn;
@property (weak, nonatomic) IBOutlet UIButton *chooseRelationBtn;

/**
 *  UIPickerView
 */
@property (strong, nonatomic) IBOutlet UIPickerView *myPicker;
@property (strong, nonatomic) IBOutlet UIView *pickerBgView;
@property (strong, nonatomic) UIView *maskView;

@end
