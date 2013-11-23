//
//  UIPopoverListView.m
//  Danci
//
//  Created by HuHao on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "UIPopoverListView.h"
#import <QuartzCore/QuartzCore.h>

//#define FRAME_X_INSET 20.0f
//#define FRAME_Y_INSET 40.0f

@interface UIPopoverListView () <UITextFieldDelegate>

- (void)defalutInit;
- (void)fadeIn;
- (void)fadeOut;

@end

@implementation UIPopoverListView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defalutInit];
    }
    return self;
}

- (id)initWithFrameType:(CGRect)frame popType:(int)pType
{
    type = pType;
    self = [super initWithFrame:frame];
    if (self) {
        [self defalutInit];
    }
    return self;
}

- (void)defalutInit
{
    if(type == TYPE_LOGIN){
        CGRect frameLogin = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                       self.frame.size.width, HEIGHT_LOGIN);
        self.frame = frameLogin;
        NSLog(@"frame of login");
    }else{
        CGRect frameLogin = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                       self.frame.size.width, HEIGHT_REG);
        self.frame = frameLogin;
        NSLog(@"frame of register");
    }
    float heightTitle = 32.0f;
    
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 10.0f;
    self.clipsToBounds = TRUE;
    
    //segment
    CGFloat xWidth = self.bounds.size.width;
    _segments = [[UISegmentedControl alloc] initWithItems:@[@"登陆", @"注册"]];
    _segments.frame = CGRectMake((xWidth - 100)/2, 2, 100, heightTitle);
    [_segments addTarget:self action:@selector(showPopView:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_segments];
    _segments.selectedSegmentIndex = type;
    [self showPopView:nil];
    _overlayView = [[UIControl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _overlayView.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:.5];
    [_overlayView addTarget:self
                     action:@selector(dismiss)
           forControlEvents:UIControlEventTouchUpInside];
}

-(void) showPopView:(UIPopoverController *)sender
{
    UIColor *colorLblBackGroud = [UIColor colorWithRed:59./255.
                                                 green:89./255.
                                                  blue:152./255.
                                                 alpha:1.0f];
    CGFloat xWidth = self.bounds.size.width;
    float height = 28.0f;
    float splitHeight = 4.0f;
    float widthLeft = 60.0f;
    float heightTitle = 32.0f;
    type = _segments.selectedSegmentIndex;
    
    //清理控件
    [_btnEnter removeFromSuperview];
    [_lblTip removeFromSuperview];
    [_lblMid removeFromSuperview];
    [_txtMid removeFromSuperview];
    [_lblPwd removeFromSuperview];
    [_txtPwd removeFromSuperview];
    [_lblPwdConfirm removeFromSuperview];
    [_txtPwdConfirm removeFromSuperview];
    [_lblTuijian removeFromSuperview];
    [_txtTuijian removeFromSuperview];
    
    if(type == TYPE_LOGIN){
        CGRect frameLogin = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                       self.frame.size.width, HEIGHT_LOGIN);
        self.frame = frameLogin;
        NSLog(@"frame of login");
    }else{
        CGRect frameLogin = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                       self.frame.size.width, HEIGHT_REG);
        self.frame = frameLogin;
        NSLog(@"frame of register");
    }
    
    //login img
    _imgLogin.image = [UIImage imageNamed:@"login.jpg"];
    
    //Mid 用户名
    _lblMid = [[UILabel alloc] initWithFrame:CGRectZero];
    _lblMid.text = @"用户名:";
    _lblMid.textAlignment = NSTextAlignmentRight;
    _lblMid.frame = CGRectMake(1, heightTitle + height * 0 + splitHeight * 1, widthLeft, height);
    [self addSubview:_lblMid];
    _txtMid = [[UITextField alloc] initWithFrame:CGRectZero];
    _txtMid.borderStyle = UITextBorderStyleLine;
    _txtMid.placeholder = @"手机号/邮箱";
    _txtMid.frame = CGRectMake(widthLeft + splitHeight, heightTitle + height * 0 + splitHeight * 1, xWidth - widthLeft - splitHeight * 2, height);
    _txtMid.delegate = self;
    [self addSubview:_txtMid];
    //pwd 密码
    _lblPwd = [[UILabel alloc] initWithFrame:CGRectZero];
    _lblPwd.text = @"密码:";
    _lblPwd.textAlignment = NSTextAlignmentRight;
    //    _lblPwd.backgroundColor = colorLblBackGroud;
    //    _lblPwd.textColor = [UIColor whiteColor];
    _lblPwd.frame = CGRectMake(1, heightTitle + height * 1 + splitHeight * 2, widthLeft, height);
    [self addSubview: _lblPwd];
    _txtPwd = [[UITextField alloc] initWithFrame:CGRectZero];
    _txtPwd.borderStyle = UITextBorderStyleLine;
    _txtPwd.placeholder = @"不少于6位数字与字母";
    _txtPwd.frame = CGRectMake(widthLeft + splitHeight, heightTitle + height * 1 + splitHeight * 2, xWidth - widthLeft - splitHeight * 2, height);
    _txtPwd.delegate = self;
    [self addSubview:_txtPwd];
    UIFont *fontTip = [UIFont fontWithName:@"Verdana" size:13];
    if(type == TYPE_LOGIN){
        //tip
        _lblTip = [[UILabel alloc] initWithFrame:CGRectZero];
        _lblTip.text = @"登陆后才能保存图文并茂的助记，启用更多功能哦 :)";
        _lblTip.numberOfLines = 0;
        _lblTip.font = fontTip;
        _lblTip.frame = CGRectMake(splitHeight * 4, heightTitle + height * 2 + splitHeight * 3, self.bounds.size.width - splitHeight * 8, height*1.5);
        [self addSubview:_lblTip];
        
        _btnEnter = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnEnter setTitle:@"登  陆" forState:UIControlStateNormal];
        _btnEnter.frame = CGRectMake((self.bounds.size.width - 80.0f)/2,self.bounds.size.height - 35.0f, 80.0f, 32.0f);
        _btnEnter.backgroundColor = colorLblBackGroud;
        [_btnEnter addTarget:self
                      action:@selector(login)
            forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnEnter];
        
        //清除注册控件
        [_lblTuijian removeFromSuperview];
        [_txtTuijian removeFromSuperview];
    }else{
        //推荐人
        _lblTuijian = [[UILabel alloc] initWithFrame:CGRectZero];
        _lblTuijian.text = @"推荐人:";
        _lblTuijian.textAlignment = NSTextAlignmentRight;
        _lblTuijian.frame = CGRectMake(1, heightTitle + height * 2 + splitHeight * 3, widthLeft, height);
        [self addSubview:_lblTuijian];
        _txtTuijian = [[UITextField alloc] initWithFrame:CGRectZero];
        _txtTuijian.borderStyle = UITextBorderStyleLine;
        _txtTuijian.placeholder = @"推荐人的学号(选填)";
        _txtTuijian.frame = CGRectMake(widthLeft + splitHeight, heightTitle + height * 2 + splitHeight * 3, xWidth - widthLeft - splitHeight * 2, height);
        _txtTuijian.delegate = self;
        [self addSubview:_txtTuijian];
        
        //tip
        _lblTip = [[UILabel alloc] initWithFrame:CGRectZero];
        _lblTip.text = @"建议使用手机号注册，记忆更方便\n填写推荐人能为双方提升学习上限哦";
        _lblTip.numberOfLines = 0;
        _lblTip.font = fontTip;
        _lblTip.frame = CGRectMake(splitHeight * 4, heightTitle + height * 3 + splitHeight * 4, self.bounds.size.width - splitHeight * 8, height*1.5);
        [self addSubview:_lblTip];
        
        _btnEnter = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnEnter setTitle:@"注  册" forState:UIControlStateNormal];
        _btnEnter.frame = CGRectMake((self.bounds.size.width - 80.0f)/2,self.bounds.size.height - 35.0f, 80.0f, 32.0f);
        _btnEnter.backgroundColor = colorLblBackGroud;
        [_btnEnter addTarget:self
                      action:@selector(regist)
            forControlEvents: UIControlEventTouchUpInside];
        [self addSubview:_btnEnter];
    }
    
    self.backgroundColor = [UIColor whiteColor];
}

