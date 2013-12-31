//
//  ConfigurationViewController.m
//  Danci
//
//  Created by zhenghao on 12/9/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "UIPopoverListView.h"
#import "DanciServer.h"

#define TABLE_CELL_FOR_USER_INFO @"tableCellForUserInfo"

@interface ConfigurationViewController () <UIScrollViewDelegate, UIPopoverListViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    NSString *appDescription;
    NSString *teamIntroduction;
    NSString *supportInfo;
    
    bool viewInited;
}

- (void) initScrollView;
- (void) createEmptyPagesForScrollView;

- (void) showView;
- (void) showUserInfoView;
- (void) showHelpView;

// "登录"/"注销"按钮
- (void) onBtnUserLogin;

// "同步"按钮
- (void) onBtnUserSync;


@end

@implementation ConfigurationViewController

@synthesize danciDatabase = _danciDatabase;
@synthesize curUser = _curUser;


- (UserInfo *) curUser
{
    if(_curUser == nil){
        _curUser = [UserInfo getUser:self.danciDatabase.managedObjectContext];
    }
    return _curUser;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.title = @"配置";
    
    // Init controls
    self.btnUserInfo.showsTouchWhenHighlighted = YES;
    [self.btnUserInfo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.btnHelp.showsTouchWhenHighlighted = YES;
    [self.btnHelp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   
    [self updateHelpInfo];
    viewInited = false;
    [self initScrollView];
}

//- (void) viewWillAppear:(BOOL)animated
//{
//    UIButton *btnUserInfo = [self btnUserInfo];
//    CGFloat btnUserInfoWidth = btnUserInfo.frame.size.width;
//    CGFloat btnUserInfoHeight = btnUserInfo.frame.size.height;
//    CGFloat btnUserInfoX = btnUserInfo.frame.origin.x;
//    CGFloat btnUserInfoY = self.scrollView.frame.origin.y + self.scrollView.frame.size.height - btnUserInfoHeight;
//    [btnUserInfo setFrame:CGRectMake(btnUserInfoX, btnUserInfoY, btnUserInfoWidth, btnUserInfoHeight)];
//}

- (void)updateHelpInfo {
    appDescription = @"学好单词\n拒绝死记硬背，通过图片、词根词缀、网友分享的优秀助记，理解单词，轻松记住；丰富的记忆提取线索，帮你记得更牢；即时复习策略、依据遗忘曲线计算遗忘零界点，有效减少重复学习的时间浪费；真人发音、真人读例句，同步提高英语综合能力！";
    teamIntroduction = @"关于我们:\n我们都在持续地学习英语、背单词，我们想积累更多单词，学好英语，我们总结自己多年的学习经历，做出了这个APP。\n创始人：石玉明 袁锡杰 刘正浩";
    supportInfo = @"官网:    http://www.xuehaodanci.com \n官网微博帐号:@学好单词";
    
    dispatch_queue_t queue = dispatch_queue_create("queueGetHelpInfoFromServer", NULL);
    dispatch_async(queue, ^{
        NSDictionary *helpInfoDict = [DanciServer getHelpInfoFromServer];
        [helpInfoDict enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
            NSString *name = key;
            if ([name isEqualToString: @"appDescription"]) {
                appDescription = value;
            }
            else if ([name isEqualToString: @"teamIntroduction"]) {
                teamIntroduction = value;
            }
            else if ([name isEqualToString: @"supportInfo"]) {
                supportInfo = value;            }
        }];
        
        // 在主线程中完成UI更新
        if (curPage == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showView];
            });
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - show views

- (void) showView
{
    if (!viewInited) { // 防止在updateHelpInfo触发updateView时, view尚未init.
        [self initScrollView];
    }
    
    switch (curPage) {
        case 0:
            [self showUserInfoView];
            break;
            
        case 1:
            [self showHelpView];
            break;
            
        default:
            break;
    }
}

- (void) showUserInfoView
{
    //// 页面切换效果
    [self.btnUserInfo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnHelp setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    
    [UIView beginAnimations:nil context:nil]; // 动画开始
    [UIView setAnimationDuration:0.3];
    
    float labelForCurPageY = self.labelForCurPage.frame.origin.y;
    self.labelForCurPage.frame = CGRectMake(0, labelForCurPageY, 159, 4);
    [self.scrollView setContentOffset:CGPointMake(320 * 0, 0)]; // 页面滑动
    
    [UIView commitAnimations];
}

- (void) showHelpView
{
    //// 页面切换效果
    [self.btnHelp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnUserInfo setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    
    [UIView beginAnimations:nil context:nil]; // 动画开始
    [UIView setAnimationDuration:0.3];
    
    float labelForCurPageY = self.labelForCurPage.frame.origin.y;
    self.labelForCurPage.frame = CGRectMake(161, labelForCurPageY, 159, 4);
    [self.scrollView setContentOffset:CGPointMake(320 * 1, 0)]; // 页面滑动
    
    labelAppDescription.text = appDescription;
    labelTeamIntruction.text = teamIntroduction;
    labelSupport.text = supportInfo;
    
    [UIView commitAnimations];
}

#pragma mark - switch views by scroll

- (void)initScrollView
{
    // 一个page是一个scollView
    self.scrollView.pagingEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 7.0) {
        self.scrollView.frame = CGRectMake(0.0, 0.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 2, self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    
//    NSLog(@"self.scrollView.frame's x: %f, y: %f, w: %f, h: %f", self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    self.labelForCurPage.text = @"";
    curPage = 0;
    pageControl.numberOfPages = 2;
    pageControl.currentPage = curPage;
    pageControl.backgroundColor = [UIColor whiteColor];
    
    [self createEmptyPagesForScrollView];
    
    viewInited = true;
}

- (void)createEmptyPagesForScrollView
{
    //// offset
    NSInteger offsetYForAllPages = 0;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 7.0) {
        offsetYForAllPages = 40;
    }
    
    //// page for user info
    NSInteger btnUserLogInWidth = self.scrollView.frame.size.width / 4;
    NSInteger btnUserLogInHeight = 40;
    
    NSInteger btnUserSyncWidth = self.scrollView.frame.size.width / 4;
    NSInteger btnUserSyncHeight = 40;
    
    NSInteger labelUserInfoHeight = self.scrollView.frame.size.height - btnUserLogInHeight - btnUserSyncHeight - 40;
    
    NSInteger btnUserLogInX = 320 * 0 + (self.scrollView.frame.size.width - btnUserLogInWidth - btnUserSyncWidth - 2) / 2;
    NSInteger btnUserLogInY = labelUserInfoHeight + 20;
    
    NSInteger btnUserSyncX = 320 * 0 + (self.scrollView.frame.size.width - btnUserLogInWidth - btnUserSyncWidth - 2) / 2 + btnUserSyncWidth + 2;
    NSInteger btnUserSyncY = labelUserInfoHeight + 20;
    
    
    // 用户信息table
    tableUserInfo = [[UITableView alloc] init];
    tableUserInfo.frame = CGRectMake(320 * 0, offsetYForAllPages, 320, labelUserInfoHeight);
    [tableUserInfo registerClass:[UITableViewCell class] forCellReuseIdentifier:TABLE_CELL_FOR_USER_INFO];
    [tableUserInfo setDelegate:self];
    [tableUserInfo setDataSource:self];
    
    
    // 登录按钮
    btnUserLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    btnUserLogin.frame = CGRectMake(btnUserLogInX, btnUserLogInY, btnUserLogInWidth, btnUserLogInHeight);
    btnUserLogin.showsTouchWhenHighlighted = YES;
    [btnUserLogin setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnUserSync setBackgroundColor:[UIColor grayColor]];
//    [btnUserLogin setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    [btnUserLogin addTarget:self action:@selector(onBtnUserLogin) forControlEvents:UIControlEventTouchUpInside];
    [self updateBtnUserLogIn];
    
    // 同步按钮
    btnUserSync = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnUserSync setTitle:@"同步" forState:UIControlStateNormal];
    btnUserSync.frame = CGRectMake(btnUserSyncX, btnUserSyncY, btnUserSyncWidth, btnUserSyncHeight);
    btnUserSync.showsTouchWhenHighlighted = YES;
    [btnUserSync setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnUserSync setBackgroundColor:[UIColor grayColor]];
//    [btnUserSync setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    [btnUserSync addTarget:self action:@selector(onBtnUserSync) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *userView = [[UIView alloc] init];
    userView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    [userView addSubview:tableUserInfo];
    [userView addSubview:btnUserLogin];
    [userView addSubview:btnUserSync];
    
    [self.scrollView addSubview:userView];
    
    //// page for help
    labelAppDescription = [[UILabel alloc] init];
    labelAppDescription.frame = CGRectMake(320 * 1 + 20, offsetYForAllPages + 20, 300, 90);
    labelAppDescription.numberOfLines = 0;
    labelAppDescription.text = appDescription;
    labelAppDescription.font = [UIFont fontWithName:@"Verdana" size:12];
    [self.scrollView addSubview:labelAppDescription];

    labelTeamIntruction = [[UILabel alloc] init];
    labelTeamIntruction.frame = CGRectMake(320 * 1 + 20,  offsetYForAllPages + 110, 300, 100);
    labelTeamIntruction.numberOfLines = 0;
    labelTeamIntruction.text = teamIntroduction;
    labelTeamIntruction.font = [UIFont fontWithName:@"Verdana" size:12];
    [self.scrollView addSubview:labelTeamIntruction];
    
    labelSupport = [[UILabel alloc] init];
    labelSupport.frame = CGRectMake(320 * 1 + 20,  offsetYForAllPages + 210, 300, 45);
    labelSupport.numberOfLines = 1;
    labelSupport.text = supportInfo;
    labelSupport.font = [UIFont fontWithName:@"Verdana" size:12];
    [self.scrollView addSubview:labelSupport];
    
    // 默认显示用户信息页面
    // 注: 此处不能调用showView, 否则会形成无穷嵌套(showView()->initScrollView()->createEmptyPagesForScrollView()->showView())
    [self showUserInfoView];
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    pageControl.currentPage = page;
    curPage = page;
    pageControlUsed = NO;
    [self showView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 暂不处理 - 其实左右滑动还有包含开始等等操作
}

- (IBAction)showUserInfo:(id)sender {
    [self showUserInfoView];
}

- (IBAction)showHelp:(id)sender {
    [self showHelpView];
}

#pragma mark - event processors

-(void) popLoginView:(int)popType
{
    CGFloat xWidth = self.view.bounds.size.width - 80.0f;
    CGFloat yHeight = HEIGHT_LOGIN;
    CGFloat yOffset = (self.view.bounds.size.height - yHeight - 100)/2.0f;
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrameType:CGRectMake(10, yOffset, xWidth, yHeight) popType:popType];
    poplistview.delegate = self;
    [poplistview show];
}

- (BOOL) userLoggedIn
{
    if(self.curUser.mid == nil || [self.curUser.mid length] < 2) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void) onBtnUserLogin
{
    if(![self userLoggedIn]) { // 未登录==>弹出登录框
        [self popLoginView:TYPE_LOGIN];
    }
    else { // 已登录==>注销
        [[[UIAlertView alloc] initWithTitle:@"注销用户" message:@"确定要注销吗?" delegate:self cancelButtonTitle:@"不" otherButtonTitles:@"是", nil] show];
    }
}

- (void) onBtnUserSync
{
    // 同步user信息
    dispatch_queue_t queue = dispatch_queue_create("merge user", NULL);
    dispatch_async(queue, ^{
        self.curUser = [UserInfo mergerUserToServer:self.curUser];
        
        // 在主线程中完成UI更新
        dispatch_async(dispatch_get_main_queue(), ^{
            // update UI
            [tableUserInfo reloadData];
        });
    });
}

#pragma mark - alertViewDelegate

- (void) updateBtnUserLogIn
{
    NSString *title = ([self userLoggedIn] ? @"注销" : @"登录");
    [btnUserLogin setTitle:title forState:UIControlStateNormal];
    if (![self userLoggedIn]) {
        [btnUserLogin setBackgroundColor:[UIColor colorWithRed:0.0 green:0.75 blue:0.0 alpha:1]];
    }
    else {
        [btnUserLogin setBackgroundColor:[UIColor colorWithRed:0.9 green:0.0 blue:0.0 alpha:1]];
    }
}

- (void) doLogOut
{
    // 清除curUser
    self.curUser.mid = @"";
    self.curUser.comsumeWordNum = 0;
    self.curUser.maxWordNum = 0;
    self.curUser.recommendStudyNo = 0;
    self.curUser.regTime = nil;
    self.curUser.studyNo = 0;
    self.curUser.words = @"";
    
    // 强制清除本地用户信息
    [self.danciDatabase saveToURL:self.danciDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    
    // 更新按钮标题及背景色
    [self updateBtnUserLogIn];

    // 更新页面显示
    [tableUserInfo reloadData];
}

// 处理UIAlertView中的按钮被单击的事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // 用户取消了注销
            break;
            
        case 1:
            // 用户确认要注销
            [self doLogOut];
            break;
            
        default:
            break;
    }
}


#pragma mark - popListViewDelegate

-(void) popoverListViewCancel:(UIPopoverListView *)popoverListView
{
    [self updateBtnUserLogIn];
    
//    NSLog(@"user do not want to reg or login");
}

- (void)pushDataToUser:(NSDictionary *)userInfo
{
    // 更新user信息
    self.curUser.mid = [userInfo objectForKey:@"mid"];
    self.curUser.studyNo = [NSNumber numberWithInt:[[userInfo objectForKey:@"studyNo"] intValue]];
    self.curUser.maxWordNum = [NSNumber numberWithInt:[[userInfo objectForKey:@"maxWordNum"] intValue]];
    self.curUser.comsumeWordNum = [NSNumber numberWithInt:[[userInfo objectForKey:@"comsumeWordNum"]intValue]];
    self.curUser.regTime = [NSDate dateWithTimeIntervalSince1970:[[userInfo objectForKey:@"regTime"] intValue]];
    
    // 显式地save
    [self.danciDatabase saveToURL:self.danciDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    
//    NSLog(@"++++++++user login in. user:%@, real study no: %d, got studo no: %@", self.curUser, [[userInfo objectForKey:@"studyNo"] intValue], self.curUser.studyNo);
}

-(void) popoverListViewLogin:(UIPopoverListView *)popoverListView oldUser:(NSDictionary *)userInfo
{
    // 保存数据
    [self pushDataToUser:userInfo];
    
    // 更新按钮标题
    [self updateBtnUserLogIn];
    
    // 更新页面显示
    [tableUserInfo reloadData];
    
//    NSLog(@"user login in. user:%@", self.curUser);
}

-(void) popoverListViewRegist:(UIPopoverListView *)popoverListView newUser:(NSDictionary *)userInfo
{
    // 保存数据
    [self pushDataToUser:userInfo];

    // 更新按钮标题
    [self updateBtnUserLogIn];
    
    // 更新页面显示
    [tableUserInfo reloadData];
    
//    NSLog(@"user regist. user:%@", self.curUser);
}

#pragma mark - Table view delegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = TABLE_CELL_FOR_USER_INFO;
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    NSString *title = @"";
    NSString *detail = @"";
    
    switch (indexPath.row) {
        case 0:
            title = @"用户名:";
            detail = ([self userLoggedIn] ? self.curUser.mid : @"");
            break;
            
        case 1:
            title = @"学号:";
            detail = ([self userLoggedIn] ? [NSString stringWithFormat:@"%d", [self.curUser.studyNo intValue]] : @"");
            break;
            
        case 2:
        {
            title = @"注册时间:";
            if ([self userLoggedIn]) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:SS"];
                detail = [dateFormatter stringFromDate:self.curUser.regTime];
            }
            else {
                detail = @"";
            }
        }
            break;

        case 3:
            title = @"推荐人学号:";
            detail = ([self userLoggedIn] && self.curUser.recommendStudyNo != nil ? [NSString stringWithFormat:@"%@", self.curUser.recommendStudyNo] : @"");
            break;

        case 4:
            title = @"可记单词数上限:";
            detail = ([self userLoggedIn] ? [NSString stringWithFormat:@"%@", self.curUser.maxWordNum] : @"");
            break;

        case 5:
            title = @"已记单词数:";
            detail = ([self userLoggedIn] ? [NSString stringWithFormat:@"%@", self.curUser.comsumeWordNum] : @"");
            break;

        default:
            break;
    }
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    
    return cell;
}


@end
