//
//  UIPopoverListView.h
//  Danci
//
//  Created by shiyuming on 13-9-20.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#define TYPE_LOGIN 0
#define TYPE_REG 1
#define HEIGHT_LOGIN 180
#define HEIGHT_REG 220

@class UIPopoverListView;

@protocol UIPopoverListViewDelegate <NSObject>

@optional
//注册
- (void) popoverListViewRegist:(UIPopoverListView *)popoverListView newUser:(NSDictionary *)userInfo;
//登陆
- (void) popoverListViewLogin:(UIPopoverListView *)popoverListView oldUser:(NSDictionary *)userInfo;
//取消
- (void)popoverListViewCancel:(UIPopoverListView *)popoverListView;

@end


@interface UIPopoverListView : UIView
{
    // 1:login 2:regiest
    int type;
    
    UISegmentedControl *_segments;
    
    UIControl   *_overlayView;
    UILabel     *_titleView;
    UIImageView *_imgLogin;
    UILabel *_lblMid;
    UITextField *_txtMid;
    UILabel *_lblPwd;
    UITextField *_txtPwd;
    UILabel *_lblPwdConfirm;
    UITextField *_txtPwdConfirm;
    UILabel *_lblTuijian;
    UITextField *_txtTuijian;
    UILabel *_lblTip;
    UIButton *_btnEnter;
}

@property (nonatomic, assign) id<UIPopoverListViewDelegate>   delegate;

- (id)initWithFrameType:(CGRect)frame popType:(int)pType;
- (void)setTitle:(NSString *)title;

- (void)show;
- (void)dismiss;

@end
