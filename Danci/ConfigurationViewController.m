//
//  ConfigurationViewController.m
//  Danci
//
//  Created by zhenghao on 12/9/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "UIPopoverListView.h"


@interface ConfigurationViewController () <UIScrollViewDelegate, UIPopoverListViewDelegate>

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
    
    //// 显示用户信息
    [self showCurUserDetails];
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
    
    //// 显示帮助信息
}

- (void) showCurUserDetails
{
//    labelUserInfo.lineBreakMode = UILineBreakModeMiddleTruncation;
    labelUserInfo.numberOfLines = 6;
    
    NSString *userDetail = [NSString stringWithFormat:
                                 @"用户名: %@\n学号: %@\n注册时间: %@\n推荐人学号: %@\n最高可记单词数: %@\n已记单词数: %@"
                                 , self.curUser.mid
                                 , self.curUser.studyNo
                                 , self.curUser.regTime
                                 , self.curUser.recommendStudyNo
                                 , self.curUser.maxWordNum
                                 , self.curUser.comsumeWordNum];
    
    labelUserInfo.text = userDetail;
    
    // 顶端对齐显示
    CGSize maximumSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height - 40);

    UIFont *userDetailFont = [UIFont fontWithName:@"Helvetica" size:14];
    CGSize userDetailStringSize = [userDetail sizeWithFont:userDetailFont
                                             constrainedToSize:maximumSize
                                             lineBreakMode:labelUserInfo.lineBreakMode];
    
    CGRect userDetailFrame = CGRectMake(10, 10, self.scrollView.frame.size.width, userDetailStringSize.height);
    labelUserInfo.frame = userDetailFrame;
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
    
    // 用户信息label
    labelUserInfo = [[UILabel alloc] init];
    labelUserInfo.frame = CGRectMake(320 * 0, 0, 320, labelUserInfoHeight);
    
//    [labelUserInfo registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_ID_TIPS_TXT];
//    [labelUserInfo setDelegate:self];
//    [labelUserInfo setDataSource:self];
//
    
    // 登录按钮
    btnUserLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    //判断是否登陆
//    NSLog(@"user [%@]", self.curUser);
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
    
    [userView addSubview:labelUserInfo];
    [userView addSubview:btnUserLogin];
    [userView addSubview:btnUserSync];
    
    [self.scrollView addSubview:userView];
    
    //// page for help
    labelHelp = [[UILabel alloc] init];
    labelHelp.frame = CGRectMake(320 * 1, 0, 320, 45);
    labelHelp.numberOfLines = 0;
    labelHelp.text = @"官网: http://www.danci.com";
    labelHelp.font = [UIFont fontWithName:@"Verdana" size:12];
    [self.scrollView addSubview:labelHelp];
    
    

    
//    txtEditTip = [[UITextView alloc] init];
//    txtEditTip.frame = CGRectMake(320 * 1, 50, 320, 100);
//    txtEditTip.delegate = self;
//    [txtEditTip setText:self.curWord.txt_tip];
//    txtEditTip.layer.borderColor = [UIColor grayColor].CGColor;
//    txtEditTip.layer.borderWidth = 0.5;
//    txtEditTip.layer.cornerRadius = 5.0;
//    [self.mScrollView addSubview:txtEditTip];
//    btnOK = [[UIButton alloc] init];
//    btnOK.frame = CGRectMake(320 * 1.2, 154, 320*0.6, 30);
//    [btnOK setTitle:@"OK 这样就记住啦" forState:UIControlStateNormal];
//    btnOK.backgroundColor = [UIColor darkGrayColor];
//    btnOK.showsTouchWhenHighlighted = YES;
//    [btnOK addTarget:self action:@selector(saveTipTxt:) forControlEvents:UIControlEventTouchUpInside];
//    [self.mScrollView addSubview:btnOK];
    
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
    //暂不处理 - 其实左右滑动还有包含开始等等操作
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
    if(![self userLoggedIn]) {
        [self popLoginView:TYPE_LOGIN];
    }
    else {
        self.curUser.mid = @"";
        self.curUser.comsumeWordNum = 0;
        self.curUser.maxWordNum = 0;
        self.curUser.recommendStudyNo = 0;
        self.curUser.regTime = nil;
        self.curUser.studyNo = 0;
        self.curUser.words = @"";
        
        // 显式地save
        [self.danciDatabase saveToURL:self.danciDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    }
    
    NSString *title = [NSString stringWithFormat:@"%@", ([self userLoggedIn] ? @"注销" : @"登录")];
    [btnUserLogin setTitle:title forState:UIControlStateNormal];
}

- (void) onBtnUserSync
{
    // 同步user信息
    dispatch_queue_t queue = dispatch_queue_create("merge user", NULL);
    dispatch_async(queue, ^{
        self.curUser = [UserInfo mergerUserToServer:self.curUser];
        dispatch_async(dispatch_get_main_queue(), ^{
            // update UI
            [self showCurUserDetails];
        });
    });
}


#pragma mark - popListViewDelegate

-(void) popoverListViewCancel:(UIPopoverListView *)popoverListView
{
    //应该纪录下来 计算流失率
    [btnUserLogin setTitle:@"登录" forState:UIControlStateNormal];
    
    NSLog(@"user do not want to reg or login");
}

- (void)pushDataToUser:(NSDictionary *)userInfo
{
    self.curUser.mid = [userInfo objectForKey:@"mid"];
    self.curUser.studyNo = [NSNumber numberWithInt:[[userInfo objectForKey:@"studyNo"] intValue]];
    self.curUser.maxWordNum = [NSNumber numberWithInt:[[userInfo objectForKey:@"maxWordNum"] intValue]];
    self.curUser.comsumeWordNum = [NSNumber numberWithInt:[[userInfo objectForKey:@"comsumeWordNum"]intValue]];
    self.curUser.regTime = [NSDate dateWithTimeIntervalSince1970:[[userInfo objectForKey:@"regTime"] intValue]];
}

-(void) popoverListViewLogin:(UIPopoverListView *)popoverListView oldUser:(NSDictionary *)userInfo
{
    NSString *title = [NSString stringWithFormat:@"%@", ((userInfo != nil) ? @"注销" : @"登录")];
    [btnUserLogin setTitle:title forState:UIControlStateNormal];
    
    [self pushDataToUser:userInfo];
    NSLog(@"user login in. user:%@", self.curUser);
}

-(void) popoverListViewRegist:(UIPopoverListView *)popoverListView newUser:(NSDictionary *)userInfo
{
    [self pushDataToUser:userInfo];
    NSLog(@"user regist. user:%@", self.curUser);
}


@end
