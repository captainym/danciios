//
//  ConfigurationViewController.m
//  Danci
//
//  Created by zhenghao on 12/9/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import "ConfigurationViewController.h"

@interface ConfigurationViewController () <UIScrollViewDelegate>

- (void) initScrollView;
- (void) createEmptyPagesForScrollView;

- (void) showView;
- (void) showUserInfoView;
- (void) showHelpView;

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
//    [self.btnUserInfo addTarget:self action:@selector(showUserInfoView) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnHelp.showsTouchWhenHighlighted = YES;
    [self.btnHelp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.btnHelp addTarget:self action:@selector(showHelpView) forControlEvents:UIControlEventTouchUpInside];
    
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
    [self.btnUserInfo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnHelp setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.3];
    
    float labelForCurPageY = self.labelForCurPage.frame.origin.y;
    self.labelForCurPage.frame = CGRectMake(0, labelForCurPageY, 159, 4);
    [self.scrollView setContentOffset:CGPointMake(320*0, 0)];//页面滑动
    
    [UIView commitAnimations];
//    [tblTipstxt reloadData];
}

- (void) showHelpView
{
    [self.btnHelp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnUserInfo setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.3];
    
    float labelForCurPageY = self.labelForCurPage.frame.origin.y;
    self.labelForCurPage.frame = CGRectMake(161, labelForCurPageY, 159, 4);
    [self.scrollView setContentOffset:CGPointMake(320 * 1, 0)];//页面滑动
    
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
    // page for user info
    labelUserInfo = [[UILabel alloc] init];
    labelUserInfo.frame = CGRectMake(320 * 0, 0, 320, self.scrollView.frame.size.height);
//    NSString *userInfoContent = [NSString stringWithFormat:@"%@"]
//    [labelUserInfo registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_ID_TIPS_TXT];
//    [labelUserInfo setDelegate:self];
//    [labelUserInfo setDataSource:self];
    [self.scrollView addSubview:labelUserInfo];
    
    // page for help
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

//- (IBAction)showUserInfo:(id)sender {
//    [self showUserInfoView];
//}
//
//- (IBAction)showHelp:(id)sender {
//    [self showHelpView];
//}

@end
