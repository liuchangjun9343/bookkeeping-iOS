/**
 * 注册
 * @author 郑业强 2018-12-22 创建文件
 */

#import "RE1Controller.h"
#import "RE2Controller.h"

#pragma mark - 声明
@interface RE1Controller() {
    NSInteger index;
}

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameConstraintH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameConstraintL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textConstraintR;

@end


#pragma mark - 实现
@implementation RE1Controller


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"注册"];
    [self setJz_navigationBarHidden:NO];
    [self setJz_navigationBarTintColor:kColor_Main_Color];
    [self.view setBackgroundColor:kColor_BG];
    [self.nameLab setFont:[UIFont systemFontOfSize:AdjustFont(12) weight:UIFontWeightLight]];
    [self.nameLab setTextColor:kColor_Text_Black];
    [self.textfield setFont:[UIFont systemFontOfSize:AdjustFont(14) weight:UIFontWeightLight]];
    [self.textfield setTextColor:kColor_Text_Black];
    [self.textfield addTarget:self action:@selector(textFieldDidEditing:) forControlEvents:UIControlEventEditingChanged];
    [self.textfield setRightViewMode:UITextFieldViewModeAlways];
    [self.registerBtn.layer setCornerRadius:3];
    [self.registerBtn.layer setMasksToBounds:YES];
    
    [self.line setBackgroundColor:kColor_Line_Color];
    [self buttonCanTap:false];
    
    [self.nameConstraintH setConstant:countcoordinatesX(50)];
    [self.nameConstraintL setConstant:countcoordinatesX(15)];
    [self.textConstraintR setConstant:countcoordinatesX(15)];
}


// 按钮是否可以点击
- (void)buttonCanTap:(BOOL)tap {
    if (tap == true) {
        [self.registerBtn setUserInteractionEnabled:YES];
        [self.registerBtn.titleLabel setFont:[UIFont systemFontOfSize:AdjustFont(14) weight:UIFontWeightLight]];
        [self.registerBtn setTitleColor:kColor_Text_Black forState:UIControlStateNormal];
        [self.registerBtn setTitleColor:kColor_Text_Black forState:UIControlStateHighlighted];
        [self.registerBtn setBackgroundImage:[UIColor createImageWithColor:kColor_Main_Color] forState:UIControlStateNormal];
        [self.registerBtn setBackgroundImage:[UIColor createImageWithColor:kColor_Main_Dark_Color] forState:UIControlStateHighlighted];
    } else {
        [self.registerBtn setUserInteractionEnabled:NO];
        [self.registerBtn.titleLabel setFont:[UIFont systemFontOfSize:AdjustFont(14) weight:UIFontWeightLight]];
        [self.registerBtn setTitleColor:kColor_Text_Gary forState:UIControlStateNormal];
        [self.registerBtn setTitleColor:kColor_Text_Gary forState:UIControlStateHighlighted];
        [self.registerBtn setBackgroundImage:[UIColor createImageWithColor:kColor_Line_Color] forState:UIControlStateNormal];
        [self.registerBtn setBackgroundImage:[UIColor createImageWithColor:kColor_Line_Color] forState:UIControlStateHighlighted];
    }
}

// 文本编辑
- (void)textFieldDidEditing:(UITextField *)textField {
    if (textField == self.textfield) {
        if (textField.text.length > index) {
            // 输入
            if (textField.text.length == 4 || textField.text.length == 9 ) {
                NSMutableString * str = [[NSMutableString alloc ] initWithString:textField.text];
                [str insertString:@"-" atIndex:(textField.text.length-1)];
                textField.text = str;
                [self buttonCanTap:false];
            }
            // 输入完成
            if (textField.text.length >= 13) {
                textField.text = [textField.text substringToIndex:13];
                [self buttonCanTap:true];
            }
            index = textField.text.length;
        }
        // 删除
        else if (textField.text.length < index) {
            if (textField.text.length == 4 || textField.text.length == 9) {
                textField.text = [NSString stringWithFormat:@"%@",textField.text];
                textField.text = [textField.text substringToIndex:(textField.text.length-1)];
            }
            index = textField.text.length;
            [self buttonCanTap:false];
        }
    }
}

// 注册
- (IBAction)registerBtnClick:(UIButton *)sender {
    @weakify(self)
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请确认手机号\n152-6529-6375" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alert show];
    [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *number) {
        @strongify(self)
        if ([number integerValue] == 1) {
            [self.view endEditing:YES];
            RE2Controller *vc = [[RE2Controller alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textfield resignFirstResponder];
}


@end