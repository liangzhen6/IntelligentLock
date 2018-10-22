//
//  LeftMenuViewController.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/29.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "SettTableViewCell.h"
#import "SettSwitchTableViewCell.h"
#import "SettModel.h"
#import "User.h"
#import "LoginViewController.h"
#import "AlertConreoller.h"
#import <SVProgressHUD.h>
#import "LockConnectManger.h"

@interface LeftMenuViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightWidth;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UITableView *settTableView;
@property (weak, nonatomic) IBOutlet UIImageView *headerIcon;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property(nonatomic,strong)NSMutableArray * settTableData;
@end
/*
 菜单内 拥有的一些功能
 1.设置主体颜色
 2.开启指纹登录
 3.设置widget的一些快捷事件（开锁等。。）
 */
static NSString *const TableViewCellNormal = @"TableViewCellNormal";
static NSString *const TableViewCellSwitch = @"TableViewCellSwitch";

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view from its nib.
}

- (void)initData {
    [self.settTableData removeAllObjects];
    User *user = [User shareUser];
    BOOL isLoginState = [user loginState];
    NSArray * titles = @[@"禁用所有设备", @"指纹登录", @"新增账号"];
    NSMutableArray * titlesM = [[NSMutableArray alloc] initWithArray:titles];
    if ([[User shareUser] loginState]) {
        [titlesM addObject:@"退出登录"];
    }
    NSMutableArray * arrM1 = [[NSMutableArray alloc] init];
    NSMutableArray * arrM2 = [[NSMutableArray alloc] init];
    NSMutableArray * arrM3 = [[NSMutableArray alloc] init];
    [self.settTableData addObjectsFromArray:@[arrM1, arrM2, arrM3]];
    for (NSInteger i = 0; i < titlesM.count; i++) {
        switch (i) {
            case 0:
                {
                    [arrM1 addObject:[SettModel settModelWithTitle:titlesM[i] modelType:SettModelTypeCloseAllDeviceSwitch loginState:isLoginState switchOn:user.closeAllDevice]];
                }
                break;
            case 1:
                {
                    [arrM2 addObject:[SettModel settModelWithTitle:titlesM[i] modelType:SettModelTypeFingerprintLoginSwitch loginState:isLoginState switchOn:user.fingerprintLogin]];
                }
                break;
            case 2:
                {
                    [arrM2 addObject:[SettModel settModelWithTitle:titlesM[i] modelType:SettModelTypeInsert loginState:isLoginState switchOn:NO]];
                }
                break;
            case 3:
                {
                    [arrM3 addObject:[SettModel settModelWithTitle:titlesM[i] modelType:SettModelTypeNormal loginState:isLoginState switchOn:NO]];
                }
                break;
            default:
                break;
        }
    }
    
    [self.settTableView reloadData];
}
// 接受通知 的方法
- (void)loginStateNotifition:(NSNotification *)notification {
    if ([notification.userInfo[@"state"] isEqualToString:@"login"]) {
        // 是登录状态 刷新UI
        [self setLoginStateUI];
    }
}

- (void)setLoginStateUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initData];
        User * user = [User shareUser];
        if ([user loginState]) {
            self.headerIcon.image = [UIImage imageNamed:user.userIcon];
            self.username.text = user.username;
        } else {
            self.headerIcon.image = [UIImage imageNamed:@"header_icon"];
            self.username.text = @"";
        }
    });
}

