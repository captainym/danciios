//
//  ConfigurationViewController.h
//  Danci
//
//  Created by zhenghao on 12/9/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo+Server.h"

@interface ConfigurationViewController : UIViewController
{
    //// 数据控件
    // 用户信息相关
    UILabel *labelUserInfo;
//    UITableView *tableUserInfo;
    UIButton *btnUserLogin;
    UIButton *btnUserSync;
    
    // 帮助相关
    UILabel *labelHelp;
    
    //// 滑动控件
    UIPageControl *pageControl;
    int curPage;
    BOOL pageControlUsed;
}

@property (nonatomic, strong) UIManagedDocument *danciDatabase;
@property (nonatomic, strong) UserInfo *curUser;


@property (strong, nonatomic) IBOutlet UIButton *btnUserInfo;
@property (strong, nonatomic) IBOutlet UIButton *btnHelp;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *labelForCurPage;


@end
