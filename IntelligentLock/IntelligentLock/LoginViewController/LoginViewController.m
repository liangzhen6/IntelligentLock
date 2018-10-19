//
//  LoginViewController.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/29.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "LoginViewController.h"
#import "Tools.h"
#import "User.h"
#import <SVProgressHUD.h>

@interface LoginViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIView *usernameLine;
@property (weak, nonatomic) IBOutlet UIView *passwordLine;
@property (weak, nonatomic) IBOutlet UIScrollView *backScrollView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITableView *paddingTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paddingTableHeight;
@property(nonatomic,strong)NSMutableArray * paddingTableData;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    // Do any additional setup after loading the view from its nib.
}

- (void)initView {
    self.iconImage.layer.cornerRadius = 40;
    self.iconImage.layer.borderWidth = 1;
    self.iconImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.username.delegate = self;
    self.password.delegate = self;
    self.loginBtn.layer.cornerRadius = 20;
    
    self.paddingTableView.delegate = self;
    self.paddingTableView.dataSource = self;

    // 监听键盘升起 与 落下
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
//    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self.backScrollView setContentOffset:CGPointMake(0, 163) animated:YES];

}

- (void)keyboardWillHide:(NSNotification *)notification {
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
//    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    [UIView animateWithDuration:duration animations:^{
//        [self.backScrollView setContentOffset:CGPointMake(0, 163) animated:YES];
//    }];
    [self.backScrollView setContentOffset:CGPointMake(0, 0) animated:YES];

}

- (IBAction)scrollViewTapAction:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)removeLogin:(UIButton *)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginAction:(UIButton *)sender {
    if ([self chickUsernamePassword]) {
        [self.view endEditing:YES];
    }
}

- (BOOL)chickUsernamePassword {
    if (![[Tools shareTools] isValidateEmail:_username.text]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的邮箱号码！"];
        [SVProgressHUD dismissWithDelay:1.0];
        return NO;
    }
    if (![_password.text length]) {
        [SVProgressHUD showErrorWithStatus:@"密码不能为空字符！"];
        [SVProgressHUD dismissWithDelay:1.0];
        return NO;
    }
    return YES;
}
#pragma mark---UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == _username) {
        _usernameLine.backgroundColor = [UIColor redColor];
        _passwordLine.backgroundColor = [UIColor lightGrayColor];
    } else {
        _usernameLine.backgroundColor = [UIColor lightGrayColor];
        _passwordLine.backgroundColor = [UIColor redColor];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _usernameLine.backgroundColor = [UIColor lightGrayColor];
    _passwordLine.backgroundColor = [UIColor lightGrayColor];
    if (textField == _username) {
        // 看看是不是 自己的头像
        if ([textField.text isEqualToString:[[User shareUser] username]]) {
            _iconImage.image = [UIImage imageNamed:@"liangzhen"];
        } else {
            _iconImage.image = [UIImage imageNamed:@"header_icon"];
        }
        self.paddingTableHeight.constant = 0;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL chickUsername = NO;
    BOOL chickPassword = NO;
    
    NSMutableString * userName = [[NSMutableString alloc] initWithString:_username.text];
    if (textField == _username) {
        if ([string length]) {
            // 增加字符串
            [userName insertString:string atIndex:range.location];
        } else {
            // 删除字符串
            [userName deleteCharactersInRange:range];
        }
        // 处理动态补全问题
        [self handleUsernameTextFieldChange:userName];
    }

    if ([[Tools shareTools] isValidateEmail:userName]) {
        chickUsername = YES;
    }
    
    NSMutableString * password = [[NSMutableString alloc] initWithString:_password.text];
    if (textField == _password) {
        if ([string length]) {
            // 增加字符串
            [password insertString:string atIndex:range.location];
        } else {
            // 删除字符串
            [password deleteCharactersInRange:range];
        }
    }
    
    if ([password length]) {
        chickPassword = YES;
    }
    
    if (chickUsername && chickPassword) {
        // 邮箱格式正确 密码不为空字符串  登录按钮 变色
        _loginBtn.backgroundColor = [UIColor redColor];
    } else {
        _loginBtn.backgroundColor = RGBColor(255.0, 106.0, 114.0);
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_username == textField) {
        // 密码开始编辑
        [_username resignFirstResponder];
        [_password becomeFirstResponder];
    } else {
        // 登录操作
        if ([self chickUsernamePassword]) {
            [self.view endEditing:YES];
        }
    }
    return YES;
}

#pragma mark --UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.paddingTableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"paddingTable"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    cell.textLabel.text = self.paddingTableData[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.paddingTableHeight.constant = 0;
    self.username.text = self.paddingTableData[indexPath.row];
}

- (void)handleUsernameTextFieldChange:(NSString *)usernameText {
    [self.paddingTableData removeAllObjects];
    NSArray * paddingStrArr = @[@"@163.com", @"@126.com", @"@qq.com",  @"@yeah.net", @"@gmail.com"];
    NSMutableString * keyText = nil;
    NSArray * keyArr = [usernameText componentsSeparatedByString:@"@"];
    NSString * prefixText = keyArr.firstObject;
    
    if ([keyArr count] > 1) {
        keyText = [[NSMutableString alloc] initWithString:usernameText];
        NSRange prefixRange = [usernameText rangeOfString:prefixText];
        // 删除那些前缀
        [keyText deleteCharactersInRange:prefixRange];
        // 把字符串转化为小写
        keyText = [[keyText lowercaseString] mutableCopy];
    }
    if (keyText.length) {
        for (NSString *paddingStr in paddingStrArr) {
            if ([paddingStr hasPrefix:keyText]) {
                [self.paddingTableData addObject:[NSString stringWithFormat:@"%@%@",prefixText,paddingStr]];
            }
        }
    } else {
        if (usernameText.length) {
            // 没有关键字 就是 所有匹配
            for (NSString *paddingStr in paddingStrArr) {
                [self.paddingTableData addObject:[NSString stringWithFormat:@"%@%@",prefixText,paddingStr]];
            }
        }
    }
    self.paddingTableHeight.constant = 40*self.paddingTableData.count;
    [self.paddingTableView reloadData];
}

#pragma mark --UIGestureRecognizerDelegate 处理手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

- (NSMutableArray *)paddingTableData {
    if (_paddingTableData == nil) {
        _paddingTableData = [[NSMutableArray alloc] init];
    }
    return _paddingTableData;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