- (void)initView {
    self.view.backgroundColor = RGBColor(39.0, 31.0, 61.0);
    self.mainView.backgroundColor = RGBColor(39.0, 31.0, 61.0);
    self.rightWidth.constant = -(Screen_Width - MaginWidth);
    self.headerIcon.layer.cornerRadius = 40;
    self.headerIcon.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.headerIcon.layer.borderWidth = 1;
    
    [self setLoginStateUI];
    
    // 注册 cell
    UINib * normalNib = [UINib nibWithNibName:NSStringFromClass([SettTableViewCell class]) bundle:nil];
    [self.settTableView registerNib:normalNib forCellReuseIdentifier:TableViewCellNormal];
    UINib * switchNib = [UINib nibWithNibName:NSStringFromClass([SettSwitchTableViewCell class]) bundle:nil];
    [self.settTableView registerNib:switchNib forCellReuseIdentifier:TableViewCellSwitch];
    
    self.settTableView.separatorColor = RGBColor(39.0, 31.0, 61.0);
    [self.settTableView setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    self.settTableView.delegate  = self;
    self.settTableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateNotifition:) name:Login_State_Key object:nil];
}
- (IBAction)headerTapAction:(UITapGestureRecognizer *)sender {
    if ([[User shareUser] loginState]) {
        // 是登录成功 就 换头像
    } else {
        // 是登出状态 就是去登陆
        LoginViewController * loginVC = [[LoginViewController alloc] init];
        loginVC.loginType = LoginVCTypeLogin;
        loginVC.needFingerLogin = YES;
        [loginVC setSuccessBlock:^{
            // 打开长链接
            [[LockConnectManger shareLockConnectManger] setLockMangerCanConnect:YES];
            [[LockConnectManger shareLockConnectManger] connect];
        }];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

- (void)handleSwitchBtnState:(SettModel *)model {
    User *user = [User shareUser];
    if (model.modelType == SettModelTypeCloseAllDeviceSwitch) {
        // 禁用所有设备 1.发送后台数据 2.更改user的设置
        user.closeAllDevice = model.switchOn;
        
        [user writeUserMesage];
    } else {
        // 开启指纹验证
//        user.fingerprintLogin = model.switchOn;
        
        UIAlertController * alertTextController = [UIAlertController alertControllerWithTitle:@"请输入当前账号的密码" message:user.username preferredStyle:UIAlertControllerStyleAlert];
        __block UITextField * codeTextField = nil;
        [alertTextController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.secureTextEntry = YES;
            textField.returnKeyType = UIReturnKeyGo;
            codeTextField = textField;
        }];
        UIAlertAction * alertActionDone = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (codeTextField) {
                [self handlePasswordTextField:codeTextField.text];
            }
        }];
        UIAlertAction * alertActionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertTextController addAction:alertActionDone];
        [alertTextController addAction:alertActionCancel];
        [self presentViewController:alertTextController animated:YES completion:nil];
        
    }
    [user writeUserMesage];
}

- (void)handlePasswordTextField:(NSString *)password {
    if (password.length) {
        User *user = [User shareUser];
        if ([user.password isEqualToString:password]) {
            // 密码相同，指纹开启或关闭成功 1.设置 user状态 2.刷新UI
            user.fingerprintLogin = !user.fingerprintLogin;
            [user writeUserMesage];
            
            [self initData];
        } else {
            [SVProgressHUD showErrorWithStatus:@"密码输入错误，请稍后再试"];
            [SVProgressHUD dismissWithDelay:1.5];
        }
    }
}

#pragma mark--UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settTableData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settTableData[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettModel * model = self.settTableData[indexPath.section][indexPath.row];
    if (model.modelType == SettModelTypeCloseAllDeviceSwitch || model.modelType == SettModelTypeFingerprintLoginSwitch) {
        // switch 样式
        SettSwitchTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellSwitch];
        __weak typeof (self) ws = self;
        [cell setSwitchBtnBlock:^(SettModel *model) {
            [ws handleSwitchBtnState:model];
        }];
        cell.model = model;
        return cell;
    } else {
        SettTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellNormal];
        if (model.modelType == SettModelTypeInsert) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.model = model;
        return cell;
    }

}
// 选中
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 1) {
        if ([[User shareUser] loginState]) {
            // 登录成功后才允许操作
            // 创建新的账号
            LoginViewController * loginVC = [[LoginViewController alloc] init];
            loginVC.loginType = LoginVCTypeRegister;
            [self presentViewController:loginVC animated:YES completion:nil];
        }
    }
    if (indexPath.section == 2) {
        // 是退出登录
        if ([[User shareUser] loginState]) {
            // 登录成功后才允许操作
            [AlertConreoller alertControllerWithController:self title:@"提示" message:@"确定要退出当前账户" cancelButtonTitle:@"再想想" otherButtonTitle:@"确定" cancelAction:nil otherAction:^{
                [[User shareUser] setLoginState:NO];
                [[User shareUser] writeUserMesage];
                [self setLoginStateUI];
                // 发出登出的消息，告诉其他页面刷新消息
                [[NSNotificationCenter defaultCenter] postNotificationName:Login_State_Key object:nil userInfo:@{@"state":@"logout"}];
            // 关闭长链接
                [[LockConnectManger shareLockConnectManger] setLockMangerCanConnect:NO];
                [[LockConnectManger shareLockConnectManger] closeConnect];
            }];
        }
    }
}


- (NSMutableArray *)settTableData {
    if (_settTableData == nil) {
        _settTableData = [[NSMutableArray alloc] init];
    }
    return _settTableData;
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
