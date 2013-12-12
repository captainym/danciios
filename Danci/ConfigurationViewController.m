//
//  ConfigurationViewController.m
//  Danci
//
//  Created by zhenghao on 12/9/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "UIPopoverListView.h"

#define TABLE_CELL_FOR_USER_INFO @"tableCellForUserInfo"

@interface ConfigurationViewController () <UIScrollViewDelegate, UIPopoverListViewDelegate, UITableViewDataSource, UITableViewDelegate>

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
   
    [self initScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - show views

- (void) showView
{
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
    
    [UIView commitAnimations];
}

#pragma mark - switch views by scroll

- (void)initScrollView
{
    // 一个page是一个scollView
    self.scrollView.pagingEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 2, self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    
    self.labelForCurPage.text = @"";
    curPage = 0;
    pageControl.numberOfPages = 2;
    pageControl.currentPage = curPage;
    pageControl.backgroundColor = [UIColor whiteColor];
    [self createEmptyPagesForScrollView];
}

- (void)createEmptyPagesForScrollView
{
    //// page for user info
    NSInteger btnUserLogInWidth = self.scrollView.frame.size.width / 2;
    NSInteger btnUserLogInHeight = 20;
    
    NSInteger btnUserSyncWidth = self.scrollView.frame.size.width / 2;
    NSInteger btnUserSyncHeight = 20;
    
    NSInteger labelUserInfoHeight = self.scrollView.frame.size.height - btnUserLogInHeight - btnUserSyncHeight - 40;
    
    // 用户信息table
    tableUserInfo = [[UITableView alloc] init];
    tableUserInfo.frame = CGRectMake(320 * 0, 0, 320, labelUserInfoHeight);
    [tableUserInfo registerClass:[UITableViewCell class] forCellReuseIdentifier:TABLE_CELL_FOR_USER_INFO];
    [tableUserInfo setDelegate:self];
    [tableUserInfo setDataSource:self];
    
    
    // 登录按钮
    btnUserLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    
    //判断是否登陆
    if(self.curUser.mid == nil || [self.curUser.mid length] < 2) {
        [btnUserLogin setTitle:@"登录" forState:UIControlStateNormal];
    }
    else {
        [btnUserLogin setTitle:@"注销" forState:UIControlStateNormal];
    }
    
    btnUserLogin.frame = CGRectMake(320 * 0 + (self.scrollView.frame.size.width - btnUserLogInWidth) / 2, labelUserInfoHeight, btnUserLogInWidth, btnUserLogInHeight);
    btnUserLogin.showsTouchWhenHighlighted = YES;
    [btnUserLogin setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnUserLogin setBackgroundColor:[UIColor darkGrayColor]];
    [btnUserLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnUserLogin addTarget:self action:@selector(onBtnUserLogin) forControlEvents:UIControlEventTouchUpInside];
    
    // 同步按钮
    btnUserSync = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnUserSync setTitle:@"同步" forState:UIControlStateNormal];
    btnUserSync.frame = CGRectMake(320 * 0 + (self.scrollView.frame.size.width - btnUserLogInWidth) / 2, labelUserInfoHeight + btnUserLogInHeight + 2, btnUserSyncWidth, btnUserSyncHeight);
    btnUserSync.showsTouchWhenHighlighted = YES;
    [btnUserSync setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnUserSync setBackgroundColor:[UIColor darkGrayColor]];
    [btnUserSync setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    [btnUserSync addTarget:self action:@selector(onBtnUserSync) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *userView = [[UIView alloc] init];
    userView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    [userView addSubview:tableUserInfo];
    [userView addSubview:btnUserLogin];
    [userView addSubview:btnUserSync];
    
    [self.scrollView addSubview:userView];
    
    //// page for help
    labelAppDescription = [[UILabel alloc] init];
    labelAppDescription.frame = CGRectMake(320 * 1, 10, 320, 45);
    labelAppDescription.numberOfLines = 2;
    labelAppDescription.text = @"记单词\n科学记单词 高效学英语";
    labelAppDescription.font = [UIFont fontWithName:@"Verdana" size:12];
    [self.scrollView addSubview:labelAppDescription];

    labelTeamIntruction = [[UILabel alloc] init];
    labelTeamIntruction.frame = CGRectMake(320 * 1, 60, 320, 80);
    labelTeamIntruction.numberOfLines = 6;
    labelTeamIntruction.text = @"关于我们:\n我们是一支年轻的团队, 致力于提升基于智能平台上的英语学习体验.\n我们的宗旨是精益求精, 以专注的精神和科学的方法提供优质的学习体验.";
    labelTeamIntruction.font = [UIFont fontWithName:@"Verdana" size:12];
    [self.scrollView addSubview:labelTeamIntruction];

    
    labelHelp = [[UILabel alloc] init];
    labelHelp.frame = CGRectMake(320 * 1, 140, 320, 45);
    labelHelp.numberOfLines = 1;
    labelHelp.text = @"官网:    http://www.danci.com";
    labelHelp.font = [UIFont fontWithName:@"Verdana" size:12];
    [self.scrollView addSubview:labelHelp];
    
    // 默认显示用户信息页面
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
        self.curUser.mid = @"";
        self.curUser.comsumeWordNum = 0;
        self.curUser.maxWordNum = 0;
        self.curUser.recommendStudyNo = 0;
        self.curUser.regTime = nil;
        self.curUser.studyNo = 0;
        self.curUser.words = @"";
        
        // 更新用户信息至CoreData
        [self.danciDatabase saveToURL:self.danciDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
        
        // 更新按钮标题
        [btnUserLogin setTitle:@"登录" forState:UIControlStateNormal];
        
        // 更新页面显示
        [tableUserInfo reloadData];
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


#pragma mark - popListViewDelegate

-(void) popoverListViewCancel:(UIPopoverListView *)popoverListView
{
    // 应该纪录下来 计算流失率
    [btnUserLogin setTitle:@"登录" forState:UIControlStateNormal];
    
//    NSLog(@"user do not want to reg or login");
}

- (void)pushDataToUser:(NSDictionary *)userInfo
{
    self.curUser.mid = [userInfo objectForKey:@"mid"];
//    self.curUser.studyNo = [NSNumber numberWithInteger: [[userInfo objectForKey:@"studyNo"] integerValue]];
    self.curUser.studyNo = [NSNumber numberWithInt:[[userInfo objectForKey:@"studyNo"] intValue]];
    self.curUser.maxWordNum = [NSNumber numberWithInt:[[userInfo objectForKey:@"maxWordNum"] intValue]];
    self.curUser.comsumeWordNum = [NSNumber numberWithInt:[[userInfo objectForKey:@"comsumeWordNum"]intValue]];
    self.curUser.regTime = [NSDate dateWithTimeIntervalSince1970:[[userInfo objectForKey:@"regTime"] intValue]];
    
    // 显式地save
    [self.danciDatabase saveToURL:self.danciDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    
    NSLog(@"++++++++user login in. user:%@, real study no: %d, got studo no: %@", self.curUser, [[userInfo objectForKey:@"studyNo"] intValue], self.curUser.studyNo);
}

-(void) popoverListViewLogin:(UIPopoverListView *)popoverListView oldUser:(NSDictionary *)userInfo
{
    // 更新按钮标题
    NSString *title = [NSString stringWithFormat:@"%@", ((userInfo != nil) ? @"注销" : @"登录")];
    [btnUserLogin setTitle:title forState:UIControlStateNormal];
    
    // 保存数据
    [self pushDataToUser:userInfo];
    
    // 更新页面显示
    [tableUserInfo reloadData];
    
//    NSLog(@"user login in. user:%@", self.curUser);
}

-(void) popoverListViewRegist:(UIPopoverListView *)popoverListView newUser:(NSDictionary *)userInfo
{
    // 更新按钮标题
    NSString *title = [NSString stringWithFormat:@"%@", ((userInfo != nil) ? @"注销" : @"登录")];
    [btnUserLogin setTitle:title forState:UIControlStateNormal];
    
    // 保存数据
    [self pushDataToUser:userInfo];
    
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
                [dateFormatter setDateFormat:@"YYYY-MM-DD HH:mm:SS"];
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