#pragma mark - textfiled代理

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
//    CGRect rect = CGRectMake(0.0f, 20.0f, self.frame.size.width, self.frame.size.height);
//    self.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 事件响应

- (void) login
{
    NSString *userMid = _txtMid.text;
    
    //校验
    
    //登陆验证
    
    //通过检验后 回调主页面
    NSDictionary *userInfo = @{@"userMid":userMid};
    [self.delegate popoverListViewLogin:self oldUser:userInfo];
    [self dismiss];
}

- (void) regist
{
    NSString *userMid = _txtMid.text;
    NSString *userPwd = _txtPwd.text;
    NSString *tuijian = _txtTuijian.text;
    //校验
    
    //注册验证
    
    //通过检验后 持久化保存用户信息在本地
    //回调主页面
    NSDictionary *userInfo = @{@"userMid": userMid};
    [self.delegate popoverListViewRegist:self newUser:userInfo];
    [self dismiss];
}

#pragma mark - animations

- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
}
- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            //必须remove 否则selector无效
            [_overlayView removeFromSuperview];
            [_btnEnter removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
}

- (void)setTitle:(NSString *)title
{
    _titleView.text = title;
}

- (void)show
{
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:_overlayView];
    [keywindow addSubview:self];
    
    self.center = CGPointMake(keywindow.bounds.size.width/2.0f,
                              keywindow.bounds.size.height/2.0f);
    [self fadeIn];
}

- (void)dismiss
{
    //判断点击范围是否在frame之外
//    NSLog(@"frame:x[%f] y[%f] width[%f] height[%f]",self.frame.origin.x, self.frame.origin.y,self.frame.size.width,self.frame.size.height);
    // tell the delegate the cancellation
    if (self.delegate && [self.delegate respondsToSelector:@selector(popoverListViewCancel:)]) {
        [self.delegate popoverListViewCancel:self];
    }
    [self fadeOut];
}

@end
